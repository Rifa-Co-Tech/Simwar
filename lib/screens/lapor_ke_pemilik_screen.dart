import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/laporan_model.dart';
import '../models/pengguna_model.dart';
import '../utils/formatters.dart';
import 'laporan_saya_screen.dart';
import 'laporan_terkirim_screen.dart';

/// SIMWAR — Form Lapor ke Pemilik (POV Penjaga)
/// Figma node: 2073:4002
class LaporKePemilikScreen extends StatefulWidget {
  final PenggunaModel? pengguna;
  const LaporKePemilikScreen({super.key, this.pengguna});

  @override
  State<LaporKePemilikScreen> createState() => _LaporKePemilikScreenState();
}

class _LaporKePemilikScreenState extends State<LaporKePemilikScreen> {
  // ── Palet Warna Desain Resmi SIMWAR ─────────────────────────────────────
  static const Color _bgLayar = Color(0xFFF4EFE0);
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _hijauMuda = Color(0xFFE3EFE8);
  static const Color _abuTeks = Color(0xFF6E7468);
  static const Color _borderGaris = Color(0xFFE4DCC3);
  static const Color _borderInput = Color(0xFFCFC7AA);

  // Kategori sesuai desain
  final List<String> _kategoriList = [
    'Barang rusak',
    'Stok habis',
    'Pelanggan',
    'Kasbon',
    'Lainnya',
  ];

  String _kategoriDipilih = 'Stok habis';
  final TextEditingController _pesanCtrl = TextEditingController(
    text: 'Gula pasir 1 kg habis. Tolong dibelikan lagi sebelum sore.',
  );

  final List<XFile> _fotoFiles = [];
  final ImagePicker _picker = ImagePicker();
  int _jumlahFoto = 0;
  String? _barangTertaut;
  int? _sisaStokTertaut;

  @override
  void dispose() {
    _pesanCtrl.dispose();
    super.dispose();
  }

