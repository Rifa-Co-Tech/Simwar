import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/analisis_laba_model.dart';
import '../models/pengguna_model.dart';
import '../models/transaksi_model.dart';
import '../services/excel_export_service.dart';
import '../utils/formatters.dart';

/// SIMWAR — Analisis Laba per Barang
/// Figma node: 2053:94
class LabaPerBarangScreen extends StatefulWidget {
  final PenggunaModel? pengguna;
  const LabaPerBarangScreen({super.key, this.pengguna});

  @override
  State<LabaPerBarangScreen> createState() => _LabaPerBarangScreenState();
}

class _LabaPerBarangScreenState extends State<LabaPerBarangScreen> {
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

  String _sortTab = 'Laba'; // 'Laba' | 'Laris' | 'Margin'
  String _kategoriDipilih = 'Semua';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _kategoriList = [
    'Semua',
    'Sembako',
    'Makanan',
    'Minuman',
    'Alat mandi',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ItemLabaAnalisis> get _sortedList {
    final raw = List<ItemLabaAnalisis>.from(LaporanService.instance.semuaProduk);
    final q = _searchCtrl.text.toLowerCase().trim();

    final filtered = raw.where((item) {
      final matchKategori = _kategoriDipilih == 'Semua' ||
          item.kategori.toLowerCase() == _kategoriDipilih.toLowerCase();
      final matchSearch = q.isEmpty || item.nama.toLowerCase().contains(q);
      return matchKategori && matchSearch;
    }).toList();

    if (_sortTab == 'Laba') {
      filtered.sort((a, b) => b.totalLaba.compareTo(a.totalLaba));
    } else if (_sortTab == 'Laris') {
      filtered.sort((a, b) => b.terjual.compareTo(a.terjual));
    } else if (_sortTab == 'Margin') {
      filtered.sort((a, b) => b.marginPersen.compareTo(a.marginPersen));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final service = LaporanService.instance;
    final totalLaba = service.totalLabaKeseluruhan;
    final totalOmset = service.totalOmsetKeseluruhan;
    final avgMargin = totalOmset > 0 ? (totalLaba / totalOmset * 100).toStringAsFixed(1) : '0';

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
          'Laba per Barang',
          style: GoogleFonts.inter(
            color: _hijauTua,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: _hijauTua),
            tooltip: 'Ekspor Excel (.xlsx)',
            onPressed: () async {
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
                totalTransaksi: TransaksiStore.instance.semua.length,
                periode: 'Katalog Barang',
              );
              if (file != null && context.mounted) {
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
      body: Column(
        children: [
          // 1. Hero Summary Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _hijauTua,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _hijauTua.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Laba Bersih Katalog',
                          style: GoogleFonts.inter(color: const Color(0xFFB9CFC4), fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          SimwarFormatter.rupiah(totalLaba),
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _kuningAksen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rata-rata Margin',
                        style: GoogleFonts.inter(color: const Color(0xFFB9CFC4), fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$avgMargin%',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 2. Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.inter(color: _hijauTua, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari barang di analisis laba...',
                hintStyle: GoogleFonts.inter(color: _abuTeks.withValues(alpha: 0.7), fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: _abuTeks, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _borderGaris),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _borderGaris),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _hijauAksi, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 3. Tab Urutkan (Laba Tertinggi, Paling Laris, Margin %)
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildSortTab('Laba', 'Laba Tertinggi'),
                const SizedBox(width: 8),
                _buildSortTab('Laris', 'Paling Laris'),
                const SizedBox(width: 8),
                _buildSortTab('Margin', 'Margin % Terbesar'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 4. Kategori Filter Chips
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _kategoriList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final kat = _kategoriList[i];
                final isSelected = _kategoriDipilih == kat;
                return ChoiceChip(
                  label: Text(
                    kat,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : _hijauTua,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: _hijauAksi,
                  backgroundColor: Colors.white,
                  side: BorderSide(color: isSelected ? _hijauAksi : _borderGaris),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  onSelected: (val) {
                    if (val) setState(() => _kategoriDipilih = kat);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // 5. Daftar Barang & Analisis
          Expanded(
            child: _sortedList.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada barang ditemukan',
                      style: GoogleFonts.inter(color: _abuTeks),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: _sortedList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _sortedList[index];
                      return _buildItemCard(item, index + 1);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortTab(String key, String label) {
    final isSelected = _sortTab == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _sortTab = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? _hijauTua : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? _hijauTua : _borderGaris),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : _hijauTua,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(ItemLabaAnalisis item, int rank) {
    Color rankColor;
    if (rank == 1) {
      rankColor = const Color(0xFFEAB308); // Emas
    } else if (rank == 2) {
      rankColor = const Color(0xFF94A3B8); // Perak
    } else if (rank == 3) {
      rankColor = const Color(0xFFD97706); // Perunggu
    } else {
      rankColor = _hijauMuda;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderGaris),
        boxShadow: [
          BoxShadow(
            color: _hijauTua.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge Peringkat
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: rankColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: rank <= 3 ? Colors.white : _hijauTua,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info Nama & Kategori
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nama,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _hijauTua,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _hijauMuda,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.kategori,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _hijauAksi,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• Terjual: ${item.terjual} pcs',
                          style: GoogleFonts.inter(fontSize: 11, color: _abuTeks),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Total Laba Produk
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Laba',
                    style: GoogleFonts.inter(fontSize: 10, color: _abuTeks),
                  ),
                  Text(
                    SimwarFormatter.rupiah(item.totalLaba),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _hijauAksi,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: _borderGaris),
          const SizedBox(height: 10),

          // Breakdown: Modal vs Jual & Margin
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Beli: ${SimwarFormatter.rupiah(item.hargaBeli)}  →  Jual: ${SimwarFormatter.rupiah(item.hargaJual)}',
                style: GoogleFonts.inter(fontSize: 11, color: _abuTeks),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF6EA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kuningAksen.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '+${SimwarFormatter.rupiah(item.labaPerUnit)} / pcs (${item.marginPersen.toStringAsFixed(0)}%)',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
