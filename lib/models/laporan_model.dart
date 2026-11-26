import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SIMWAR — Model Data Laporan & Kotak Masuk
/// Sesuai Figma node 2073:4002, 2073:4066, 2073:4093, 2073:4338, 2073:4412
class LaporanModel {
  final String id;
  final String judul; // 'Stok habis', 'Barang rusak', 'Pelanggan', 'Kasbon', 'Lainnya'
  final String pengirim;
  final String peranPengirim;
  final String waktu;
  final String pesan;
  final String? namaBarang;
  final int? sisaStok;
  String status; // 'Baru', 'Terkirim', 'Dibalas', 'Selesai'
  final List<String> lampiran;
  final List<String> balasan;
  final DateTime createdAt;

  LaporanModel({
    required this.id,
    required this.judul,
    required this.pengirim,
    this.peranPengirim = 'Penjaga',
    required this.waktu,
    required this.pesan,
    this.namaBarang,
    this.sisaStok,
    this.status = 'Baru',
    List<String>? lampiran,
    List<String>? balasan,
    DateTime? createdAt,
  })  : lampiran = lampiran ?? const [],
        balasan = balasan ?? [],
        createdAt = createdAt ?? DateTime.now();

  bool get isBaru => status.toLowerCase() == 'baru' || status.toLowerCase() == 'terkirim';
  bool get isSelesai => status.toLowerCase() == 'selesai';
  bool get isDibalas => status.toLowerCase() == 'dibalas';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'pengirim': pengirim,
      'peran_pengirim': peranPengirim,
      'waktu': waktu,
      'pesan': pesan,
      'nama_barang': namaBarang,
      'sisa_stok': sisaStok,
      'status': status,
      'lampiran': lampiran,
      'balasan': balasan,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory LaporanModel.fromMap(Map<String, dynamic> map) {
    return LaporanModel(
      id: (map['id'] ?? '').toString(),
      judul: (map['judul'] ?? '').toString(),
      pengirim: (map['pengirim'] ?? '').toString(),
      peranPengirim: (map['peran_pengirim'] ?? 'Penjaga').toString(),
      waktu: (map['waktu'] ?? '').toString(),
      pesan: (map['pesan'] ?? '').toString(),
      namaBarang: map['nama_barang']?.toString(),
      sisaStok: (map['sisa_stok'] as num?)?.toInt(),
      status: (map['status'] ?? 'Baru').toString(),
      lampiran: (map['lampiran'] is List)
          ? List<String>.from((map['lampiran'] as List).map((e) => e.toString()))
          : [],
      balasan: (map['balasan'] is List)
          ? List<String>.from((map['balasan'] as List).map((e) => e.toString()))
          : [],
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }
}

/// Store laporan dengan persistensi SharedPreferences agar sinkron antara Penjaga & Pemilik
class LaporanStore {
  static final LaporanStore instance = LaporanStore._internal();
  factory LaporanStore() => instance;
  LaporanStore._internal();

  static const String _keyLocal = 'simwar_laporan_v1';
  final List<LaporanModel> _list = [];

  List<LaporanModel> get semua => List.unmodifiable(_list);

  List<LaporanModel> get baru =>
      _list.where((l) => l.isBaru).toList();

  int get jumlahBaru => baru.length;

  List<LaporanModel> get selesai =>
      _list.where((l) => l.isSelesai).toList();

  Future<void> simpanKeLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_list.map((l) => l.toMap()).toList());
      await prefs.setString(_keyLocal, encoded);
    } catch (e) {
      debugPrint('Gagal simpan laporan ke SharedPreferences: $e');
    }
  }

  Future<void> muatDariLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyLocal);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) {
          _list.clear();
          for (var item in decoded) {
            if (item is Map) {
              _list.add(LaporanModel.fromMap(Map<String, dynamic>.from(item)));
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Gagal muat laporan dari SharedPreferences: $e');
    }
  }

  void tambahLaporan(LaporanModel laporan) {
    _list.insert(0, laporan);
    simpanKeLocalStorage();
  }

  void balasLaporan(String id, String teksBalasan) {
    final idx = _list.indexWhere((l) => l.id == id);
    if (idx != -1) {
      _list[idx].balasan.add(teksBalasan);
      _list[idx].status = 'Dibalas';
      simpanKeLocalStorage();
    }
  }

  void tandaiSelesai(String id) {
    final idx = _list.indexWhere((l) => l.id == id);
    if (idx != -1) {
      _list[idx].status = 'Selesai';
      simpanKeLocalStorage();
    }
  }
}