  void _kirimLaporan() {
    final pesan = _pesanCtrl.text.trim();
    if (pesan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tulis isi laporan terlebih dahulu'),
          backgroundColor: Color(0xFFC8401E),
        ),
      );
      return;
    }

    final waktuSekarang = SimwarFormatter.tanggal(DateTime.now());
    final namaPengirim = widget.pengguna?.nama.isNotEmpty == true
        ? widget.pengguna!.nama
        : 'Rina';

    final laporanBaru = LaporanModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      judul: _kategoriDipilih,
      pengirim: namaPengirim,
      peranPengirim: 'Penjaga',
      waktu: waktuSekarang,
      pesan: pesan,
      namaBarang: _barangTertaut ?? (_kategoriDipilih == 'Stok habis' ? 'Gula Pasir 1 kg' : null),
      sisaStok: _sisaStokTertaut ?? (_kategoriDipilih == 'Stok habis' ? 0 : null),
      status: 'Baru',
      lampiran: _fotoFiles.map((f) => f.path).toList(),
    );

    LaporanStore.instance.tambahLaporan(laporanBaru);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LaporanTerkirimScreen(
          laporan: laporanBaru,
          pengguna: widget.pengguna,
        ),
      ),
    );
  }

  void _tambahFotoDialog() {
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
              'Tambah Bukti Foto',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _hijauTua,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ambil foto langsung dengan kamera atau pilih dari galeri HP',
              style: GoogleFonts.inter(fontSize: 13, color: _abuTeks),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: _hijauMuda,
                child: Icon(Icons.camera_alt, color: _hijauAksi),
              ),
              title: Text('Buka Kamera HP', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  final photo = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1080,
                    maxHeight: 1080,
                    imageQuality: 85,
                  );
                  if (photo != null) {
                    setState(() {
                      _fotoFiles.add(photo);
                      _jumlahFoto = _fotoFiles.length;
                    });
                  }
                } catch (e) {
                  debugPrint('Gagal membuka kamera: $e');
                }
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: _hijauMuda,
                child: Icon(Icons.photo_library, color: _hijauAksi),
              ),
              title: Text('Pilih dari Galeri HP', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  final photo = await _picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1080,
                    maxHeight: 1080,
                    imageQuality: 85,
                  );
                  if (photo != null) {
                    setState(() {
                      _fotoFiles.add(photo);
                      _jumlahFoto = _fotoFiles.length;
                    });
                  }
                } catch (e) {
                  debugPrint('Gagal memilih galeri: $e');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _tautkanBarangDialog() {
    final katalog = [
      {'nama': 'Gula Pasir 1 kg', 'sisa': 0},
      {'nama': 'Minyak Goreng 1 L', 'sisa': 2},
      {'nama': 'Indomie Goreng Spesial', 'sisa': 5},
      {'nama': 'Telur Ayam 1 kg', 'sisa': 1},
      {'nama': 'Beras Ramos 5 kg', 'sisa': 0},
    ];

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
              'Tautkan Barang Warung',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _hijauTua,
              ),
            ),
            const SizedBox(height: 12),
            ...katalog.map((item) {
              final nama = item['nama'] as String;
              final sisa = item['sisa'] as int;
              return ListTile(
                title: Text(nama, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                subtitle: Text('Sisa stok: $sisa', style: GoogleFonts.inter(fontSize: 12, color: _abuTeks)),
                trailing: const Icon(Icons.add_circle_outline, color: _hijauAksi),
                onTap: () {
                  setState(() {
                    _barangTertaut = nama;
                    _sisaStokTertaut = sisa;
                  });
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
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
                              builder: (_) => LaporanSayaScreen(pengguna: widget.pengguna),
                            ),
                          );
                        },
                        child: Text(
                          'Laporan saya',
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
                    'Lapor ke pemilik',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _hijauTua,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Apa saja boleh dilaporkan',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _abuTeks,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── 1. Jenis Laporan ─────────────────────────────────────
                  Text(
                    'Jenis laporan',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _hijauTua,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: _kategoriList.map((kategori) {
                      final bool isSelected = _kategoriDipilih == kategori;
                      return GestureDetector(
                        onTap: () => setState(() => _kategoriDipilih = kategori),
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
                            kategori,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : _hijauTua,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),

                  // ── 2. Ceritakan Singkat ─────────────────────────────────
                  Text(
                    'Ceritakan singkat',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _hijauTua,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _hijauAksi, width: 1.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: TextField(
                      controller: _pesanCtrl,
                      maxLines: 4,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _hijauTua,
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Tulis detail laporan untuk pemilik...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: _abuTeks,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ── 3. Tambahan (opsional) ────────────────────────────────
                  Text(
                    'Tambahan (opsional)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
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
                    child: Column(
                      children: [
                        // Row Tambah Foto
                        InkWell(
                          onTap: _tambahFotoDialog,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/ikon-camera-20x20-23794F.svg',
                                  width: 20,
                                  height: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _jumlahFoto > 0 ? 'Foto ditambahkan ($_jumlahFoto)' : 'Tambah foto',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _hijauTua,
                                    ),
                                  ),
                                ),
                                SvgPicture.asset(
                                  'assets/icons/ikon-chev-18x18-23794F.svg',
                                  width: 18,
                                  height: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Preview Foto yang Baru Saja Diambil/Dipilih
                        if (_fotoFiles.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: SizedBox(
                              height: 64,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _fotoFiles.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, i) {
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: kIsWeb
                                            ? Image.network(
                                                _fotoFiles[i].path,
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                File(_fotoFiles[i].path),
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _fotoFiles.removeAt(i);
                                              _jumlahFoto = _fotoFiles.length;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close, size: 12, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFE8E3D1)),
                        // Row Tautkan Barang
                        InkWell(
                          onTap: _tautkanBarangDialog,
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/ikon-receipt-20x20-23794F.svg',
                                  width: 20,
                                  height: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _barangTertaut != null
                                        ? 'Tertaut: $_barangTertaut'
                                        : 'Tautkan transaksi atau barang',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _hijauTua,
                                    ),
                                  ),
                                ),
                                SvgPicture.asset(
                                  'assets/icons/ikon-chev-18x18-23794F.svg',
                                  width: 18,
                                  height: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Info Hint Text ───────────────────────────────────────
                  Text(
                    'Laporan langsung masuk ke Kotak masuk pemilik dan tidak bisa diubah setelah dikirim.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _abuTeks,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Tombol Kirim ke Pemilik ──────────────────────────────
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _kirimLaporan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hijauAksi,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'Kirim ke pemilik',
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
