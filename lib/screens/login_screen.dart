import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/barang_model.dart';
import '../models/pengaturan_warung_model.dart';
import '../services/auth_service.dart';
import '../services/session_data_service.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import 'register_screen_1.dart';

/// SIMWAR - Layar Login (Pemilik / Penjaga)
/// Diport persis dari Spesifikasi Desain Figma node 2073:3815 & SIMWAR_Login_Pemilik_SPEC.md
class LoginScreen extends StatefulWidget {
  final String? initialNomorHp;
  const LoginScreen({super.key, this.initialNomorHp});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ── Token Warna Desain Figma (Bagian 2 Spec) ────────────────────────
  static const Color _hijauAtas = Color(0xFF1A4838);   // Gradien atas
  static const Color _hijauBawah = Color(0xFF0C261F);  // Gradien bawah
  static const Color _hijauTua = Color(0xFF14372D);    // Teks input & papan
  static const Color _hijau = Color(0xFF23794F);       // Tab aktif & tombol Masuk
  static const Color _krem = Color(0xFFF4EFE0);        // SIMWAR & status bar
  static const Color _kuning = Color(0xFFF8B62B);      // Logo, Azzam, kanopi, papan
  static const Color _merah = Color(0xFFC8401E);       // Palang, pintu, pot
  static const Color _garis = Color(0xFFE4DCC3);       // Border kartu & segmen tab
  static const Color _garisInput = Color(0xFFCFC7AA);  // Border input
  static const Color _teks = Color(0xFF1F2D26);        // Teks tab sekunder & link

  // ── State Interaksi ──────────────────────────────────────────────────
  String _peranDipilih = 'Pemilik'; // 'Pemilik' | 'Penjaga'
  bool _sandiTerlihat = false;
  bool _isLoading = false;
  String? _errorMsg;

