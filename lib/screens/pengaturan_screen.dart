import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/barang_model.dart';
import '../models/pengaturan_warung_model.dart';
import '../models/pengguna_model.dart';
import '../services/auth_service.dart';
import '../services/session_data_service.dart';
import 'login_screen.dart';
import 'register_screen_1.dart';
import 'tambah_akun_penjaga_screen.dart';

/// SIMWAR — Layar Pengaturan Warung & Profil Pengguna
/// Figma nodes: 2073:3815 (Profil & Akun), 2052:3 (QRIS & Kasir), 2030:36 (Struk Belanja)
class PengaturanScreen extends StatefulWidget {
  final PenggunaModel pengguna;
  const PengaturanScreen({super.key, required this.pengguna});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  // Palet Warna SIMWAR
  static const Color _bgLayar = Color(0xFFF4EFE0);
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _hijauMuda = Color(0xFFE3EFE8);
  static const Color _abuTeks = Color(0xFF6E7468);
  static const Color _borderGaris = Color(0xFFE4DCC3);
  static const Color _borderInput = Color(0xFFCFC7AA);
  static const Color _kuningAksen = Color(0xFFF8B62B);
  static const Color _merahAksen = Color(0xFFC8401E);

  late PenggunaModel _user;
  final PengaturanWarungModel _cfg = PengaturanStore.instance.pengaturan;

  bool get _isPemilik => _user.peran.toLowerCase() == 'pemilik';

