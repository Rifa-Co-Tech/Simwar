import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/peringatan_service.dart';

/// Banner notifikasi heads-up mengambang di atas layar HP (seperti push notif sistem asli)
class HeadsUpNotificationBanner extends StatefulWidget {
  final VoidCallback? onBukaStok;

  const HeadsUpNotificationBanner({super.key, this.onBukaStok});

  @override
  State<HeadsUpNotificationBanner> createState() =>
      _HeadsUpNotificationBannerState();
}

class _HeadsUpNotificationBannerState extends State<HeadsUpNotificationBanner>
    with SingleTickerProviderStateMixin {
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _kuningAksen = Color(0xFFF8B62B);
  static const Color _merahAksen = Color(0xFFC8401E);
  static const Color _bgKrem = Color(0xFFF4EFE0);

  PeringatanAlert? _currentAlert;
  Timer? _autoDismissTimer;
  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0.0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutBack,
    ));

    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOut,
    );

    PeringatanService.instance.alertBannerAktif.addListener(_onAlertChanged);
  }

  void _onAlertChanged() {
    final alert = PeringatanService.instance.alertBannerAktif.value;
    if (alert != null) {
      _autoDismissTimer?.cancel();
      setState(() => _currentAlert = alert);
      _animCtrl.forward(from: 0.0);
      try {
        HapticFeedback.mediumImpact();
        SystemSound.play(SystemSoundType.alert);
      } catch (_) {}

      // Otomatis sembunyi setelah 6 detik
      _autoDismissTimer = Timer(const Duration(seconds: 6), () {
        _dismiss();
      });
    } else {
      _dismiss();
    }
  }

  void _dismiss() {
    _autoDismissTimer?.cancel();
    if (_animCtrl.isAnimating || _animCtrl.value > 0) {
      _animCtrl.reverse().then((_) {
        if (mounted) {
          setState(() => _currentAlert = null);
          PeringatanService.instance.dismissAlert();
        }
      });
    }
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _animCtrl.dispose();
    PeringatanService.instance.alertBannerAktif.removeListener(_onAlertChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentAlert == null) return const SizedBox.shrink();

    final isExpired = _currentAlert!.isKedaluwarsa;
    final accentColor = isExpired ? _merahAksen : _kuningAksen;

    return Positioned(
      top: 8,
      left: 16,
      right: 16,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SlideTransition(
            position: _slideAnim,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta! < -4) {
                    _dismiss();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _hijauTua,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.65),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.20),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Sistem: Ikon, Judul SIMWAR, Waktu, Close
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              isExpired
                                  ? Icons.event_busy_rounded
                                  : Icons.warning_amber_rounded,
                              size: 14,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SIMWAR • Peringatan Sistem',
                            style: GoogleFonts.inter(
                              color: accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Baru saja',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFB9CFC4),
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _dismiss,
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Color(0xFFB9CFC4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Judul & Pesan Notifikasi
                      Text(
                        _currentAlert!.judul,
                        style: GoogleFonts.inter(
                          color: _bgKrem,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currentAlert!.pesan,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFE4DCC3),
                          fontSize: 12,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Tombol Tindakan
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            _dismiss();
                            widget.onBukaStok?.call();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: accentColor.withValues(alpha: 0.6),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Periksa di Stok',
                                  style: GoogleFonts.inter(
                                    color: accentColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 12,
                                  color: accentColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
