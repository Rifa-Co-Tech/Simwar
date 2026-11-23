/// SIMWAR — Model & Perhitungan Analisis Penjualan & Laba per Barang
/// Figma nodes: 2030:75 (Laporan Penjualan), 2053:94 (Laba per Barang), 2055:211 (Rekap Keuangan)

class ItemLabaAnalisis {
  final String id;
  final String nama;
  final String kategori;
  final int hargaBeli;
  final int hargaJual;
  final int terjual;
  final int sisaStok;

  ItemLabaAnalisis({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.hargaBeli,
    required this.hargaJual,
    required this.terjual,
    required this.sisaStok,
  });

  int get labaPerUnit => (hargaJual - hargaBeli).clamp(0, 999999999);

  double get marginPersen => hargaJual > 0 ? (labaPerUnit / hargaJual) * 100 : 0.0;

  int get totalOmset => hargaJual * terjual;

  int get totalLaba => labaPerUnit * terjual;

  String get badgeStatus {
    if (totalLaba >= 100000 && terjual >= 50) return '⭐ Bintang Warung';
    if (marginPersen >= 30) return '🔥 Margin Tinggi';
    if (terjual >= 80) return '⚡ Paling Laris';
    return 'Reguler';
  }
}

class LaporanService {
  static final LaporanService instance = LaporanService._internal();
  factory LaporanService() => instance;
  LaporanService._internal();

  // Data historis performa penjualan per barang untuk simulasi akurat
  final List<ItemLabaAnalisis> _produkList = [
    ItemLabaAnalisis(
      id: '1',
      nama: 'Indomie Goreng Spesial',
      kategori: 'Makanan',
      hargaBeli: 2800,
      hargaJual: 3500,
      terjual: 148,
      sisaStok: 46,
    ),
    ItemLabaAnalisis(
      id: '2',
      nama: 'Minyak Goreng SunCo 2L',
      kategori: 'Sembako',
      hargaBeli: 34000,
      hargaJual: 38000,
      terjual: 32,
      sisaStok: 8,
    ),
    ItemLabaAnalisis(
      id: '3',
      nama: 'Beras Ramos Super 5kg',
      kategori: 'Sembako',
      hargaBeli: 68000,
      hargaJual: 75000,
      terjual: 24,
      sisaStok: 5,
    ),
    ItemLabaAnalisis(
      id: '4',
      nama: 'Teh Botol Sosro 450ml',
      kategori: 'Minuman',
      hargaBeli: 3500,
      hargaJual: 5000,
      terjual: 96,
      sisaStok: 18,
    ),
    ItemLabaAnalisis(
      id: '5',
      nama: 'Telur Ayam Ras 1kg',
      kategori: 'Sembako',
      hargaBeli: 25000,
      hargaJual: 28000,
      terjual: 45,
      sisaStok: 12,
    ),
    ItemLabaAnalisis(
      id: '6',
      nama: 'Kopi Kapal Api Special Mix',
      kategori: 'Minuman',
      hargaBeli: 1200,
      hargaJual: 2000,
      terjual: 165,
      sisaStok: 30,
    ),
    ItemLabaAnalisis(
      id: '7',
      nama: 'Gula Pasir Gulaku 1kg',
      kategori: 'Sembako',
      hargaBeli: 15500,
      hargaJual: 17500,
      terjual: 50,
      sisaStok: 14,
    ),
    ItemLabaAnalisis(
      id: '8',
      nama: 'Sabun Lifebuoy Total 10',
      kategori: 'Alat mandi',
      hargaBeli: 3200,
      hargaJual: 4500,
      terjual: 42,
      sisaStok: 16,
    ),
  ];

  List<ItemLabaAnalisis> get semuaProduk => List.unmodifiable(_produkList);

  int get totalOmsetKeseluruhan =>
      _produkList.fold(0, (sum, p) => sum + p.totalOmset);

  int get totalLabaKeseluruhan =>
      _produkList.fold(0, (sum, p) => sum + p.totalLaba);

  int get totalBarangTerjual =>
      _produkList.fold(0, (sum, p) => sum + p.terjual);

  // Data 7 Hari Terakhir untuk grafik batang
  List<Map<String, dynamic>> get dataGrafikMingguan => [
        {'hari': 'Sen', 'omset': 980000, 'laba': 245000},
        {'hari': 'Sel', 'omset': 1120000, 'laba': 290000},
        {'hari': 'Rab', 'omset': 1050000, 'laba': 270000},
        {'hari': 'Kam', 'omset': 1280000, 'laba': 340000},
        {'hari': 'Jum', 'omset': 1420000, 'laba': 380000},
        {'hari': 'Sab', 'omset': 1850000, 'laba': 495000}, // Puncak akhir pekan
        {'hari': 'Min', 'omset': 1650000, 'laba': 430000},
      ];
}
