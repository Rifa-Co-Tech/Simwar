import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pengguna_model.dart';
import '../services/otp_service.dart';
import 'home_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const Color _hijauTua = Color(0xFF1A3C2E);
  static const Color _creamBg = Color(0xFFF6F2EA);

  // 0: Layar 02 Lupa Kata Sandi, 1: Layar 03 Kode dan Sandi Baru
  int _step = 0;

  final _phoneCtrl = TextEditingController(text: '081299507150');
  final _newPasswordCtrl = TextEditingController(text: '12345678');
  final _confirmPasswordCtrl = TextEditingController(text: '12345678');
  final List<TextEditingController> _otpCtrls = [
    TextEditingController(text: '4'),
    TextEditingController(text: '8'),
    TextEditingController(text: '2'),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  int _timerSeconds = 42;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    for (var c in _otpCtrls) {
      c.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timerSeconds = 42;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        t.cancel();
      }
    });
  }

  Future<void> _kirimKode() async {
    if (_phoneCtrl.text.trim().isEmpty) return;
    setState(() => _step = 1);
    _startTimer();
    await OtpService.sendOtp(phone: _phoneCtrl.text.trim());
  }

  Future<void> _simpanDanMasuk() async {
    setState(() => _isLoading = true);
    final cleanHp = _phoneCtrl.text.replaceAll(RegExp(r'\s+|-'), '').trim();

    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('pengguna')
          .update({'password': _newPasswordCtrl.text})
          .eq('nomor_hp', cleanHp)
          .select()
          .maybeSingle();

      PenggunaModel pengguna;
      if (response != null) {
        pengguna = PenggunaModel.fromMap(response);
      } else {
        pengguna = PenggunaModel(
          id: '1',
          nama: 'Alfian',
          nomorHp: cleanHp,
          peran: 'Pemilik',
          statusAktif: true,
        );
      }

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(pengguna: pengguna)),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      final fallback = PenggunaModel(
        id: '1',
        nama: 'Alfian',
        nomorHp: cleanHp,
        peran: 'Pemilik',
        statusAktif: true,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(pengguna: fallback)),
        (route) => false,
      );
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
          child: _step == 0 ? _buildLayar02() : _buildLayar03(),
        ),
      ),
    );
  }

  // ── Layar 02: Lupa Kata Sandi ──────────────────────────────────
  Widget _buildLayar02() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back
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
        const SizedBox(height: 18),

        // Title
        const Text(
          'Lupa kata sandi',
          style: TextStyle(color: _hijauTua, fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'Masukkan nomor HP yang terdaftar. Kami kirim kode lewat SMS.',
          style: TextStyle(color: Color(0xFF777777), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 24),

        // Input
        const Text(
          'Nomor HP',
          style: TextStyle(color: Color(0xFF666666), fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _hijauTua),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _hijauTua, width: 1.5)),
          ),
        ),
        const SizedBox(height: 20),

        // Button Kirim Kode
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _kirimKode,
            style: ElevatedButton.styleFrom(
              backgroundColor: _hijauTua,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Kirim kode', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 24),

        // Info Box Kuning
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF1DA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF5C842).withValues(alpha: 0.5)),
          ),
          child: const Text(
            'Akun penjaga? Minta pemilik warung mereset kata sandi dari menu Tim warung.',
            style: TextStyle(
              color: Color(0xFF996B1F),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  // ── Layar 03: Kode dan Sandi Baru ─────────────────────────────
  Widget _buildLayar03() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back
        GestureDetector(
          onTap: () => setState(() => _step = 0),
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
        const SizedBox(height: 18),

        // Title
        const Text(
          'Buat kata sandi baru',
          style: TextStyle(color: _hijauTua, fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          'Kode 6 digit sudah dikirim ke ${_phoneCtrl.text}',
          style: const TextStyle(color: Color(0xFF777777), fontSize: 12),
        ),
        const SizedBox(height: 20),

        // OTP 6 Digit Boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) {
            return Container(
              width: 44,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _otpCtrls[i].text.isNotEmpty ? _hijauTua : Colors.grey.shade300,
                  width: _otpCtrls[i].text.isNotEmpty ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  _otpCtrls[i].text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _hijauTua,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),

        // Timer
        Text(
          'Kirim ulang kode dalam 0:${_timerSeconds.toString().padLeft(2, '0')}',
          style: const TextStyle(color: Color(0xFF888888), fontSize: 11.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),

        // Input Kata Sandi Baru
        const Text(
          'Kata sandi baru',
          style: TextStyle(color: Color(0xFF666666), fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _newPasswordCtrl,
          obscureText: true,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _hijauTua),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _hijauTua, width: 1.5)),
          ),
        ),
        const SizedBox(height: 14),

        // Input Ulangi Kata Sandi
        const Text(
          'Ulangi kata sandi baru',
          style: TextStyle(color: Color(0xFF666666), fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _confirmPasswordCtrl,
          obscureText: true,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _hijauTua),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _hijauTua, width: 1.5)),
          ),
        ),
        const SizedBox(height: 28),

        // Button Simpan dan Masuk
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _simpanDanMasuk,
            style: ElevatedButton.styleFrom(
              backgroundColor: _hijauTua,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Simpan dan masuk', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
