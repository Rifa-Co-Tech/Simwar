import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/barang_model.dart';
import '../models/pengguna_model.dart';
import '../utils/formatters.dart';
import '../widgets/barcode_widget.dart';
import 'tambah_barang_screen.dart';

/// SIMWAR — Kelola Barang & Katalog Warung
/// Figma node: 2010:806
class KelolaBarangScreen extends StatefulWidget {
  final PenggunaModel? pengguna;
  const KelolaBarangScreen({super.key, this.pengguna});

  @override
  State<KelolaBarangScreen> createState() => _KelolaBarangScreenState();
}

class _KelolaBarangScreenState extends State<KelolaBarangScreen> {
  static const Color _bgLayar = Color(0xFFF4EFE0);
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _abuTeks = Color(0xFF6E7468);
  static const Color _borderGaris = Color(0xFFE4DCC3);
  static const Color _borderInput = Color(0xFFCFC7AA);
  static const Color _kuningAksen = Color(0xFFF8B62B);

  final TextEditingController _searchCtrl = TextEditingController();
  String _kategoriDipilih = 'Semua';

  final List<String> _kategoriList = [
    'Semua',
    'Makanan',
    'Minuman',
    'Sembako',
    'Alat mandi',
    'Skincare',
    'Lainnya',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<BarangModel> get _daftarBarang {
    final query = _searchCtrl.text.toLowerCase().trim();
    return BarangStore.instance.semua.where((b) {
      final matchKategori = _matchKategori(b);
      final matchQuery = query.isEmpty ||
          b.nama.toLowerCase().contains(query) ||
          b.barcode.toLowerCase().contains(query);
      return matchKategori && matchQuery;
    }).toList();
  }

  bool _matchKategori(BarangModel b) {
    if (_kategoriDipilih == 'Semua') return true;
    final k = b.kategori.toLowerCase().trim();
    final p = _kategoriDipilih.toLowerCase().trim();
    if (k == p) return true;
    if (p == 'skincare' && k.contains('kosmetik')) return true;
    if (p == 'lainnya' &&
        !const {'makanan', 'minuman', 'sembako', 'alat mandi', 'skincare'}.contains(k) &&
        !k.contains('kosmetik')) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final list = _daftarBarang;
    final totalJenis = BarangStore.instance.semua.length;

    return Scaffold(
      backgroundColor: _bgLayar,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TambahBarangScreen(pengguna: widget.pengguna),
            ),
          ).then((_) => setState(() {}));
        },
        backgroundColor: _kuningAksen,
        elevation: 4,
        icon: const Icon(Icons.add, color: _hijauTua),
        label: Text(
          'Tambah barang',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _hijauTua,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 16, 24, 90 + MediaQuery.paddingOf(context).bottom),
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
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kelola barang',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _hijauTua,
                            ),
                          ),
                          Text(
                            '$totalJenis jenis barang terdaftar',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: _abuTeks,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── Kolom Pencarian ───────────────────────────────────────
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _borderInput),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 20, color: _abuTeks),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (_) => setState(() {}),
                            style: GoogleFonts.inter(fontSize: 13, color: _hijauTua),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Cari nama barang atau kode batang',
                              hintStyle: GoogleFonts.inter(fontSize: 13, color: _abuTeks),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Kategori Chips Horizontal Scroll ─────────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _kategoriList.map((kat) {
                        final bool isSelected = _kategoriDipilih == kat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _kategoriDipilih = kat),
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
                                kat,
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
                  ),
                  const SizedBox(height: 18),

                  // ── Daftar Kartu Barang ──────────────────────────────────
                  if (list.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 48, color: _borderInput),
                            const SizedBox(height: 12),
                            Text(
                              _searchCtrl.text.isNotEmpty
                                  ? 'Barang "${_searchCtrl.text}" tidak ditemukan'
                                  : 'Belum ada barang di katalog warung.\nKlik "+ Tambah barang" di atas untuk mulai.',
                              style: GoogleFonts.inter(color: _abuTeks, fontSize: 13, height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...list.map((b) => _buildBarangCard(b)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarangCard(BarangModel b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderGaris, width: 1),
      ),
      child: Row(
        children: [
          // Thumbnail Tile
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFE8D2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/ikon-stok-24x24-23794F.svg',
                width: 24,
                height: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info Barang
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
                  b.barcode.isNotEmpty
                      ? '${b.barcode} · ${SimwarFormatter.rupiah(b.hargaJual)}'
                      : SimwarFormatter.rupiah(b.hargaJual),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: _abuTeks,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stok ${b.stok}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: b.isStokMenipis ? const Color(0xFFC8401E) : const Color(0xFF1F2D26),
                  ),
                ),
              ],
            ),
          ),
          // Tombol Lihat Barcode
          IconButton(
            icon: const Icon(Icons.qr_code, color: _hijauTua, size: 20),
            tooltip: 'Lihat Kode Batang',
            onPressed: () => _tampilkanBarcodeDialog(b),
          ),
          // Tombol Ubah
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TambahBarangScreen(
                    barangEdit: b,
                    pengguna: widget.pengguna,
                  ),
                ),
              ).then((_) => setState(() {}));
            },
            child: Text(
              'Ubah',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _hijauAksi,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _tampilkanBarcodeDialog(BarangModel b) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Text(
              b.nama,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: _hijauTua),
            ),
            const SizedBox(height: 4),
            Text(
              '${b.kategori} · ${SimwarFormatter.rupiah(b.hargaJual)}',
              style: GoogleFonts.inter(fontSize: 12, color: _abuTeks),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF8EE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _borderGaris),
              ),
              child: b.barcode.isNotEmpty
                  ? SimwarBarcodeWidget(
                      barcodeValue: b.barcode,
                      width: 210,
                      height: 75,
                      showText: true,
                    )
                  : Column(
                      children: [
                        const Icon(Icons.qr_code_2_outlined, size: 42, color: _abuTeks),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada kode barcode (opsional)',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _hijauTua,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              b.barcode.isNotEmpty
                  ? 'Kode batang ini dapat dipindai oleh scanner kasir atau kamera saat transaksi.'
                  : 'Anda dapat menambahkan kode barcode kapan saja melalui menu Ubah barang.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 11, color: _abuTeks),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: _abuTeks)),
          ),
          ElevatedButton.icon(
            onPressed: b.barcode.isEmpty
                ? null
                : () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Label kode batang untuk "${b.nama}" siap dicetak!'),
                        backgroundColor: _hijauAksi,
                      ),
                    );
                  },
            icon: const Icon(Icons.print, size: 16),
            label: const Text('Cetak Label Barcode'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _hijauAksi,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
