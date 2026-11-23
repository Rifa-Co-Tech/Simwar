import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/barang_model.dart';
import '../models/item_keranjang.dart';
import '../models/pengguna_model.dart';
import '../utils/formatters.dart';
import '../widgets/scanner_modal.dart';
import 'catat_barang_masuk_screen.dart';
import 'pembayaran_screen.dart';

/// SIMWAR — Modul Kasir: Keranjang & Jual (Figma node 2029:2)
class KasirScreen extends StatefulWidget {
  final PenggunaModel? pengguna;
  const KasirScreen({super.key, this.pengguna});

  @override
  State<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends State<KasirScreen> {
  static const Color _bgLayar = Color(0xFFF4EFE0);
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _hijauMuda = Color(0xFFE3EFE8);
  static const Color _abuTeks = Color(0xFF6E7468);
  static const Color _borderGaris = Color(0xFFE4DCC3);
  static const Color _borderInput = Color(0xFFCFC7AA);
  static const Color _kuningAksen = Color(0xFFF8B62B);
  static const Color _teksMuted = Color(0xFFB9CFC4);

  // Keranjang Belanja Kasir (Mulai Bersih untuk APK Baru)
  final List<ItemKeranjang> _keranjang = [];

  // Katalog Barang Warung dinamis dari BarangStore (termasuk barang baru & titipan)
  List<ItemKeranjang> get _katalogBarang {
    return BarangStore.instance.semua.map((b) => ItemKeranjang(
      id: b.id,
      nama: b.nama,
      harga: b.hargaJual,
      satuan: b.satuan,
    )).toList();
  }

  int get _totalTagihan =>
      _keranjang.fold(0, (sum, item) => sum + item.subtotal);

  int get _totalJumlahBarang =>
      _keranjang.fold(0, (sum, item) => sum + item.jumlah);

  String _formatRupiah(int nominal) {
    return SimwarFormatter.rupiah(nominal);
  }

  void _tambahKuantiti(int index) {
    setState(() {
      _keranjang[index].jumlah++;
    });
  }

  void _kurangKuantiti(int index) {
    setState(() {
      if (_keranjang[index].jumlah > 1) {
        _keranjang[index].jumlah--;
      } else {
        _hapusBarang(index);
      }
    });
  }

  void _hapusBarang(int index) {
    final nama = _keranjang[index].nama;
    setState(() {
      _keranjang.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$nama dihapus dari keranjang'),
        backgroundColor: const Color(0xFFC8401E),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _bukaPindaiBarang() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PindaiBarcodeModal(
        katalog: _katalogBarang,
        onBarangTerpindai: (item) {
          _tambahBarangManual(item);
        },
      ),
    );
  }

  void _bukaDialogCariBarang() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredBarang = BarangStore.instance.semua.where((b) {
              final q = query.toLowerCase();
              return b.nama.toLowerCase().contains(q) ||
                  b.kategori.toLowerCase().contains(q) ||
                  b.barcode.contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _borderInput,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilih Barang dari Katalog',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _hijauTua,
                        ),
                      ),
                      Text(
                        '${filteredBarang.length} barang',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _abuTeks,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari nama barang atau barcode...',
                      prefixIcon: const Icon(Icons.search, color: _hijauAksi),
                      filled: true,
                      fillColor: _bgLayar,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setModalState(() => query = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: filteredBarang.isEmpty
                        ? Center(
                            child: Text(
                              'Barang "$query" tidak ditemukan.',
                              style: GoogleFonts.inter(color: _abuTeks),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredBarang.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (_, idx) {
                              final item = filteredBarang[idx];
                              final bool habis = item.stok <= 0;
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.nama,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          color: _hijauTua,
                                        ),
                                      ),
                                    ),
                                    if (item.isTitipan)
                                      Container(
                                        margin: const EdgeInsets.only(left: 6),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE3EFE8),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Titipan',
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: _hijauAksi,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      '${_formatRupiah(item.hargaJual)} / ${item.satuan}',
                                      style: GoogleFonts.inter(
                                          color: _abuTeks, fontSize: 13),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '•  Stok: ${item.stok}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: habis
                                            ? const Color(0xFFC8401E)
                                            : (item.isStokMenipis
                                                ? const Color(0xFFBE780A)
                                                : _hijauAksi),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _tambahBarangManual(ItemKeranjang(
                                      id: item.id,
                                      nama: item.nama,
                                      harga: item.hargaJual,
                                      satuan: item.satuan,
                                      jumlah: 1,
                                    ));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _hijauMuda,
                                    foregroundColor: _hijauAksi,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text('+ Tambah'),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _tambahBarangManual(ItemKeranjang item) {
    setState(() {
      final existingIndex = _keranjang.indexWhere((k) =>
          (k.id.isNotEmpty && k.id == item.id) ||
          k.nama.trim().toLowerCase() == item.nama.trim().toLowerCase());
      if (existingIndex >= 0) {
        _keranjang[existingIndex].jumlah++;
      } else {
        _keranjang.add(item.copyWith(jumlah: 1));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.nama} ditambahkan ke keranjang'),
        backgroundColor: _hijauAksi,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLayar,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Konten Atas Scrollable
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 180),
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── 1. Top Bar: Tombol Kembali & Judul ─────────────────
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: _borderInput, width: 1),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/icons/ikon-chevl-18x18-14372D.svg',
                                  width: 18,
                                  height: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Kasir',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _hijauTua,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── 2. Kartu Pindai Barang (Figma 342x92) ──────────────
                      GestureDetector(
                        onTap: _bukaPindaiBarang,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _hijauTua,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: _kuningAksen,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/ikon-scan-28x28-14372D.svg',
                                    width: 28,
                                    height: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pindai barang',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Arahkan kamera ke kode batang',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: _teksMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.16),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/ikon-chevr-18x18-F4EFE0.svg',
                                    width: 18,
                                    height: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── 3. Tombol Input Manual Cari Barang & Titipan Warga ──
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: GestureDetector(
                              onTap: _bukaDialogCariBarang,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: _hijauAksi, width: 1.5),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/ikon-pensil-18x18-23794F.svg',
                                      width: 18,
                                      height: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Cari barang',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _hijauTua,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CatatBarangMasukScreen(pengguna: widget.pengguna),
                                  ),
                                );
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDF6EA),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFD97706), width: 1.5),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.handshake_outlined, size: 18, color: Color(0xFFD97706)),
                                    const SizedBox(width: 6),
                                    Text(
                                      '+ Titipan',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF92400E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── 4. Header Keranjang (Judul & Jumlah Barang) ────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Keranjang',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _hijauTua,
                            ),
                          ),
                          Text(
                            '${_keranjang.length} jenis · $_totalJumlahBarang barang',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _abuTeks,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── 5. Daftar Kartu Barang Belanja (Figma 342x84) ──────
                      if (_keranjang.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'Keranjang masih kosong.\nPindai barcode atau cari barang untuk mulai.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: _abuTeks,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        ...List.generate(_keranjang.length, (idx) {
                          final item = _keranjang[idx];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildItemCard(item, idx),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),

            // ── 6. Fixed Bottom Sticky Panel (Figma Spec @ 0,688) ───────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: _hijauTua.withValues(alpha: 0.10),
                      blurRadius: 14,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Label Total & Angka
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total · $_totalJumlahBarang barang',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: _abuTeks,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatRupiah(_totalTagihan),
                                  style: GoogleFonts.inter(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: _hijauTua,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Tombol Bayar Sekarang (Figma 342x52)
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _keranjang.isEmpty
                                ? null
                                : () async {
                                    final res = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PembayaranScreen(
                                          items: List.from(_keranjang),
                                          totalTagihan: _totalTagihan,
                                          pengguna: widget.pengguna,
                                        ),
                                      ),
                                    );
                                    if (res == true) {
                                      // Transaksi baru -> Reset keranjang
                                      setState(() {
                                        _keranjang.clear();
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _hijauAksi,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  _hijauAksi.withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Bayar sekarang',
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
          ],
        ),
      ),
    );
  }

  // ── Kartu Barang Belanja (Figma 342x84) ───────────────────────────────────
  Widget _buildItemCard(ItemKeranjang item, int index) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderGaris, width: 1),
        boxShadow: [
          BoxShadow(
            color: _hijauTua.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Box Kuning Muda
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
          const SizedBox(width: 14),

          // Info Nama & Counter
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatRupiah(item.harga)} / ${item.satuan}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: _abuTeks,
                  ),
                ),
                const SizedBox(height: 6),

                // Minus & Plus Counter
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _kurangKuantiti(index),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: _hijauAksi, width: 1.5),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/ikon-minus-14x14-23794F.svg',
                            width: 12,
                            height: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${item.jumlah}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _hijauTua,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _tambahKuantiti(index),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: _hijauAksi, width: 1.5),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/ikon-plus-14x14-23794F.svg',
                            width: 12,
                            height: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Subtotal & Tombol Hapus (Trash)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatRupiah(item.subtotal),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _hijauTua,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _hapusBarang(index),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: SvgPicture.asset(
                    'assets/icons/ikon-trash-18x18-6E7468.svg',
                    width: 18,
                    height: 18,
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
