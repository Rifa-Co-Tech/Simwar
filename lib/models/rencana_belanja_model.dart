import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_scope.dart';
import 'barang_masuk_model.dart';
import 'barang_model.dart';

/// SIMWAR — Model Data Rencana Belanja Warung (Restock Planner)
/// Figma node: 2010:698

class ItemBelanja {
  final String id;
  final String? barangId;
  String nama;
  int jumlah;
  String satuan;
  int estimasiHarga; // Harga satuan (Rp per unit)
  String tokoTujuan; // 'Grosir Berkah', 'Pasar Induk', 'Distributor Indomarco', 'Lainnya'
  bool isSudahDibeli;
  String alasan; // 'Stok Kritis', 'Stok Menipis', 'Permintaan Pelanggan', 'Manual'

  ItemBelanja({
    required this.id,
    this.barangId,
    required this.nama,
    required this.jumlah,
    this.satuan = 'pcs',
    required this.estimasiHarga,
    this.tokoTujuan = 'Grosir Berkah',
    this.isSudahDibeli = false,
    this.alasan = 'Stok Menipis',
  });

  int get subtotal => jumlah * estimasiHarga;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barang_id': barangId,
      'nama': nama,
      'jumlah': jumlah,
      'satuan': satuan,
      'estimasi_harga': estimasiHarga,
      'toko_tujuan': tokoTujuan,
      'is_sudah_dibeli': isSudahDibeli,
      'alasan': alasan,
    };
  }

  factory ItemBelanja.fromMap(Map<String, dynamic> map) {
    return ItemBelanja(
      id: (map['id'] ?? '').toString(),
      barangId: map['barang_id']?.toString(),
      nama: (map['nama'] ?? '').toString(),
      jumlah: (map['jumlah'] as num?)?.toInt() ?? 1,
      satuan: (map['satuan'] ?? 'pcs').toString(),
      estimasiHarga: (map['estimasi_harga'] as num?)?.toInt() ?? 0,
      tokoTujuan: (map['toko_tujuan'] ?? 'Grosir Berkah').toString(),
      isSudahDibeli: map['is_sudah_dibeli'] == true,
      alasan: (map['alasan'] ?? 'Manual').toString(),
    );
  }
}

class RencanaBelanjaStore {
  static final RencanaBelanjaStore instance = RencanaBelanjaStore._internal();
  factory RencanaBelanjaStore() => instance;
  RencanaBelanjaStore._internal();

  static String get _keyLocal => StorageScope.key('simwar_rencana_belanja_v2');
  final List<ItemBelanja> _list = [];

  void resetInMemory() {
    _list.clear();
  }

  List<ItemBelanja> get semua => List.unmodifiable(_list);

  List<ItemBelanja> get perluDibeli =>
      _list.where((i) => !i.isSudahDibeli).toList();

  List<ItemBelanja> get sudahDibeli =>
      _list.where((i) => i.isSudahDibeli).toList();

  int get totalEstimasiAnggaran =>
      _list.fold(0, (sum, i) => sum + i.subtotal);

  int get totalAnggaranPerluDibeli =>
      perluDibeli.fold(0, (sum, i) => sum + i.subtotal);

  int get totalSudahDibelanjakan =>
      sudahDibeli.fold(0, (sum, i) => sum + i.subtotal);

  Future<void> simpanKeLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_list.map((i) => i.toMap()).toList());
      await prefs.setString(_keyLocal, encoded);
    } catch (e) {
      debugPrint('Gagal simpan rencana belanja ke SharedPreferences: $e');
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
              _list.add(ItemBelanja.fromMap(Map<String, dynamic>.from(item)));
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Gagal muat rencana belanja dari SharedPreferences: $e');
    }
  }

  void tambahItem(ItemBelanja item) {
    _list.insert(0, item);
    simpanKeLocalStorage();
  }

  void toggleStatus(String id) {
    final idx = _list.indexWhere((i) => i.id == id);
    if (idx != -1) {
      _list[idx].isSudahDibeli = !_list[idx].isSudahDibeli;
      simpanKeLocalStorage();
    }
  }

  void hapusItem(String id) {
    _list.removeWhere((i) => i.id == id);
    simpanKeLocalStorage();
  }

  /// Sinkronisasi otomatis dari barang stok menipis
  void sinkronkanDariStokMenipis() {
    final menipis = BarangStore.instance.stokMenipis;
    for (var b in menipis) {
      final exists = _list.any((item) =>
          item.barangId == b.id ||
          item.nama.trim().toLowerCase() == b.nama.trim().toLowerCase());
      if (!exists) {
        _list.add(
          ItemBelanja(
            id: 'rb-auto-${DateTime.now().millisecondsSinceEpoch}-${b.id}',
            barangId: b.id,
            nama: b.nama,
            jumlah: b.batasMin * 2,
            satuan: b.satuan,
            estimasiHarga: b.hargaBeli,
            tokoTujuan: b.namaPemasok ?? 'Grosir Berkah',
            isSudahDibeli: false,
            alasan: b.isKritis ? 'Stok Kritis' : 'Stok Menipis',
          ),
        );
      }
    }
    simpanKeLocalStorage();
  }

  /// Terapkan barang yang sudah dibeli menjadi BarangMasuk & update stok
  int selesaikanBelanjaDanUpdateStok(String dicatatOleh) {
    final itemsBeli = List<ItemBelanja>.from(sudahDibeli);
    if (itemsBeli.isEmpty) return 0;

    final masukItems = itemsBeli.map((ib) {
      return BarangMasukItem(
        barangId: ib.barangId ?? 'AUTO-${DateTime.now().millisecondsSinceEpoch}',
        namaBarang: ib.nama,
        jumlah: ib.jumlah,
        satuan: ib.satuan,
        hargaBeli: ib.estimasiHarga,
      );
    }).toList();

    final grandTotal = itemsBeli.fold(0, (sum, i) => sum + i.subtotal);

    final modelMasuk = BarangMasukModel(
      id: 'BM-BELANJA-${DateTime.now().millisecondsSinceEpoch % 10000}',
      tanggal: DateTime.now(),
      jenis: JenisBarangMasuk.distributor,
      namaPemasok: 'Kulakan Pasar & Grosir (Rencana Belanja)',
      items: masukItems,
      totalNilai: grandTotal,
      statusBayar: StatusBayarPasokan.lunas,
      catatan: 'Hasil belanja dari Rencana Belanja Warung',
      dicatatOleh: dicatatOleh,
    );

    BarangMasukStore.instance.tambahBarangMasuk(modelMasuk);

    // Hapus barang yang sudah dibeli dari daftar belanja aktif
    _list.removeWhere((i) => i.isSudahDibeli);
    simpanKeLocalStorage();

    return itemsBeli.length;
  }
}
