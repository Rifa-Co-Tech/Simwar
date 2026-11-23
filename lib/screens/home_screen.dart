import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/analisis_laba_model.dart';
import '../models/barang_model.dart';
import '../models/notifikasi_model.dart';
import '../models/pengguna_model.dart';
import '../utils/formatters.dart';
import 'barang_masuk_screen.dart';
import 'catat_barang_masuk_screen.dart';
import 'kasir_screen.dart';
import 'kasbon_screen.dart';
import 'kelola_barang_screen.dart';
import 'kelola_titipan_screen.dart';
import 'kotak_masuk_screen.dart';
import 'laba_per_barang_screen.dart';
import 'lapor_ke_pemilik_screen.dart';
import 'laporan_penjualan_screen.dart';
import 'laporan_saya_screen.dart';
import 'login_screen.dart';
import 'notifikasi_screen.dart';
import 'pengaturan_screen.dart';
import 'rencana_belanja_screen.dart';
import 'riwayat_transaksi_screen.dart';
import 'stok_screen.dart';
import 'tambah_akun_penjaga_screen.dart';

/// SIMWAR — Beranda Pemilik & Beranda Penjaga
/// Diport dari Spesifikasi Figma:
/// - Beranda Pemilik: node 2073:4221
/// - Beranda Penjaga: node 2073:3915
class HomeScreen extends StatefulWidget {
  final PenggunaModel pengguna;
  const HomeScreen({super.key, required this.pengguna});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Palet Warna Desain Resmi SIMWAR (tokens.json) ─────────────────────
  static const Color _bgLayar = Color(0xFFF4EFE0);        // Krem latar belakang
  static const Color _hijauTua = Color(0xFF14372D);       // Teks utama & hero card
  static const Color _hijauAksi = Color(0xFF23794F);      // Tombol utama & tab aktif
  static const Color _hijauMuda = Color(0xFFE3EFE8);      // Latar ubin ikon & avatar
  static const Color _abuTeks = Color(0xFF6E7468);        // Teks sekunder
  static const Color _borderGaris = Color(0xFFE4DCC3);    // Border kartu
  static const Color _borderInput = Color(0xFFCFC7AA);    // Border tombol lapor
  static const Color _kuningAksen = Color(0xFFF8B62B);    // Angka penjualan & aktif nav
  static const Color _merahAksen = Color(0xFFC8401E);     // Kedaluwarsa & badge notif
  static const Color _kuningPeringatan = Color(0xFFE0A100);// Stok menipis
  static const Color _teksMuted = Color(0xFFB9CFC4);      // Teks di atas hijau tua

  int _currentNavIndex = 0;
  late PenggunaModel _penggunaAktif;

  @override
  void initState() {
    super.initState();
    _penggunaAktif = widget.pengguna;
    BarangStore.instance.sinkronkanDariSupabase().then((_) {
      if (mounted) setState(() {});
    });
  }

  bool get _isPemilik =>
      _penggunaAktif.peran.toLowerCase() == 'pemilik';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLayar,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Konten Utama Scrollable
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── 1. Top Bar: Salam, Nama Warung, Alamat, Avatar & Notif ──
                      _buildTopHeader(),
                      const SizedBox(height: 18),

                      // ── 2. Kartu Penjualan / Transaksi (Hero Card) ──────
                      _buildHeroCard(),
                      const SizedBox(height: 12),

                      // ── 3. Tombol CTA Utama (Mulai Jual / Kasir) ────────
                      _buildCtaButton(),
                      const SizedBox(height: 12),

                      // ── 3b. Khusus Penjaga: Banner Lapor ke Pemilik ─────
                      if (!_isPemilik) ...[
                        _buildBannerLaporPenjaga(),
                        const SizedBox(height: 14),
                      ],

                      // ── 4. Bagian "Perlu perhatian" ──────────────────────
                      _buildPerluPerhatianSection(),
                      const SizedBox(height: 18),

