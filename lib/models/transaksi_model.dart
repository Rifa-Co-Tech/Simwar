import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_scope.dart';
import '../utils/formatters.dart';
import 'barang_model.dart';
import 'item_keranjang.dart';

/// SIMWAR — Model Data Riwayat Transaksi Warung
/// Figma node: 2055:463 (Pemilik) & 2073:2716 (Penjaga)
class TransaksiModel {
  final String id;
  final String kode; // 'TRX-0001'
  final DateTime createdAt;
  final String kasir;
  final String metode; // 'Tunai' | 'QRIS' | 'Kasbon'
  String status; // 'Selesai' | 'Menunggu' | 'Dibatalkan'
  final int total;
  final String? namaPelanggan; // Khusus kasbon misal 'Pak Rahmat'
  final List<ItemKeranjang> items;
  final String? waktuCustom;
  final String? tanggalCustom;

  TransaksiModel({
    required this.id,
    required this.kode,
    DateTime? createdAt,
    String? waktu,
    String? tanggal,
    required this.kasir,
    required this.metode,
    this.status = 'Selesai',
    required this.total,
    this.namaPelanggan,
    List<ItemKeranjang>? items,
  })  : createdAt = createdAt ?? DateTime.now(),
        waktuCustom = waktu,
        tanggalCustom = tanggal,
        items = items ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kode': kode,
      'created_at': createdAt.toIso8601String(),
      'waktu_custom': waktuCustom,
      'tanggal_custom': tanggalCustom,
      'kasir': kasir,
      'metode': metode,
      'status': status,
      'total': total,
      'nama_pelanggan': namaPelanggan,
      'items': items.map((i) => i.toMap()).toList(),
    };
  }

  factory TransaksiModel.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'];
    final List<ItemKeranjang> parsedItems = [];
    if (rawItems is List) {
      for (var it in rawItems) {
        if (it is Map) {
          parsedItems.add(ItemKeranjang.fromMap(Map<String, dynamic>.from(it)));
        }
      }
    }

    return TransaksiModel(
      id: (map['id'] ?? '').toString(),
      kode: (map['kode'] ?? '').toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      waktu: map['waktu_custom']?.toString(),
      tanggal: map['tanggal_custom']?.toString(),
      kasir: (map['kasir'] ?? '').toString(),
      metode: (map['metode'] ?? 'Tunai').toString(),
      status: (map['status'] ?? 'Selesai').toString(),
      total: (map['total'] as num?)?.toInt() ?? 0,
      namaPelanggan: map['nama_pelanggan']?.toString(),
      items: parsedItems,
    );
  }

  bool get isHariIni {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  bool get is7HariTerakhir {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final trxDay = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final diffDays = today.difference(trxDay).inDays;
    return diffDays >= 0 && diffDays <= 6;
  }

  bool get isBulanIni {
    final now = DateTime.now();
    return createdAt.year == now.year && createdAt.month == now.month;
  }

  String get waktu {
    if (waktuCustom != null && waktuCustom!.isNotEmpty) return waktuCustom!;
    return '${createdAt.hour.toString().padLeft(2, '0')}.${createdAt.minute.toString().padLeft(2, '0')}';
  }

  String get tanggal {
    if (isHariIni) return 'Hari ini';
    return SimwarFormatter.tanggal(createdAt);
  }

  int hitungLaba() {
    int laba = 0;
    for (var item in items) {
      final barang = BarangStore.instance.semua.firstWhere(
        (b) =>
            (item.id.isNotEmpty && b.id == item.id) ||
            b.nama.trim().toLowerCase() == item.nama.trim().toLowerCase(),
        orElse: () => BarangModel(
          id: '',
          nama: item.nama,
          barcode: '',
          kategori: 'Umum',
          hargaBeli: (item.harga * 0.8).round(),
          hargaJual: item.harga,
          stok: 0,
        ),
      );
      final marginPerItem = (item.harga - barang.hargaBeli);
      laba += (marginPerItem > 0 ? marginPerItem : 0) * item.jumlah;
    }
    return laba;
  }

  String get subteks {
    if (metode == 'Kasbon') {
      return 'Kasbon · ${namaPelanggan ?? "Pelanggan"}';
    }
    if (status == 'Menunggu') {
      return '$metode · menunggu pembayaran';
    }
    final int jml = items.fold(0, (sum, i) => sum + i.jumlah);
    if (jml > 0) {
      return '$metode · oleh $kasir · $jml barang';
    }
    return '$metode · oleh $kasir';
  }
}

/// Store transaksi warung dengan persistensi SharedPreferences
class TransaksiStore {
  static final TransaksiStore instance = TransaksiStore._internal();
  factory TransaksiStore() => instance;
  TransaksiStore._internal();

  static String get _keyLocal => StorageScope.key('simwar_transaksi_v2');
  final List<TransaksiModel> _list = [];

  void resetInMemory() {
    _list.clear();
  }

  List<TransaksiModel> get semua => List.unmodifiable(_list);

  Future<void> simpanKeLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_list.map((t) => t.toMap()).toList());
      await prefs.setString(_keyLocal, encoded);
    } catch (e) {
      debugPrint('Gagal simpan transaksi ke SharedPreferences: $e');
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
              _list.add(TransaksiModel.fromMap(Map<String, dynamic>.from(item)));
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Gagal muat transaksi dari SharedPreferences: $e');
    }
  }

  void tambahTransaksi(TransaksiModel trx) {
    _list.insert(0, trx);
    simpanKeLocalStorage();
  }

  void batalkanTransaksi(String id) {
    final idx = _list.indexWhere((t) => t.id == id);
    if (idx != -1 && _list[idx].status != 'Dibatalkan') {
      _list[idx].status = 'Dibatalkan';
      // Kembalikan stok barang jika transaksi sebelumnya mengurangi stok
      for (var item in _list[idx].items) {
        BarangStore.instance.tambahStokAsync(item.id, item.nama, item.jumlah);
      }
      simpanKeLocalStorage();
    }
  }

  void resetData() {
    _list.clear();
    simpanKeLocalStorage();
  }
}
