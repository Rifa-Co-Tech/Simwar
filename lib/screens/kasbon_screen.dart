import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/kasbon_model.dart';
import '../models/pengguna_model.dart';
import '../utils/formatters.dart';
import 'catat_kasbon_screen.dart';
import 'kasbon_detail_screen.dart';

/// SIMWAR — Modul Kasbon Warung: Daftar Pelanggan (Pemilik & Penjaga)
/// Figma node: 2055:2 (Pemilik) & 2073:2972 (Penjaga)
class KasbonScreen extends StatefulWidget {
  final PenggunaModel? pengguna;
  const KasbonScreen({super.key, this.pengguna});

  @override
  State<KasbonScreen> createState() => _KasbonScreenState();
}

class _KasbonScreenState extends State<KasbonScreen> {
  static const Color _bgLayar = Color(0xFFF4EFE0);
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _abuTeks = Color(0xFF6E7468);
  static const Color _borderGaris = Color(0xFFE4DCC3);
  static const Color _kuningAksen = Color(0xFFF8B62B);

  List<PelangganKasbonModel> get _daftarPelanggan => KasbonStore.instance.semua;
  int get _totalSemuaUtang => KasbonStore.instance.totalSemuaUtang;

  @override
  Widget build(BuildContext context) {
    final list = _daftarPelanggan;

    return Scaffold(
      backgroundColor: _bgLayar,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
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
                    'Kasbon',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _hijauTua,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Utang pelanggan warung',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _abuTeks,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Hero Card: Total Belum Dibayar ───────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _hijauTua,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total belum dibayar',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFB9CFC4),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              SimwarFormatter.rupiah(_totalSemuaUtang),
                              style: GoogleFonts.inter(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: _kuningAksen,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Text(
                              '${list.length} pelanggan',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Section: Belum Lunas ─────────────────────────────────
                  Text(
                    'Belum lunas',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _hijauTua,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Kartu Daftar Pelanggan Kasbon ─────────────────────────
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
                    child: list.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'Belum ada catatan kasbon pelanggan.\nKlik "+ Catat kasbon" di atas untuk menambahkan.',
                                style: GoogleFonts.inter(fontSize: 13, color: _abuTeks, height: 1.5),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE8E3D1)),
                      itemBuilder: (ctx, idx) {
                        final p = list[idx];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => KasbonDetailScreen(
                                  pelanggan: p,
                                  pengguna: widget.pengguna,
                                ),
                              ),
                            ).then((_) => setState(() {}));
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.nama,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: _hijauTua,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Sejak ${p.sejak} · ${p.jumlahTransaksi} transaksi',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: _abuTeks,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  SimwarFormatter.rupiah(p.totalUtang),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _hijauTua,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Tombol + Catat Kasbon Baru ────────────────────────────
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CatatKasbonScreen(pengguna: widget.pengguna),
                          ),
                        ).then((_) => setState(() {}));
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
                        '+ Catat kasbon baru',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
