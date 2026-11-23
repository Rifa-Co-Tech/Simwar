import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/laporan_model.dart';
import '../models/pengguna_model.dart';
import 'detail_laporan_screen.dart';
import 'lapor_ke_pemilik_screen.dart';

/// SIMWAR — Laporan Saya (POV Penjaga)
/// Figma node: 2073:4093
class LaporanSayaScreen extends StatefulWidget {
  final PenggunaModel? pengguna;
  const LaporanSayaScreen({super.key, this.pengguna});

  @override
  State<LaporanSayaScreen> createState() => _LaporanSayaScreenState();
}

class _LaporanSayaScreenState extends State<LaporanSayaScreen> {
  static const Color _bgLayar = Color(0xFFF4EFE0);
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _hijauMuda = Color(0xFFE3EFE8);
  static const Color _abuTeks = Color(0xFF6E7468);
  static const Color _borderGaris = Color(0xFFE4DCC3);
  static const Color _borderInput = Color(0xFFCFC7AA);
  static const Color _kuningAksen = Color(0xFFF8B62B);

  String _filterAktif = 'Semua'; // 'Semua' | 'Menunggu' | 'Selesai'

  List<LaporanModel> get _daftarLaporan {
    final semua = LaporanStore.instance.semua;
    if (_filterAktif == 'Menunggu') {
      return semua.where((l) => l.isBaru || l.isDibalas).toList();
    }
    if (_filterAktif == 'Selesai') {
      return semua.where((l) => l.isSelesai).toList();
    }
    return semua;
  }

  @override
  Widget build(BuildContext context) {
    final list = _daftarLaporan;

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
                    'Laporan saya',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _hijauTua,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Semua laporan yang kamu kirim',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _abuTeks,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Filter Chips: Semua | Menunggu | Selesai ─────────────
                  Row(
                    children: ['Semua', 'Menunggu', 'Selesai'].map((tab) {
                      final bool isSelected = _filterAktif == tab;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _filterAktif = tab),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? _hijauAksi : Colors.white,
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(
                                color: isSelected ? _hijauAksi : _borderInput,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              tab,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : _hijauTua,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // ── Daftar Kartu Laporan ─────────────────────────────────
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
                                'Belum ada laporan di kategori ini',
                                style: GoogleFonts.inter(fontSize: 13, color: _abuTeks),
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
                              final lap = list[idx];
                              return _buildLaporanItem(lap);
                            },
                          ),
                  ),
                  const SizedBox(height: 28),

                  // ── Tombol + Buat Laporan Baru ────────────────────────────
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LaporKePemilikScreen(pengguna: widget.pengguna),
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
                        '+ Buat laporan baru',
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

  Widget _buildLaporanItem(LaporanModel lap) {
    // Tentukan badge status warna & label sesuai desain Figma
    Color badgeBg;
    Color badgeTextColor;
    String badgeText;

    if (lap.isSelesai) {
      badgeBg = _hijauMuda;
      badgeTextColor = _hijauAksi;
      badgeText = 'Selesai';
    } else if (lap.isDibalas) {
      badgeBg = _hijauMuda;
      badgeTextColor = _hijauAksi;
      badgeText = 'Dibalas';
    } else {
      badgeBg = _kuningAksen;
      badgeTextColor = _hijauTua;
      badgeText = 'Terkirim';
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailLaporanScreen(
              idLaporan: lap.id,
              judul: lap.judul,
              pengirim: lap.pengirim,
              waktu: lap.waktu,
              pesan: lap.pesan,
              namaBarang: lap.namaBarang ?? '',
              sisaStok: lap.sisaStok ?? 0,
              statusAwal: lap.status,
            ),
          ),
        ).then((_) => setState(() {}));
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lap.judul,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _hijauTua,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lap.pesan,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _abuTeks,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  lap.waktu,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: _abuTeks,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
