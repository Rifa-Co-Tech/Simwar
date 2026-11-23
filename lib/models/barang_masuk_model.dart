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

  final List<BarangMasukModel> _list = [
    BarangMasukModel(
      id: 'BM-20261122-01',
      tanggal: DateTime.now().subtract(const Duration(hours: 3)),
      jenis: JenisBarangMasuk.titipan,
      namaPemasok: 'Bu Siti (Kue Basah & Jajanan)',
      noFaktur: '0812-9876-1122',
      items: [
        BarangMasukItem(
          barangId: 't1',
          namaBarang: 'Risoles Mayo Daging',
          jumlah: 20,
          satuan: 'pcs',
          hargaBeli: 2500, // Harga setor
          hargaJual: 3000, // Harga jual warung
        ),
        BarangMasukItem(
          barangId: 't2',
          namaBarang: 'Pastel Sayur Telur',
          jumlah: 20,
          satuan: 'pcs',
          hargaBeli: 2000,
          hargaJual: 2500,
        ),
      ],
      totalNilai: 90000,
      statusBayar: StatusBayarPasokan.konsinyasi,
      catatan: 'Titipan pagi hari, dicek jam 17.00',
      dicatatOleh: 'Rina (Penjaga)',
      sisaRetur: 4,
      sudahDisetorKePenitip: false,
    ),
    BarangMasukModel(
      id: 'BM-20261121-02',
      tanggal: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      jenis: JenisBarangMasuk.distributor,
      namaPemasok: 'PT Indomarco Adi Prima',
      noFaktur: 'INV-IND-88319',
      items: [
        BarangMasukItem(
          barangId: '1',
          namaBarang: 'Indomie Goreng Spesial',
          jumlah: 80,
          satuan: 'pcs (2 dus)',
          hargaBeli: 2800,
          hargaJual: 3500,
        ),
        BarangMasukItem(
          barangId: '2',
          namaBarang: 'Minyak Goreng SunCo 2L',
          jumlah: 12,
          satuan: 'pouch (2 karton)',
          hargaBeli: 34000,
          hargaJual: 38000,
        ),
      ],
      totalNilai: 632000,
      statusBayar: StatusBayarPasokan.lunas,
      catatan: 'Faktur lunas dibayar tunai ke sales',
      dicatatOleh: 'Pemilik',
    ),
    BarangMasukModel(
      id: 'BM-20261120-03',
      tanggal: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
      jenis: JenisBarangMasuk.distributor,
      namaPemasok: 'Grosir Beras Berkah Utama',
      noFaktur: 'SJ-BB-4401',
      items: [
        BarangMasukItem(
          barangId: '3',
          namaBarang: 'Beras Rojolele Super 5kg',
          jumlah: 10,
          satuan: 'karung',
          hargaBeli: 68000,
          hargaJual: 75000,
        ),
      ],
      totalNilai: 680000,
      statusBayar: StatusBayarPasokan.tempo,
      jatuhTempo: DateTime.now().add(const Duration(days: 7)),
      catatan: 'Tempo 7 hari, jatuh tempo minggu depan',
      dicatatOleh: 'Pemilik',
    ),
    BarangMasukModel(
      id: 'BM-20261119-04',
      tanggal: DateTime.now().subtract(const Duration(days: 3)),
      jenis: JenisBarangMasuk.titipan,
      namaPemasok: 'Bu Tejo (Camilan Tradisional)',
      noFaktur: '0857-4321-9988',
      items: [
        BarangMasukItem(
          barangId: 't3',
          namaBarang: 'Rempeyek Kacang Gurih',
          jumlah: 25,
          satuan: 'bungkus',
          hargaBeli: 4000,
          hargaJual: 5000,
        ),
      ],
      totalNilai: 100000,
      statusBayar: StatusBayarPasokan.lunas,
      catatan: 'Sudah direkap & disetor penuh ke Bu Tejo',
      dicatatOleh: 'Pemilik',
      sisaRetur: 2,
      sudahDisetorKePenitip: true,
    ),
  ];

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
