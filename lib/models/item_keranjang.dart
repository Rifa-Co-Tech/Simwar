class ItemKeranjang {
  final String id;
  final String nama;
  final int harga;
  final String satuan;
  int jumlah;

  ItemKeranjang({
    required this.id,
    required this.nama,
    required this.harga,
    this.satuan = 'pcs',
    this.jumlah = 1,
  });

  int get subtotal => harga * jumlah;

  ItemKeranjang copyWith({int? jumlah}) {
    return ItemKeranjang(
      id: id,
      nama: nama,
      harga: harga,
      satuan: satuan,
      jumlah: jumlah ?? this.jumlah,
    );
  }
}
