import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen_1.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ── Palet Warna Desain Figma Baru ───────────────────────────
  static const Color _bgGradienAtas = Color(0xFF1A4838);   // Dark forest green
  static const Color _bgGradienBawah = Color(0xFF0C261F);  // Deep emerald
  static const Color _kremTeks = Color(0xFFF4EFE0);        // Cream for SIMWAR
  static const Color _emasKuning = Color(0xFFF8B62B);      // Gold for Azzam & accent
  static const Color _hijauAksi = Color(0xFF23794F);       // Primary button green
  static const Color _teksGelap = Color(0xFF14372D);       // Deep green text
  static const Color _borderCard = Color(0xFFE4DCC3);      // Card border
  static const Color _borderInput = Color(0xFFCFC7AA);     // Input border
  static const Color _merahTenda = Color(0xFFC8401E);      // Red canopy/door accent

  // ── State ───────────────────────────────────────────────────
  String _peranDipilih = 'Pemilik'; // 'Pemilik' | 'Penjaga'
  bool _passwordVisible = false;
  bool _isLoading = false;
  String? _errorMsg;

  final _nomorHpCtrl = TextEditingController(text: '0812 3456 7890');
  final _passwordCtrl = TextEditingController(text: '12345678');
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  @override
  void dispose() {
    _nomorHpCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _switchPeran(String peran) {
    if (_peranDipilih == peran) return;
    setState(() {
      _peranDipilih = peran;
      _errorMsg = null;
      if (peran == 'Pemilik') {
        _nomorHpCtrl.text = '0812 3456 7890';
      } else {
        _nomorHpCtrl.text = '0813 9876 5432';
      }
    });
  }

  // ── Handler Login ────────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final pengguna = await _authService.login(
        nomorHp: _nomorHpCtrl.text.trim(),
        password: _passwordCtrl.text,
        peran: _peranDipilih,
      );

      if (!mounted) return;

      if (pengguna != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(pengguna: pengguna),
          ),
        );
      } else {
        setState(() {
          _errorMsg =
              'Nomor HP atau kata sandi $_peranDipilih salah. Silakan periksa kembali.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = 'Terjadi kesalahan: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgGradienAtas, _bgGradienBawah],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // ── 1. HEADER BRANDING (SIMWAR Warung Azzam) ──────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo Box Emas
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _emasKuning,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.storefront_rounded,
                                color: _teksGelap,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Judul SIMWAR
                          const Text(
                            'SIMWAR',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: _kremTeks,
                              letterSpacing: 2.5,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Sub-judul Warung Azzam
                          const Text(
                            'Warung Azzam',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: _emasKuning,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── 2. ILUSTRASI WARUNG AZZAM SESUAI FIGMA ────────
                    _buildIlustrasiWarung(),

                    const Spacer(),

                    // ── 3. FORM LOGIN BOTTOM CARD ────────────────────
                    _buildFormCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Ilustrasi Warung Azzam ───────────────────────────────────
  Widget _buildIlustrasiWarung() {
    return Center(
      child: SizedBox(
        width: 320,
        height: 175,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Garis Tanah / Platform
            Positioned(
              bottom: 0,
              child: Container(
                width: 280,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF23794F).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // Badan Toko
            Positioned(
              bottom: 8,
              child: Container(
                width: 210,
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E0C8),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Jendela Toko (Etalase)
                    Positioned(
                      left: 14,
                      top: 40,
                      child: Container(
                        width: 100,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF14372D).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            // Rak 1
                            Positioned(
                              top: 24,
                              left: 8,
                              right: 8,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4EFE0).withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            // Toples-toples di Rak 1
                            Positioned(
                              top: 10,
                              left: 12,
                              right: 12,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildToplesItem(const Color(0xFFF8B62B)),
                                  _buildToplesItem(const Color(0xFFC8401E)),
                                  _buildToplesItem(const Color(0xFF23794F)),
                                  _buildToplesItem(const Color(0xFFF4EFE0)),
                                ],
                              ),
                            ),
                            // Rak 2
                            Positioned(
                              top: 48,
                              left: 8,
                              right: 8,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4EFE0).withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            // Toples-toples di Rak 2
                            Positioned(
                              top: 34,
                              left: 14,
                              right: 14,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildToplesItem(const Color(0xFFC8401E)),
                                  _buildToplesItem(const Color(0xFFF8B62B)),
                                  _buildToplesItem(const Color(0xFF23794F)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Pintu Merah Toko
                    Positioned(
                      right: 20,
                      top: 40,
                      child: Container(
                        width: 58,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: _merahTenda,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(26),
                            topRight: Radius.circular(26),
                          ),
                        ),
                        child: Align(
                          alignment: const Alignment(0.65, 0.1),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: _emasKuning,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Kanopi / Tenda Bergaris Kuning-Putih
            Positioned(
              bottom: 108,
              child: SizedBox(
                width: 240,
                child: Column(
                  children: [
                    // Palang Merah Kanopi
                    Container(
                      width: 240,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _merahTenda,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    // Garis-garis Kanopi (Kuning - Putih)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (i) {
                        final isYellow = i % 2 == 0;
                        return Container(
                          width: 38,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isYellow ? _emasKuning : Colors.white,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // Papan "BUKA" di Atas Kanopi
            Positioned(
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                decoration: BoxDecoration(
                  color: _emasKuning,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'BUKA',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: _teksGelap,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ),

            // Pot Tanaman di Kiri
            Positioned(
              left: 28,
              bottom: 8,
              child: Column(
                children: [
                  const Icon(
                    Icons.eco_rounded,
                    color: Color(0xFF23794F),
                    size: 24,
                  ),
                  Container(
                    width: 20,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _merahTenda,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),

            // Kotak Buah di Kanan
            Positioned(
              right: 28,
              bottom: 8,
              child: Container(
                width: 30,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EFE0).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Icon(
                    Icons.apple_rounded,
                    color: _emasKuning,
                    size: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToplesItem(Color color) {
    return Container(
      width: 13,
      height: 13,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  // ── Form Login Card (Bottom Sheet Style) ──────────────────────
  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1414372D),
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sakelar Tab Pemilik / Penjaga
            _buildPeranSelector(),
            const SizedBox(height: 20),

            // Input Nomor HP
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _borderInput, width: 1.2),
              ),
              child: TextFormField(
                controller: _nomorHpCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _teksGelap,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.phone_outlined, color: _hijauAksi, size: 20),
                  hintText: '0812 3456 7890',
                  hintStyle: TextStyle(color: Color(0xFF9EA399), fontSize: 14),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nomor HP tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 14),

            // Input Kata Sandi
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _borderInput, width: 1.2),
              ),
              child: TextFormField(
                controller: _passwordCtrl,
                obscureText: !_passwordVisible,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _teksGelap,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.lock_outline, color: _hijauAksi, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF6E7468),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _passwordVisible = !_passwordVisible);
                    },
                  ),
                  hintText: '••••••••',
                  hintStyle: const TextStyle(color: Color(0xFF9EA399), fontSize: 16),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Kata sandi tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ),

            // Pesan Error jika Login Gagal
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
                    const Icon(Icons.error_outline, color: Color(0xFFC8401E), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMsg!,
                        style: const TextStyle(
                          color: Color(0xFF9B1C1C),
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

            // Tombol Masuk →
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hijauAksi,
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
                    : Text(
                        'Masuk sebagai $_peranDipilih  →',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 18),

            // Tautan Registrasi / Bantuan
            Center(
              child: _peranDipilih == 'Pemilik'
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen1(),
                          ),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: 'Belum punya akun? ',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFF6E7468),
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: 'Buat profil pemilik',
                              style: TextStyle(
                                color: _hijauAksi,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Text(
                      'Akun penjaga didaftarkan oleh Pemilik Warung',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF6E7468),
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sakelar Tab [Pemilik | Penjaga] ───────────────────────────
  Widget _buildPeranSelector() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _borderCard, width: 1.2),
      ),
      child: Row(
        children: [
          // Tab Pemilik
          Expanded(
            child: GestureDetector(
              onTap: () => _switchPeran('Pemilik'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 44,
                decoration: BoxDecoration(
                  color: _peranDipilih == 'Pemilik' ? _hijauAksi : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Text(
                    'Pemilik',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _peranDipilih == 'Pemilik'
                          ? Colors.white
                          : const Color(0xFF1F2D26),
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 44,
                decoration: BoxDecoration(
                  color: _peranDipilih == 'Penjaga' ? _hijauAksi : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Text(
                    'Penjaga',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _peranDipilih == 'Penjaga'
                          ? Colors.white
                          : const Color(0xFF1F2D26),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
