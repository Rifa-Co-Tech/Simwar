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

  final List<PelangganKasbonModel> _pelanggan = [];

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
