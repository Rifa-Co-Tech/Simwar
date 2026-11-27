import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_scope.dart';
import 'barang_model.dart';

/// SIMWAR — Model Data Barang Masuk (Distributor & Titipan Warga)
/// Figma node: 2224:2 (Daftar Barang Masuk) & 2224:93 (Catat Barang Masuk)

enum JenisBarangMasuk { distributor, titipan }

enum StatusBayarPasokan { lunas, tempo, konsinyasi }

class BarangMasukItem {
  final String barangId;
  final String namaBarang;
  final int jumlah;
  final String satuan; // 'pcs', 'dus', 'renceng', 'pack', 'karton', 'bungkus'
  final int hargaBeli; // atau harga setor titipan
  final int? hargaJual; // harga jual eceran warung

  BarangMasukItem({
    required this.barangId,
    required this.namaBarang,
    required this.jumlah,
    this.satuan = 'pcs',
    required this.hargaBeli,
    this.hargaJual,
  });

  int get subtotal => jumlah * hargaBeli;

  Map<String, dynamic> toMap() {
    return {
      'barang_id': barangId,
      'nama_barang': namaBarang,
      'jumlah': jumlah,
      'satuan': satuan,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
    };
  }

  factory BarangMasukItem.fromMap(Map<String, dynamic> map) {
    return BarangMasukItem(
      barangId: (map['barang_id'] ?? '').toString(),
      namaBarang: (map['nama_barang'] ?? '').toString(),
      jumlah: (map['jumlah'] as num?)?.toInt() ?? 0,
      satuan: (map['satuan'] ?? 'pcs').toString(),
      hargaBeli: (map['harga_beli'] as num?)?.toInt() ?? 0,
      hargaJual: (map['harga_jual'] as num?)?.toInt(),
    );
  }
}

class BarangMasukModel {
  final String id;
  final DateTime tanggal;
  final JenisBarangMasuk jenis;
  final String namaPemasok; // Nama Distributor atau Nama Penitip
  final String? noFaktur; // No Invoice atau No HP Penitip
  final List<BarangMasukItem> items;
  final int totalNilai;
  StatusBayarPasokan statusBayar;
  final DateTime? jatuhTempo; // jika tempo
  final String? catatan;
  final String dicatatOleh; // 'Pemilik' atau nama Penjaga

  // Khusus Konsinyasi Titipan Warga
  int? sisaRetur;
  bool sudahDisetorKePenitip;

  BarangMasukModel({
    required this.id,
    required this.tanggal,
    required this.jenis,
    required this.namaPemasok,
    this.noFaktur,
    required this.items,
    required this.totalNilai,
    required this.statusBayar,
    this.jatuhTempo,
    this.catatan,
    this.dicatatOleh = 'Pemilik',
    this.sisaRetur = 0,
    this.sudahDisetorKePenitip = false,
  });

  bool get isDistributor => jenis == JenisBarangMasuk.distributor;
  bool get isTitipan => jenis == JenisBarangMasuk.titipan;

  int get totalItemCount => items.fold(0, (sum, i) => sum + i.jumlah);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal.toIso8601String(),
      'jenis': jenis.name,
      'nama_pemasok': namaPemasok,
      'no_faktur': noFaktur,
      'items': items.map((i) => i.toMap()).toList(),
      'total_nilai': totalNilai,
      'status_bayar': statusBayar.name,
      'jatuh_tempo': jatuhTempo?.toIso8601String(),
      'catatan': catatan,
      'dicatat_oleh': dicatatOleh,
      'sisa_retur': sisaRetur,
      'sudah_disetor': sudahDisetorKePenitip,
    };
  }

  factory BarangMasukModel.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'];
    final List<BarangMasukItem> parsedItems = [];
    if (rawItems is List) {
      for (var it in rawItems) {
        if (it is Map) {
          parsedItems.add(BarangMasukItem.fromMap(Map<String, dynamic>.from(it)));
        }
      }
    }

    final jenisStr = (map['jenis'] ?? 'distributor').toString();
    final jenisVal = jenisStr == 'titipan'
        ? JenisBarangMasuk.titipan
        : JenisBarangMasuk.distributor;

    final statusStr = (map['status_bayar'] ?? 'lunas').toString();
    StatusBayarPasokan statusVal = StatusBayarPasokan.lunas;
    if (statusStr == 'tempo') statusVal = StatusBayarPasokan.tempo;
    if (statusStr == 'konsinyasi') statusVal = StatusBayarPasokan.konsinyasi;

    return BarangMasukModel(
      id: (map['id'] ?? '').toString(),
      tanggal: DateTime.tryParse(map['tanggal']?.toString() ?? '') ?? DateTime.now(),
      jenis: jenisVal,
      namaPemasok: (map['nama_pemasok'] ?? '').toString(),
      noFaktur: map['no_faktur']?.toString(),
      items: parsedItems,
      totalNilai: (map['total_nilai'] as num?)?.toInt() ?? 0,
      statusBayar: statusVal,
      jatuhTempo: map['jatuh_tempo'] != null
          ? DateTime.tryParse(map['jatuh_tempo'].toString())
          : null,
      catatan: map['catatan']?.toString(),
      dicatatOleh: (map['dicatat_oleh'] ?? 'Pemilik').toString(),
      sisaRetur: (map['sisa_retur'] as num?)?.toInt() ?? 0,
      sudahDisetorKePenitip: map['sudah_disetor'] == true,
    );
  }
}

