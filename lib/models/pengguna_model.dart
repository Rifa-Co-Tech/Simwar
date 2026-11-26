class PenggunaModel {
  final String id;
  final String nama;
  final String nomorHp;
  final String peran;
  final bool statusAktif;
  final String namaWarung;

  PenggunaModel({
    required this.id,
    required this.nama,
    required this.nomorHp,
    required this.peran,
    required this.statusAktif,
    this.namaWarung = 'Warung Azzam',
  });

  factory PenggunaModel.fromMap(Map<String, dynamic> map) {
    return PenggunaModel(
      id: (map['id_pengguna'] ?? map['id'] ?? '').toString(),
      nama: (map['nama'] ?? '').toString(),
      nomorHp: (map['nomor_hp'] ?? '').toString(),
      peran: (map['peran'] ?? '').toString(),
      statusAktif: map['status_aktif'] == true,
      namaWarung: (map['nama_warung'] ?? 'Warung Azzam').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_pengguna': id,
      'nama': nama,
      'nomor_hp': nomorHp,
      'peran': peran,
      'status_aktif': statusAktif,
      'nama_warung': namaWarung,
    };
  }

  PenggunaModel copyWith({
    String? id,
    String? nama,
    String? nomorHp,
    String? peran,
    bool? statusAktif,
    String? namaWarung,
  }) {
    return PenggunaModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      nomorHp: nomorHp ?? this.nomorHp,
      peran: peran ?? this.peran,
      statusAktif: statusAktif ?? this.statusAktif,
      namaWarung: namaWarung ?? this.namaWarung,
    );
  }
}
