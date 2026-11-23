import 'barang_masuk_model.dart';
import 'barang_model.dart';

/// SIMWAR — Model Data Rencana Belanja Warung (Restock Planner)
/// Figma node: 2010:698

class ItemBelanja {
  final String id;
  final String? barangId;
  String nama;
  int jumlah;
  String satuan;
  int estimasiHarga;
  String tokoTujuan; // 'Grosir Berkah', 'Pasar Induk', 'Distributor Indomarco', 'Lainnya'
  bool isSudahDibeli;
  String alasan; // 'Stok Kritis', 'Stok Menipis', 'Permintaan Pelanggan', 'Manual'

  ItemBelanja({
    required this.id,
    this.barangId,
    required this.nama,
    required this.jumlah,
    this.satuan = 'pcs',
    required this.estimasiHarga,
    this.tokoTujuan = 'Grosir Berkah',
    this.isSudahDibeli = false,
    this.alasan = 'Stok Menipis',
  });

  int get subtotal => jumlah * estimasiHarga;
}

class RencanaBelanjaStore {
  static final RencanaBelanjaStore instance = RencanaBelanjaStore._internal();
  factory RencanaBelanjaStore() => instance;
  RencanaBelanjaStore._internal();

  final List<ItemBelanja> _list = [];

  List<ItemBelanja> get semua => List.unmodifiable(_list);

  List<ItemBelanja> get perluDibeli =>
      _list.where((i) => !i.isSudahDibeli).toList();

  List<ItemBelanja> get sudahDibeli =>
      _list.where((i) => i.isSudahDibeli).toList();

  int get totalEstimasiAnggaran =>
      _list.fold(0, (sum, i) => sum + i.subtotal);

  int get totalAnggaranPerluDibeli =>
      perluDibeli.fold(0, (sum, i) => sum + i.subtotal);

  int get totalSudahDibelanjakan =>
      sudahDibeli.fold(0, (sum, i) => sum + i.subtotal);

  void tambahItem(ItemBelanja item) {
    _list.insert(0, item);
  }

  void toggleStatus(String id) {
    final idx = _list.indexWhere((i) => i.id == id);
    if (idx != -1) {
      _list[idx].isSudahDibeli = !_list[idx].isSudahDibeli;
    }
  }

  void hapusItem(String id) {
    _list.removeWhere((i) => i.id == id);
  }

  /// Sinkronisasi otomatis dari barang stok menipis
  void sinkronkanDariStokMenipis() {
    final menipis = BarangStore.instance.stokMenipis;
    for (var b in menipis) {
      final exists = _list.any((item) =>
          item.barangId == b.id ||
          item.nama.toLowerCase() == b.nama.toLowerCase());
      if (!exists) {
        _list.add(
          ItemBelanja(
            id: 'rb-auto-${DateTime.now().millisecondsSinceEpoch}-${b.id}',
            barangId: b.id,
            nama: b.nama,
            jumlah: b.batasMin * 2,
            satuan: b.satuan,
            estimasiHarga: b.hargaBeli * (b.batasMin * 2),
            tokoTujuan: b.namaPemasok ?? 'Grosir Berkah',
            isSudahDibeli: false,
            alasan: b.isKritis ? 'Stok Kritis' : 'Stok Menipis',
          ),
        );
      }
    }
  }

  /// Terapkan barang yang sudah dibeli menjadi BarangMasuk & update stok
  int selesaikanBelanjaDanUpdateStok(String dicatatOleh) {
    final itemsBeli = List<ItemBelanja>.from(sudahDibeli);
    if (itemsBeli.isEmpty) return 0;

    final masukItems = itemsBeli.map((ib) {
      return BarangMasukItem(
        barangId: ib.barangId ?? 'AUTO-${DateTime.now().millisecondsSinceEpoch}',
        namaBarang: ib.nama,
        jumlah: ib.jumlah,
        satuan: ib.satuan,
        hargaBeli: ib.jumlah > 0 ? (ib.estimasiHarga ~/ ib.jumlah) : ib.estimasiHarga,
      );
    }).toList();

    final grandTotal = itemsBeli.fold(0, (sum, i) => sum + i.subtotal);

    final modelMasuk = BarangMasukModel(
      id: 'BM-BELANJA-${DateTime.now().millisecondsSinceEpoch % 10000}',
      tanggal: DateTime.now(),
      jenis: JenisBarangMasuk.distributor,
      namaPemasok: 'Kulakan Pasar & Grosir (Rencana Belanja)',
      items: masukItems,
      totalNilai: grandTotal,
      statusBayar: StatusBayarPasokan.lunas,
      catatan: 'Hasil belanja dari Rencana Belanja Warung',
      dicatatOleh: dicatatOleh,
    );

    BarangMasukStore.instance.tambahBarangMasuk(modelMasuk);

    // Hapus barang yang sudah dibeli dari daftar belanja aktif
    _list.removeWhere((i) => i.isSudahDibeli);

    return itemsBeli.length;
  }
}
