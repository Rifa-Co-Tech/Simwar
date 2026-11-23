import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/analisis_laba_model.dart';
import '../models/barang_masuk_model.dart';
import '../models/pengguna_model.dart';
import '../services/excel_export_service.dart';
import '../utils/formatters.dart';
import 'kelola_titipan_screen.dart';
import 'laba_per_barang_screen.dart';

/// SIMWAR — Laporan Penjualan & Rekap Keuangan Warung
/// Figma nodes: 2030:75 & 2055:211
class LaporanPenjualanScreen extends StatefulWidget {
  final PenggunaModel? pengguna;
  const LaporanPenjualanScreen({super.key, this.pengguna});

  @override
  State<LaporanPenjualanScreen> createState() => _LaporanPenjualanScreenState();
}

class _LaporanPenjualanScreenState extends State<LaporanPenjualanScreen> {
  // Palet Warna SIMWAR
  static const Color _bgLayar = Color(0xFFF4EFE0);
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _hijauMuda = Color(0xFFE3EFE8);
  static const Color _abuTeks = Color(0xFF6E7468);
  static const Color _borderGaris = Color(0xFFE4DCC3);
  static const Color _borderInput = Color(0xFFCFC7AA);
  static const Color _kuningAksen = Color(0xFFF8B62B);
  static const Color _merahAksen = Color(0xFFC8401E);

  String _periodeDipilih = '7 Hari'; // 'Hari Ini' | '7 Hari' | 'Bulan Ini' | 'Semua'

  int get totalOmset => LaporanService.instance.getOmsetByPeriode(_periodeDipilih);
  int get totalLaba => LaporanService.instance.getLabaByPeriode(_periodeDipilih);
  int get totalTrx => LaporanService.instance.getTransaksiCountByPeriode(_periodeDipilih);

