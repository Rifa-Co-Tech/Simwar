import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pengguna_model.dart';

/// SIMWAR — Tambah Akun Penjaga (POV Pemilik)
/// Figma node: 2010:1061
class TambahAkunPenjagaScreen extends StatefulWidget {
  final PenggunaModel? pengguna;
  const TambahAkunPenjagaScreen({super.key, this.pengguna});

  @override
  State<TambahAkunPenjagaScreen> createState() => _TambahAkunPenjagaScreenState();
}

class _TambahAkunPenjagaScreenState extends State<TambahAkunPenjagaScreen> {
  static const Color _bgLayar = Color(0xFFF4EFE0);
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _hijauMuda = Color(0xFFE3EFE8);
  static const Color _abuTeks = Color(0xFF6E7468);
  static const Color _borderGaris = Color(0xFFE4DCC3);
  static const Color _borderInput = Color(0xFFCFC7AA);

  final TextEditingController _namaCtrl = TextEditingController(text: 'Rina');
  final TextEditingController _hpCtrl = TextEditingController(text: '0813 5555 0101');
  final TextEditingController _sandiCtrl = TextEditingController(text: 'rina2026');
  bool _sandiTerlihat = false;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _hpCtrl.dispose();
    _sandiCtrl.dispose();
    super.dispose();
  }

  void _simpanAkun() {
    final nama = _namaCtrl.text.trim();
    final hp = _hpCtrl.text.trim();
    final sandi = _sandiCtrl.text.trim();

    if (nama.isEmpty || hp.isEmpty || sandi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi semua data akun penjaga'),
          backgroundColor: Color(0xFFC8401E),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Akun Penjaga Berhasil Dibuat!',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _hijauTua),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Penjaga dapat langsung masuk menggunakan:', style: GoogleFonts.inter(color: _abuTeks)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _hijauMuda,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nama: $nama', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: _hijauTua)),
                  Text('No. HP: $hp', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: _hijauTua)),
                  Text('Sandi: $sandi', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: _hijauTua)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _hijauAksi,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
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
                        'Tambah akun penjaga',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _hijauTua,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Avatar Placeholder (Figma 84x84) ──────────────────────
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: const BoxDecoration(
                            color: _hijauMuda,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.camera_alt,
                              size: 32,
                              color: _hijauAksi,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tambah foto (opsional)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2D26),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Field 1: Nama Penjaga ────────────────────────────────
                  Text(
                    'Nama penjaga',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _abuTeks,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _borderInput, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _namaCtrl,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _hijauTua,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Contoh: Rina',
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Field 2: Nomor HP ────────────────────────────────────
                  Text(
                    'Nomor HP',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _abuTeks,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _borderInput, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _hpCtrl,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _hijauTua,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Contoh: 0813 5555 0101',
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Field 3: Kata Sandi Sementara ────────────────────────
                  Text(
                    'Kata sandi sementara',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _abuTeks,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _borderInput, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _sandiCtrl,
                            obscureText: !_sandiTerlihat,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: _hijauTua,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Minimal 6 karakter',
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _sandiTerlihat = !_sandiTerlihat),
                          icon: Icon(
                            _sandiTerlihat ? Icons.visibility_off : Icons.visibility,
                            color: _abuTeks,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ── Tombol Simpan Akun Penjaga ────────────────────────────
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _simpanAkun,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hijauAksi,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      child: Text(
                        'Simpan akun penjaga',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Penjaga diminta mengganti kata sandi saat pertama masuk.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: _abuTeks,
                    ),
                    textAlign: TextAlign.center,
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
