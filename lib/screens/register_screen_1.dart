import 'package:flutter/material.dart';
import '../services/otp_service.dart';
import 'register_otp_screen.dart';

class RegisterScreen1 extends StatefulWidget {
  const RegisterScreen1({super.key});

  @override
  State<RegisterScreen1> createState() => _RegisterScreen1State();
}

class _RegisterScreen1State extends State<RegisterScreen1> {
  static const Color _hijauTua = Color(0xFF1A3C2E);
  static const Color _creamBg = Color(0xFFF6F2EA);

  final _namaCtrl = TextEditingController();
  final _nomorHpCtrl = TextEditingController();
  final _namaWarungCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordConfirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSendingOtp = false;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nomorHpCtrl.dispose();
    _namaWarungCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLanjut() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSendingOtp = true);

    final res = await OtpService.sendOtp(phone: _nomorHpCtrl.text.trim());
    if (!mounted) return;
    setState(() => _isSendingOtp = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kode OTP berhasil dikirim ke WhatsApp ${_nomorHpCtrl.text}!'),
          backgroundColor: const Color(0xFF1A3C2E),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kode OTP: ${res['otp']} (Scan QR di Fonnte agar pesan masuk langsung ke WA)'),
          backgroundColor: Colors.amber.shade900,
          duration: const Duration(seconds: 4),
        ),
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterOtpScreen(
          nama: _namaCtrl.text.trim(),
          nomorHp: _nomorHpCtrl.text.trim(),
          namaWarung: _namaWarungCtrl.text.trim(),
          password: _passwordCtrl.text,
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
          child: Form(
            key: _formKey,
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
                  'Buat profil pemilik',
                  style: TextStyle(
                    color: _hijauTua,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Langkah 1 dari 2 - data pemilik dan warung',
                  style: TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),

                // ── Progress Bar (50%) ─────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: Color(0xFFDDD7CC),
                    valueColor: AlwaysStoppedAnimation(_hijauTua),
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Lingkaran Tambah Foto ─────────────────────
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4EDE7),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF2D6A4F).withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.crop_free_rounded,
                            size: 32,
                            color: _hijauTua,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tambah foto',
                        style: TextStyle(
                          color: _hijauTua,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Input: Nama Lengkap ───────────────────────
                _buildFieldLabel('Nama lengkap'),
                _buildInputField(
                  controller: _namaCtrl,
                  hint: 'Masukkan nama lengkap pemilik',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 14),

                // ── Input: Nomor HP ───────────────────────────
                _buildFieldLabel('Nomor HP'),
                _buildInputField(
                  controller: _nomorHpCtrl,
                  hint: 'Contoh: 0812xxxxxxxx',
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Nomor HP wajib diisi';
                    if (v.replaceAll(RegExp(r'\s+|-'), '').length < 9) {
                      return 'Masukkan nomor HP yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ── Input: Nama Warung ────────────────────────
                _buildFieldLabel('Nama warung'),
                _buildInputField(
                  controller: _namaWarungCtrl,
                  hint: 'Contoh: Warung Azzam / Warung Berkah',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama warung wajib diisi' : null,
                ),
                const SizedBox(height: 14),

                // ── Input: Kata Sandi ─────────────────────────
                _buildFieldLabel('Kata sandi'),
                _buildInputField(
                  controller: _passwordCtrl,
                  hint: 'Minimal 6 karakter',
                  obscure: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
                    if (v.length < 6) return 'Kata sandi minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ── Input: Ulangi Kata Sandi ──────────────────
                _buildFieldLabel('Ulangi kata sandi'),
                _buildInputField(
                  controller: _passwordConfirmCtrl,
                  hint: 'Ketik ulang kata sandi',
                  obscure: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ulangi kata sandi';
                    if (v != _passwordCtrl.text) return 'Kata sandi tidak sama';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // ── Tombol Lanjut ─────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSendingOtp ? null : _onLanjut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hijauTua,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSendingOtp
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Lanjut',
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
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF666666),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _hijauTua,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
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
      validator: validator,
    );
  }
}
