import 'barang_model.dart';
import 'transaksi_model.dart';

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

  double get marginPersen =>
      hargaJual > 0 ? (labaPerUnit / hargaJual) * 100 : 0.0;

  int get totalOmset => hargaJual * terjual;

  int get totalLaba => labaPerUnit * terjual;

  String get badgeStatus {
    if (totalLaba >= 100000 && terjual >= 50) return '⭐ Bintang Warung';
    if (marginPersen >= 30) return '🔥 Margin Tinggi';
    if (terjual >= 80) return '⚡ Paling Laris';
    if (terjual > 0) return 'Terjual';
    return 'Belum Ada Penjualan';
  }
}

class MetodeBayarStat {
  final String metode;
  final int totalNominal;
  final double persen;
  final int jumlahTransaksi;

  MetodeBayarStat({
    required this.metode,
    required this.totalNominal,
    required this.persen,
    required this.jumlahTransaksi,
  });
}

class LaporanService {
  static final LaporanService instance = LaporanService._internal();
  factory LaporanService() => instance;
  LaporanService._internal();

  /// Mengambil transaksi selesai sesuai filter periode
  List<TransaksiModel> getTransaksiByPeriode(String periode) {
    final trxs = TransaksiStore.instance.semua
        .where((t) => t.status == 'Selesai');

    if (periode == 'Hari Ini') {
      return trxs.where((t) => t.isHariIni).toList();
    } else if (periode == '7 Hari') {
      return trxs.where((t) => t.is7HariTerakhir).toList();
    } else if (periode == 'Bulan Ini') {
      return trxs.where((t) => t.isBulanIni).toList();
    }
    return trxs.toList();
  }

  int getOmsetByPeriode(String periode) {
    return getTransaksiByPeriode(periode)
        .fold(0, (sum, t) => sum + t.total);
  }

  int getLabaByPeriode(String periode) {
    return getTransaksiByPeriode(periode)
        .fold(0, (sum, t) => sum + t.hitungLaba());
  }

  int getTransaksiCountByPeriode(String periode) {
    return getTransaksiByPeriode(periode).length;
  }

  int getBarangTerjualCountByPeriode(String periode) {
    return getTransaksiByPeriode(periode).fold(
        0, (sum, t) => sum + t.items.fold(0, (s, i) => s + i.jumlah));
  }

  int get totalOmsetKeseluruhan =>
      getOmsetByPeriode('Semua');

  int get totalLabaKeseluruhan =>
      getLabaByPeriode('Semua');

  int get totalBarangTerjual =>
      getBarangTerjualCountByPeriode('Semua');

  /// Breakdown metode pembayaran dinamis (Tunai, QRIS, Kasbon)
  List<MetodeBayarStat> getMetodeBayarStats(String periode) {
    final trxs = getTransaksiByPeriode(periode);
    int totalNominalSemua = trxs.fold(0, (sum, t) => sum + t.total);

    int tunaiNominal = 0;
    int tunaiCount = 0;
    int qrisNominal = 0;
    int qrisCount = 0;
    int kasbonNominal = 0;
    int kasbonCount = 0;

    for (var t in trxs) {
      if (t.metode == 'Tunai') {
        tunaiNominal += t.total;
        tunaiCount++;
      } else if (t.metode == 'QRIS') {
        qrisNominal += t.total;
        qrisCount++;
      } else if (t.metode == 'Kasbon') {
        kasbonNominal += t.total;
        kasbonCount++;
      }
    }

    final double totalF = totalNominalSemua > 0 ? totalNominalSemua.toDouble() : 1.0;

    return [
      MetodeBayarStat(
        metode: 'Tunai',
        totalNominal: tunaiNominal,
        persen: totalNominalSemua > 0 ? (tunaiNominal / totalF) * 100 : 0.0,
        jumlahTransaksi: tunaiCount,
      ),
      MetodeBayarStat(
        metode: 'QRIS Dinamis',
        totalNominal: qrisNominal,
        persen: totalNominalSemua > 0 ? (qrisNominal / totalF) * 100 : 0.0,
        jumlahTransaksi: qrisCount,
      ),
      MetodeBayarStat(
        metode: 'Kasbon Pelanggan',
        totalNominal: kasbonNominal,
        persen: totalNominalSemua > 0 ? (kasbonNominal / totalF) * 100 : 0.0,
        jumlahTransaksi: kasbonCount,
      ),
    ];
  }

  /// Data 7 Hari Terakhir Dinamis (berdasarkan tanggal kalender saat ini)
  List<Map<String, dynamic>> getDataGrafikMingguan() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> hasil = [];
    const namaHari = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = namaHari[date.weekday % 7];
      final labelTanggal = '${date.day}/${date.month}';

      final trxsOnDate = TransaksiStore.instance.semua.where((t) =>
          t.status == 'Selesai' &&
          t.createdAt.year == date.year &&
          t.createdAt.month == date.month &&
          t.createdAt.day == date.day);

      final omset = trxsOnDate.fold(0, (sum, t) => sum + t.total);
      final laba = trxsOnDate.fold(0, (sum, t) => sum + t.hitungLaba());

      hasil.add({
        'hari': dayName,
        'label': labelTanggal,
        'omset': omset,
        'laba': laba,
      });
    }
    return hasil;
  }

  /// Menjaga kompatibilitas dengan getter lama
  List<Map<String, dynamic>> get dataGrafikMingguan => getDataGrafikMingguan();

  /// Analisis performa penjualan seluruh produk dari transaksi nyata
  List<ItemLabaAnalisis> getProdukAnalisisByPeriode(String periode) {
    final trxs = getTransaksiByPeriode(periode);
    final Map<String, int> qtyTerjualMap = {};

    for (var t in trxs) {
      for (var item in t.items) {
        final key = item.nama.trim().toLowerCase();
        qtyTerjualMap[key] = (qtyTerjualMap[key] ?? 0) + item.jumlah;
      }
    }

    final List<ItemLabaAnalisis> hasil = [];
    for (var b in BarangStore.instance.semua) {
      final terjual = qtyTerjualMap[b.nama.trim().toLowerCase()] ?? 0;
      hasil.add(ItemLabaAnalisis(
        id: b.id,
        nama: b.nama,
        kategori: b.kategori,
        hargaBeli: b.hargaBeli,
        hargaJual: b.hargaJual,
        terjual: terjual,
        sisaStok: b.stok,
      ));
    }

    // Urutkan dari produk paling laris / terjual terbanyak
    hasil.sort((a, b) => b.terjual.compareTo(a.terjual));
    return hasil;
  }

  /// Kompatibilitas dengan properti lama
  List<ItemLabaAnalisis> get semuaProduk =>
      getProdukAnalisisByPeriode('Semua');
}
