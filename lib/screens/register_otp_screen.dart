import 'dart:async';
import 'package:flutter/material.dart';
import '../services/otp_service.dart';
import 'register_screen_2.dart';

class RegisterOtpScreen extends StatefulWidget {
  final String nama;
  final String nomorHp;
  final String namaWarung;
  final String password;

  const RegisterOtpScreen({
    super.key,
    required this.nama,
    required this.nomorHp,
    required this.namaWarung,
    required this.password,
  });

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  static const Color _hijauTua = Color(0xFF1A3C2E);
  static const Color _creamBg = Color(0xFFF6F2EA);

  late List<TextEditingController> _otpCtrls;
  late List<FocusNode> _focusNodes;

  int _timerSeconds = 42;
  Timer? _timer;
  bool _isResending = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    // Kotak dibuat kosong agar pengguna mengetik kode sendiri
    _otpCtrls = List.generate(
      6,
      (i) => TextEditingController(text: ''),
    );
    _focusNodes = List.generate(6, (i) => FocusNode());
    _startTimer();
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

  @override
  void dispose() {
    for (var c in _otpCtrls) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resendOtp() async {
    setState(() => _isResending = true);
    final res = await OtpService.sendOtp(phone: widget.nomorHp);
    if (!mounted) return;
    setState(() => _isResending = false);

    for (int i = 0; i < 6; i++) {
      _otpCtrls[i].clear();
    }

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode OTP baru telah dikirimkan ke WhatsApp Anda!'),
          backgroundColor: Color(0xFF1A3C2E),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kode OTP baru: ${res['otp']} (Scan QR di Fonnte agar pesan terkirim ke WA)'),
          backgroundColor: Colors.amber.shade900,
          duration: const Duration(seconds: 4),
        ),
      );
    }

    _startTimer();
  }

  void _onVerifikasi() {
    final inputOtp = _otpCtrls.map((c) => c.text).join();
    if (inputOtp.length < 6) {
      setState(() => _errorMsg = 'Masukkan seluruh 6 digit kode OTP');
      return;
    }

    if (!OtpService.verifyOtp(inputOtp)) {
      setState(() => _errorMsg = 'Kode OTP tidak cocok. Silakan coba lagi.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterScreen2(
          nama: widget.nama,
          nomorHp: widget.nomorHp,
          namaWarung: widget.namaWarung,
          password: widget.password,
        ),
      ),
    );
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
              const SizedBox(height: 18),

              // ── Judul Halaman ─────────────────────────────
              const Text(
                'Kode verifikasi',
                style: TextStyle(
                  color: _hijauTua,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Kode 6 digit sudah dikirim ke ${widget.nomorHp} via WhatsApp',
                style: const TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),

              // ── Kotak OTP 6 Digit Interaktif ──────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 46,
                    height: 52,
                    child: TextFormField(
                      controller: _otpCtrls[i],
                      focusNode: _focusNodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: _hijauTua,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: _otpCtrls[i].text.isNotEmpty ? _hijauTua : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: _otpCtrls[i].text.isNotEmpty ? _hijauTua : Colors.grey.shade300,
                            width: _otpCtrls[i].text.isNotEmpty ? 1.5 : 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: _hijauTua, width: 2),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() => _errorMsg = null);
                        if (val.isNotEmpty && i < 5) {
                          _focusNodes[i + 1].requestFocus();
                        } else if (val.isEmpty && i > 0) {
                          _focusNodes[i - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),

              if (_errorMsg != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMsg!,
                  style: const TextStyle(color: Colors.red, fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3EDE6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 15, color: _hijauTua),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pesan terkirim ke WhatsApp Anda. Buka chat "Pesan ke diri sendiri" (You) di aplikasi WhatsApp ponsel Anda.',
                        style: TextStyle(color: _hijauTua, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Timer Kirim Ulang ─────────────────────────
              Row(
                children: [
                  Text(
                    _timerSeconds > 0
                        ? 'Kirim ulang kode dalam 0:${_timerSeconds.toString().padLeft(2, '0')}'
                        : 'Belum menerima kode?',
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_timerSeconds == 0) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isResending ? null : _resendOtp,
                      child: Text(
                        _isResending ? 'Mengirim...' : 'Kirim ulang WhatsApp',
                        style: const TextStyle(
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
              const SizedBox(height: 36),

              // ── Tombol Verifikasi dan Lanjut ───────────────
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _onVerifikasi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hijauTua,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Verifikasi dan lanjut',
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
