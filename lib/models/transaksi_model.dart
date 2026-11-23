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

  bool get isHariIni {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  bool get is7HariTerakhir {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays <= 7 && !difference.isNegative;
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
    if (tanggalCustom != null && tanggalCustom!.isNotEmpty) return tanggalCustom!;
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

/// Store in-memory transaksi warung (Bersih untuk APK baru)
class TransaksiStore {
  static final TransaksiStore instance = TransaksiStore._internal();
  factory TransaksiStore() => instance;
  TransaksiStore._internal();

  final List<TransaksiModel> _list = [];

  List<TransaksiModel> get semua => List.unmodifiable(_list);

  void tambahTransaksi(TransaksiModel trx) {
    _list.insert(0, trx);
  }

  void batalkanTransaksi(String id) {
    final idx = _list.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _list[idx].status = 'Dibatalkan';
    }
  }

  void resetData() {
    _list.clear();
  }
}