/// Store transaksi barang masuk & pasokan dengan persistensi SharedPreferences
class BarangMasukStore {
  static final BarangMasukStore instance = BarangMasukStore._internal();
  factory BarangMasukStore() => instance;
  BarangMasukStore._internal();

  static String get _keyLocal => StorageScope.key('simwar_barang_masuk_v2');
  final List<BarangMasukModel> _list = [];

  void resetInMemory() {
    _list.clear();
  }

  List<BarangMasukModel> get semua => List.unmodifiable(_list);

  List<BarangMasukModel> get distributorOnly =>
      _list.where((item) => item.isDistributor).toList();

  List<BarangMasukModel> get titipanOnly =>
      _list.where((item) => item.isTitipan).toList();

  int get totalNilaiBulanIni {
    final now = DateTime.now();
    return _list
        .where((item) =>
            item.tanggal.year == now.year && item.tanggal.month == now.month)
        .fold(0, (sum, item) => sum + item.totalNilai);
  }

  int get titipanAktifCount =>
      _list.where((item) => item.isTitipan && !item.sudahDisetorKePenitip).length;

  int get fakturTempoCount =>
      _list.where((item) => item.statusBayar == StatusBayarPasokan.tempo).length;

  Future<void> simpanKeLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_list.map((b) => b.toMap()).toList());
      await prefs.setString(_keyLocal, encoded);
    } catch (e) {
      debugPrint('Gagal simpan barang masuk ke SharedPreferences: $e');
    }
  }

  Future<void> muatDariLocalStorage() async {
    _list.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyLocal);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) {
          for (var item in decoded) {
            if (item is Map) {
              _list.add(BarangMasukModel.fromMap(Map<String, dynamic>.from(item)));
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Gagal muat barang masuk dari SharedPreferences: $e');
    }
  }

  void tambahBarangMasuk(BarangMasukModel model) {
    _list.insert(0, model);
    simpanKeLocalStorage();

    // Otomatis update / sinkronisasi stok di BarangStore
    for (var item in model.items) {
      final index = BarangStore.instance.semua.indexWhere((b) =>
          b.id == item.barangId ||
          b.nama.trim().toLowerCase() == item.namaBarang.trim().toLowerCase());
      if (index != -1) {
        final existing = BarangStore.instance.semua[index];
        existing.stok += item.jumlah;
        BarangStore.instance.ubahBarangAsync(existing);
      } else {
        // Jika belum ada di katalog, daftarkan otomatis
        final newBarang = BarangModel(
          id: item.barangId.isNotEmpty
              ? item.barangId
              : 'BM-AUTO-${DateTime.now().millisecondsSinceEpoch}',
          nama: item.namaBarang,
          barcode: '',
          kategori: model.isTitipan ? 'Makanan' : 'Sembako',
          hargaBeli: item.hargaBeli,
          hargaJual: item.hargaJual ?? (item.hargaBeli * 1.2).toInt(),
          stok: item.jumlah,
          batasMin: 5,
          satuan: item.satuan,
          isTitipan: model.isTitipan,
          namaPemasok: model.namaPemasok,
          tglKedaluwarsa: model.isTitipan
              ? DateTime.now().add(const Duration(days: 2))
              : null,
        );
        BarangStore.instance.tambahBarangAsync(newBarang);
      }
    }
  }

  void selesaikanKonsinyasi(String id, int sisaRetur) {
    final idx = _list.indexWhere((item) => item.id == id);
    if (idx != -1) {
      _list[idx].sisaRetur = sisaRetur;
      _list[idx].sudahDisetorKePenitip = true;
      _list[idx].statusBayar = StatusBayarPasokan.lunas;
      simpanKeLocalStorage();
    }
  }

  void tandaiFakturLunas(String id) {
    final idx = _list.indexWhere((item) => item.id == id);
    if (idx != -1) {
      _list[idx].statusBayar = StatusBayarPasokan.lunas;
      simpanKeLocalStorage();
    }
  }
}
