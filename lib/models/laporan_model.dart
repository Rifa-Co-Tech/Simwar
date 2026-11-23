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
}

/// Store in-memory terpusat agar sinkron antara POV Penjaga & Pemilik
class LaporanStore {
  static final LaporanStore instance = LaporanStore._internal();
  factory LaporanStore() => instance;
  LaporanStore._internal();

  final List<LaporanModel> _list = [];

  List<LaporanModel> get semua => List.unmodifiable(_list);

  List<LaporanModel> get baru =>
      _list.where((l) => l.isBaru).toList();

  List<LaporanModel> get selesai =>
      _list.where((l) => l.isSelesai).toList();

  void tambahLaporan(LaporanModel laporan) {
    _list.insert(0, laporan);
  }

  void balasLaporan(String id, String teksBalasan) {
    final idx = _list.indexWhere((l) => l.id == id);
    if (idx != -1) {
      _list[idx].balasan.add(teksBalasan);
      _list[idx].status = 'Dibalas';
    }
  }

  void tandaiSelesai(String id) {
    final idx = _list.indexWhere((l) => l.id == id);
    if (idx != -1) {
      _list[idx].status = 'Selesai';
    }
  }
}
