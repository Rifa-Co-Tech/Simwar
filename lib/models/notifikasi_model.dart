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
}

class NotifikasiStore {
  static final NotifikasiStore instance = NotifikasiStore._internal();
  factory NotifikasiStore() => instance;
  NotifikasiStore._internal();

  final List<NotifikasiModel> _list = [
    NotifikasiModel(
      id: 'notif-1',
      judul: 'Stok Kritis: Gula Pasir 1 kg',
      pesan: 'Sisa stok tinggal 0 pcs. Penjaga Rina telah mengirimkan laporan pengadaan.',
      waktu: DateTime.now().subtract(const Duration(minutes: 15)),
      kategori: KategoriNotif.stok,
      isRead: false,
      routeTarget: 'stok',
    ),
    NotifikasiModel(
      id: 'notif-2',
      judul: 'Laporan Baru dari Penjaga',
      pesan: 'Rina melaporkan: "Minyak goreng SunCo kemasan 2L bocor 1 pouch di rak depan."',
      waktu: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
      kategori: KategoriNotif.laporan,
      isRead: false,
      routeTarget: 'laporan',
    ),
    NotifikasiModel(
      id: 'notif-3',
      judul: 'Pembayaran QRIS Berhasil',
      pesan: 'Transaksi TRX-0141 sebesar Rp 45.000 telah berhasil diterima via QRIS Dinamis.',
      waktu: DateTime.now().subtract(const Duration(hours: 3)),
      kategori: KategoriNotif.transaksi,
      isRead: false,
      routeTarget: 'transaksi',
    ),
    NotifikasiModel(
      id: 'notif-4',
      judul: 'Pasokan Distributor Tiba',
      pesan: 'Barang masuk dari PT Indomarco Adi Prima (80 Indomie, 12 SunCo 2L) senilai Rp 632.000.',
      waktu: DateTime.now().subtract(const Duration(days: 1)),
      kategori: KategoriNotif.pasokan,
      isRead: true,
      routeTarget: 'barang_masuk',
    ),
    NotifikasiModel(
      id: 'notif-5',
      judul: 'Peringatan Jatuh Tempo Faktur',
      pesan: 'Faktur Beras Berkah Utama sebesar Rp 680.000 akan jatuh tempo dalam 5 hari.',
      waktu: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      kategori: KategoriNotif.pasokan,
      isRead: true,
      routeTarget: 'barang_masuk',
    ),
    NotifikasiModel(
      id: 'notif-6',
      judul: 'Peringatan Barang Kedaluwarsa',
      pesan: 'Sari Roti Sobek Coklat mendekati tanggal kedaluwarsa (sisa 2 hari).',
      waktu: DateTime.now().subtract(const Duration(days: 2)),
      kategori: KategoriNotif.stok,
      isRead: true,
      routeTarget: 'stok',
    ),
  ];

  List<NotifikasiModel> get semua => List.unmodifiable(_list);

  int get unreadCount => _list.where((n) => !n.isRead).length;

  void tandaiSemuaDibaca() {
    for (var n in _list) {
      n.isRead = true;
    }
  }

  void tandaiDibaca(String id) {
    final idx = _list.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _list[idx].isRead = true;
    }
  }

  void hapusNotifikasi(String id) {
    _list.removeWhere((n) => n.id == id);
  }
}
