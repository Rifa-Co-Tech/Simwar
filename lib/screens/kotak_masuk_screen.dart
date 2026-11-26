import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/laporan_model.dart';
import '../models/pengguna_model.dart';
import 'detail_laporan_screen.dart';

/// SIMWAR — Kotak Masuk Pemilik (POV Pemilik)
/// Figma node: 2073:4338
class KotakMasukScreen extends StatefulWidget {
  final PenggunaModel? pengguna;
  final bool embeddedInNavbar;
  final VoidCallback? onBackToHome;

  const KotakMasukScreen({
    super.key,
    this.pengguna,
    this.embeddedInNavbar = false,
    this.onBackToHome,
  });

  @override
  State<KotakMasukScreen> createState() => _KotakMasukScreenState();
}

class _KotakMasukScreenState extends State<KotakMasukScreen> {
  static const Color _bgLayar = Color(0xFFF4EFE0);
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _hijauMuda = Color(0xFFE3EFE8);
  static const Color _merahAksen = Color(0xFFC8401E);
  static const Color _abuTeks = Color(0xFF6E7468);
  static const Color _borderGaris = Color(0xFFE4DCC3);
  static const Color _borderInput = Color(0xFFCFC7AA);

  String _filterAktif = 'Semua'; // 'Semua' | 'Baru' | 'Selesai'

  List<LaporanModel> get _daftarLaporan {
    final semua = LaporanStore.instance.semua;
    if (_filterAktif == 'Baru') {
      return semua.where((l) => l.isBaru).toList();
    }
    if (_filterAktif == 'Selesai') {
      return semua.where((l) => l.isSelesai || l.isDibalas).toList();
    }
    return semua;
  }

  int get _jumlahBaru => LaporanStore.instance.baru.length;

  @override
  Widget build(BuildContext context) {
    final list = _daftarLaporan;

    return Scaffold(
      backgroundColor: _bgLayar,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            widget.embeddedInNavbar
                ? (115 + MediaQuery.paddingOf(context).bottom)
                : (40 + MediaQuery.paddingOf(context).bottom),
          ),
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
                        onTap: () {
                          if (widget.onBackToHome != null) {
                            widget.onBackToHome!();
                          } else {
                            Navigator.pop(context);
                          }
                        },
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
                    'Kotak masuk',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _hijauTua,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Laporan dari penjaga',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _abuTeks,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Filter Chips: Semua | Baru (N) | Selesai ─────────────
                  Row(
                    children: [
                      _buildFilterChip('Semua', 'Semua'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Baru', 'Baru ($_jumlahBaru)'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Selesai', 'Selesai'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Kartu Daftar Laporan Masuk ────────────────────────────
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
                                'Tidak ada laporan di kategori ini',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final bool isSelected = _filterAktif == filterKey;
    return GestureDetector(
      onTap: () => setState(() => _filterAktif = filterKey),
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
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : _hijauTua,
          ),
        ),
      ),
    );
  }

  Widget _buildLaporanItem(LaporanModel lap) {
    final bool isBaru = lap.isBaru;

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
            // Penanda bulat merah belum dibaca jika Baru
            if (isBaru) ...[
              Container(
                margin: const EdgeInsets.only(top: 6, right: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _merahAksen,
                  shape: BoxShape.circle,
                ),
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${lap.judul} · ${lap.pengirim}',
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
                    color: isBaru ? _merahAksen : _hijauMuda,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    isBaru ? 'Baru' : (lap.isDibalas ? 'Dibalas' : 'Selesai'),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isBaru ? Colors.white : _hijauAksi,
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
