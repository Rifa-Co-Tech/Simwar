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
      id: 'welcome',
      judul: 'Selamat Datang di SIMWAR Warung Azzam',
      pesan: 'Aplikasi manajemen warung siap digunakan. Mulai dengan mencatat barang dan transaksi Anda.',
      waktu: DateTime.now(),
      kategori: KategoriNotif.transaksi,
      isRead: false,
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