                      // ── 5. Bagian "Menu" ─────────────────────────────────
                      _buildMenuSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // ── Floating Bottom Navigation Bar (Figma spec @ 0,764) ─────
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _buildBottomNav(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 1. Header: Warung Azzam, Alamat, Lonceng & Avatar ──────────────────
  Widget _buildTopHeader() {
    final nama = widget.pengguna.nama.isNotEmpty ? widget.pengguna.nama : 'Alfian';
    final initial = nama.isNotEmpty ? nama[0].toUpperCase() : 'A';
    final peranLabel = _isPemilik ? 'Pemilik' : 'Penjaga · $nama';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kolom Kiri: Salam, Nama Warung, Alamat
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat sore,',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: _abuTeks,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Warung Azzam',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _hijauTua,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/ikon-pin-14x14-23794F.svg',
                    width: 14,
                    height: 14,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Jl. Garuda Sakti Km 1, Tampan',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: _abuTeks,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Kolom Kanan: Notifikasi Lonceng & Avatar Profil
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lonceng Notifikasi (Figma 40x40, radius 20, border, shadow)
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotifikasiScreen(pengguna: _penggunaAktif),
                  ),
                );
                setState(() {});
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: _borderGaris, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: _hijauTua.withValues(alpha: 0.10),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/ikon-lonceng-20x20-14372D.svg',
                      width: 20,
                      height: 20,
                    ),
                    // Dot penanda merah jika ada notifikasi belum dibaca
                    if (NotifikasiStore.instance.unreadCount > 0)
                      Positioned(
                        top: 7,
                        right: 8,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: _merahAksen,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Avatar & Lencana Peran
            Column(
              children: [
                GestureDetector(
                  onTap: _bukaPengaturan,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: _hijauMuda,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _hijauAksi,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _hijauMuda,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    peranLabel,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _hijauAksi,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  int get _omsetHariIni => LaporanService.instance.getOmsetByPeriode('Hari Ini');
  int get _labaHariIni => LaporanService.instance.getLabaByPeriode('Hari Ini');
  int get _transaksiHariIniCount => LaporanService.instance.getTransaksiCountByPeriode('Hari Ini');
  int get _barangTerjualHariIniCount => LaporanService.instance.getBarangTerjualCountByPeriode('Hari Ini');

  // ── 2. Kartu Penjualan / Laba (Figma 342x112 / 342x92) ───────────────────
  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _hijauTua,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isPemilik ? 'Penjualan hari ini' : 'Transaksi hari ini',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _teksMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isPemilik
                    ? SimwarFormatter.rupiah(_omsetHariIni)
                    : '$_transaksiHariIniCount',
                style: GoogleFonts.inter(
                  fontSize: _isPemilik ? 30 : 36,
                  fontWeight: FontWeight.w800,
                  color: _kuningAksen,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isPemilik
                    ? (_omsetHariIni > 0
                        ? 'Laba ${SimwarFormatter.rupiah(_labaHariIni)}  ·  $_barangTerjualHariIniCount barang terjual'
                        : 'Belum ada transaksi hari ini')
                    : '$_transaksiHariIniCount transaksi tersimpan di sistem',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _teksMuted,
                ),
              ),
            ],
          ),

          // Badge chip kanan atas (+8% atau Shift)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                _isPemilik
                    ? (_omsetHariIni > 0 ? 'Hari ini' : 'Siap jualan')
                    : 'Shift aktif',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Tombol Utama (Mulai Jual / Kasir) ──────────────────────────────────
  Widget _buildCtaButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KasirScreen(pengguna: widget.pengguna),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _hijauAksi,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: Text(
          'Mulai jual (Kasir)',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ── 3b. Banner Lapor ke Pemilik (Khusus Penjaga, Figma 342x84) ────────────
  Widget _buildBannerLaporPenjaga() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LaporKePemilikScreen(pengguna: widget.pengguna),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _borderInput, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: _hijauMuda,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/ikon-flag-22x22-23794F.svg',
                  width: 22,
                  height: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lapor ke pemilik',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _hijauTua,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Apa saja boleh dilaporkan. Langsung masuk ke Kotak masuk pemilik.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _abuTeks,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 4. Bagian "Perlu perhatian" ──────────────────────────────────────────
  Widget _buildPerluPerhatianSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Perlu perhatian',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _hijauTua,
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CatatBarangMasukScreen(pengguna: widget.pengguna),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _hijauMuda,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _hijauAksi.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_box_outlined, size: 15, color: _hijauAksi),
                    const SizedBox(width: 4),
                    Text(
                      '+ Tambah Stok',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _hijauAksi,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _borderGaris, width: 1),
            boxShadow: [
              BoxShadow(
                color: _hijauTua.withValues(alpha: 0.10),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Ubin 1: Stok Menipis
                  _buildPerhatianTile(
                    label: 'Stok menipis',
                    iconPath: 'assets/icons/ikon-alert-22x22-B7791F.svg',
                    tileBgColor: const Color(0xFFF5B82E).withValues(alpha: 0.30),
                    badgeCount: '${BarangStore.instance.stokMenipis.length}',
                    badgeColor: _kuningPeringatan,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StokScreen(
                            initialTab: 'menipis',
                            pengguna: widget.pengguna,
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    },
                  ),

                  // Ubin 2: Kedaluwarsa
                  _buildPerhatianTile(
                    label: 'Kedaluwarsa',
                    iconPath: 'assets/icons/ikon-cal-22x22-C8401E.svg',
                    tileBgColor: _merahAksen.withValues(alpha: 0.14),
                    badgeCount: '${BarangStore.instance.hampirKedaluwarsa.length}',
                    badgeColor: _merahAksen,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StokScreen(
                            initialTab: 'kedaluwarsa',
                            pengguna: widget.pengguna,
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    },
                  ),

                  // Ubin 3: Laporan Baru (2) — Hanya Pemilik
                  if (_isPemilik)
                    _buildPerhatianTile(
                      label: 'Laporan baru',
                      iconPath: 'assets/icons/ikon-inbox-22x22-23794F.svg',
                      tileBgColor: _hijauMuda,
                      badgeCount: '2',
                      badgeColor: _merahAksen,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KotakMasukScreen(pengguna: widget.pengguna),
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFEFE8D6)),
              const SizedBox(height: 10),
              // Tombol cepat Tambah Pasokan Stok
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CatatBarangMasukScreen(pengguna: widget.pengguna),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_circle, color: _hijauAksi, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Pasok / Tambah Stok Masuk Sekarang',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _hijauAksi,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios, color: _hijauAksi, size: 11),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerhatianTile({
    required String label,
    required String iconPath,
    required Color tileBgColor,
    required String badgeCount,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: tileBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconPath,
                    width: 22,
                    height: 22,
                  ),
                ),
              ),
              // Badge Angka di kanan atas
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badgeCount,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: _abuTeks,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── 5. Bagian "Menu" (Grid 4 Kolom) ───────────────────────────────────────
  Widget _buildMenuSection() {
    // Menu Pemilik: 7 ubin, Menu Penjaga: 3 ubin
    final items = _isPemilik
        ? [
            {
              'label': 'Barang masuk',
              'icon': 'assets/icons/ikon-inn-22x22-23794F.svg',
              'action': () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BarangMasukScreen(pengguna: widget.pengguna),
                  ),
                );
              },
            },
            {
              'label': 'Kelola barang',
              'icon': 'assets/icons/ikon-box-22x22-23794F.svg',
              'action': () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KelolaBarangScreen(pengguna: widget.pengguna),
                  ),
                );
              },
            },
            {
              'label': 'Rencana belanja',
              'icon': 'assets/icons/ikon-clip-22x22-23794F.svg',
              'action': () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RencanaBelanjaScreen(pengguna: widget.pengguna),
                  ),
                );
              },
            },
            {
              'label': 'Kasbon',
              'icon': 'assets/icons/ikon-wallet-22x22-23794F.svg',
              'action': () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KasbonScreen(pengguna: widget.pengguna),
                  ),
                );
              },
            },
            {
              'label': 'Riwayat transaksi',
              'icon': 'assets/icons/ikon-receipt-22x22-23794F.svg',
              'action': () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RiwayatTransaksiScreen(pengguna: widget.pengguna),
                  ),
                );
              },
            },
            {
              'label': 'Laba per barang',
              'icon': 'assets/icons/ikon-trend-22x22-23794F.svg',
              'action': () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LabaPerBarangScreen(pengguna: widget.pengguna),
                  ),
                );
              },
            },
            {
              'label': 'Tim warung',
              'icon': 'assets/icons/ikon-users-22x22-23794F.svg',
              'action': () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TambahAkunPenjagaScreen(pengguna: widget.pengguna),
                  ),
                );
              },
            },
            {
              'label': 'Kelola titipan',
              'icon': 'assets/icons/ikon-flag-22x22-23794F.svg',
              'action': () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KelolaTitipanScreen(pengguna: widget.pengguna),
                  ),
                );
              },
            },
          ]
        : [
            {
              'label': 'Barang masuk',
              'icon': 'assets/icons/ikon-inn-22x22-23794F.svg',
              'action': () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BarangMasukScreen(pengguna: widget.pengguna),
                  ),
                );
              },
            },
            {
              'label': 'Kelola titipan',
              'icon': 'assets/icons/ikon-flag-22x22-23794F.svg',
              'action': () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KelolaTitipanScreen(pengguna: widget.pengguna),
                  ),
                );
              },
            },
            {
              'label': 'Kasbon',
              'icon': 'assets/icons/ikon-wallet-22x22-23794F.svg',
              'action': () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KasbonScreen(pengguna: widget.pengguna),
                  ),
                );
              },
            },
            {
              'label': 'Riwayat transaksi',
              'icon': 'assets/icons/ikon-receipt-22x22-23794F.svg',
              'action': () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RiwayatTransaksiScreen(pengguna: widget.pengguna),
                  ),
                );
              },
            },
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _hijauTua,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _borderGaris, width: 1),
            boxShadow: [
              BoxShadow(
                color: _hijauTua.withValues(alpha: 0.10),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 18,
            alignment: WrapAlignment.start,
            children: items.map((item) {
              return SizedBox(
                width: 70,
                child: GestureDetector(
                  onTap: item['action'] as VoidCallback,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: _hijauMuda,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            item['icon'] as String,
                            width: 22,
                            height: 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: _abuTeks,
                          height: 1.15,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── 6. Bottom Navigation Bar Floating Pill ────────────────────────────────
  Widget _buildBottomNav() {
    final navItems = _isPemilik
        ? [
            {'label': 'Beranda', 'icon': 'assets/icons/ikon-home-22x22-F8B62B.svg'},
            {'label': 'Kasir', 'icon': 'assets/icons/ikon-cart-22x22-F4EFE0.svg'},
            {'label': 'Stok', 'icon': 'assets/icons/ikon-box-22x22-F4EFE0.svg'},
            {'label': 'Laporan', 'icon': 'assets/icons/ikon-chart-22x22-F4EFE0.svg'},
            {'label': 'Kotak masuk', 'icon': 'assets/icons/ikon-inbox-22x22-F4EFE0.svg'},
          ]
        : [
            {'label': 'Beranda', 'icon': 'assets/icons/ikon-home-22x22-F8B62B.svg'},
            {'label': 'Kasir', 'icon': 'assets/icons/ikon-cart-22x22-F4EFE0.svg'},
            {'label': 'Stok', 'icon': 'assets/icons/ikon-box-22x22-F4EFE0.svg'},
            {'label': 'Lapor', 'icon': 'assets/icons/ikon-flag-22x22-F4EFE0.svg'},
          ];

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _hijauTua,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (idx) {
          final item = navItems[idx];
          final bool isActive = _currentNavIndex == idx;
          final Color itemColor = isActive ? _kuningAksen : _bgLayar;

          return GestureDetector(
            onTap: () {
              setState(() => _currentNavIndex = idx);
              if (idx == 1) {
                // Modul Kasir
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KasirScreen(pengguna: widget.pengguna),
                  ),
                );
              } else if (idx == 2) {
                // Modul Stok
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StokScreen(pengguna: widget.pengguna),
                  ),
                );
              } else if (_isPemilik && idx == 3) {
                // Modul Laporan Penjualan (Pemilik)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LaporanPenjualanScreen(pengguna: widget.pengguna),
                  ),
                );
              } else if (_isPemilik && idx == 4) {
                // Kotak Masuk (Pemilik)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KotakMasukScreen(pengguna: widget.pengguna),
                  ),
                );
              } else if (!_isPemilik && idx == 3) {
                // Lapor (Penjaga) -> Laporan Saya / Form Lapor
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LaporanSayaScreen(pengguna: widget.pengguna),
                  ),
                );
              } else {
                _showSnackbar('Navigasi ke ${item['label']}');
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  item['icon'] as String,
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
                ),
                const SizedBox(height: 3),
                Text(
                  item['label'] as String,
                  style: GoogleFonts.inter(
                    color: itemColor,
                    fontSize: 10.5,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<void> _bukaPengaturan() async {
    final updated = await Navigator.push<PenggunaModel>(
      context,
      MaterialPageRoute(
        builder: (_) => PengaturanScreen(pengguna: _penggunaAktif),
      ),
    );
    if (updated != null) {
      setState(() => _penggunaAktif = updated);
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _hijauTua,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showProfilDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Profil Warung Azzam',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _hijauTua),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${widget.pengguna.nama}', style: GoogleFonts.inter()),
            Text('No. HP: ${widget.pengguna.nomorHp}', style: GoogleFonts.inter()),
            Text('Peran: ${widget.pengguna.peran}', style: GoogleFonts.inter()),
            Text('Warung: ${widget.pengguna.namaWarung}', style: GoogleFonts.inter()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Keluar (Logout)', style: TextStyle(color: _merahAksen)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: _hijauAksi,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
