import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/barang_model.dart';
import '../models/pengaturan_warung_model.dart';
import '../models/pengguna_model.dart';
import '../utils/formatters.dart';
import '../widgets/scanner_modal.dart';

/// SIMWAR — Tambah & Ubah Barang (Pemilik & Penjaga)
/// Figma node: 2010:885 (Tambah) & 2010:915 (Ubah)
class TambahBarangScreen extends StatefulWidget {
  final BarangModel? barangEdit;
  final PenggunaModel? pengguna;

  const TambahBarangScreen({
    super.key,
    this.barangEdit,
    this.pengguna,
  });

  @override
  State<TambahBarangScreen> createState() => _TambahBarangScreenState();
}

class _TambahBarangScreenState extends State<TambahBarangScreen> {
  static const Color _bgLayar = Color(0xFFF4EFE0);
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _hijauMuda = Color(0xFFE3EFE8);
  static const Color _abuTeks = Color(0xFF6E7468);
  static const Color _borderGaris = Color(0xFFE4DCC3);
  static const Color _borderInput = Color(0xFFCFC7AA);

  late final TextEditingController _namaCtrl;
  late final TextEditingController _barcodeCtrl;
  late final TextEditingController _hargaBeliCtrl;
  late final TextEditingController _hargaJualCtrl;
  late final TextEditingController _batasMinCtrl;
  late final TextEditingController _stokAwalCtrl;

  String _kategori = 'Makanan';
  bool _isTitipan = false;
  bool _isSaving = false;
  DateTime? _tglKedaluwarsa;

  bool get _isEdit => widget.barangEdit != null;

