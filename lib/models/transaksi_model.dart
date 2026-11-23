import 'item_keranjang.dart';

/// SIMWAR — Model Data Riwayat Transaksi
/// Figma node: 2055:463 (Pemilik) & 2073:2716 (Penjaga)
class TransaksiModel {
  final String id;
  final String kode; // 'TRX-0143'
  final String waktu; // '09.50'
  final String tanggal; // '17 Nov 2026'
  final String kasir; // 'Rina'
  final String metode; // 'Tunai' | 'QRIS' | 'Kasbon'
  String status; // 'Selesai' | 'Menunggu' | 'Dibatalkan'
  final int total;
  final String? namaPelanggan; // Khusus kasbon misal 'Pak Rahmat'
  final List<ItemKeranjang> items;

  TransaksiModel({
    required this.id,
    required this.kode,
    required this.waktu,
    required this.tanggal,
    required this.kasir,
    required this.metode,
    this.status = 'Selesai',
    required this.total,
    this.namaPelanggan,
    List<ItemKeranjang>? items,
  }) : items = items ?? [];

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

/// Store in-memory transaksi warung
class TransaksiStore {
  static final TransaksiStore instance = TransaksiStore._internal();
  factory TransaksiStore() => instance;
  TransaksiStore._internal();

  final List<TransaksiModel> _list = [
    TransaksiModel(
      id: '1',
      kode: 'TRX-0143',
      waktu: '09.50',
      tanggal: '17 Nov 2026',
      kasir: 'Rina',
      metode: 'QRIS',
      status: 'Menunggu',
      total: 28000,
      items: [
        ItemKeranjang(id: '1', nama: 'Minyak Goreng 1 L', harga: 16000, jumlah: 1),
        ItemKeranjang(id: '2', nama: 'Telur Ayam 1/2 kg', harga: 12000, jumlah: 1),
      ],
    ),
    TransaksiModel(
      id: '2',
      kode: 'TRX-0142',
      waktu: '09.41',
      tanggal: '17 Nov 2026',
      kasir: 'Rina',
      metode: 'Tunai',
      status: 'Selesai',
      total: 28000,
      items: [
        ItemKeranjang(id: '1', nama: 'Indomie Goreng Spesial', harga: 3500, jumlah: 2),
        ItemKeranjang(id: '2', nama: 'Teh Botol Sosro', harga: 5000, jumlah: 1),
        ItemKeranjang(id: '3', nama: 'Minyak Goreng 1 L', harga: 16000, jumlah: 1),
      ],
    ),
    TransaksiModel(
      id: '3',
      kode: 'TRX-0141',
      waktu: '09.28',
      tanggal: '17 Nov 2026',
      kasir: 'Rina',
      metode: 'QRIS',
      status: 'Selesai',
      total: 45000,
      items: [
        ItemKeranjang(id: '1', nama: 'Beras Ramos 2.5 kg', harga: 35000, jumlah: 1),
        ItemKeranjang(id: '2', nama: 'Kopi Kapal Api', harga: 5000, jumlah: 2),
      ],
    ),
    TransaksiModel(
      id: '4',
      kode: 'TRX-0140',
      waktu: '09.10',
      tanggal: '17 Nov 2026',
      kasir: 'Rina',
      metode: 'Kasbon',
      status: 'Selesai',
      namaPelanggan: 'Pak Rahmat',
      total: 150000,
      items: [
        ItemKeranjang(id: '1', nama: 'Beras Ramos 5 kg', harga: 68000, jumlah: 1),
        ItemKeranjang(id: '2', nama: 'Minyak Goreng 2 L', harga: 32000, jumlah: 1),
        ItemKeranjang(id: '3', nama: 'Telur Ayam 1 kg', harga: 28000, jumlah: 1),
        ItemKeranjang(id: '4', nama: 'Gula Pasir 1 kg', harga: 17500, jumlah: 1),
      ],
    ),
    TransaksiModel(
      id: '5',
      kode: 'TRX-0139',
      waktu: '09.02',
      tanggal: '17 Nov 2026',
      kasir: 'Rina',
      metode: 'QRIS',
      status: 'Selesai',
      total: 18500,
      items: [
        ItemKeranjang(id: '1', nama: 'Gula Pasir 1 kg', harga: 17500, jumlah: 1),
        ItemKeranjang(id: '2', nama: 'Permen Kopi', harga: 1000, jumlah: 1),
      ],
    ),
    TransaksiModel(
      id: '6',
      kode: 'TRX-0138',
      waktu: '08.55',
      tanggal: '17 Nov 2026',
      kasir: 'Rina',
      metode: 'Tunai',
      status: 'Dibatalkan',
      total: 12500,
      items: [
        ItemKeranjang(id: '1', nama: 'Sabun Mandi Lifebuoy', harga: 4000, jumlah: 2),
        ItemKeranjang(id: '2', nama: 'Pasta Gigi Pepsodent', harga: 4500, jumlah: 1),
      ],
    ),
  ];

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
}
