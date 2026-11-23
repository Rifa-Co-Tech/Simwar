import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// SIMWAR — Model Data Barang & Stok Warung
/// Figma node: 2010:806 (Kelola Barang), 2010:885 (Tambah Barang), 2010:611 (Stok Menipis), 2010:494 (Kedaluwarsa)
class BarangModel {
  final String id;
  String nama;
  String barcode;
  String kategori; // 'Makanan', 'Minuman', 'Sembako', 'Alat mandi', 'Skincare', 'Lainnya'
  int hargaBeli;
  int hargaJual;
  int stok;
  int batasMin;
  String satuan;
  DateTime? tglKedaluwarsa;
  bool isTitipan;
  String? namaPemasok;
  String? fotoPath;

  BarangModel({
    required this.id,
    required this.nama,
    required this.barcode,
    required this.kategori,
    required this.hargaBeli,
    required this.hargaJual,
    required this.stok,
    this.batasMin = 10,
    this.satuan = 'pcs',
    this.tglKedaluwarsa,
    this.isTitipan = false,
    this.namaPemasok,
    this.fotoPath,
  });

  factory BarangModel.fromMap(Map<String, dynamic> map) {
    return BarangModel(
      id: (map['id_barang'] ?? map['id'] ?? '').toString(),
      nama: (map['nama_barang'] ?? map['nama'] ?? '').toString(),
      barcode: (map['barcode'] ?? '').toString(),
      kategori: (map['kategori'] ?? map['id_kategori'] ?? 'Makanan').toString(),
      hargaBeli: (map['harga_beli'] as num?)?.toInt() ?? 0,
      hargaJual: (map['harga_jual'] as num?)?.toInt() ?? 0,
      stok: (map['stok'] as num?)?.toInt() ?? 0,
      batasMin: (map['stok_minimum'] as num?)?.toInt() ?? 10,
      satuan: (map['satuan'] ?? 'pcs').toString(),
      isTitipan: map['is_titipan'] == true,
      tglKedaluwarsa: map['tanggal_kedaluwarsa'] != null
          ? DateTime.tryParse(map['tanggal_kedaluwarsa'].toString())
          : null,
      fotoPath: map['foto_path']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama_barang': nama,
      'barcode': barcode.isNotEmpty ? barcode : null,
      'kategori': kategori,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
      'stok': stok,
      'stok_minimum': batasMin,
      'satuan': satuan,
      'is_titipan': isTitipan,
      if (tglKedaluwarsa != null)
        'tanggal_kedaluwarsa': tglKedaluwarsa!.toIso8601String().split('T')[0],
      if (fotoPath != null) 'foto_path': fotoPath,
    };
  }

  bool get isStokMenipis => stok <= batasMin;
  bool get isKritis => stok <= (batasMin / 3).ceil();

  int get sisaHariKedaluwarsa {
    if (tglKedaluwarsa == null) return 999;
    final now = DateTime.now();
    return tglKedaluwarsa!.difference(now).inDays;
  }

  bool get isHampirKedaluwarsa => sisaHariKedaluwarsa <= 30;
  bool get isLewatKedaluwarsa => sisaHariKedaluwarsa < 0;
}

/// Store in-memory katalog barang warung
class BarangStore {
  static final BarangStore instance = BarangStore._internal();
  factory BarangStore() => instance;
  BarangStore._internal();

  final List<BarangModel> _list = [];

  List<BarangModel> get semua => _list;

  List<BarangModel> get stokMenipis =>
      _list.where((b) => b.isStokMenipis).toList();

  List<BarangModel> get hampirKedaluwarsa =>
      _list.where((b) => b.isHampirKedaluwarsa).toList();

  void tambahBarang(BarangModel barang) {
    _list.insert(0, barang);
  }