  final _teleponCtrl = TextEditingController();
  final _sandiCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _isiNomorTerdaftarAwal();
  }

  Future<void> _isiNomorTerdaftarAwal() async {
    if (widget.initialNomorHp != null && widget.initialNomorHp!.isNotEmpty) {
      if (mounted) {
        setState(() => _teleponCtrl.text = widget.initialNomorHp!);
      }
      return;
    }
    final regPhone = await _authService.getRegisteredPhone(_peranDipilih);
    if (mounted && regPhone.isNotEmpty) {
      setState(() => _teleponCtrl.text = regPhone);
    }
  }

  @override
  void dispose() {
    _teleponCtrl.dispose();
    _sandiCtrl.dispose();
    super.dispose();
  }

  Future<void> _switchPeran(String peran) async {
    if (_peranDipilih == peran) return;
    setState(() {
      _peranDipilih = peran;
      _errorMsg = null;
      _teleponCtrl.clear();
    });
    final regPhone = await _authService.getRegisteredPhone(peran);
    if (mounted && _peranDipilih == peran && regPhone.isNotEmpty) {
      setState(() => _teleponCtrl.text = regPhone);
    }
  }

  // ── Submit Login ─────────────────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final pengguna = await _authService.login(
        nomorHp: _teleponCtrl.text.trim(),
        password: _sandiCtrl.text,
        peran: _peranDipilih,
      );

      if (!mounted) return;

      if (pengguna != null) {
        // Muat seluruh data warung milik akun aktif (Offline SharedPreferences + Supabase Cloud)
        await SessionDataService.loadAllForUser(pengguna);
        BarangStore.instance.sinkronkanDariSupabase().catchError((_) {});

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => HomeScreen(pengguna: pengguna),
            transitionsBuilder: (_, anim, __, child) {
              final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.03),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 380),
          ),
        );
      } else {
        setState(() {
          _errorMsg =
              'Nomor HP belum terdaftar atau kata sandi $_peranDipilih tidak sesuai. Pastikan Anda sudah mendaftar.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = 'Gagal masuk: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('>>> [DEBUG] LoginScreen build() running!');
    return Scaffold(
      backgroundColor: _hijauBawah,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_hijauAtas, _hijauBawah],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── BAGIAN ATAS: Dekorasi, Status Bar, Brand, Warung ──
                    SizedBox(
                      height: 424,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 1. Dekorasi Latar (Lingkaran & Titik Emas)
                          Positioned(
                            left: 0,
                            top: 0,
                            right: 0,
                            height: 430,
                            child: SvgPicture.asset(
                              'assets/dekorasi.svg',
                              fit: BoxFit.fill,
                            ),
                          ),

                          // 2. Status Bar Visual (Figma Mock)
                          Positioned(
                            left: 28,
                            right: 28,
                            top: 13,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '09.41',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _krem,
                                  ),
                                ),
                                SvgPicture.asset(
                                  'assets/status-bar.svg',
                                  width: 62,
                                  height: 12,
                                ),
                              ],
                            ),
                          ),

                          // 3. Brand: Logo, Title SIMWAR, Subtitle Warung Azzam
                          Positioned(
                            left: 24,
                            top: 40,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _kuning,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/ikon-stok.svg',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 24,
                            top: 92,
                            child: Text(
                              'SIMWAR',
                              style: GoogleFonts.fraunces(
                                fontSize: 50,
                                fontWeight: FontWeight.w900,
                                color: _krem,
                                letterSpacing: 3.0,
                                height: 1.0,
                              ),
                            ),
                          ),

                          Positioned(
                            left: 26,
                            right: 26,
                            top: 150,
                            child: Text(
                              PengaturanStore.instance.pengaturan.namaWarung,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.fraunces(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.italic,
                                color: _kuning,
                                height: 1.0,
                              ),
                            ),
                          ),

                          // 4. Ilustrasi Warung Azzam Geometri Tetap (390 x 230 @ top 190)
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 190,
                            child: Center(
                              child: _buildIlustrasiWarung(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── BAGIAN BAWAH: Kartu Form (Radius 36 top) ─────────
                    _buildKartuForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── 4.4 Ilustrasi Warung Azzam (Geometri Tetap 390x230) ──────────────
  Widget _buildIlustrasiWarung() {
    return SizedBox(
      width: 390,
      height: 230,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Tanah: left 58, top 198, w 274, h 8, rgba(35,121,79,.9), r4
          Positioned(
            left: 58,
            top: 198,
            child: Container(
              width: 274,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xE623794F),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Badan Toko: left 90, top 60, w 210, h 140, #e8e0c8, r10
          Positioned(
            left: 90,
            top: 60,
            child: Container(
              width: 210,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E0C8),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Jendela: left 104, top 110, w 100, h 70, rgba(20,55,45,.95), r10
          Positioned(
            left: 104,
            top: 110,
            child: Container(
              width: 100,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xF214372D),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Rak 1: left 112, top 136, w 84, h 4, rgba(244,239,224,.85), r2
          Positioned(
            left: 112,
            top: 136,
            child: Container(
              width: 84,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xD9F4EFE0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Rak 2: left 112, top 162, w 84, h 4, rgba(244,239,224,.85), r2
          Positioned(
            left: 112,
            top: 162,
            child: Container(
              width: 84,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xD9F4EFE0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Toples atas 1–4 (top 122, 14x14)
          Positioned(
            left: 116,
            top: 122,
            child: SvgPicture.asset('assets/toples-1.svg', width: 14, height: 14),
          ),
          Positioned(
            left: 134,
            top: 122,
            child: SvgPicture.asset('assets/toples-2.svg', width: 14, height: 14),
          ),
          Positioned(
            left: 152,
            top: 122,
            child: SvgPicture.asset('assets/toples-3.svg', width: 14, height: 14),
          ),
          Positioned(
            left: 170,
            top: 122,
            child: SvgPicture.asset('assets/toples-4.svg', width: 14, height: 14),
          ),

          // Toples bawah 1–4 (top 148, 14x14)
          Positioned(
            left: 122,
            top: 148,
            child: SvgPicture.asset('assets/toples-3.svg', width: 14, height: 14),
          ),
          Positioned(
            left: 140,
            top: 148,
            child: SvgPicture.asset('assets/toples-1.svg', width: 14, height: 14),
          ),
          Positioned(
            left: 158,
            top: 148,
            child: SvgPicture.asset('assets/toples-4.svg', width: 14, height: 14),
          ),
          Positioned(
            left: 176,
            top: 148,
            child: SvgPicture.asset('assets/toples-2.svg', width: 14, height: 14),
          ),

          // Pintu: left 222, top 128, w 60, h 72, #c8401e, r30 sudut atas
          Positioned(
            left: 222,
            top: 128,
            child: Container(
              width: 60,
              height: 72,
              decoration: const BoxDecoration(
                color: _merah,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
            ),
          ),

          // Gagang Pintu: left 266, top 162, 6x6
          Positioned(
            left: 266,
            top: 162,
            child: SvgPicture.asset('assets/gagang-pintu.svg', width: 6, height: 6),
          ),

          // Kanopi 1–6 (top 50, w 40, h 34, berselang kuning/putih)
          Positioned(
            left: 75,
            top: 50,
            child: Container(width: 40, height: 34, color: _kuning),
          ),
          Positioned(
            left: 115,
            top: 50,
            child: Container(width: 40, height: 34, color: Colors.white),
          ),
          Positioned(
            left: 155,
            top: 50,
            child: Container(width: 40, height: 34, color: _kuning),
          ),
          Positioned(
            left: 195,
            top: 50,
            child: Container(width: 40, height: 34, color: Colors.white),
          ),
          Positioned(
            left: 235,
            top: 50,
            child: Container(width: 40, height: 34, color: _kuning),
          ),
          Positioned(
            left: 275,
            top: 50,
            child: Container(width: 40, height: 34, color: Colors.white),
          ),

          // Lengkung Kanopi 1–6 (top 72, w 40, h 24)
          Positioned(
            left: 75,
            top: 72,
            child: SvgPicture.asset('assets/lengkung-1.svg', width: 40, height: 24),
          ),
          Positioned(
            left: 115,
            top: 72,
            child: SvgPicture.asset('assets/lengkung-2.svg', width: 40, height: 24),
          ),
          Positioned(
            left: 155,
            top: 72,
            child: SvgPicture.asset('assets/lengkung-1.svg', width: 40, height: 24),
          ),
          Positioned(
            left: 195,
            top: 72,
            child: SvgPicture.asset('assets/lengkung-2.svg', width: 40, height: 24),
          ),
          Positioned(
            left: 235,
            top: 72,
            child: SvgPicture.asset('assets/lengkung-1.svg', width: 40, height: 24),
          ),
          Positioned(
            left: 275,
            top: 72,
            child: SvgPicture.asset('assets/lengkung-2.svg', width: 40, height: 24),
          ),

          // Palang Kanopi: left 70, top 40, w 250, h 12, #c8401e, r6
          Positioned(
            left: 70,
            top: 40,
            child: Container(
              width: 250,
              height: 12,
              decoration: BoxDecoration(
                color: _merah,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),

          // Papan "BUKA": left 145, top 12, w 100, h 24, #f8b62b, r12
          Positioned(
            left: 145,
            top: 12,
            child: Container(
              width: 100,
              height: 24,
              decoration: BoxDecoration(
                color: _kuning,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'BUKA',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.32,
                    color: _hijauTua,
                  ),
                ),
              ),
            ),
          ),

          // Pot Tanaman: left 62, top 182, w 22, h 16, #c8401e, r4
          Positioned(
            left: 62,
            top: 182,
            child: Container(
              width: 22,
              height: 16,
              decoration: BoxDecoration(
                color: _merah,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Daun 1: left 58, top 154, w 28, h 28
          Positioned(
            left: 58,
            top: 154,
            child: SvgPicture.asset('assets/daun-1.svg', width: 28, height: 28),
          ),

          // Daun 2: left 72, top 144, w 20, h 26
          Positioned(
            left: 72,
            top: 144,
            child: SvgPicture.asset('assets/daun-2.svg', width: 20, height: 26),
          ),

          // Peti: left 312, top 176, w 34, h 22, rgba(244,239,224,.95), r4
          Positioned(
            left: 312,
            top: 176,
            child: Container(
              width: 34,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xF2F4EFE0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Buah 1: left 316, top 164, 13x13
          Positioned(
            left: 316,
            top: 164,
            child: SvgPicture.asset('assets/buah-1.svg', width: 13, height: 13),
          ),

          // Buah 2: left 331, top 162, 13x13
          Positioned(
            left: 331,
            top: 162,
            child: SvgPicture.asset('assets/buah-2.svg', width: 13, height: 13),
          ),
        ],
      ),
    );
  }

  // ── 4.5 Kartu Form Login (Layout Normal Flex) ────────────────────────
  Widget _buildKartuForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        border: Border(
          top: BorderSide(color: _garis, width: 1),
          left: BorderSide(color: _garis, width: 1),
          right: BorderSide(color: _garis, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1414382E),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Segmen Tab Peran (342 x 52, r26, border _garis)
            Container(
              height: 52,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: _garis, width: 1),
              ),
              child: Row(
                children: [
                  // Tab Pemilik
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _switchPeran('Pemilik'),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: _peranDipilih == 'Pemilik'
                              ? _hijau
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Center(
                          child: Text(
                            'Pemilik',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _peranDipilih == 'Pemilik'
                                  ? Colors.white
                                  : _teks,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Tab Penjaga
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _switchPeran('Penjaga'),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: _peranDipilih == 'Penjaga'
                              ? _hijau
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Center(
                          child: Text(
                            'Penjaga',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _peranDipilih == 'Penjaga'
                                  ? Colors.white
                                  : _teks,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Input Telepon (h=52, r16, border _garisInput)
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _garisInput, width: 1),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  SvgPicture.asset(
                    'assets/ikon-telepon.svg',
                    width: 18,
                    height: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _teleponCtrl,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _hijauTua,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Masukkan nomor HP terdaftar',
                        hintStyle: TextStyle(
                          color: Color(0xFF9BA39D),
                          fontSize: 14,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Nomor telepon wajib diisi';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 3. Input Sandi (h=52, r16, border _garisInput, toggle mata)
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _garisInput, width: 1),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  SvgPicture.asset(
                    'assets/ikon-kunci.svg',
                    width: 18,
                    height: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _sandiCtrl,
                      obscureText: !_sandiTerlihat,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _hijauTua,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Masukkan kata sandi',
                        hintStyle: TextStyle(
                          color: Color(0xFF9BA39D),
                          fontSize: 14,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Kata sandi wajib diisi';
                        }
                        return null;
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() => _sandiTerlihat = !_sandiTerlihat);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/ikon-mata.svg',
                        width: 18,
                        height: 18,
                        colorFilter: _sandiTerlihat
                            ? const ColorFilter.mode(_hijau, BlendMode.srcIn)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),

            // Tampilan Pesan Error jika ada
            if (_errorMsg != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF8B4B4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: _merah, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMsg!,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9B1C1C),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // 4. Tombol Masuk (342 x 54, r27, hijau #23794F, teks putih Inter 700 16px)
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hijau,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Masuk',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '→',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 28),

            // 5. Tautan Daftar & Lupa Kata Sandi
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Lupa kata sandi?',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: _hijau,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen1(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Belum punya akun? Buat profil pemilik',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _teks,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
