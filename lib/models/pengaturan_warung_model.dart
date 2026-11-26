import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SIMWAR — Model & Store Pengaturan Warung & Profil Usaha
class PengaturanWarungModel {
  String namaWarung;
  String alamatWarung;
  String noTeleponWarung;
  bool qrisAktif;
  String nmidQris;
  String pesanHeaderStruk;
  String pesanFooterStruk;
  bool otomatisCetakStruk;
  bool notifStokMenipis;
  bool notifKedaluwarsa;
  bool suaraKasirAktif;
  int hariPeringatanKedaluwarsa;
  int batasStokDefault;

  PengaturanWarungModel({
    this.namaWarung = 'Warung Azzam',
    this.alamatWarung = 'Jl. Garuda Sakti Km 1, Tampan',
    this.noTeleponWarung = '',
    this.qrisAktif = true,
    this.nmidQris = 'ID1020039485712',
    this.pesanHeaderStruk = 'WARUNG AZZAM\nBelanja Hemat, Lengkap & Berkah',
    this.pesanFooterStruk =
        'Terima kasih atas kunjungan Anda!\nBarang yang sudah dibeli dapat ditukar 1x24 jam',
    this.otomatisCetakStruk = true,
    this.notifStokMenipis = true,
    this.notifKedaluwarsa = true,
    this.suaraKasirAktif = true,
    this.hariPeringatanKedaluwarsa = 3,
    this.batasStokDefault = 10,
  });

  Map<String, dynamic> toMap() {
    return {
      'nama_warung': namaWarung,
      'alamat_warung': alamatWarung,
      'no_telepon_warung': noTeleponWarung,
      'qris_aktif': qrisAktif,
      'nmid_qris': nmidQris,
      'pesan_header_struk': pesanHeaderStruk,
      'pesan_footer_struk': pesanFooterStruk,
      'otomatis_cetak_struk': otomatisCetakStruk,
      'notif_stok_menipis': notifStokMenipis,
      'notif_kedaluwarsa': notifKedaluwarsa,
      'suara_kasir_aktif': suaraKasirAktif,
      'hari_peringatan_kedaluwarsa': hariPeringatanKedaluwarsa,
      'batas_stok_default': batasStokDefault,
    };
  }

  void applyMap(Map<String, dynamic> map) {
    if (map['nama_warung'] != null) {
      namaWarung = map['nama_warung'].toString();
    }
    if (map['alamat_warung'] != null) {
      alamatWarung = map['alamat_warung'].toString();
    }
    if (map['no_telepon_warung'] != null) {
      noTeleponWarung = map['no_telepon_warung'].toString();
    }
    if (map['qris_aktif'] != null) qrisAktif = map['qris_aktif'] == true;
    if (map['nmid_qris'] != null) nmidQris = map['nmid_qris'].toString();
    if (map['pesan_header_struk'] != null) {
      pesanHeaderStruk = map['pesan_header_struk'].toString();
    }
    if (map['pesan_footer_struk'] != null) {
      pesanFooterStruk = map['pesan_footer_struk'].toString();
    }
    if (map['otomatis_cetak_struk'] != null) {
      otomatisCetakStruk = map['otomatis_cetak_struk'] == true;
    }
    if (map['notif_stok_menipis'] != null) {
      notifStokMenipis = map['notif_stok_menipis'] == true;
    }
    if (map['notif_kedaluwarsa'] != null) {
      notifKedaluwarsa = map['notif_kedaluwarsa'] == true;
    }
    if (map['suara_kasir_aktif'] != null) {
      suaraKasirAktif = map['suara_kasir_aktif'] == true;
    }
    if (map['hari_peringatan_kedaluwarsa'] != null) {
      hariPeringatanKedaluwarsa =
          (map['hari_peringatan_kedaluwarsa'] as num?)?.toInt() ?? 3;
    }
    if (map['batas_stok_default'] != null) {
      batasStokDefault = (map['batas_stok_default'] as num?)?.toInt() ?? 10;
    }
  }
}

class PengaturanStore {
  static final PengaturanStore instance = PengaturanStore._internal();
  factory PengaturanStore() => instance;
  PengaturanStore._internal();

  static const String _keyLocal = 'simwar_pengaturan_warung_v1';
  final PengaturanWarungModel pengaturan = PengaturanWarungModel();

  Future<void> simpanKeLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLocal, jsonEncode(pengaturan.toMap()));
    } catch (e) {
      debugPrint('Gagal simpan pengaturan ke SharedPreferences: $e');
    }
  }

  Future<void> muatDariLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyLocal);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is Map) {
          pengaturan.applyMap(Map<String, dynamic>.from(decoded));
        }
      }
    } catch (e) {
      debugPrint('Gagal muat pengaturan dari SharedPreferences: $e');
    }
  }
}