  @override
  void initState() {
    super.initState();
    final b = widget.barangEdit;
    final batasDefault = PengaturanStore.instance.pengaturan.batasStokDefault;
    _namaCtrl = TextEditingController(text: b?.nama ?? '');
    _barcodeCtrl = TextEditingController(text: b?.barcode ?? '');
    _hargaBeliCtrl = TextEditingController(text: b != null ? b.hargaBeli.toString() : '');
    _hargaJualCtrl = TextEditingController(text: b != null ? b.hargaJual.toString() : '');
    _batasMinCtrl = TextEditingController(text: (b?.batasMin ?? batasDefault).toString());
    _stokAwalCtrl = TextEditingController(text: b != null ? b.stok.toString() : '');
    _kategori = b?.kategori ?? 'Makanan';
    _isTitipan = b?.isTitipan ?? false;
    _tglKedaluwarsa = b?.tglKedaluwarsa;
    if (b?.fotoPath != null && b!.fotoPath!.isNotEmpty) {
      _fotoBarang = XFile(b.fotoPath!);
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _barcodeCtrl.dispose();
    _hargaBeliCtrl.dispose();
    _hargaJualCtrl.dispose();
    _batasMinCtrl.dispose();
    _stokAwalCtrl.dispose();
    super.dispose();
  }

  XFile? _fotoBarang;
  final ImagePicker _picker = ImagePicker();

  void _bukaKameraScanBarcode() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PindaiBarcodeModal(
        katalog: const [],
        onBarangTerpindai: (_) {},
        onBarcodeRawTerdeteksi: (barcode) {
          setState(() {
            _barcodeCtrl.text = barcode;
          });
        },
      ),
    );
  }

  void _pilihFotoBarangDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Foto Produk Barang',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: _hijauTua),
            ),
            const SizedBox(height: 8),
            Text('Ambil foto kemasan barang atau pilih dari galeri HP', style: GoogleFonts.inter(fontSize: 13, color: _abuTeks)),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFE3EFE8), child: Icon(Icons.camera_alt, color: _hijauAksi)),
              title: Text('Buka Kamera HP', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(ctx);
                final img = await _picker.pickImage(source: ImageSource.camera, maxWidth: 800, maxHeight: 800, imageQuality: 85);
                if (img != null) setState(() => _fotoBarang = img);
              },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFE3EFE8), child: Icon(Icons.photo_library, color: _hijauAksi)),
              title: Text('Pilih dari Galeri HP', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(ctx);
                final img = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 85);
                if (img != null) setState(() => _fotoBarang = img);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _simpanBarang() async {
    if (_isSaving) return;
    final nama = _namaCtrl.text.trim();
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama barang tidak boleh kosong'), backgroundColor: Color(0xFFC8401E)),
      );
      return;
    }

    final beli = int.tryParse(_hargaBeliCtrl.text.trim()) ?? 0;
    final jual = int.tryParse(_hargaJualCtrl.text.trim()) ?? 0;
    if (jual <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga jual harus diisi lebih dari Rp 0'), backgroundColor: Color(0xFFC8401E)),
      );
      return;
    }

    final batasDefault = PengaturanStore.instance.pengaturan.batasStokDefault;
    final batas = int.tryParse(_batasMinCtrl.text.trim()) ?? batasDefault;
    final stok = int.tryParse(_stokAwalCtrl.text.trim()) ?? 0;

    setState(() => _isSaving = true);
    try {
      if (_isEdit) {
        final updated = widget.barangEdit!;
        updated.nama = nama;
        updated.barcode = _barcodeCtrl.text.trim();
        updated.kategori = _kategori;
        updated.hargaBeli = beli;
        updated.hargaJual = jual;
        updated.batasMin = batas;
        updated.stok = stok;
        updated.isTitipan = _isTitipan;
        updated.tglKedaluwarsa = _tglKedaluwarsa;
        if (_fotoBarang != null) {
          updated.fotoPath = _fotoBarang!.path;
        }
        await BarangStore.instance.ubahBarangAsync(updated);
      } else {
        final newBarang = BarangModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nama: nama,
          barcode: _barcodeCtrl.text.trim(),
          kategori: _kategori,
          hargaBeli: beli,
          hargaJual: jual,
          stok: stok,
          batasMin: batas,
          isTitipan: _isTitipan,
          tglKedaluwarsa: _tglKedaluwarsa,
          fotoPath: _fotoBarang?.path,
        );
        await BarangStore.instance.tambahBarangAsync(newBarang);
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Data barang berhasil diperbarui!' : 'Barang baru berhasil ditambahkan!'),
          backgroundColor: _hijauAksi,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _hapusBarang() async {
    final target = widget.barangEdit;
    if (target == null || _isSaving) return;

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Barang?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: _hijauTua),
        ),
        content: Text(
          'Barang "${target.nama}" akan dihapus permanen dari katalog warung.',
          style: GoogleFonts.inter(fontSize: 13, color: _abuTeks),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: GoogleFonts.inter(color: _abuTeks)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC8401E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;
    setState(() => _isSaving = true);
    try {
      await BarangStore.instance.hapusBarangAsync(target.id);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barang berhasil dihapus dari katalog.'),
          backgroundColor: Color(0xFFC8401E),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      const SizedBox(width: 14),
                      Text(
                        _isEdit ? 'Ubah barang' : 'Tambah barang',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _hijauTua,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Foto Produk (Kamera HP / Galeri) ─────────────────────
                  GestureDetector(
                    onTap: _pilihFotoBarangDialog,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _fotoBarang != null ? _hijauAksi : _borderInput,
                          width: _fotoBarang != null ? 2 : 1,
                        ),
                      ),
                      child: _fotoBarang != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: kIsWeb
                                      ? Image.network(
                                          _fotoBarang!.path,
                                          width: double.infinity,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(_fotoBarang!.path),
                                          width: double.infinity,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _fotoBarang = null),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _hijauTua.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.edit, color: Colors.white, size: 12),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Ganti Foto',
                                          style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE3EFE8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt, color: _hijauAksi, size: 24),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Foto Produk (Kamera HP / Galeri)',
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _hijauTua),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Sentuh untuk mengambil foto produk fisik',
                                  style: GoogleFonts.inter(fontSize: 11, color: _abuTeks),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── 1. Nama Barang ───────────────────────────────────────
                  Text(
                    'Nama barang',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: _abuTeks),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _borderInput),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _namaCtrl,
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: _hijauTua),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Contoh: Indomie Goreng Spesial',
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── 2. Kode Batang & Tombol Scan ──────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kode batang (Barcode)',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: _abuTeks),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _hijauMuda,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Opsional',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: _hijauAksi),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _borderGaris),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _barcodeCtrl,
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: _hijauTua),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Pindai atau kosongkan jika tidak ada barcode',
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _bukaKameraScanBarcode,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _hijauAksi, width: 1.5),
                            ),
                            child: Text(
                              'Scan',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _hijauAksi),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── 3. Harga Beli & Harga Jual ───────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Harga beli', style: GoogleFonts.inter(fontSize: 12, color: _abuTeks)),
                            const SizedBox(height: 6),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _borderInput),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.centerLeft,
                              child: TextField(
                                controller: _hargaBeliCtrl,
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: _hijauTua),
                                decoration: const InputDecoration(border: InputBorder.none, prefixText: 'Rp '),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Harga jual', style: GoogleFonts.inter(fontSize: 12, color: _abuTeks)),
                            const SizedBox(height: 6),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _borderInput),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.centerLeft,
                              child: TextField(
                                controller: _hargaJualCtrl,
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: _hijauTua),
                                decoration: const InputDecoration(border: InputBorder.none, prefixText: 'Rp '),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── 4. Batas Stok Minimum & Stok Saat Ini ─────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Batas stok minimum', style: GoogleFonts.inter(fontSize: 12, color: _abuTeks)),
                            const SizedBox(height: 6),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _borderInput),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.centerLeft,
                              child: TextField(
                                controller: _batasMinCtrl,
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: _hijauTua),
                                decoration: const InputDecoration(border: InputBorder.none, suffixText: 'pcs'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Stok saat ini', style: GoogleFonts.inter(fontSize: 12, color: _abuTeks)),
                            const SizedBox(height: 6),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _borderInput),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.centerLeft,
                              child: TextField(
                                controller: _stokAwalCtrl,
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: _hijauTua),
                                decoration: const InputDecoration(border: InputBorder.none, suffixText: 'pcs'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── 5. Tanggal Kedaluwarsa (Opsional) ────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tanggal kedaluwarsa (Expired)',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: _abuTeks),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _hijauMuda,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Opsional',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: _hijauAksi),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _tglKedaluwarsa ?? DateTime.now().add(const Duration(days: 180)),
                        firstDate: DateTime.now().subtract(const Duration(days: 60)),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(primary: _hijauAksi),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() => _tglKedaluwarsa = picked);
                      }
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _tglKedaluwarsa != null ? _hijauAksi : _borderInput,
                          width: _tglKedaluwarsa != null ? 1.5 : 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 18, color: _hijauAksi),
                              const SizedBox(width: 10),
                              Text(
                                _tglKedaluwarsa != null
                                    ? SimwarFormatter.tanggalPendek(_tglKedaluwarsa!)
                                    : 'Pilih tanggal kedaluwarsa produk...',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: _tglKedaluwarsa != null ? FontWeight.w600 : FontWeight.w400,
                                  color: _tglKedaluwarsa != null ? _hijauTua : _abuTeks,
                                ),
                              ),
                            ],
                          ),
                          if (_tglKedaluwarsa != null)
                            GestureDetector(
                              onTap: () => setState(() => _tglKedaluwarsa = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 14, color: Colors.black54),
                              ),
                            )
                          else
                            const Icon(Icons.arrow_drop_down, color: _abuTeks),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ── 6. Barang Titipan Warga (Card Switch) ────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _borderGaris),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Barang titipan warga',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: _hijauTua),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Dicatat terpisah dari pasokan distributor',
                                style: GoogleFonts.inter(fontSize: 11, color: _abuTeks),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isTitipan,
                          activeColor: _hijauAksi,
                          onChanged: (val) => setState(() => _isTitipan = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Tombol Simpan Barang ─────────────────────────────────
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _simpanBarang,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hijauAksi,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Simpan barang',
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  if (_isEdit) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _isSaving ? null : _hapusBarang,
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFC8401E)),
                        label: Text(
                          'Hapus barang',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFC8401E),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFC8401E)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
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
