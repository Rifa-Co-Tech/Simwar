import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Helper mapping nama kategori <-> id_kategori di Supabase
int _kategoriToId(String kategori) {
  final k = kategori.toLowerCase();
  if (k.contains('rokok')) return 2;
  if (k.contains('minum')) return 3;
  if (k.contains('kosmetik') ||
      k.contains('rawat') ||
      k.contains('skincare') ||
      k.contains('mandi')) {
    return 4;
  }
  return 1; // Sembako / Makanan / Lainnya
}

String _idToKategori(dynamic idKategori) {
  final id = int.tryParse(idKategori.toString()) ?? 1;
  switch (id) {
    case 1:
      return 'Sembako';
    case 2:
      return 'Rokok';
    case 3:
      return 'Minuman';
    case 4:
      return 'Kosmetik & Perawatan';
    default:
      return 'Sembako';
  }
}

/// SIMWAR — Model Data Barang & Stok Warung
class BarangModel {
  String id;
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
    // Kategori: bisa dari string langsung atau id_kategori dari Supabase
    String kat = 'Sembako';
    if (map['kategori'] != null && map['kategori'].toString().isNotEmpty) {
      kat = map['kategori'].toString();
    } else if (map['id_kategori'] != null) {
      kat = _idToKategori(map['id_kategori']);
    }

    return BarangModel(
      id: (map['id_barang'] ?? map['id'] ?? '').toString(),
      nama: (map['nama_barang'] ?? map['nama'] ?? '').toString(),
      barcode: (map['barcode'] ?? '').toString(),
      kategori: kat,
      hargaBeli: (map['harga_beli'] as num?)?.toInt() ?? (map['hargaBeli'] as num?)?.toInt() ?? 0,
      hargaJual: (map['harga_jual'] as num?)?.toInt() ?? (map['hargaJual'] as num?)?.toInt() ?? 0,
      stok: (map['stok'] as num?)?.toInt() ?? 0,
      batasMin: (map['stok_minimum'] as num?)?.toInt() ?? (map['batasMin'] as num?)?.toInt() ?? 10,
      satuan: (map['satuan'] ?? 'pcs').toString(),
      isTitipan: map['is_titipan'] == true || map['isTitipan'] == true,
      tglKedaluwarsa: map['tanggal_kedaluwarsa'] != null
          ? DateTime.tryParse(map['tanggal_kedaluwarsa'].toString())
          : (map['tglKedaluwarsa'] != null
              ? DateTime.tryParse(map['tglKedaluwarsa'].toString())
              : null),
      namaPemasok: map['nama_pemasok']?.toString() ?? map['namaPemasok']?.toString(),
      fotoPath: map['foto_path']?.toString() ?? map['fotoPath']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_barang': id,
      'nama': nama,
      'nama_barang': nama,
      'barcode': barcode,
      'kategori': kategori,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
      'stok': stok,
      'stok_minimum': batasMin,
      'satuan': satuan,
      'is_titipan': isTitipan,
      if (tglKedaluwarsa != null)
        'tanggal_kedaluwarsa': tglKedaluwarsa!.toIso8601String().split('T')[0],
      if (namaPemasok != null) 'nama_pemasok': namaPemasok,
      if (fotoPath != null) 'foto_path': fotoPath,
    };
  }

  bool get isStokMenipis => stok <= batasMin;
  bool get isKritis => stok <= (batasMin / 3).ceil();

  int get sisaHariKedaluwarsa {
    if (tglKedaluwarsa == null) return 999;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expDay = DateTime(
      tglKedaluwarsa!.year,
      tglKedaluwarsa!.month,
      tglKedaluwarsa!.day,
    );
    return expDay.difference(today).inDays;
  }

  bool get isHampirKedaluwarsa => sisaHariKedaluwarsa <= 30;
  bool get isLewatKedaluwarsa => sisaHariKedaluwarsa < 0;
}

/// Store katalog barang warung dengan dual-persistence (SharedPreferences Offline + Supabase Cloud)
class BarangStore {
  static final BarangStore instance = BarangStore._internal();
  factory BarangStore() => instance;
  BarangStore._internal();

  static const String _keyLocalBarang = 'simwar_katalog_barang_v1';
  final List<BarangModel> _list = [];
  bool _isLocalLoaded = false;

