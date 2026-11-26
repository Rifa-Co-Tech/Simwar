import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/barang_masuk_model.dart';
import '../models/barang_model.dart';
import '../models/kasbon_model.dart';
import '../models/laporan_model.dart';
import '../models/notifikasi_model.dart';
import '../models/pengaturan_warung_model.dart';
import '../models/pengguna_model.dart';
import '../models/rencana_belanja_model.dart';
import '../models/transaksi_model.dart';
import '../services/auth_service.dart';
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

  // 0: Layar Lupa Kata Sandi, 1: Layar Kode OTP dan Sandi Baru
  int _step = 0;

  final _phoneCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  late final List<TextEditingController> _otpCtrls;
  late final List<FocusNode> _otpFocusNodes;

  int _timerSeconds = 42;
  Timer? _timer;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _otpCtrls = List.generate(6, (_) => TextEditingController());
    _otpFocusNodes = List.generate(6, (_) => FocusNode());
    _isiNomorTerdaftar();
  }

  Future<void> _isiNomorTerdaftar() async {
    final phone = await AuthService().getRegisteredPhone('Pemilik');
    if (mounted && phone.isNotEmpty) {
      setState(() => _phoneCtrl.text = phone);
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    for (var c in _otpCtrls) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timerSeconds = 42;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        t.cancel();
      }
    });
  }

  Future<void> _kirimKode() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      setState(() => _errorMsg = 'Masukkan nomor HP yang terdaftar terlebih dahulu.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final res = await OtpService.sendOtp(phone: phone);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _step = 1;
    });
    _startTimer();

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kode OTP telah dikirim ke WhatsApp $phone!'),
          backgroundColor: _hijauTua,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kode OTP: ${res['otp']}'),
          backgroundColor: Colors.amber.shade900,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _simpanDanMasuk() async {
    final inputOtp = _otpCtrls.map((c) => c.text).join();
    if (inputOtp.length < 6 || !OtpService.verifyOtp(inputOtp)) {
      setState(() => _errorMsg = 'Kode OTP 6 digit tidak sesuai.');
      return;
    }

    if (_newPasswordCtrl.text.length < 6) {
      setState(() => _errorMsg = 'Kata sandi baru minimal 6 karakter.');
      return;
    }

    if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      setState(() => _errorMsg = 'Konfirmasi kata sandi baru tidak cocok.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    final cleanHp = AuthService.normalizePhone(_phoneCtrl.text);

    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('pengguna')
          .update({'password': _newPasswordCtrl.text})
          .eq('nomor_hp', cleanHp)
          .select()
          .maybeSingle();

      final authService = AuthService();
      PenggunaModel pengguna;
      if (response != null) {
        pengguna = PenggunaModel.fromMap({
          ...response,
          'nama_warung': PengaturanStore.instance.pengaturan.namaWarung,
        });
      } else {
        final team = await authService.getTeamAccounts();
        final match = team.where((u) => AuthService.normalizePhone(u.nomorHp) == cleanHp).toList();
        if (match.isEmpty) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _errorMsg = 'Nomor HP $cleanHp belum terdaftar di aplikasi.';
          });
          return;
        }
        pengguna = match.first;
      }

      await authService.saveLocalAccount(
        user: pengguna,
        password: _newPasswordCtrl.text,
      );
      await authService.saveActiveSession(pengguna);

      await Future.wait([
        PengaturanStore.instance.muatDariLocalStorage(),
        BarangStore.instance.muatDariLocalStorage(),
        TransaksiStore.instance.muatDariLocalStorage(),
        KasbonStore.instance.muatDariLocalStorage(),
        BarangMasukStore.instance.muatDariLocalStorage(),
        RencanaBelanjaStore.instance.muatDariLocalStorage(),
        LaporanStore.instance.muatDariLocalStorage(),
        NotifikasiStore.instance.muatDariLocalStorage(),
      ]);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(pengguna: pengguna)),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = 'Gagal memperbarui kata sandi: $e';
      });
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _step == 0 ? _buildLayar02() : _buildLayar03(),
            ),
          ),
        ),
      ),
    );
  }

  // ── Layar 02: Lupa Kata Sandi ──────────────────────────────────
  Widget _buildLayar02() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const Text(
          'Lupa kata sandi',
          style: TextStyle(color: _hijauTua, fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'Masukkan nomor HP yang terdaftar. Kami kirim kode verifikasi ke WhatsApp Anda.',
          style: TextStyle(color: Color(0xFF777777), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 24),
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
            hintText: 'Contoh: 0812xxxxxxxx',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _hijauTua, width: 1.5)),
          ),
        ),
        if (_errorMsg != null) ...[
          const SizedBox(height: 10),
          Text(_errorMsg!, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _kirimKode,
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
                : const Text('Kirim kode', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF1DA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF5C842).withValues(alpha: 0.5)),
          ),
          child: const Text(
            'Akun penjaga? Minta pemilik warung mereset atau mendaftarkan ulang kata sandi dari menu Tim warung.',
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
        GestureDetector(
          onTap: () => setState(() {
            _step = 0;
            _errorMsg = null;
          }),
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
        const Text(
          'Buat kata sandi baru',
          style: TextStyle(color: _hijauTua, fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          'Masukkan kode 6 digit yang dikirim ke ${_phoneCtrl.text}',
          style: const TextStyle(color: Color(0xFF777777), fontSize: 12),
        ),
        const SizedBox(height: 20),

        // OTP 6 Digit Interaktif
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) {
            return SizedBox(
              width: 44,
              height: 50,
              child: TextFormField(
                controller: _otpCtrls[i],
                focusNode: _otpFocusNodes[i],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _hijauTua,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _hijauTua, width: 2),
                  ),
                ),
                onChanged: (val) {
                  setState(() => _errorMsg = null);
                  if (val.isNotEmpty && i < 5) {
                    _otpFocusNodes[i + 1].requestFocus();
                  } else if (val.isEmpty && i > 0) {
                    _otpFocusNodes[i - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              _timerSeconds > 0
                  ? 'Kirim ulang kode dalam 0:${_timerSeconds.toString().padLeft(2, '0')}'
                  : 'Belum menerima kode?',
              style: const TextStyle(color: Color(0xFF888888), fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
            if (_timerSeconds == 0) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _kirimKode,
                child: const Text(
                  'Kirim ulang',
                  style: TextStyle(
                    color: _hijauTua,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),

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
            hintText: 'Minimal 6 karakter',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _hijauTua, width: 1.5)),
          ),
        ),
        const SizedBox(height: 14),
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
            hintText: 'Ketik ulang kata sandi baru',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _hijauTua, width: 1.5)),
          ),
        ),
        if (_errorMsg != null) ...[
          const SizedBox(height: 12),
          Text(_errorMsg!, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
        const SizedBox(height: 28),
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
