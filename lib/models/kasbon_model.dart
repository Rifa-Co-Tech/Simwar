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
}

/// Store in-memory kasbon pelanggan warung
class KasbonStore {
  static final KasbonStore instance = KasbonStore._internal();
  factory KasbonStore() => instance;
  KasbonStore._internal();

  final List<PelangganKasbonModel> _pelanggan = [
    PelangganKasbonModel(
      id: '1',
      nama: 'Pak Rahmat',
      nomorHp: '0812 8888 1111',
      sejak: '29 Okt 2026',
      totalUtang: 420000,
      riwayat: [
        RiwayatKasbonItem(id: '1', judul: 'Belanja 6 barang', tanggal: '29 Okt 2026', nominal: 180000, isBayar: false),
        RiwayatKasbonItem(id: '2', judul: 'Belanja 5 barang', tanggal: '5 Nov 2026', nominal: 190000, isBayar: false),
        RiwayatKasbonItem(id: '3', judul: 'Bayar sebagian (tunai)', tanggal: '11 Nov 2026', nominal: 100000, isBayar: true),
        RiwayatKasbonItem(id: '4', judul: 'Belanja 3 barang', tanggal: '14 Nov 2026', nominal: 150000, isBayar: false),
      ],
    ),
    PelangganKasbonModel(
      id: '2',
      nama: 'Bu Aminah',
      nomorHp: '0813 7777 2222',
      sejak: '3 Nov 2026',
      totalUtang: 285000,
      riwayat: [
        RiwayatKasbonItem(id: '1', judul: 'Belanja 4 barang', tanggal: '3 Nov 2026', nominal: 135000, isBayar: false),
        RiwayatKasbonItem(id: '2', judul: 'Belanja 3 barang', tanggal: '8 Nov 2026', nominal: 150000, isBayar: false),
      ],
    ),
    PelangganKasbonModel(
      id: '3',
      nama: 'Ibu Rahmah',
      nomorHp: '0815 6666 3333',
      sejak: '10 Nov 2026',
      totalUtang: 95000,
      riwayat: [
        RiwayatKasbonItem(id: '1', judul: 'Belanja 2 barang', tanggal: '10 Nov 2026', nominal: 95000, isBayar: false),
      ],
    ),
    PelangganKasbonModel(
      id: '4',
      nama: 'Mas Dimas',
      nomorHp: '0817 5555 4444',
      sejak: '14 Nov 2026',
      totalUtang: 150000,
      riwayat: [
        RiwayatKasbonItem(id: '1', judul: 'Belanja 1 barang (Beras 5kg)', tanggal: '14 Nov 2026', nominal: 150000, isBayar: false),
      ],
    ),
  ];

  List<PelangganKasbonModel> get semua => _pelanggan;

  int get totalSemuaUtang => _pelanggan.fold(0, (sum, p) => sum + p.totalUtang);

  void bayarKasbon(String idPelanggan, int nominal, String metode) {
    final idx = _pelanggan.indexWhere((p) => p.id == idPelanggan);
    if (idx != -1) {
      final p = _pelanggan[idx];
      p.totalUtang -= nominal;
      if (p.totalUtang < 0) p.totalUtang = 0;
      p.riwayat.add(
        RiwayatKasbonItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          judul: 'Bayar (${metode.toLowerCase()})',
          tanggal: 'Hari ini',
          nominal: nominal,
          isBayar: true,
        ),
      );
    }
  }

  void tambahKasbon(String namaPelanggan, int nominal, String catatan) {
    final idx = _pelanggan.indexWhere((p) => p.nama.toLowerCase() == namaPelanggan.toLowerCase());
    if (idx != -1) {
      final p = _pelanggan[idx];
      p.totalUtang += nominal;
      p.riwayat.add(
        RiwayatKasbonItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          judul: catatan.isNotEmpty ? catatan : 'Belanja kasbon',
          tanggal: 'Hari ini',
          nominal: nominal,
          isBayar: false,
        ),
      );
    } else {
      _pelanggan.add(
        PelangganKasbonModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nama: namaPelanggan,
          nomorHp: '0812 xxx xxxx',
          sejak: 'Hari ini',
          totalUtang: nominal,
          riwayat: [
            RiwayatKasbonItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              judul: catatan.isNotEmpty ? catatan : 'Belanja kasbon baru',
              tanggal: 'Hari ini',
              nominal: nominal,
              isBayar: false,
            ),
          ],
        ),
      );
    }
  }
}
