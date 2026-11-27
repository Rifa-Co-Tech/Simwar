import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_scope.dart';
import '../utils/formatters.dart';

/// SIMWAR — Model Data Kasbon Warung
/// Figma node: 2055:2 (Daftar Pelanggan), 2055:110 (Detail Pelanggan), 2233:2 (Bayar Kasbon)
class RiwayatKasbonItem {
  final String id;
  final String judul;
  final String tanggal;
  final int nominal;
  final bool isBayar; // true jika pembayaran (mengurangi utang), false jika belanja (menambah utang)

  RiwayatKasbonItem({
    required this.id,
    required this.judul,
    required this.tanggal,
    required this.nominal,
    required this.isBayar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'tanggal': tanggal,
      'nominal': nominal,
      'is_bayar': isBayar,
    };
  }

  factory RiwayatKasbonItem.fromMap(Map<String, dynamic> map) {
    return RiwayatKasbonItem(
      id: (map['id'] ?? '').toString(),
      judul: (map['judul'] ?? '').toString(),
      tanggal: (map['tanggal'] ?? '').toString(),
      nominal: (map['nominal'] as num?)?.toInt() ?? 0,
      isBayar: map['is_bayar'] == true,
    );
  }
}

class PelangganKasbonModel {
  final String id;
  final String nama;
  final String nomorHp;
  final String sejak;
  int totalUtang;
  final List<RiwayatKasbonItem> riwayat;

  PelangganKasbonModel({
    required this.id,
    required this.nama,
    required this.nomorHp,
    required this.sejak,
    required this.totalUtang,
    List<RiwayatKasbonItem>? riwayat,
  }) : riwayat = riwayat ?? [];

  int get jumlahTransaksi => riwayat.length;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'nomor_hp': nomorHp,
      'sejak': sejak,
      'total_utang': totalUtang,
      'riwayat': riwayat.map((r) => r.toMap()).toList(),
    };
  }

  factory PelangganKasbonModel.fromMap(Map<String, dynamic> map) {
    final rawRiwayat = map['riwayat'];
    final List<RiwayatKasbonItem> parsedRiwayat = [];
    if (rawRiwayat is List) {
      for (var r in rawRiwayat) {
        if (r is Map) {
          parsedRiwayat.add(RiwayatKasbonItem.fromMap(Map<String, dynamic>.from(r)));
        }
      }
    }

    return PelangganKasbonModel(
      id: (map['id'] ?? '').toString(),
      nama: (map['nama'] ?? '').toString(),
      nomorHp: (map['nomor_hp'] ?? '').toString(),
      sejak: (map['sejak'] ?? '').toString(),
      totalUtang: (map['total_utang'] as num?)?.toInt() ?? 0,
      riwayat: parsedRiwayat,
    );
  }
}

/// Store kasbon pelanggan warung dengan persistensi SharedPreferences
class KasbonStore {
  static final KasbonStore instance = KasbonStore._internal();
  factory KasbonStore() => instance;
  KasbonStore._internal();

  static String get _keyLocal => StorageScope.key('simwar_kasbon_v2');
  final List<PelangganKasbonModel> _pelanggan = [];

  void resetInMemory() {
    _pelanggan.clear();
  }

  List<PelangganKasbonModel> get semua => _pelanggan;

  int get totalSemuaUtang => _pelanggan.fold(0, (sum, p) => sum + p.totalUtang);

  Future<void> simpanKeLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_pelanggan.map((p) => p.toMap()).toList());
      await prefs.setString(_keyLocal, encoded);
    } catch (e) {
      debugPrint('Gagal simpan kasbon ke SharedPreferences: $e');
    }
  }

  Future<void> muatDariLocalStorage() async {
    _pelanggan.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyLocal);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) {
          for (var item in decoded) {
            if (item is Map) {
              _pelanggan.add(
                PelangganKasbonModel.fromMap(Map<String, dynamic>.from(item)),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Gagal muat kasbon dari SharedPreferences: $e');
    }
  }

  void bayarKasbon(String idPelanggan, int nominal, String metode) {
    final idx = _pelanggan.indexWhere((p) => p.id == idPelanggan);
    if (idx != -1) {
      final p = _pelanggan[idx];
      p.totalUtang -= nominal;
      if (p.totalUtang < 0) p.totalUtang = 0;
      final now = DateTime.now();
      p.riwayat.add(
        RiwayatKasbonItem(
          id: now.millisecondsSinceEpoch.toString(),
          judul: 'Bayar (${metode.toLowerCase()})',
          tanggal: SimwarFormatter.tanggalPendek(now),
          nominal: nominal,
          isBayar: true,
        ),
      );
      simpanKeLocalStorage();
    }
  }

  void tambahKasbon(String namaPelanggan, int nominal, String catatan) {
    final now = DateTime.now();
    final tglStr = SimwarFormatter.tanggalPendek(now);
    final idx = _pelanggan.indexWhere(
      (p) => p.nama.trim().toLowerCase() == namaPelanggan.trim().toLowerCase(),
    );
    if (idx != -1) {
      final p = _pelanggan[idx];
      p.totalUtang += nominal;
      p.riwayat.add(
        RiwayatKasbonItem(
          id: now.millisecondsSinceEpoch.toString(),
          judul: catatan.isNotEmpty ? catatan : 'Belanja kasbon',
          tanggal: tglStr,
          nominal: nominal,
          isBayar: false,
        ),
      );
    } else {
      _pelanggan.add(
        PelangganKasbonModel(
          id: now.millisecondsSinceEpoch.toString(),
          nama: namaPelanggan,
          nomorHp: '-',
          sejak: tglStr,
          totalUtang: nominal,
          riwayat: [
            RiwayatKasbonItem(
              id: now.millisecondsSinceEpoch.toString(),
              judul: catatan.isNotEmpty ? catatan : 'Belanja kasbon baru',
              tanggal: tglStr,
              nominal: nominal,
              isBayar: false,
            ),
          ],
        ),
      );
    }
    simpanKeLocalStorage();
  }
}
