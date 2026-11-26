import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SIMWAR — Model & Store Notifikasi Warung
enum KategoriNotif { stok, transaksi, laporan, pasokan }

class NotifikasiModel {
  final String id;
  final String judul;
  final String pesan;
  final DateTime waktu;
  final KategoriNotif kategori;
  bool isRead;
  final String? routeTarget; // 'stok', 'transaksi', 'laporan', 'barang_masuk'

  NotifikasiModel({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.waktu,
    required this.kategori,
    this.isRead = false,
    this.routeTarget,
  });

  String get waktuRelatif {
    final diff = DateTime.now().difference(waktu);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari lalu';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'pesan': pesan,
      'waktu': waktu.toIso8601String(),
      'kategori': kategori.name,
      'is_read': isRead,
      'route_target': routeTarget,
    };
  }

  factory NotifikasiModel.fromMap(Map<String, dynamic> map) {
    final katStr = (map['kategori'] ?? 'stok').toString();
    KategoriNotif kat = KategoriNotif.stok;
    if (katStr == 'transaksi') kat = KategoriNotif.transaksi;
    if (katStr == 'laporan') kat = KategoriNotif.laporan;
    if (katStr == 'pasokan') kat = KategoriNotif.pasokan;

    return NotifikasiModel(
      id: (map['id'] ?? '').toString(),
      judul: (map['judul'] ?? '').toString(),
      pesan: (map['pesan'] ?? '').toString(),
      waktu: DateTime.tryParse(map['waktu']?.toString() ?? '') ?? DateTime.now(),
      kategori: kat,
      isRead: map['is_read'] == true,
      routeTarget: map['route_target']?.toString(),
    );
  }
}

class NotifikasiStore {
  static final NotifikasiStore instance = NotifikasiStore._internal();
  factory NotifikasiStore() => instance;
  NotifikasiStore._internal();

  static const String _keyLocal = 'simwar_notifikasi_v1';

  final List<NotifikasiModel> _list = [
    NotifikasiModel(
      id: 'welcome',
      judul: 'Selamat Datang di SIMWAR Warung Azzam',
      pesan:
          'Aplikasi manajemen warung siap digunakan. Mulai dengan mencatat barang dan transaksi Anda.',
      waktu: DateTime.now(),
      kategori: KategoriNotif.transaksi,
      isRead: false,
    ),
  ];

  List<NotifikasiModel> get semua => List.unmodifiable(_list);

  int get unreadCount => _list.where((n) => !n.isRead).length;

  Future<void> simpanKeLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_list.map((n) => n.toMap()).toList());
      await prefs.setString(_keyLocal, encoded);
    } catch (e) {
      debugPrint('Gagal simpan notifikasi ke SharedPreferences: $e');
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
              _list.add(
                NotifikasiModel.fromMap(Map<String, dynamic>.from(item)),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Gagal muat notifikasi dari SharedPreferences: $e');
    }
  }

  void tandaiSemuaDibaca() {
    for (var n in _list) {
      n.isRead = true;
    }
    simpanKeLocalStorage();
  }

  void tandaiDibaca(String id) {
    final idx = _list.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _list[idx].isRead = true;
      simpanKeLocalStorage();
    }
  }

  void tambahNotifikasi(NotifikasiModel notif) {
    final ada = _list.any((n) =>
        n.id == notif.id ||
        (n.judul == notif.judul &&
            DateTime.now().difference(n.waktu).inHours < 12));
    if (!ada) {
      _list.insert(0, notif);
      simpanKeLocalStorage();
    }
  }

  void hapusNotifikasi(String id) {
    _list.removeWhere((n) => n.id == id);
    simpanKeLocalStorage();
  }
}
