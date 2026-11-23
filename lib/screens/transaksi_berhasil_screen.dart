import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/item_keranjang.dart';
import '../models/pengguna_model.dart';
import '../utils/formatters.dart';
import 'home_screen.dart';

/// SIMWAR — Kasir: Transaksi Berhasil (Figma node 2030:36)
class TransaksiBerhasilScreen extends StatelessWidget {
  final List<ItemKeranjang> items;
  final int totalTagihan;
  final int uangDiterima;
  final int kembalian;
  final String metodePembayaran; // 'Tunai' | 'QRIS'
  final PenggunaModel? pengguna;

  const TransaksiBerhasilScreen({
    super.key,
    required this.items,
    required this.totalTagihan,
    required this.uangDiterima,
    required this.kembalian,
    this.metodePembayaran = 'Tunai',
    this.pengguna,
  });

  static const Color _bgLayar = Color(0xFFF4EFE0);
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _abuTeks = Color(0xFF6E7468);
  static const Color _borderGaris = Color(0xFFE4DCC3);
  static const Color _borderInput = Color(0xFFCFC7AA);
  static const Color _kuningAksen = Color(0xFFF8B62B);

  String _formatRupiah(int nominal) {
    return SimwarFormatter.rupiah(nominal);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final tglStr = SimwarFormatter.tanggal(now);

    return Scaffold(
      backgroundColor: _bgLayar,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),

                  // ── 1. Icon Centang Berhasil (Figma 120x120 & 96x96) ───
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _kuningAksen.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            color: _hijauAksi,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/ikon-check-48x48-FFFFFF.svg',
                              width: 48,
                              height: 48,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── 2. Teks Berhasil & Nominal ─────────────────────────
                  Text(
                    'Pembayaran berhasil',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _hijauTua,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatRupiah(totalTagihan),
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: _hijauAksi,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$metodePembayaran · $tglStr',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _abuTeks,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // ── 3. Kartu Struk Rincian Belanja (Figma 342x248) ─────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: _borderGaris, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: _hijauTua.withValues(alpha: 0.10),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Rincian per Barang
                        ...items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.nama} ×${item.jumlah}',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: _hijauTua,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  _formatRupiah(item.subtotal),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _hijauTua,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // Garis Putus-putus Pemisah
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: CustomPaint(
                            size: const Size(double.infinity, 1.5),
                            painter: _DashedLinePainter(color: _borderInput),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _hijauTua,
                              ),
                            ),
                            Text(
                              _formatRupiah(totalTagihan),
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _hijauTua,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Tunai Diterima / Metode
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              metodePembayaran == 'Tunai'
                                  ? 'Tunai diterima'
                                  : 'Metode',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: _abuTeks,
                              ),
                            ),
                            Text(
                              metodePembayaran == 'Tunai'
                                  ? _formatRupiah(uangDiterima)
                                  : 'QRIS Otomatis',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _hijauTua,
                              ),
                            ),
                          ],
                        ),

                        // Kembalian (Hanya jika tunai)
                        if (metodePembayaran == 'Tunai') ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Kembalian',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _hijauAksi,
                                ),
                              ),
                              Text(
                                _formatRupiah(kembalian),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _hijauAksi,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── 4. Tombol "Transaksi baru" (Primary) ───────────────
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Kembali ke layar Kasir baru
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hijauAksi,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'Transaksi baru',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── 5. Tombol "Lihat riwayat" (Secondary) ──────────────
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        // Kembali ke Beranda
                        if (pengguna != null) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HomeScreen(pengguna: pengguna!),
                            ),
                            (route) => false,
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _borderInput, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'Kembali ke Beranda',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _hijauTua,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