  List<BarangModel> get semua => _list;

  List<BarangModel> get stokMenipis =>
      _list.where((b) => b.isStokMenipis).toList();

  List<BarangModel> get hampirKedaluwarsa =>
      _list.where((b) => b.isHampirKedaluwarsa).toList();

  BarangModel? cariById(String id) {
    if (id.isEmpty) return null;
    try {
      return _list.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  BarangModel? cari(String nama) {
    if (nama.isEmpty) return null;
    try {
      return _list.firstWhere(
        (b) => b.nama.trim().toLowerCase() == nama.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  // ── 1. Local Storage Persistence (SharedPreferences) ──────────────────────
  Future<void> simpanKeLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final maps = _list.map((b) => b.toMap()).toList();
      final jsonStr = jsonEncode(maps);
      await prefs.setString(_keyLocalBarang, jsonStr);
    } catch (e) {
      debugPrint('Gagal simpan barang ke SharedPreferences: $e');
    }
  }

  Future<void> muatDariLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyLocalBarang);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) {
          _list.clear();
          for (var item in decoded) {
            if (item is Map<String, dynamic>) {
              _list.add(BarangModel.fromMap(item));
            } else if (item is Map) {
              _list.add(BarangModel.fromMap(Map<String, dynamic>.from(item)));
            }
          }
          _isLocalLoaded = true;
        }
      }
    } catch (e) {
      debugPrint('Gagal muat barang dari SharedPreferences: $e');
    }
  }

  // ── 2. Operasi Data (Tambah, Ubah, Hapus, Kurang Stok) ─────────────────────
  void tambahBarang(BarangModel barang) {
    _list.insert(0, barang);
    simpanKeLocalStorage();
  }

  Future<void> tambahBarangAsync(BarangModel barang) async {
    // 1. Simpan lokal instan agar UI & offline langsung tersimpan
    tambahBarang(barang);

    // 2. Simpan ke Supabase Cloud
    try {
      final client = Supabase.instance.client;
      final idKat = _kategoriToId(barang.kategori);

      final res = await client.from('barang').insert({
        'id_kategori': idKat,
        'nama_barang': barang.nama,
        'barcode': barang.barcode.isNotEmpty ? barang.barcode : '',
        'harga_beli': barang.hargaBeli,
        'harga_jual': barang.hargaJual,
        'stok_minimum': barang.batasMin,
        'hari_peringatan': 30,
      }).select().maybeSingle();

      if (res != null) {
        final rawId = res['id_barang'];
        final numId = rawId != null ? int.tryParse(rawId.toString()) : null;

        if (numId != null) {
          // Update ID lokal barang dengan ID resmi Supabase
          barang.id = numId.toString();
          await simpanKeLocalStorage();

          // Simpan batch stok ke tabel kelompok_kedaluwarsa
          final tglMasuk = DateTime.now().toIso8601String().split('T')[0];
          await client.from('kelompok_kedaluwarsa').insert({
            'id_barang': numId,
            'tanggal_masuk': tglMasuk,
            if (barang.tglKedaluwarsa != null)
              'tanggal_kedaluwarsa':
                  barang.tglKedaluwarsa!.toIso8601String().split('T')[0],
            'jumlah_stok': barang.stok,
          });
        }
      }
    } catch (e) {
      debugPrint('Gagal simpan barang ke Supabase (Data tetap aman di lokal): $e');
    }
  }

  void ubahBarang(BarangModel barang) {
    final idx = _list.indexWhere((b) => b.id == barang.id || b.nama.trim().toLowerCase() == barang.nama.trim().toLowerCase());
    if (idx != -1) {
      _list[idx] = barang;
    }
    simpanKeLocalStorage();
  }

  Future<void> ubahBarangAsync(BarangModel barang) async {
    ubahBarang(barang);

    try {
      final client = Supabase.instance.client;
      final numId = int.tryParse(barang.id);
      final idKat = _kategoriToId(barang.kategori);

      if (numId != null) {
        await client.from('barang').update({
          'id_kategori': idKat,
          'nama_barang': barang.nama,
          'barcode': barang.barcode.isNotEmpty ? barang.barcode : '',
          'harga_beli': barang.hargaBeli,
          'harga_jual': barang.hargaJual,
          'stok_minimum': barang.batasMin,
        }).eq('id_barang', numId);

        // Update stok di kelompok_kedaluwarsa
        final batches = await client.from('kelompok_kedaluwarsa').select().eq('id_barang', numId);
        if (batches.isNotEmpty) {
          final firstBatchId = batches[0]['id_batch'];
          await client.from('kelompok_kedaluwarsa').update({
            'jumlah_stok': barang.stok,
            if (barang.tglKedaluwarsa != null)
              'tanggal_kedaluwarsa': barang.tglKedaluwarsa!.toIso8601String().split('T')[0],
          }).eq('id_batch', firstBatchId);
        } else {
          final tglMasuk = DateTime.now().toIso8601String().split('T')[0];
          await client.from('kelompok_kedaluwarsa').insert({
            'id_barang': numId,
            'tanggal_masuk': tglMasuk,
            if (barang.tglKedaluwarsa != null)
              'tanggal_kedaluwarsa':
                  barang.tglKedaluwarsa!.toIso8601String().split('T')[0],
            'jumlah_stok': barang.stok,
          });
        }
      }
    } catch (e) {
      debugPrint('Gagal ubah barang di Supabase: $e');
    }
  }

  void hapusBarang(String id) {
    _list.removeWhere((b) => b.id == id);
    simpanKeLocalStorage();
  }

  Future<void> hapusBarangAsync(String id) async {
    hapusBarang(id);

    try {
      final client = Supabase.instance.client;
      final numId = int.tryParse(id);
      if (numId != null) {
        try {
          await client.from('kelompok_kedaluwarsa').delete().eq('id_barang', numId);
        } catch (_) {}
        await client.from('barang').delete().eq('id_barang', numId);
      }
    } catch (e) {
      debugPrint('Gagal hapus barang di Supabase: $e');
    }
  }

  void tambahStok(String id, String nama, int jumlah) {
    final target = cariById(id) ?? cari(nama);
    if (target != null && jumlah > 0) {
      target.stok += jumlah;
      simpanKeLocalStorage();
    }
  }

  Future<void> tambahStokAsync(String id, String nama, int jumlah) async {
    tambahStok(id, nama, jumlah);
    try {
      final target = cariById(id) ?? cari(nama);
      final client = Supabase.instance.client;
      final numId = int.tryParse(target?.id ?? id);
      if (numId != null && target != null) {
        final batches = await client
            .from('kelompok_kedaluwarsa')
            .select()
            .eq('id_barang', numId);
        if (batches.isNotEmpty) {
          final bId = batches[0]['id_batch'];
          final currentStok = (batches[0]['jumlah_stok'] as num?)?.toInt() ?? 0;
          await client
              .from('kelompok_kedaluwarsa')
              .update({'jumlah_stok': currentStok + jumlah})
              .eq('id_batch', bId);
        }
      }
    } catch (e) {
      debugPrint('Gagal kembalikan stok di Supabase: $e');
    }
  }

  void kurangiStok(String id, String nama, int jumlah) {
    final idx = _list.indexWhere((b) =>
        (id.isNotEmpty && b.id == id) ||
        b.nama.trim().toLowerCase() == nama.trim().toLowerCase());
    if (idx != -1) {
      final b = _list[idx];
      b.stok = (b.stok - jumlah) >= 0 ? (b.stok - jumlah) : 0;
      simpanKeLocalStorage();
    }
  }

  Future<void> kurangiStokAsync(String id, String nama, int jumlah) async {
    kurangiStok(id, nama, jumlah);

    try {
      final target = cariById(id) ?? cari(nama);
      final client = Supabase.instance.client;
      final numId = int.tryParse(target?.id ?? id);
      if (numId != null) {
        final batches = await client
            .from('kelompok_kedaluwarsa')
            .select()
            .eq('id_barang', numId)
            .order('tanggal_kedaluwarsa', ascending: true);

        int sisaKurang = jumlah;
        for (var batch in batches) {
          if (sisaKurang <= 0) break;
          final bId = batch['id_batch'];
          final currentStok = (batch['jumlah_stok'] as num?)?.toInt() ?? 0;
          final potong = currentStok >= sisaKurang ? sisaKurang : currentStok;
          final newBatchStok = currentStok - potong;
          sisaKurang -= potong;
          await client
              .from('kelompok_kedaluwarsa')
              .update({'jumlah_stok': newBatchStok})
              .eq('id_batch', bId);
        }
      }
    } catch (e) {
      debugPrint('Gagal kurangi stok di Supabase: $e');
    }
  }

  // ── 3. Sinkronisasi Dua Arah dari Supabase Cloud ──────────────────────────
  Future<void> sinkronkanDariSupabase() async {
    // 1. Muat lokal dulu jika belum pernah dimuat
    if (!_isLocalLoaded) {
      await muatDariLocalStorage();
    }

    // 2. Ambil data terbaru dari Supabase
    try {
      final client = Supabase.instance.client;
      final resBarang = await client.from('barang').select();
      final resBatch = await client.from('kelompok_kedaluwarsa').select();

      // Peta stok & kedaluwarsa dari kelompok_kedaluwarsa per id_barang
      final Map<int, int> stokMap = {};
      final Map<int, DateTime?> expiryMap = {};

      for (var b in resBatch) {
        final idB = (b['id_barang'] as num?)?.toInt();
        if (idB != null) {
          final jStok = (b['jumlah_stok'] as num?)?.toInt() ?? 0;
          stokMap[idB] = (stokMap[idB] ?? 0) + jStok;

          if (b['tanggal_kedaluwarsa'] != null) {
            final dt = DateTime.tryParse(b['tanggal_kedaluwarsa'].toString());
            if (dt != null) {
              final existing = expiryMap[idB];
              if (existing == null || dt.isBefore(existing)) {
                expiryMap[idB] = dt;
              }
            }
          }
        }
      }

      if (resBarang.isNotEmpty) {
        for (var row in resBarang) {
          final numId = (row['id_barang'] as num?)?.toInt();
          final strId = numId?.toString() ?? (row['id'] ?? '').toString();
          final nama = (row['nama_barang'] ?? row['nama'] ?? '').toString();
          if (nama.isEmpty) continue;

          final kat = _idToKategori(row['id_kategori']);
          final beli = (row['harga_beli'] as num?)?.toInt() ?? 0;
          final jual = (row['harga_jual'] as num?)?.toInt() ?? 0;
          final batasMin = (row['stok_minimum'] as num?)?.toInt() ?? 10;
          final barcode = (row['barcode'] ?? '').toString();

          final int calculatedStok = numId != null ? (stokMap[numId] ?? 0) : 0;
          final DateTime? calculatedExp = numId != null ? expiryMap[numId] : null;

          final idx = _list.indexWhere((b) =>
              (strId.isNotEmpty && b.id == strId) ||
              b.nama.trim().toLowerCase() == nama.trim().toLowerCase());

          if (idx != -1) {
            // Perbarui data yang ada
            _list[idx].id = strId;
            _list[idx].nama = nama;
            if (barcode.isNotEmpty) _list[idx].barcode = barcode;
            final remoteKatId = int.tryParse(row['id_kategori'].toString()) ?? 1;
            if (_kategoriToId(_list[idx].kategori) != remoteKatId) {
              _list[idx].kategori = kat;
            }
            if (beli > 0) _list[idx].hargaBeli = beli;
            if (jual > 0) _list[idx].hargaJual = jual;
            _list[idx].batasMin = batasMin;
            if (stokMap.containsKey(numId)) {
              _list[idx].stok = calculatedStok;
            }
            if (calculatedExp != null) {
              _list[idx].tglKedaluwarsa = calculatedExp;
            }
          } else {
            // Masukkan barang baru dari Cloud
            _list.insert(
              0,
              BarangModel(
                id: strId,
                nama: nama,
                barcode: barcode,
                kategori: kat,
                hargaBeli: beli,
                hargaJual: jual,
                stok: calculatedStok,
                batasMin: batasMin,
                satuan: 'pcs',
                tglKedaluwarsa: calculatedExp,
              ),
            );
          }
        }

        // Simpan hasil sinkronisasi ke penyimpanan lokal
        await simpanKeLocalStorage();
      }
    } catch (e) {
      debugPrint('Gagal sinkron data barang dari Supabase (tetap pakai data lokal): $e');
    }
  }
}