  @override
  void initState() {
    super.initState();
    _user = widget.pengguna;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLayar,
      appBar: AppBar(
        backgroundColor: _bgLayar,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _hijauTua, size: 20),
          onPressed: () => Navigator.pop(context, _user),
        ),
        title: Text(
          'Pengaturan & Profil',
          style: GoogleFonts.inter(
            color: _hijauTua,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Profil Pengguna Card
            _buildProfileCard(),
            const SizedBox(height: 20),

            // 2. Data Identitas Warung
            _buildSectionCard(
              title: 'Identitas Warung',
              icon: Icons.storefront_outlined,
              children: [
                _buildInfoRow(
                  label: 'Nama Warung',
                  value: _cfg.namaWarung,
                  onTap: _isPemilik ? _showEditWarungDialog : null,
                ),
                const Divider(color: _borderGaris, height: 16),
                _buildInfoRow(
                  label: 'Alamat',
                  value: _cfg.alamatWarung,
                  onTap: _isPemilik ? _showEditWarungDialog : null,
                ),
                const Divider(color: _borderGaris, height: 16),
                _buildInfoRow(
                  label: 'No. Telepon / WhatsApp',
                  value: _cfg.noTeleponWarung,
                  onTap: _isPemilik ? _showEditWarungDialog : null,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3. Kasir, Struk & QRIS
            _buildSectionCard(
              title: 'Kasir & Pembayaran',
              icon: Icons.point_of_sale_outlined,
              children: [
                _buildSwitchRow(
                  title: 'QRIS Dinamis Warung',
                  subtitle: 'NMID: ${_cfg.nmidQris}',
                  value: _cfg.qrisAktif,
                  onChanged: (val) {
                    setState(() => _cfg.qrisAktif = val);
                    PengaturanStore.instance.simpanKeLocalStorage();
                  },
                ),
                const Divider(color: _borderGaris, height: 16),
                _buildSwitchRow(
                  title: 'Cetak Struk Otomatis',
                  subtitle: 'Langsung buka cetak setelah bayar',
                  value: _cfg.otomatisCetakStruk,
                  onChanged: (val) {
                    setState(() => _cfg.otomatisCetakStruk = val);
                    PengaturanStore.instance.simpanKeLocalStorage();
                  },
                ),
                const Divider(color: _borderGaris, height: 16),
                _buildActionRow(
                  title: 'Kustomisasi Catatan Struk',
                  subtitle: 'Ubah teks sambutan & terima kasih di struk',
                  onTap: _showEditStrukDialog,
                ),
                const Divider(color: _borderGaris, height: 16),
                _buildSwitchRow(
                  title: 'Efek Suara Kasir',
                  subtitle: 'Suara scan barcode & kalkulasi total',
                  value: _cfg.suaraKasirAktif,
                  onChanged: (val) {
                    setState(() => _cfg.suaraKasirAktif = val);
                    PengaturanStore.instance.simpanKeLocalStorage();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Notifikasi Otomatis
            _buildSectionCard(
              title: 'Pemberitahuan Otomatis',
              icon: Icons.notifications_none_outlined,
              children: [
                _buildSwitchRow(
                  title: 'Peringatan Stok Menipis',
                  subtitle: 'Beri tanda merah saat stok <= batas min',
                  value: _cfg.notifStokMenipis,
                  onChanged: (val) {
                    setState(() => _cfg.notifStokMenipis = val);
                    PengaturanStore.instance.simpanKeLocalStorage();
                  },
                ),
                const Divider(color: _borderGaris, height: 16),
                _buildSwitchRow(
                  title: 'Peringatan Barang Kedaluwarsa',
                  subtitle: 'Peringatkan barang mendekati batas simpan',
                  value: _cfg.notifKedaluwarsa,
                  onChanged: (val) {
                    setState(() => _cfg.notifKedaluwarsa = val);
                    PengaturanStore.instance.simpanKeLocalStorage();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 5. Keamanan & Akun
            _buildSectionCard(
              title: 'Keamanan Akun',
              icon: Icons.shield_outlined,
              children: [
                _buildActionRow(
                  title: 'Ganti PIN / Password',
                  subtitle: 'Amankan akses masuk aplikasi',
                  onTap: _showGantiPinDialog,
                ),
                if (_isPemilik) ...[
                  const Divider(color: _borderGaris, height: 16),
                  _buildActionRow(
                    title: 'Kelola Tim Warung',
                    subtitle: 'Tambah atau atur akun penjaga warung',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TambahAkunPenjagaScreen(pengguna: _user),
                        ),
                      );
                    },
                  ),
                ],
                const Divider(color: _borderGaris, height: 16),
                _buildActionRow(
                  title: 'Tambah Akun Pemilik Lain',
                  subtitle: 'Daftarkan akun pemilik baru untuk warung',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen1(),
                      ),
                    );
                  },
                ),
                const Divider(color: _borderGaris, height: 16),
                _buildActionRow(
                  title: 'Ganti Akun / Login Akun Lain',
                  subtitle: 'Masuk dengan nomor HP pemilik atau penjaga lain',
                  onTap: _showLogoutConfirmation,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 6. Tentang Aplikasi
            _buildSectionCard(
              title: 'Tentang Aplikasi',
              icon: Icons.info_outline,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Versi Aplikasi', style: GoogleFonts.inter(fontSize: 13, color: _hijauTua)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: _hijauMuda, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        'v1.0.0 (Stabil)',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: _hijauAksi),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Database Cloud', style: GoogleFonts.inter(fontSize: 13, color: _hijauTua)),
                    Row(
                      children: [
                        const Icon(Icons.circle, size: 8, color: Colors.green),
                        const SizedBox(width: 6),
                        Text(
                          'Supabase Terhubung',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _hijauAksi),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 7. Tombol Keluar (Logout)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _showLogoutConfirmation,
                icon: const Icon(Icons.logout, size: 20),
                label: Text(
                  'Keluar dari Aplikasi (Logout)',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _merahAksen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final initial = _user.nama.isNotEmpty ? _user.nama[0].toUpperCase() : 'W';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _hijauTua,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _hijauTua.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: _hijauMuda,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _hijauAksi,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _user.nama,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _kuningAksen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isPemilik ? 'Pemilik' : 'Penjaga',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _hijauTua,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _user.nomorHp,
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFB9CFC4)),
                ),
                Text(
                  _user.namaWarung,
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFB9CFC4).withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderGaris),
        boxShadow: [
          BoxShadow(
            color: _hijauTua.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: _hijauAksi),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _hijauTua,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: _abuTeks)),
            ),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _hijauTua,
                      ),
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.edit, size: 14, color: _hijauAksi),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _hijauTua)),
              const SizedBox(height: 2),
              Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: _abuTeks)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: _hijauAksi,
        ),
      ],
    );
  }

  Widget _buildActionRow({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _hijauTua)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: _abuTeks)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: _abuTeks),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final namaCtrl = TextEditingController(text: _user.nama);
    final hpCtrl = TextEditingController(text: _user.nomorHp);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Ubah Profil Pengguna',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _hijauTua),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaCtrl,
              decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: hpCtrl,
              decoration: const InputDecoration(labelText: 'Nomor WhatsApp / HP', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final updated = _user.copyWith(
                nama: namaCtrl.text.trim(),
                nomorHp: hpCtrl.text.trim(),
              );
              final saved = await AuthService().updateProfileAndPassword(user: updated);
              if (ctx.mounted) Navigator.pop(ctx);
              if (!mounted) return;
              setState(() => _user = saved);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: _hijauAksi),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: _hijauAksi, foregroundColor: Colors.white),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditWarungDialog() {
    final namaCtrl = TextEditingController(text: _cfg.namaWarung);
    final alamatCtrl = TextEditingController(text: _cfg.alamatWarung);
    final telpCtrl = TextEditingController(text: _cfg.noTeleponWarung);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Ubah Identitas Warung',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _hijauTua),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaCtrl,
              decoration: const InputDecoration(labelText: 'Nama Warung', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: alamatCtrl,
              decoration: const InputDecoration(labelText: 'Alamat Warung', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: telpCtrl,
              decoration: const InputDecoration(labelText: 'Nomor WhatsApp Warung', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _cfg.namaWarung = namaCtrl.text.trim();
                _cfg.alamatWarung = alamatCtrl.text.trim();
                _cfg.noTeleponWarung = telpCtrl.text.trim();
                _user = _user.copyWith(namaWarung: _cfg.namaWarung);
              });
              await PengaturanStore.instance.simpanKeLocalStorage();
              await AuthService().saveActiveSession(_user);
              if (ctx.mounted) Navigator.pop(ctx);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data warung berhasil diperbarui!'), backgroundColor: _hijauAksi),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: _hijauAksi, foregroundColor: Colors.white),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditStrukDialog() {
    final headerCtrl = TextEditingController(text: _cfg.pesanHeaderStruk);
    final footerCtrl = TextEditingController(text: _cfg.pesanFooterStruk);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Catatan Struk Belanja',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _hijauTua),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: headerCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Header Struk (Teks Atas)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: footerCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Footer Struk (Teks Bawah / Ucapan)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _cfg.pesanHeaderStruk = headerCtrl.text.trim();
                _cfg.pesanFooterStruk = footerCtrl.text.trim();
              });
              await PengaturanStore.instance.simpanKeLocalStorage();
              if (ctx.mounted) Navigator.pop(ctx);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Format catatan struk disimpan!'), backgroundColor: _hijauAksi),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: _hijauAksi, foregroundColor: Colors.white),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showGantiPinDialog() {
    final pinLamaCtrl = TextEditingController();
    final pinBaruCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Ganti Password / PIN',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _hijauTua),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinLamaCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password / PIN Lama', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pinBaruCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password / PIN Baru (min 6 karakter)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final baru = pinBaruCtrl.text.trim();
              if (baru.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password / PIN baru minimal 6 karakter!'), backgroundColor: _merahAksen),
                );
                return;
              }
              await AuthService().updateProfileAndPassword(user: _user, newPassword: baru);
              if (ctx.mounted) Navigator.pop(ctx);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password / PIN berhasil diperbarui!'), backgroundColor: _hijauAksi),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: _hijauAksi, foregroundColor: Colors.white),
            child: const Text('Simpan Password'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Keluar dari Akun?',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _hijauTua),
        ),
        content: Text(
          'Anda akan diarahkan kembali ke halaman login SIMWAR Warung Azzam.',
          style: GoogleFonts.inter(fontSize: 13, color: _abuTeks),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: _abuTeks)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Pastikan seluruh data katalog & transaksi aman tersimpan sebelum logout, lalu reset sesi & memory store
              await BarangStore.instance.simpanKeLocalStorage();
              await PengaturanStore.instance.simpanKeLocalStorage();
              await SessionDataService.clearForLogout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _merahAksen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }
}
