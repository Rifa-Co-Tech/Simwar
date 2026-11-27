import 'package:flutter/material.dart';
import '../models/barang_model.dart';
import '../models/pengaturan_warung_model.dart';
import '../services/auth_service.dart';
import '../services/session_data_service.dart';
import 'home_screen.dart';
import 'tambah_akun_penjaga_screen.dart';

class RegisterScreen2 extends StatefulWidget {
  final String nama;
  final String nomorHp;
  final String namaWarung;
  final String password;

  const RegisterScreen2({
    super.key,
    required this.nama,
    required this.nomorHp,
    required this.namaWarung,
    required this.password,
  });

  @override
  State<RegisterScreen2> createState() => _RegisterScreen2State();
}

class _RegisterScreen2State extends State<RegisterScreen2> {
  static const Color _hijauTua = Color(0xFF1A3C2E);
  static const Color _creamBg = Color(0xFFF6F2EA);

  String _selectedKedaluwarsa = '7 hari';
  final _batasStokCtrl = TextEditingController(text: '10 pcs');
  bool _tambahPenjaga = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _batasStokCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSelesaiDanMasuk() async {
    setState(() => _isLoading = true);

    try {
      final namaWarungFinal = widget.namaWarung.trim().isNotEmpty
          ? widget.namaWarung.trim()
          : 'Warung Saya';
      final parsedBatas = int.tryParse(
            _batasStokCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          10;
      final batasFinal = parsedBatas > 0 ? parsedBatas : 10;
      final parsedHari = int.tryParse(
            _selectedKedaluwarsa.replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          3;

      // 1. Daftarkan akun ke Supabase & Cache Lokal + Set Scope Akun Baru (terisolasi dari akun/HP lain)
      final authService = AuthService();
      final pengguna = await authService.registerOrUpdateAccount(
        nama: widget.nama,
        nomorHp: widget.nomorHp,
        password: widget.password,
        peran: 'Pemilik',
        namaWarung: namaWarungFinal,
      );
      await authService.saveActiveSession(pengguna);
      await SessionDataService.loadAllForUser(pengguna);

      // 2. Simpan preferensi warung pada scope akun baru
      final cfg = PengaturanStore.instance.pengaturan;
      cfg.namaWarung = namaWarungFinal;
      cfg.pesanHeaderStruk =
          '${namaWarungFinal.toUpperCase()}\nBelanja Hemat, Lengkap & Berkah';
      cfg.noTeleponWarung = widget.nomorHp.trim();
      cfg.batasStokDefault = batasFinal;
      cfg.hariPeringatanKedaluwarsa = parsedHari;
      await PengaturanStore.instance.simpanKeLocalStorage();

      BarangStore.instance.sinkronkanDariSupabase().catchError((_) {});

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => HomeScreen(pengguna: pengguna),
          transitionsBuilder: (_, anim, __, child) {
            final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
            return FadeTransition(opacity: curved, child: child);
          },
          transitionDuration: const Duration(milliseconds: 380),
        ),
        (route) => false,
      );

      if (_tambahPenjaga) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TambahAkunPenjagaScreen(pengguna: pengguna),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _creamBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Tombol Back Bulat ─────────────────────────
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: _hijauTua),
                ),
              ),
              const SizedBox(height: 16),

              // ── Judul Halaman ─────────────────────────────
              const Text(
                'Atur peringatan warung',
                style: TextStyle(
                  color: _hijauTua,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Langkah 2 dari 2 - bisa diubah nanti',
                style: TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),

              // ── Progress Bar (100%) ────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  value: 1.0,
                  backgroundColor: Color(0xFFDDD7CC),
                  valueColor: AlwaysStoppedAnimation(_hijauTua),
                  minHeight: 5,
                ),
              ),
              const SizedBox(height: 28),

              // ── Bagian 1: Ingatkan sebelum kedaluwarsa ────
              const Text(
                'Ingatkan sebelum kedaluwarsa',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Penjaga menerima peringatan sesuai batas ini',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),

              // Chip Pilihan Hari
              Row(
                children: ['7 hari', '14 hari', '30 hari'].map((chip) {
                  final isSelected = _selectedKedaluwarsa == chip;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedKedaluwarsa = chip),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? _hijauTua : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? _hijauTua : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        chip,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF444444),
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ── Bagian 2: Batas stok menipis ───────────────
              const Text(
                'Batas stok menipis (bawaan semua barang)',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _batasStokCtrl,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _hijauTua,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _hijauTua, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Bisa diatur berbeda untuk tiap barang di Kelola barang.',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // ── Bagian 3: Tambah akun penjaga sekarang ─────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tambah akun penjaga sekarang',
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Atau nanti dari menu Profil - Tim warung',
                            style: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _tambahPenjaga,
                      activeColor: _hijauTua,
                      onChanged: (v) => setState(() => _tambahPenjaga = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // ── Tombol Selesai dan Masuk ───────────────────
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onSelesaiDanMasuk,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hijauTua,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Selesai dan masuk',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
