class PenggunaModel {
  final String id;
  final String nama;
  final String nomorHp;
  final String peran;
  final bool statusAktif;

  PenggunaModel({
    required this.id,
    required this.nama,
    required this.nomorHp,
    required this.peran,
    required this.statusAktif,
  });

  factory PenggunaModel.fromMap(Map<String, dynamic> map) {
    return PenggunaModel(
      id: map['id']?.toString() ?? '',
      nama: map['nama']?.toString() ?? '',
      nomorHp: map['nomor_hp']?.toString() ?? '',
      peran: map['peran']?.toString() ?? '',
      statusAktif: map['status_aktif'] == true,
    );
  }
}
