import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// Item data untuk navigasi SIMWAR
class SimwarNavItem {
  final String label;
  final String? svgPath;
  final IconData? iconData;

  const SimwarNavItem({
    required this.label,
    this.svgPath,
    this.iconData,
  });
}

/// Floating Bottom Navigation Bar Modern dengan animasi Sliding Capsule & Spring Bounce
class SimwarBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isPemilik;
  final List<SimwarNavItem>? customItems;

  const SimwarBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isPemilik = true,
    this.customItems,
  });

  @override
  State<SimwarBottomNav> createState() => _SimwarBottomNavState();
}

class _SimwarBottomNavState extends State<SimwarBottomNav> {
  // Palet Warna SIMWAR
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _kuningAksen = Color(0xFFF8B62B);
  static const Color _borderGaris = Color(0xFFE4DCC3);

  List<SimwarNavItem> get _items {
    if (widget.customItems != null) return widget.customItems!;
    if (widget.isPemilik) {
      return const [
        SimwarNavItem(label: 'Beranda', svgPath: 'assets/icons/ikon-home-22x22-F8B62B.svg'),
        SimwarNavItem(label: 'Kasir', svgPath: 'assets/icons/ikon-cart-22x22-F4EFE0.svg'),
        SimwarNavItem(label: 'Stok', svgPath: 'assets/icons/ikon-box-22x22-F4EFE0.svg'),
        SimwarNavItem(label: 'Laporan', svgPath: 'assets/icons/ikon-chart-22x22-F4EFE0.svg'),
        SimwarNavItem(label: 'Kotak masuk', svgPath: 'assets/icons/ikon-inbox-22x22-F4EFE0.svg'),
      ];
    } else {
      return const [
        SimwarNavItem(label: 'Beranda', svgPath: 'assets/icons/ikon-home-22x22-F8B62B.svg'),
        SimwarNavItem(label: 'Kasir', svgPath: 'assets/icons/ikon-cart-22x22-F4EFE0.svg'),
        SimwarNavItem(label: 'Stok', svgPath: 'assets/icons/ikon-box-22x22-F4EFE0.svg'),
        SimwarNavItem(label: 'Lapor', svgPath: 'assets/icons/ikon-flag-22x22-F4EFE0.svg'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final int safeIndex = widget.currentIndex.clamp(0, items.length - 1);

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: _hijauTua,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: const Color(0xFF2B5B49).withValues(alpha: 0.55),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: _hijauAksi.withValues(alpha: 0.20),
            blurRadius: 14,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double itemWidth = constraints.maxWidth / items.length;

          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              // ── 1. Animated Sliding Active Capsule Indicator ─────────────
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutBack,
                left: safeIndex * itemWidth + 3,
                top: 2,
                width: itemWidth - 6,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _hijauAksi.withValues(alpha: 0.65),
                        _hijauAksi.withValues(alpha: 0.30),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: _kuningAksen.withValues(alpha: 0.55),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _kuningAksen.withValues(alpha: 0.16),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 2. Interactive Navigation Buttons Row ────────────────────
              Row(
                children: List.generate(items.length, (idx) {
                  final item = items[idx];
                  final bool isActive = safeIndex == idx;
                  final Color itemColor = isActive
                      ? _kuningAksen
                      : _borderGaris.withValues(alpha: 0.85);

                  return Expanded(
                    child: _NavItemButton(
                      item: item,
                      isActive: isActive,
                      itemColor: itemColor,
                      onTap: () => widget.onTap(idx),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavItemButton extends StatefulWidget {
  final SimwarNavItem item;
  final bool isActive;
  final Color itemColor;
  final VoidCallback onTap;

  const _NavItemButton({
    required this.item,
    required this.isActive,
    required this.itemColor,
    required this.onTap,
  });

  @override
  State<_NavItemButton> createState() => _NavItemButtonState();
}

class _NavItemButtonState extends State<_NavItemButton> {
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon dengan AnimatedScale Spring Bounce saat aktif
              AnimatedScale(
                scale: widget.isActive ? 1.14 : 1.0,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutBack,
                child: widget.item.svgPath != null
                    ? SvgPicture.asset(
                        widget.item.svgPath!,
                        width: 22,
                        height: 22,
                        colorFilter: ColorFilter.mode(
                          widget.itemColor,
                          BlendMode.srcIn,
                        ),
                      )
                    : Icon(
                        widget.item.iconData ?? Icons.circle,
                        size: 22,
                        color: widget.itemColor,
                      ),
              ),
              const SizedBox(height: 3),
              // Animated Text Style
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                style: GoogleFonts.inter(
                  color: widget.itemColor,
                  fontSize: 10.5,
                  fontWeight: widget.isActive ? FontWeight.w800 : FontWeight.w500,
                  letterSpacing: widget.isActive ? 0.2 : 0,
                ),
                child: Text(
                  widget.item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              // Glowing Active Indicator Dot
              AnimatedOpacity(
                opacity: widget.isActive ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 220),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8B62B),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFF8B62B),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
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
