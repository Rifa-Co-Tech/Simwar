import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/barang_model.dart';
import '../models/pengguna_model.dart';
import '../models/rencana_belanja_model.dart';
import '../utils/formatters.dart';

/// SIMWAR — Rencana Belanja Warung (Restock Planner & Smart Shopping List)
/// Figma node: 2010:698
class RencanaBelanjaScreen extends StatefulWidget {
  final PenggunaModel? pengguna;
  const RencanaBelanjaScreen({super.key, this.pengguna});

  @override
  State<RencanaBelanjaScreen> createState() => _RencanaBelanjaScreenState();
}

class _RencanaBelanjaScreenState extends State<RencanaBelanjaScreen> {
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

  String _tabStatus = 'Semua'; // 'Semua' | 'Perlu Dibeli' | 'Sudah Dibeli'
  String _tokoDipilih = 'Semua';

  final List<String> _tokoList = [
    'Semua',
    'Grosir Berkah',
    'Pasar Induk',
    'Distributor Indomarco',
    'Lainnya',
  ];

  List<ItemBelanja> get _filteredItems {
    final store = RencanaBelanjaStore.instance;
    List<ItemBelanja> list;

    if (_tabStatus == 'Perlu Dibeli') {
      list = store.perluDibeli;
    } else if (_tabStatus == 'Sudah Dibeli') {
      list = store.sudahDibeli;
    } else {
      list = store.semua;
    }

    if (_tokoDipilih != 'Semua') {
      list = list.where((i) => i.tokoTujuan == _tokoDipilih).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final store = RencanaBelanjaStore.instance;
    final totalItems = store.semua.length;
    final boughtItems = store.sudahDibeli.length;
    final progress = totalItems > 0 ? boughtItems / totalItems : 0.0;

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
          'Rencana Belanja Warung',
          style: GoogleFonts.inter(
            color: _hijauTua,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: _hijauTua),
            tooltip: 'Sinkronkan dari Stok Menipis',
            onPressed: () {
              setState(() {
                store.sinkronkanDariStokMenipis();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Daftar barang stok menipis otomatis ditambahkan!'),
                  backgroundColor: _hijauAksi,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: _hijauTua),
            tooltip: 'Bagikan Catatan Belanja',
            onPressed: _showShareDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Hero Budget Card
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimasi Anggaran Perlu Dibeli',
                            style: GoogleFonts.inter(color: const Color(0xFFB9CFC4), fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            SimwarFormatter.rupiah(store.totalAnggaranPerluDibeli),
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: _kuningAksen,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$boughtItems / $totalItems Selesai',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(_kuningAksen),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Anggaran: ${SimwarFormatter.rupiah(store.totalEstimasiAnggaran)}',
                        style: GoogleFonts.inter(color: const Color(0xFFB9CFC4), fontSize: 11),
                      ),
                      Text(
                        'Terbeli: ${SimwarFormatter.rupiah(store.totalSudahDibelanjakan)}',
                        style: GoogleFonts.inter(color: const Color(0xFFB9CFC4), fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 2. Tab Filter Status
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildStatusTab('Semua', totalItems),
                const SizedBox(width: 8),
                _buildStatusTab('Perlu Dibeli', store.perluDibeli.length),
                const SizedBox(width: 8),
                _buildStatusTab('Sudah Dibeli', boughtItems),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 3. Filter Toko Chips
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _tokoList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final toko = _tokoList[i];
                final isSelected = _tokoDipilih == toko;
                return ChoiceChip(
                  label: Text(
                    toko,
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
                    if (val) setState(() => _tokoDipilih = toko);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // 4. Checklist Item Belanja
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 54, color: _abuTeks.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada daftar barang belanja',
                          style: GoogleFonts.inter(color: _abuTeks, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
                    itemCount: _filteredItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return _buildItemBelanjaCard(item);
                    },
                  ),
          ),
        ],
      ),

      // 5. Bottom Action Bar: Tambah Item & Selesai Belanja
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showTambahItemDialog,
                icon: const Icon(Icons.add, size: 18, color: _hijauAksi),
                label: Text(
                  'Tambah Barang',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: _hijauAksi,
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _hijauAksi),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            if (boughtItems > 0) ...[
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _selesaikanBelanja,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(
                    'Update ke Stok ($boughtItems)',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hijauAksi,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTab(String label, int count) {
    final isSelected = _tabStatus == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabStatus = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? _hijauTua : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? _hijauTua : _borderGaris),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : _hijauTua,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '($count)',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? _kuningAksen : _abuTeks,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemBelanjaCard(ItemBelanja item) {
    final isDone = item.isSudahDibeli;

    Color badgeBg;
    Color badgeText;
    if (item.alasan.contains('Kritis')) {
      badgeBg = const Color(0xFFFDE8E8);
      badgeText = _merahAksen;
    } else if (item.alasan.contains('Menipis')) {
      badgeBg = const Color(0xFFFEF3C7);
      badgeText = const Color(0xFFB45309);
    } else {
      badgeBg = _hijauMuda;
      badgeText = _hijauAksi;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFFAF8F2) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDone ? _borderGaris : _borderGaris, width: isDone ? 1 : 1.2),
        boxShadow: isDone
            ? []
            : [
                BoxShadow(
                  color: _hijauTua.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Checkbox interaktif
          GestureDetector(
            onTap: () {
              setState(() {
                RencanaBelanjaStore.instance.toggleStatus(item.id);
              });
            },
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isDone ? _hijauAksi : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDone ? _hijauAksi : _borderInput,
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Detail Barang Belanja
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.nama,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDone ? _abuTeks : _hijauTua,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.alasan,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: badgeText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.jumlah} ${item.satuan} • ${item.tokoTujuan}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: _abuTeks,
                      ),
                    ),
                    Text(
                      SimwarFormatter.rupiah(item.subtotal),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDone ? _abuTeks : _hijauTua,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tombol Hapus Item
          IconButton(
            icon: const Icon(Icons.delete_outline, color: _merahAksen, size: 20),
            onPressed: () {
              setState(() {
                RencanaBelanjaStore.instance.hapusItem(item.id);
              });
            },
          ),
        ],
      ),
    );
  }

  void _showTambahItemDialog() {
    final namaCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final satuanCtrl = TextEditingController(text: 'pcs');
    final estimasiCtrl = TextEditingController();
    String tokoPilihan = 'Grosir Berkah';
    String? selectedCatalogId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tambah Barang Rencana Belanja',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _hijauTua,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Pilih Cepat dari Stok Menipis
                    Text(
                      'Pilih Cepat Dari Stok Menipis (Atau Ketik Bebas)',
                      style: GoogleFonts.inter(fontSize: 12, color: _abuTeks),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: BarangStore.instance.stokMenipis.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final b = BarangStore.instance.stokMenipis[i];
                          final isSelected = selectedCatalogId == b.id;
                          return ChoiceChip(
                            label: Text('${b.nama} (Sisa ${b.stok})', style: const TextStyle(fontSize: 11)),
                            selected: isSelected,
                            selectedColor: _hijauMuda,
                            onSelected: (val) {
                              setModalState(() {
                                if (val) {
                                  selectedCatalogId = b.id;
                                  namaCtrl.text = b.nama;
                                  satuanCtrl.text = b.satuan;
                                  estimasiCtrl.text = b.hargaBeli.toString();
                                } else {
                                  selectedCatalogId = null;
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Nama Barang
                    TextField(
                      controller: namaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Barang / Produk',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Jumlah & Satuan
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: qtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Jumlah',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: satuanCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Satuan (dus/kg/karton)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Estimasi Harga Satuan
                    TextField(
                      controller: estimasiCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Estimasi Harga Satuan (Rp)',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tempat / Toko Tujuan
                    Text('Toko Tujuan Kulakan:', style: GoogleFonts.inter(fontSize: 12, color: _abuTeks)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: ['Grosir Berkah', 'Pasar Induk', 'Distributor Indomarco', 'Lainnya'].map((toko) {
                        return ChoiceChip(
                          label: Text(toko, style: const TextStyle(fontSize: 11)),
                          selected: tokoPilihan == toko,
                          selectedColor: _hijauMuda,
                          onSelected: (val) {
                            if (val) setModalState(() => tokoPilihan = toko);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hijauAksi,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (namaCtrl.text.trim().isEmpty) return;
                          final qty = int.tryParse(qtyCtrl.text) ?? 1;
                          final estimasi = int.tryParse(estimasiCtrl.text) ?? 0;

                          setState(() {
                            RencanaBelanjaStore.instance.tambahItem(
                              ItemBelanja(
                                id: 'rb-${DateTime.now().millisecondsSinceEpoch}',
                                barangId: selectedCatalogId,
                                nama: namaCtrl.text.trim(),
                                jumlah: qty,
                                satuan: satuanCtrl.text.trim(),
                                estimasiHarga: estimasi,
                                tokoTujuan: tokoPilihan,
                                alasan: selectedCatalogId != null ? 'Stok Menipis' : 'Manual',
                              ),
                            );
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text('Simpan ke Rencana Belanja', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _selesaikanBelanja() {
    final count = RencanaBelanjaStore.instance.sudahDibeli.length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Update ke Stok Warung?',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _hijauTua),
        ),
        content: Text(
          'Sebanyak $count item yang sudah dicentang akan otomatis dicatat sebagai Barang Masuk dan menambah stok di katalog warung.',
          style: GoogleFonts.inter(fontSize: 13, color: _abuTeks),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: _abuTeks)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                RencanaBelanjaStore.instance.selesaikanBelanjaDanUpdateStok(widget.pengguna?.nama ?? 'Pemilik');
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Berhasil! $count item belanja telah ditambahkan ke Stok Warung.'),
                  backgroundColor: _hijauAksi,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _hijauAksi,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Masukkan Stok'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog() {
    final items = RencanaBelanjaStore.instance.perluDibeli;
    final buffer = StringBuffer();
    buffer.writeln('📋 *CATATAN BELANJA WARUNG AZZAM*');
    buffer.writeln('Tanggal: ${SimwarFormatter.tanggal(DateTime.now())}');
    buffer.writeln('--------------------------------');
    for (var i = 0; i < items.length; i++) {
      final it = items[i];
      buffer.writeln('${i + 1}. ${it.nama} - ${it.jumlah} ${it.satuan} (${it.tokoTujuan})');
    }
    buffer.writeln('--------------------------------');
    buffer.writeln('Estimasi Anggaran: ${SimwarFormatter.rupiah(RencanaBelanjaStore.instance.totalAnggaranPerluDibeli)}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Bagikan Catatan Belanja (WhatsApp)',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _hijauTua, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Teks format WhatsApp siap dibagikan ke staf warung:',
                style: GoogleFonts.inter(fontSize: 12, color: _abuTeks),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _hijauMuda,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  buffer.toString(),
                  style: GoogleFonts.inter(fontSize: 12, color: _hijauTua),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: buffer.toString()));
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Catatan belanja berhasil disalin ke clipboard!'),
                  backgroundColor: _hijauAksi,
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Salin Teks'),
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
