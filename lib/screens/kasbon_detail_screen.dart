import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/kasbon_model.dart';
import '../models/pengguna_model.dart';
import '../utils/formatters.dart';
import 'bayar_kasbon_screen.dart';

/// SIMWAR — Detail Kasbon Pelanggan (Pemilik & Penjaga)
/// Figma node: 2055:110 (Pemilik) & 2073:3051 (Penjaga)
class KasbonDetailScreen extends StatefulWidget {
  final PelangganKasbonModel pelanggan;
  final PenggunaModel? pengguna;

  const KasbonDetailScreen({
    super.key,
    required this.pelanggan,
    this.pengguna,
  });

  @override
  State<KasbonDetailScreen> createState() => _KasbonDetailScreenState();
}

class _KasbonDetailScreenState extends State<KasbonDetailScreen> {
  static const Color _bgLayar = Color(0xFFF4EFE0);
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _abuTeks = Color(0xFF6E7468);
  static const Color _borderGaris = Color(0xFFE4DCC3);
  static const Color _kuningAksen = Color(0xFFF8B62B);

  @override
  Widget build(BuildContext context) {
    final p = widget.pelanggan;

    return Scaffold(
      backgroundColor: _bgLayar,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Top Bar ──────────────────────────────────────────────
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _borderGaris),
                          ),
                          child: const Center(
                            child: Icon(Icons.arrow_back_ios_new, size: 18, color: _hijauTua),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Header Title & Subtitle ──────────────────────────────
                  Text(
                    p.nama,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _hijauTua,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kasbon sejak ${p.sejak}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _abuTeks,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Hero Card Sisa Utang ─────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _hijauTua,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sisa utang',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFB9CFC4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          SimwarFormatter.rupiah(p.totalUtang),
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: _kuningAksen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Section Riwayat ──────────────────────────────────────
                  Text(
                    'Riwayat',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _hijauTua,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _borderGaris, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF14382E).withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: p.riwayat.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(28),
                            child: Center(
                              child: Text(
                                'Belum ada riwayat transaksi kasbon',
                                style: GoogleFonts.inter(fontSize: 13, color: _abuTeks),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: p.riwayat.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, thickness: 1, color: Color(0xFFE8E3D1)),
                            itemBuilder: (ctx, idx) {
                              final item = p.riwayat[idx];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.judul,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: _hijauTua,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.tanggal,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: _abuTeks,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      item.isBayar
                                          ? '− ${SimwarFormatter.rupiah(item.nominal)}'
                                          : '+ ${SimwarFormatter.rupiah(item.nominal)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: item.isBayar ? _hijauAksi : _hijauTua,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 32),

                  // ── Tombol Catat Pembayaran ──────────────────────────────
                  if (p.totalUtang > 0) ...[
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BayarKasbonScreen(
                                pelanggan: p,
                                pengguna: widget.pengguna,
                              ),
                            ),
                          ).then((_) => setState(() {}));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hijauAksi,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: Text(
                          'Catat pembayaran',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
