import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/barang_model.dart';
import '../models/pengguna_model.dart';
import 'kelola_barang_screen.dart';

/// SIMWAR — Modul Stok: Stok Menipis & Kedaluwarsa (Pemilik & Penjaga)
/// Figma node: 2010:611 (Stok Menipis) & 2010:494 (Kedaluwarsa)
class StokScreen extends StatefulWidget {
  final String initialTab; // 'menipis' | 'kedaluwarsa'
  final PenggunaModel? pengguna;

  const StokScreen({
    super.key,
    this.initialTab = 'menipis',
    this.pengguna,
  });

  @override
  State<StokScreen> createState() => _StokScreenState();
}

class _StokScreenState extends State<StokScreen> {
  static const Color _bgLayar = Color(0xFFF4EFE0);
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _hijauMuda = Color(0xFFE3EFE8);
  static const Color _abuTeks = Color(0xFF6E7468);
  static const Color _borderGaris = Color(0xFFE4DCC3);
  static const Color _borderInput = Color(0xFFCFC7AA);
  static const Color _kuningAksen = Color(0xFFF8B62B);
  static const Color _merahAksen = Color(0xFFC8401E);

  late String _activeMainTab; // 'menipis' | 'kedaluwarsa'
  String _subFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _activeMainTab = widget.initialTab;
  }

  List<BarangModel> get _listMenipis {
    final list = BarangStore.instance.stokMenipis;
    if (_subFilter == 'Kritis') {
      return list.where((b) => b.isKritis).toList();
    }
    if (_subFilter == 'Menipis') {
      return list.where((b) => !b.isKritis).toList();
    }
    return list;
  }

  List<BarangModel> get _listKedaluwarsa {
    final list = BarangStore.instance.hampirKedaluwarsa;
    if (_subFilter == 'Lewat') {
      return list.where((b) => b.isLewatKedaluwarsa).toList();
    }
    if (_subFilter == '7 hari') {
      return list.where((b) => b.sisaHariKedaluwarsa >= 0 && b.sisaHariKedaluwarsa <= 7).toList();
    }
    if (_subFilter == '30 hari') {
      return list.where((b) => b.sisaHariKedaluwarsa > 7 && b.sisaHariKedaluwarsa <= 30).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isMenipis = _activeMainTab == 'menipis';
    final items = isMenipis ? _listMenipis : _listKedaluwarsa;

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => KelolaBarangScreen(pengguna: widget.pengguna),
                            ),
                          ).then((_) => setState(() {}));
                        },
                        child: Text(
                          'Kelola semua barang',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _hijauAksi,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Header Title & Subtitle ──────────────────────────────
                  Text(
                    isMenipis ? 'Stok menipis' : 'Kedaluwarsa',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _hijauTua,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isMenipis
                        ? 'Di bawah batas minimum · pantauan stok'
                        : 'Masa simpan dan kedaluwarsa barang',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _abuTeks,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Segmented Toggle Tab (Figma 342x40) ───────────────────
                  Container(
                    height: 42,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(color: _borderGaris),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _activeMainTab = 'kedaluwarsa';
                                _subFilter = 'Semua';
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: !isMenipis ? _hijauAksi : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Center(
                                child: Text(
                                  'Kedaluwarsa',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: !isMenipis ? Colors.white : _hijauTua,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _activeMainTab = 'menipis';
                                _subFilter = 'Semua';
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isMenipis ? _hijauAksi : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Center(
                                child: Text(
                                  'Stok menipis',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isMenipis ? Colors.white : _hijauTua,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Sub-Filters ──────────────────────────────────────────
                  Row(
                    children: (isMenipis
                            ? ['Semua', 'Kritis', 'Menipis']
                            : ['Semua', 'Lewat', '7 hari', '30 hari'])
                        .map((filter) {
                      final bool isSelected = _subFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _subFilter = filter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
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
                              filter,
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
                  const SizedBox(height: 18),

                  // ── Hero Banner Rencana Belanja (Khusus Stok Menipis) ─────
                  if (isMenipis) ...[
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _hijauTua,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${BarangStore.instance.stokMenipis.length}',
                            style: GoogleFonts.inter(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: _kuningAksen,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Barang di bawah batas',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Segera restock sebelum barang kosong',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFFB9CFC4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => KelolaBarangScreen(pengguna: widget.pengguna),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kuningAksen,
                              foregroundColor: _hijauTua,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text(
                              'Restock',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // ── List Barang (Menipis / Kedaluwarsa) ───────────────────
                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'Tidak ada barang dalam kategori ini',
                          style: GoogleFonts.inter(color: _abuTeks),
                        ),
                      ),
                    )
                  else
                    ...items.map((b) => _buildItemCard(b, isMenipis)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(BarangModel b, bool isMenipis) {
    if (isMenipis) {
      final double progress = (b.stok / b.batasMin).clamp(0.0, 1.0);
      final isKritis = b.isKritis;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _borderGaris, width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF14382E).withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge Angka Sisa
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isKritis ? const Color(0xFFF7E1DA) : const Color(0xFFFDF0CF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${b.stok}',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isKritis ? _merahAksen : const Color(0xFF7A5200),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info Nama, Batas, dan Progress Bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          b.nama,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2D26),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isKritis ? _merahAksen : _kuningAksen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isKritis ? 'Kritis' : 'Menipis',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isKritis ? Colors.white : _hijauTua,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Batas min. ${b.batasMin} · sisa ${b.stok} ${b.satuan}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: _abuTeks,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress Bar Visual
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: _borderGaris,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isKritis ? _merahAksen : _kuningAksen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Tampilan Card Kedaluwarsa
      final sisaHari = b.sisaHariKedaluwarsa;
      final isLewat = b.isLewatKedaluwarsa;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _borderGaris, width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF14382E).withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isLewat ? const Color(0xFFF7E1DA) : const Color(0xFFFDF0CF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  isLewat ? 'LEWAT' : '$sisaHari hr',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isLewat ? _merahAksen : const Color(0xFF7A5200),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.nama,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2D26),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Kategori: ${b.kategori} · Stok: ${b.stok} ${b.satuan}',
                    style: GoogleFonts.inter(fontSize: 11, color: _abuTeks),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isLewat
                        ? 'Sudah lewat masa simpan!'
                        : 'Mendekati masa kedaluwarsa ($sisaHari hari lagi)',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isLewat ? _merahAksen : _kuningAksen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