  Future<void> tambahBarangAsync(BarangModel barang) async {
    tambahBarang(barang);
    try {
      final client = Supabase.instance.client;
      final res = await client.from('barang').insert({
        'nama_barang': barang.nama,
        'barcode': barang.barcode.isNotEmpty ? barang.barcode : null,
        'kategori': barang.kategori,
        'harga_beli': barang.hargaBeli,
        'harga_jual': barang.hargaJual,
        'stok': barang.stok,
        'stok_minimum': barang.batasMin,
        'satuan': barang.satuan,
        'is_titipan': barang.isTitipan,
      }).select().maybeSingle();

      if (res != null && barang.tglKedaluwarsa != null) {
        final idBarang = res['id_barang'] ?? res['id'];
        if (idBarang != null) {
          try {
            await client.from('kelompok_kedaluwarsa').insert({
              'id_barang': idBarang,
              'tanggal_kedaluwarsa': barang.tglKedaluwarsa!.toIso8601String().split('T')[0],
              'jumlah_stok': barang.stok,
            });
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('Gagal simpan barang ke Supabase: $e');
    }
  }

  void ubahBarang(BarangModel barang) {
    final idx = _list.indexWhere((b) => b.id == barang.id);
    if (idx != -1) {
      _list[idx] = barang;
    }
  }

  Future<void> ubahBarangAsync(BarangModel barang) async {
    ubahBarang(barang);
    try {
      final client = Supabase.instance.client;
      final numId = int.tryParse(barang.id);
      if (numId != null) {
        await client.from('barang').update({
          'nama_barang': barang.nama,
          'barcode': barang.barcode.isNotEmpty ? barang.barcode : null,
          'kategori': barang.kategori,
          'harga_beli': barang.hargaBeli,
          'harga_jual': barang.hargaJual,
          'stok': barang.stok,
          'stok_minimum': barang.batasMin,
          'is_titipan': barang.isTitipan,
        }).eq('id_barang', numId);
      }
    } catch (e) {
      debugPrint('Gagal ubah barang di Supabase: $e');
    }
  }

  void hapusBarang(String id) {
    _list.removeWhere((b) => b.id == id);
  }

  Future<void> hapusBarangAsync(String id) async {
    hapusBarang(id);
    try {
      final client = Supabase.instance.client;
      final numId = int.tryParse(id);
      if (numId != null) {
        await client.from('barang').delete().eq('id_barang', numId);
      }
    } catch (e) {
      debugPrint('Gagal hapus barang di Supabase: $e');
    }
  }

  void kurangiStok(String id, String nama, int jumlah) {
    final idx = _list.indexWhere((b) =>
        (id.isNotEmpty && b.id == id) ||
        b.nama.trim().toLowerCase() == nama.trim().toLowerCase());
    if (idx != -1) {
      final b = _list[idx];
      b.stok = (b.stok - jumlah) >= 0 ? (b.stok - jumlah) : 0;
    }
  }

  Future<void> kurangiStokAsync(String id, String nama, int jumlah) async {
    final idx = _list.indexWhere((b) =>
        (id.isNotEmpty && b.id == id) ||
        b.nama.trim().toLowerCase() == nama.trim().toLowerCase());
    if (idx != -1) {
      final b = _list[idx];
      final newStok = (b.stok - jumlah) >= 0 ? (b.stok - jumlah) : 0;
      b.stok = newStok;

      try {
        final client = Supabase.instance.client;
        final numId = int.tryParse(b.id);
        if (numId != null) {
          await client.from('barang').update({'stok': newStok}).eq('id_barang', numId);
        } else {
          await client.from('barang').update({'stok': newStok}).eq('nama_barang', b.nama);
        }
      } catch (e) {
        debugPrint('Gagal kurangi stok di Supabase: $e');
      }
    }
  }

  Future<void> sinkronkanDariSupabase() async {
    try {
      final client = Supabase.instance.client;
      final res = await client.from('barang').select();
      if (res.isNotEmpty) {
        for (var row in res) {
          final item = BarangModel.fromMap(row);
          final idx = _list.indexWhere((b) =>
              (item.id.isNotEmpty && b.id == item.id) ||
              b.nama.trim().toLowerCase() == item.nama.trim().toLowerCase());
          if (idx != -1) {
            _list[idx] = item;
          } else {
            _list.insert(0, item);
          }
        }
      }
    } catch (e) {
      debugPrint('Gagal sinkron data barang dari Supabase: $e');
    }
  }
}
