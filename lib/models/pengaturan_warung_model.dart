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

  PengaturanWarungModel({
    this.namaWarung = 'Warung Azzam Berkah',
    this.alamatWarung = 'Jl. Melati Raya No. 12, RT 03/RW 04, Sukamaju',
    this.noTeleponWarung = '0812-3456-7890',
    this.qrisAktif = true,
    this.nmidQris = 'ID1020039485712',
    this.pesanHeaderStruk = 'WARUNG AZZAM BERKAH\nBelanja Hemat, Lengkap & Berkah',
    this.pesanFooterStruk = 'Terima kasih atas kunjungan Anda!\nBarang yang sudah dibeli dapat ditukar 1x24 jam',
    this.otomatisCetakStruk = true,
    this.notifStokMenipis = true,
    this.notifKedaluwarsa = true,
    this.suaraKasirAktif = true,
  });
}

class PengaturanStore {
  static final PengaturanStore instance = PengaturanStore._internal();
  factory PengaturanStore() => instance;
  PengaturanStore._internal();

  final PengaturanWarungModel pengaturan = PengaturanWarungModel();
}