  @override
  Widget build(BuildContext context) {
    final service = LaporanService.instance;
    final avgTrx = totalTrx > 0 ? (totalOmset / totalTrx).round() : 0;
    final paymentStats = service.getMetodeBayarStats(_periodeDipilih);
    final tunaiStat = paymentStats[0];
    final qrisStat = paymentStats[1];
    final kasbonStat = paymentStats[2];

    final mingguanData = service.dataGrafikMingguan;
    String peakDayText = 'Belum ada data';
    int maxOmset = 0;
    for (var d in mingguanData) {
      final o = d['omset'] as int;
      if (o > maxOmset) {
        maxOmset = o;
        peakDayText = 'Puncak: ${d['hari']} (${SimwarFormatter.rupiah(o)})';
      }
    }

    return Scaffold(
      backgroundColor: _bgLayar,
      appBar: AppBar(
        backgroundColor: _bgLayar,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _hijauTua, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Laporan Penjualan',
          style: GoogleFonts.inter(
            color: _hijauTua,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: _hijauTua),
            onPressed: _showUnduhLaporanDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Selector Periode
            _buildPeriodeSelector(),
            const SizedBox(height: 16),

            // 2. Metrik Utama (Grid 2x2)
            Row(
              children: [
                Expanded(
                  child: _buildMetricBox(
                    label: 'Total Omset',
                    value: SimwarFormatter.rupiah(totalOmset),
                    subtitle: 'Periode $_periodeDipilih',
                    color: _hijauTua,
                    icon: Icons.storefront_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricBox(
                    label: 'Laba Bersih',
                    value: SimwarFormatter.rupiah(totalLaba),
                    subtitle: totalOmset > 0
                        ? 'Margin ~${((totalLaba / totalOmset) * 100).toStringAsFixed(0)}%'
                        : 'Margin 0%',
                    color: _hijauAksi,
                    icon: Icons.trending_up,
                    highlight: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricBox(
                    label: 'Transaksi Selesai',
                    value: '$totalTrx Transaksi',
                    subtitle: 'Kasir & Kasbon',
                    color: const Color(0xFF1E3A8A),
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricBox(
                    label: 'Rata-rata Belanja',
                    value: SimwarFormatter.rupiah(avgTrx),
                    subtitle: 'Per struk belanja',
                    color: const Color(0xFFD97706),
                    icon: Icons.shopping_basket_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Grafik Penjualan Mingguan
            _buildCardWrapper(
              title: 'Tren Penjualan 7 Hari Terakhir',
              trailing: Text(
                peakDayText,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _hijauAksi,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildBarChart(mingguanData),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendDot(_hijauAksi, 'Omset Penjualan'),
                      const SizedBox(width: 20),
                      _buildLegendDot(_kuningAksen, 'Laba Bersih'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Komposisi Metode Pembayaran
            _buildCardWrapper(
              title: 'Metode Pembayaran',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Visual Multi-Color Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 16,
                      child: totalOmset > 0
                          ? Row(
                              children: [
                                if (tunaiStat.persen > 0)
                                  Expanded(
                                    flex: (tunaiStat.persen * 10).round().clamp(1, 1000),
                                    child: const ColoredBox(color: _hijauAksi),
                                  ),
                                if (qrisStat.persen > 0)
                                  Expanded(
                                    flex: (qrisStat.persen * 10).round().clamp(1, 1000),
                                    child: const ColoredBox(color: Color(0xFF0284C7)),
                                  ),
                                if (kasbonStat.persen > 0)
                                  Expanded(
                                    flex: (kasbonStat.persen * 10).round().clamp(1, 1000),
                                    child: const ColoredBox(color: Color(0xFFD97706)),
                                  ),
                              ],
                            )
                          : Container(color: _borderGaris),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Detail Angka & Persentase Dinamis
                  _buildPaymentRow(
                    'Tunai',
                    '${tunaiStat.persen.toStringAsFixed(0)}%',
                    SimwarFormatter.rupiah(tunaiStat.totalNominal),
                    _hijauAksi,
                  ),
                  const Divider(color: _borderGaris, height: 16),
                  _buildPaymentRow(
                    'QRIS Dinamis',
                    '${qrisStat.persen.toStringAsFixed(0)}%',
                    SimwarFormatter.rupiah(qrisStat.totalNominal),
                    const Color(0xFF0284C7),
                  ),
                  const Divider(color: _borderGaris, height: 16),
                  _buildPaymentRow(
                    'Kasbon Pelanggan',
                    '${kasbonStat.persen.toStringAsFixed(0)}%',
                    SimwarFormatter.rupiah(kasbonStat.totalNominal),
                    const Color(0xFFD97706),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 5. Shortcut ke Laba per Barang
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _hijauMuda,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _borderGaris),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _hijauAksi,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.auto_graph, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analisis Laba per Barang',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _hijauTua,
                          ),
                        ),
                        Text(
                          'Ketahui barang mana yang memberi untung terbesar',
                          style: GoogleFonts.inter(fontSize: 11, color: _abuTeks),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LabaPerBarangScreen(pengguna: widget.pengguna),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: _hijauAksi,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: const Text('Lihat Detail →', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 5b. Rekap Barang Titipan Warga (Konsinyasi)
            _buildRekapTitipanCard(),
            const SizedBox(height: 20),

            // 6. Tombol Ekspor Laporan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _showUnduhLaporanDialog,
                icon: const Icon(Icons.download_outlined, color: _hijauTua),
                label: Text(
                  'Unduh Rekap Laporan Warung',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: _hijauTua,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _borderInput, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodeSelector() {
    final list = ['Hari Ini', '7 Hari', 'Bulan Ini', 'Semua'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE4DCC3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: list.map((p) {
          final isSelected = _periodeDipilih == p;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _periodeDipilih = p),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _hijauTua : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    p,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : _hijauTua,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricBox({
    required String label,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: highlight ? _hijauAksi.withValues(alpha: 0.5) : _borderGaris),
        boxShadow: [
          BoxShadow(
            color: _hijauTua.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 11, color: _abuTeks)),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 10, color: _abuTeks),
          ),
        ],
      ),
    );
  }

  Widget _buildCardWrapper({required String title, required Widget child, Widget? trailing}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderGaris),
        boxShadow: [
          BoxShadow(
            color: _hijauTua.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _hijauTua,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> data) {
    int maxOmsetInWeek = 0;
    for (var d in data) {
      final o = (d['omset'] as int?) ?? 0;
      if (o > maxOmsetInWeek) maxOmsetInWeek = o;
    }
    final double maxVal = maxOmsetInWeek > 0 ? maxOmsetInWeek.toDouble() : 100000;

    return SizedBox(
      height: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((d) {
          final int omset = (d['omset'] as int?) ?? 0;
          final double ratio = maxOmsetInWeek > 0 ? (omset / maxVal).clamp(0.06, 1.0) : 0.06;
          final bool isMax = maxOmsetInWeek > 0 && omset == maxOmsetInWeek;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                omset > 0 ? '${((omset) / 1000).round()}k' : '0',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: isMax ? FontWeight.bold : FontWeight.normal,
                  color: isMax ? _hijauAksi : _abuTeks,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 24,
                height: 85 * ratio,
                decoration: BoxDecoration(
                  color: isMax ? _hijauAksi : (omset > 0 ? const Color(0xFF68B28B) : _hijauMuda),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                d['hari'] as String,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isMax ? FontWeight.bold : FontWeight.w500,
                  color: isMax ? _hijauTua : _abuTeks,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: _abuTeks)),
      ],
    );
  }

  Widget _buildPaymentRow(String metode, String persen, String nominal, Color dotColor) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(metode, style: GoogleFonts.inter(fontSize: 13, color: _hijauTua, fontWeight: FontWeight.w600)),
        ),
        Text(persen, style: GoogleFonts.inter(fontSize: 12, color: _abuTeks)),
        const SizedBox(width: 14),
        Text(nominal, style: GoogleFonts.inter(fontSize: 13, color: _hijauTua, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRekapTitipanCard() {
    final titipanList = BarangMasukStore.instance.titipanOnly;
    int totalMasuk = 0;
    int totalNilaiSetor = 0;
    for (var t in titipanList) {
      for (var it in t.items) {
        totalMasuk += it.jumlah;
        totalNilaiSetor += it.subtotal;
      }
    }
    // Estimasi margin titipan rata-rata 20%
    final int estimasiUntungWarung = (totalNilaiSetor * 0.20).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderGaris),
        boxShadow: [
          BoxShadow(
            color: _hijauTua.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF6EA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.handshake_outlined, color: Color(0xFFD97706), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Rekap Titipan Warga',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _hijauTua,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF6EA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${titipanList.length} Penitip · $totalMasuk pcs',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFD97706)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Ringkasan Keuangan Titipan (Hak Penitip vs Untung Warung)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _bgLayar,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hak Setor ke Penitip', style: GoogleFonts.inter(fontSize: 11, color: _abuTeks)),
                      const SizedBox(height: 2),
                      Text(
                        SimwarFormatter.rupiah(totalNilaiSetor),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _hijauTua,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 32, color: _borderGaris),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Untung Warung (Bagi Hasil)', style: GoogleFonts.inter(fontSize: 11, color: _abuTeks)),
                      const SizedBox(height: 2),
                      Text(
                        SimwarFormatter.rupiah(estimasiUntungWarung),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _hijauAksi,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Daftar Item Titipan Aktif
          ...titipanList.take(3).map((t) {
            final itemTitle = t.items.map((i) => '${i.namaBarang} (${i.jumlah} pcs)').join(', ');
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 14, color: _hijauAksi),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${t.namaPemasok}: $itemTitle',
                      style: GoogleFonts.inter(fontSize: 12, color: _hijauTua, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KelolaTitipanScreen(pengguna: widget.pengguna),
                  ),
                );
              },
              child: Text(
                'Kelola & Setor Titipan Warga →',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _hijauAksi,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUnduhLaporanDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Unduh Laporan Warung',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _hijauTua),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih format file laporan untuk pembukuan warung:',
              style: GoogleFonts.inter(fontSize: 13, color: _abuTeks),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.picture_as_pdf, color: _merahAksen, size: 30),
              title: const Text('Dokumen PDF (Siap Cetak / Bagikan)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('Lengkap dengan grafik dan ringkasan laba rugi', style: TextStyle(fontSize: 11)),
              onTap: () {
                Navigator.pop(ctx);
                _showSuccessDownload('Laporan_SIMWAR_Warung_Azzam.pdf');
              },
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.table_chart, color: _hijauAksi, size: 30),
              title: const Text('File Spreadsheet Excel (.xlsx)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('Rincian item per transaksi untuk kalkulasi lanjutan', style: TextStyle(fontSize: 11)),
              onTap: () async {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menyiapkan dan membuka berkas Excel (.xlsx)...'),
                    backgroundColor: _hijauTua,
                    duration: Duration(seconds: 1),
                  ),
                );
                final file = await ExcelExportService.eksporLaporanKeExcel(
                  totalOmset: totalOmset,
                  totalLaba: totalLaba,
                  totalTransaksi: totalTrx,
                  periode: _periodeDipilih,
                );
                if (file != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Laporan Excel berhasil dibagikan & disimpan!'),
                      backgroundColor: _hijauAksi,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: _abuTeks)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDownload(String namaFile) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File $namaFile berhasil diunduh!'),
        backgroundColor: _hijauAksi,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
