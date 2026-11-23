import 'barang_model.dart';

/// SIMWAR — Model Data Barang Masuk (Distributor & Titipan Warga)
/// Figma node: 2224:2 (Daftar Barang Masuk) & 2224:93 (Catat Barang Masuk)

enum JenisBarangMasuk { distributor, titipan }

enum StatusBayarPasokan { lunas, tempo, konsinyasi }

class BarangMasukItem {
  final String barangId;
  final String namaBarang;
  final int jumlah;
  final String satuan; // 'pcs', 'dus', 'renceng', 'pack', 'karton', 'bungkus'
  final int hargaBeli; // atau harga setor titipan
  final int? hargaJual; // harga jual eceran warung

  BarangMasukItem({
    required this.barangId,
    required this.namaBarang,
    required this.jumlah,
    this.satuan = 'pcs',
    required this.hargaBeli,
    this.hargaJual,
  });

  int get subtotal => jumlah * hargaBeli;
}

class BarangMasukModel {
  final String id;
  final DateTime tanggal;
  final JenisBarangMasuk jenis;
  final String namaPemasok; // Nama Distributor atau Nama Penitip
  final String? noFaktur; // No Invoice atau No HP Penitip
  final List<BarangMasukItem> items;
  final int totalNilai;
  StatusBayarPasokan statusBayar;
  final DateTime? jatuhTempo; // jika tempo
  final String? catatan;
  final String dicatatOleh; // 'Pemilik' atau nama Penjaga

  // Khusus Konsinyasi Titipan Warga
  int? sisaRetur;
  bool sudahDisetorKePenitip;

  BarangMasukModel({
    required this.id,
    required this.tanggal,
    required this.jenis,
    required this.namaPemasok,
    this.noFaktur,
    required this.items,
    required this.totalNilai,
    required this.statusBayar,
    this.jatuhTempo,
    this.catatan,
    this.dicatatOleh = 'Pemilik',
    this.sisaRetur = 0,
    this.sudahDisetorKePenitip = false,
  });

  bool get isDistributor => jenis == JenisBarangMasuk.distributor;
  bool get isTitipan => jenis == JenisBarangMasuk.titipan;

  int get totalItemCount => items.fold(0, (sum, i) => sum + i.jumlah);
}

/// Store in-memory transaksi barang masuk & pasokan
class BarangMasukStore {
  static final BarangMasukStore instance = BarangMasukStore._internal();
  factory BarangMasukStore() => instance;
  BarangMasukStore._internal();

  final List<BarangMasukModel> _list = [];

  List<BarangMasukModel> get semua => List.unmodifiable(_list);

  List<BarangMasukModel> get distributorOnly =>
      _list.where((item) => item.isDistributor).toList();

  List<BarangMasukModel> get titipanOnly =>
      _list.where((item) => item.isTitipan).toList();

  int get totalNilaiBulanIni =>
      _list.fold(0, (sum, item) => sum + item.totalNilai);

  int get titipanAktifCount =>
      _list.where((item) => item.isTitipan && !item.sudahDisetorKePenitip).length;

  int get fakturTempoCount =>
      _list.where((item) => item.statusBayar == StatusBayarPasokan.tempo).length;

  void tambahBarangMasuk(BarangMasukModel model) {
    _list.insert(0, model);

    // Otomatis update / sinkronisasi stok di BarangStore
    for (var item in model.items) {
      final index = BarangStore.instance.semua
          .indexWhere((b) => b.id == item.barangId || b.nama.toLowerCase() == item.namaBarang.toLowerCase());
      if (index != -1) {
        final existing = BarangStore.instance.semua[index];
        existing.stok += item.jumlah;
        BarangStore.instance.ubahBarangAsync(existing);
      } else {
        // Jika belum ada di katalog, daftarkan otomatis
        final newBarang = BarangModel(
          id: 'BM-AUTO-${DateTime.now().millisecondsSinceEpoch}',
          nama: item.namaBarang,
          barcode: '',
          kategori: model.isTitipan ? 'Makanan' : 'Sembako',
          hargaBeli: item.hargaBeli,
          hargaJual: item.hargaJual ?? (item.hargaBeli * 1.2).toInt(),
          stok: item.jumlah,
          batasMin: 5,
          satuan: item.satuan,
          isTitipan: model.isTitipan,
          namaPemasok: model.namaPemasok,
          tglKedaluwarsa: DateTime.now().add(const Duration(days: 90)),
        );
        BarangStore.instance.tambahBarangAsync(newBarang);
      }
    }
  }

  void selesaikanKonsinyasi(String id, int sisaRetur) {
    final idx = _list.indexWhere((item) => item.id == id);
    if (idx != -1) {
      _list[idx].sisaRetur = sisaRetur;
      _list[idx].sudahDisetorKePenitip = true;
      _list[idx].statusBayar = StatusBayarPasokan.lunas;
    }
  }

  void tandaiFakturLunas(String id) {
    final idx = _list.indexWhere((item) => item.id == id);
    if (idx != -1) {
      _list[idx].statusBayar = StatusBayarPasokan.lunas;
    }
  }
}
