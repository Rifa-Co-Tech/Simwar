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

/// Floating Bottom Navigation Bar Minimalis dengan animasi geser halus
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
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: _hijauTua,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double itemWidth = constraints.maxWidth / items.length;

          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              // ── 1. Indikator Kapsul Geser Minimalis ──────────────────────
              AnimatedPositioned(
                duration: const Duration(milliseconds: 210),
                curve: Curves.easeOutCubic,
                left: safeIndex * itemWidth + 2,
                top: 2,
                width: itemWidth - 4,
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(24),
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
                      : _borderGaris.withValues(alpha: 0.72);

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

class _NavItemButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          opacity: isActive ? 1.0 : 0.78,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              item.svgPath != null
                  ? SvgPicture.asset(
                      item.svgPath!,
                      width: 21,
                      height: 21,
                      colorFilter: ColorFilter.mode(
                        itemColor,
                        BlendMode.srcIn,
                      ),
                    )
                  : Icon(
                      item.iconData ?? Icons.circle,
                      size: 21,
                      color: itemColor,
                    ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: itemColor,
                  fontSize: 10.5,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
