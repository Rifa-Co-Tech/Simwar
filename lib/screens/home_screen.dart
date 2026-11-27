import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/analisis_laba_model.dart';
import '../models/barang_model.dart';
import '../models/laporan_model.dart';
import '../models/notifikasi_model.dart';
import '../models/pengaturan_warung_model.dart';
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
import 'notifikasi_screen.dart';
import 'pengaturan_screen.dart';
import 'rencana_belanja_screen.dart';
import 'riwayat_transaksi_screen.dart';
import 'stok_screen.dart';
import 'tambah_akun_penjaga_screen.dart';
import '../services/peringatan_service.dart';
import '../services/session_data_service.dart';
import '../widgets/heads_up_notification_banner.dart';
import '../widgets/simwar_bottom_nav.dart';

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
  final ScrollController _scrollController = ScrollController();
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _penggunaAktif = widget.pengguna;

    _clockTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });

    // 0. Inisialisasi Android Heads-Up System Notification & minta izin Android 13+
    PeringatanService.instance.init();

    // 1. Muat seluruh data lokal sesuai akun aktif seketika agar offline/cepat
    SessionDataService.loadAllForUser(_penggunaAktif).then((_) {
      if (mounted) setState(() {});
      PeringatanService.instance.periksaSemuaPeringatan();
    });

    // 2. Sinkronkan hanya barang milik akun aktif dari Supabase Cloud
    BarangStore.instance.sinkronkanDariSupabase().then((_) {
      if (mounted) setState(() {});
      PeringatanService.instance.periksaSemuaPeringatan();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      PeringatanService.instance.periksaSemuaPeringatan();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
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
            // Konten Tab Aktif (Beranda / Kasir / Stok / Laporan / Kotak Masuk)
            _buildBodyForTab(),

            // ── Modern Floating Bottom Navigation Bar (Animated Capsule) ─────
            Positioned(
              left: 16,
              right: 16,
              bottom: 16 + MediaQuery.paddingOf(context).bottom,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: SimwarBottomNav(
                    currentIndex: _currentNavIndex,
                    isPemilik: _isPemilik,
                    onTap: _handleNavTap,
                  ),
                ),
              ),
            ),

            // ── Heads-Up Notification Banner (khusus fallback preview Web; Android pakai Heads-Up OS) ──
            if (kIsWeb)
              HeadsUpNotificationBanner(
                onBukaStok: () => setState(() => _currentNavIndex = 2),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyForTab() {
    switch (_currentNavIndex) {
      case 0:
        return _buildBerandaScrollContent();
      case 1:
        return KasirScreen(
          pengguna: _penggunaAktif,
          embeddedInNavbar: true,
          onBackToHome: () => setState(() => _currentNavIndex = 0),
        );
      case 2:
        return StokScreen(
          pengguna: _penggunaAktif,
          embeddedInNavbar: true,
          onBackToHome: () => setState(() => _currentNavIndex = 0),
        );
      case 3:
        return _isPemilik
            ? LaporanPenjualanScreen(
                pengguna: _penggunaAktif,
                embeddedInNavbar: true,
                onBackToHome: () => setState(() => _currentNavIndex = 0),
              )
            : LaporanSayaScreen(
                pengguna: _penggunaAktif,
                embeddedInNavbar: true,
                onBackToHome: () => setState(() => _currentNavIndex = 0),
              );
      case 4:
        return _isPemilik
            ? KotakMasukScreen(
                pengguna: _penggunaAktif,
                embeddedInNavbar: true,
                onBackToHome: () => setState(() => _currentNavIndex = 0),
              )
            : const SizedBox.shrink();
      default:
        return _buildBerandaScrollContent();
    }
  }

  Widget _buildBerandaScrollContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        115 + MediaQuery.paddingOf(context).bottom,
      ),
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
    );
  }

  String get _salamWaktu {
    final jam = DateTime.now().hour;
    if (jam >= 4 && jam < 11) return 'Selamat pagi,';
    if (jam >= 11 && jam < 15) return 'Selamat siang,';
    if (jam >= 15 && jam < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  // ── 1. Header: Nama Warung, Alamat, Lonceng & Avatar ──────────────────
  Widget _buildTopHeader() {
    final cfg = PengaturanStore.instance.pengaturan;
    final nama = _penggunaAktif.nama.isNotEmpty ? _penggunaAktif.nama : 'Pemilik';
    final initial = nama.isNotEmpty ? nama[0].toUpperCase() : 'W';
    final peranLabel = _isPemilik ? 'Pemilik' : 'Penjaga · $nama';
    final namaWarungDisplay = cfg.namaWarung.trim().isNotEmpty
        ? cfg.namaWarung
        : _penggunaAktif.namaWarung;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kolom Kiri: Salam, Nama Warung, Alamat
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_salamWaktu · ${SimwarFormatter.hariTanggalSingkat(DateTime.now())}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _abuTeks,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                namaWarungDisplay,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                      cfg.alamatWarung,
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
          setState(() => _currentNavIndex = 1);
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
                _navigasiKe(CatatBarangMasukScreen(pengguna: _penggunaAktif));
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
                      setState(() => _currentNavIndex = 2);
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
                      setState(() => _currentNavIndex = 2);
                    },
                  ),

                  // Ubin 3: Laporan Baru (2) — Hanya Pemilik
                  if (_isPemilik)
                    _buildPerhatianTile(
                      label: 'Laporan baru',
                      iconPath: 'assets/icons/ikon-inbox-22x22-23794F.svg',
                      tileBgColor: _hijauMuda,
                      badgeCount: '${LaporanStore.instance.jumlahBaru}',
                      badgeColor: _merahAksen,
                      onTap: () {
                        setState(() => _currentNavIndex = 4);
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
                  _navigasiKe(CatatBarangMasukScreen(pengguna: _penggunaAktif));
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
    // Menu Pemilik: 8 ubin, Menu Penjaga: 4 ubin
    final items = _isPemilik
        ? [
            {
              'label': 'Barang masuk',
              'icon': 'assets/icons/ikon-inn-22x22-23794F.svg',
              'action': () => _navigasiKe(BarangMasukScreen(pengguna: widget.pengguna)),
            },
            {
              'label': 'Kelola barang',
              'icon': 'assets/icons/ikon-box-22x22-23794F.svg',
              'action': () => _navigasiKe(KelolaBarangScreen(pengguna: widget.pengguna)),
            },
            {
              'label': 'Rencana belanja',
              'icon': 'assets/icons/ikon-clip-22x22-23794F.svg',
              'action': () => _navigasiKe(RencanaBelanjaScreen(pengguna: widget.pengguna)),
            },
            {
              'label': 'Kasbon',
              'icon': 'assets/icons/ikon-wallet-22x22-23794F.svg',
              'action': () => _navigasiKe(KasbonScreen(pengguna: widget.pengguna)),
            },
            {
              'label': 'Riwayat transaksi',
              'icon': 'assets/icons/ikon-receipt-22x22-23794F.svg',
              'action': () => _navigasiKe(RiwayatTransaksiScreen(pengguna: widget.pengguna)),
            },
            {
              'label': 'Laba per barang',
              'icon': 'assets/icons/ikon-trend-22x22-23794F.svg',
              'action': () => _navigasiKe(LabaPerBarangScreen(pengguna: widget.pengguna)),
            },
            {
              'label': 'Tim warung',
              'icon': 'assets/icons/ikon-users-22x22-23794F.svg',
              'action': () => _navigasiKe(TambahAkunPenjagaScreen(pengguna: widget.pengguna)),
            },
            {
              'label': 'Kelola titipan',
              'icon': 'assets/icons/ikon-flag-22x22-23794F.svg',
              'action': () => _navigasiKe(KelolaTitipanScreen(pengguna: widget.pengguna)),
            },
          ]
        : [
            {
              'label': 'Barang masuk',
              'icon': 'assets/icons/ikon-inn-22x22-23794F.svg',
              'action': () => _navigasiKe(BarangMasukScreen(pengguna: widget.pengguna)),
            },
            {
              'label': 'Kelola titipan',
              'icon': 'assets/icons/ikon-flag-22x22-23794F.svg',
              'action': () => _navigasiKe(KelolaTitipanScreen(pengguna: widget.pengguna)),
            },
            {
              'label': 'Kasbon',
              'icon': 'assets/icons/ikon-wallet-22x22-23794F.svg',
              'action': () => _navigasiKe(KasbonScreen(pengguna: widget.pengguna)),
            },
            {
              'label': 'Riwayat transaksi',
              'icon': 'assets/icons/ikon-receipt-22x22-23794F.svg',
              'action': () => _navigasiKe(RiwayatTransaksiScreen(pengguna: widget.pengguna)),
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
                child: _BouncyMenuTile(
                  onTap: item['action'] as VoidCallback,
                  child: Column(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: _hijauMuda,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: _hijauAksi.withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
                          fontWeight: FontWeight.w500,
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

  // ── Navigasi Halus dengan PageRouteBuilder (Fluid Transitions) ────────────
  void _navigasiKe(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _currentNavIndex = 0);
        PeringatanService.instance.periksaSemuaPeringatan();
      }
    });
  }

  // ── Handler Klik Tab Navigasi Bawah ─────────────────────────────────────────
  void _handleNavTap(int idx) {
    if (idx == 0 && _currentNavIndex == 0) {
      // Jika di Beranda dan tekan Beranda lagi: Scroll halus ke atas
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
      return;
    }

    setState(() => _currentNavIndex = idx);
  }

  Future<void> _bukaPengaturan() async {
    final updated = await Navigator.push<PenggunaModel>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PengaturanScreen(pengguna: _penggunaAktif),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position:
                  Tween<Offset>(begin: const Offset(0.0, 0.04), end: Offset.zero)
                      .animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
    if (mounted) {
      setState(() {
        if (updated != null) {
          _penggunaAktif = updated;
        }
      });
    }
  }
}

/// Widget tombol interaktif dengan animasi pantulan pegas halus (tactile spring) saat ditekan
class _BouncyMenuTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BouncyMenuTile({required this.child, required this.onTap});

  @override
  State<_BouncyMenuTile> createState() => _BouncyMenuTileState();
}

class _BouncyMenuTileState extends State<_BouncyMenuTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
