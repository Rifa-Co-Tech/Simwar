import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/barang_model.dart';
import '../models/pengaturan_warung_model.dart';
import '../models/pengguna_model.dart';
import '../services/auth_service.dart';
import '../services/session_data_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// SIMWAR — Layar Pembuka Beranimasi (Splash Screen APK Modern)
/// Menampilkan animasi pembuka bertahap sekaligus memuat data lokal dan mengecek sesi auto-login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Color _hijauAtas = Color(0xFF1A4838);
  static const Color _hijauBawah = Color(0xFF0C261F);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _krem = Color(0xFFF4EFE0);
  static const Color _kuning = Color(0xFFF8B62B);
  static const Color _hijauTua = Color(0xFF14372D);

  late final AnimationController _introCtrl;
  late final AnimationController _pulseCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _footerFade;

  String _namaWarung = 'Warung Azzam';

  @override
  void initState() {
    super.initState();

    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1450),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.28, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.28, 0.65, curve: Curves.easeOut),
      ),
    );

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.40),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.45, 0.80, curve: Curves.easeOut),
      ),
    );

    _footerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );

    _introCtrl.forward();
    _siapkanAplikasiDanNavigasi();
  }

  Future<void> _siapkanAplikasiDanNavigasi() async {
    final stopwatch = Stopwatch()..start();

    // 1. Cek sesi login / registrasi aktif terlebih dahulu agar scope storage tepat
    final PenggunaModel? session = await AuthService().getActiveSession();

    // 2. Muat data lokal milik akun warung aktif saja
    if (session != null) {
      await SessionDataService.loadAllForUser(session);
      if (mounted) {
        setState(() {
          _namaWarung = PengaturanStore.instance.pengaturan.namaWarung;
        });
      }
      BarangStore.instance.sinkronkanDariSupabase().catchError((_) {});
    } else {
      SessionDataService.resetAllStoresInMemory();
    }

    // 3. Pastikan animasi pembuka selesai minimal ~1.9 detik agar terasa halus seperti APK asli
    const minDurationMs = 1950;
    final elapsedMs = stopwatch.elapsedMilliseconds;
    if (elapsedMs < minDurationMs) {
      await Future.delayed(Duration(milliseconds: minDurationMs - elapsedMs));
    }

    if (!mounted) return;

    final Widget targetScreen =
        session != null ? HomeScreen(pengguna: session) : const LoginScreen();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => targetScreen,
        transitionsBuilder: (_, anim, __, child) {
          final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 520),
      ),
    );
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Stack(
          children: [
            // Dekorasi latar lembut
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 440,
              child: FadeTransition(
                opacity: _logoFade,
                child: SvgPicture.asset(
                  'assets/dekorasi.svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Konten Utama Tengah
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const Spacer(flex: 3),

                        // Logo Emblem dengan Pulse Glow & Spring Bounce
                        AnimatedBuilder(
                          animation: Listenable.merge([_introCtrl, _pulseCtrl]),
                          builder: (context, child) {
                            final glow = 0.22 + (_pulseCtrl.value * 0.18);
                            return FadeTransition(
                              opacity: _logoFade,
                              child: ScaleTransition(
                                scale: _logoScale,
                                child: Container(
                                  width: 108,
                                  height: 108,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFFCD368),
                                        _kuning,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _kuning.withValues(alpha: glow),
                                        blurRadius: 34,
                                        spreadRadius: 6,
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.35),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 92,
                                        height: 92,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(26),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.45),
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      SvgPicture.asset(
                                        'assets/ikon-stok.svg',
                                        width: 50,
                                        height: 50,
                                        colorFilter: const ColorFilter.mode(
                                          _hijauTua,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 28),

                        // Judul Brand SIMWAR
                        FadeTransition(
                          opacity: _titleFade,
                          child: SlideTransition(
                            position: _titleSlide,
                            child: Text(
                              'SIMWAR',
                              style: GoogleFonts.fraunces(
                                fontSize: 46,
                                fontWeight: FontWeight.w900,
                                color: _krem,
                                letterSpacing: 4.0,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Subtitle Nama Warung
                        FadeTransition(
                          opacity: _subtitleFade,
                          child: SlideTransition(
                            position: _subtitleSlide,
                            child: Column(
                              children: [
                                Text(
                                  _namaWarung,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.fraunces(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.italic,
                                    color: _kuning,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _hijauAksi.withValues(alpha: 0.35),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _kuning.withValues(alpha: 0.35),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'Kasir · Stok · Konsinyasi · Laporan',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: _krem.withValues(alpha: 0.9),
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(flex: 3),

                        // Footer Progress Loading
                        FadeTransition(
                          opacity: _footerFade,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 150,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    minHeight: 4,
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.14),
                                    valueColor:
                                        const AlwaysStoppedAnimation(_kuning),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Menyiapkan aplikasi warung...',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _krem.withValues(alpha: 0.72),
                                ),
                              ),
                              const SizedBox(height: 28),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
