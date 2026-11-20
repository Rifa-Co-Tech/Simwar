import 'package:flutter/material.dart';
import '../models/pengguna_model.dart';
import 'login_screen.dart';
import 'detail_laporan_screen.dart';

class HomeScreen extends StatefulWidget {
  final PenggunaModel pengguna;
  const HomeScreen({super.key, required this.pengguna});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Palet Warna Sesuai Desain ───────────────────────────────────
  static const Color _hijauTua = Color(0xFF1A3C2E);     // Dark green
  static const Color _creamBg = Color(0xFFF6F2EA);       // Cream background
  static const Color _kuningPerhatian = Color(0xFFF5A623);// Amber/Yellow card
  static const Color _merahPerhatian = Color(0xFFE2583E); // Red/Orange card
  static const Color _hijauBadge = Color(0xFF2D6A4F);    // Green badge

  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final nama = widget.pengguna.nama.isNotEmpty ? widget.pengguna.nama : 'Alfian';
    final peran = widget.pengguna.peran.isNotEmpty ? widget.pengguna.peran : 'Pemilik';
    final initial = nama.isNotEmpty ? nama[0].toUpperCase() : 'A';

    return Scaffold(
      backgroundColor: _creamBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. TOP HEADER (Selamat sore, Warung Azzam, Avatar) ──
              _buildTopHeader(nama, peran, initial),
              const SizedBox(height: 16),

              // ── 2. HERO CARD (Barang keluar hari ini 86) ────────────
              _buildBarangKeluarCard(),
              const SizedBox(height: 20),

              // ── 3. PERLU PERHATIAN (5 Stok Menipis & 3 Kedaluwarsa) ─
              _buildPerluPerhatianSection(),
              const SizedBox(height: 18),

              // ── 3b. KARTU LAPORAN DARI PENJAGA (Figma 2073:4412) ───
              _buildLaporanMasukCard(),
              const SizedBox(height: 20),

              // ── 4. DAFTAR STOK MENIPIS ──────────────────────────────
              _buildDaftarStokMenipisSection(),
            ],
          ),
        ),
      ),

      // ── 5. BOTTOM NAVIGATION BAR HIJAU TUA ─────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── 1. Top Header ─────────────────────────────────────────────
  Widget _buildTopHeader(String nama, String peran, String initial) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat sore,',
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 1),
            const Text(
              'Warung Azzam',
              style: TextStyle(
                color: Color(0xFF1A3C2E),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFD4E8DC),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                peran,
                style: const TextStyle(
                  color: Color(0xFF1A3C2E),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),

        // Avatar Bulat Hijau Tua dengan Inisial
        PopupMenuButton<String>(
          offset: const Offset(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (val) {
            if (val == 'logout') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'user',
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nama, style: const TextStyle(fontWeight: FontWeight.w800, color: _hijauTua)),
                  Text(widget.pengguna.nomorHp, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Keluar Akun', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
          child: Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: _hijauTua,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 2. Kartu Barang Keluar Hari Ini (86) ───────────────────────
  Widget _buildBarangKeluarCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: _hijauTua,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _hijauTua.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Barang keluar hari ini',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '86',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF23533E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '+12 dari kemarin',
                  style: TextStyle(
                    color: Color(0xFF85E3B3),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          // Mini Bar Chart di Kanan
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _chartBar(18, const Color(0xFFF5C842)),
              _chartBar(26, const Color(0xFFF5C842)),
              _chartBar(34, const Color(0xFFF5C842)),
              _chartBar(44, const Color(0xFFF5C842)),
              _chartBar(54, const Color(0xFFF5C842)),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _chartBar(double height, Color color) {
    return Container(
      width: 7,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 2.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  // ── 3. Section Perlu Perhatian ─────────────────────────────────
  Widget _buildPerluPerhatianSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Perlu perhatian',
          style: TextStyle(
            color: Color(0xFF1A3C2E),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Kartu Kuning: 5 Stok Menipis
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: _kuningPerhatian,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '5',
                      style: TextStyle(
                        color: Color(0xFF1A3C2E),
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Stok menipis',
                      style: TextStyle(
                        color: Color(0xFF1A3C2E),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Kartu Merah/Oranye: 3 Mendekati kedaluwarsa
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: _merahPerhatian,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Mendekati\nkedaluwarsa',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── 4. Daftar Stok Menipis ─────────────────────────────────────
  Widget _buildDaftarStokMenipisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Stok menipis',
              style: TextStyle(
                color: Color(0xFF1A3C2E),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Lihat semua',
                style: TextStyle(
                  color: _hijauBadge,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Item 1: Minyak Goreng 1 L
        _buildStockItem(
          title: 'Minyak Goreng 1 L',
          progress: 0.35,
          progressColor: const Color(0xFFE2583E),
          badgeText: 'Sisa 3',
          badgeBg: const Color(0xFFFDE8E5),
          badgeColor: const Color(0xFFD32F2F),
        ),
        const SizedBox(height: 8),

        // Item 2: Rokok Gudang Garam 12
        _buildStockItem(
          title: 'Rokok Gudang Garam 12',
          progress: 0.55,
          progressColor: const Color(0xFFF5A623),
          badgeText: 'Sisa 5',
          badgeBg: const Color(0xFFFEF3DE),
          badgeColor: const Color(0xFFB7791F),
        ),
        const SizedBox(height: 8),

        // Item 3: Biskuit Marie (Kedaluwarsa)
        _buildStockItem(
          title: 'Biskuit Marie',
          subtitle: 'Kedaluwarsa 5 Nov 2026',
          badgeText: '4 hari',
          badgeBg: const Color(0xFFFDE8E5),
          badgeColor: const Color(0xFFD32F2F),
        ),
      ],
    );
  }

  Widget _buildStockItem({
    required String title,
    String? subtitle,
    double? progress,
    Color? progressColor,
    required String badgeText,
    required Color badgeBg,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1A3C2E),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      width: 140,
                      height: 5,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(progressColor ?? Colors.orange),
                      ),
                    ),
                  ),
                ],
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Badge Status di Kanan
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3b. Kartu Laporan Dari Penjaga (Figma Node 2073:4412) ──────
  Widget _buildLaporanMasukCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DetailLaporanScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE4DCC3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF14372D).withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE3EFE8),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'R',
                          style: TextStyle(
                            color: Color(0xFF23794F),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Laporan dari Rina',
                      style: TextStyle(
                        color: Color(0xFF14372D),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8401E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Baru',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Gula pasir 1 kg habis. Tolong dibelikan lagi sebelum sore.',
              style: TextStyle(
                color: Color(0xFF14372D),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '17 Nov 2026, 10.05 · Gula Pasir 1 kg',
                  style: TextStyle(
                    color: Color(0xFF6E7468),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: const [
                    Text(
                      'Buka & Balas',
                      style: TextStyle(
                        color: Color(0xFF23794F),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: Color(0xFF23794F),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── 5. Bottom Navigation Bar (5 Menu Figma: Beranda, Kasir, Stok, Laporan, Kotak masuk) ───
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF14372D),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, Icons.home_rounded, 'Beranda'),
          _navItem(1, Icons.shopping_cart_outlined, 'Kasir'),
          _navItem(2, Icons.inventory_2_outlined, 'Stok'),
          _navItem(3, Icons.bar_chart_outlined, 'Laporan'),
          _navItem(4, Icons.inbox_rounded, 'Kotak masuk'),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedNavIndex = index);
        if (index == 4) {
          // Buka Layar Detail Laporan (Pilihan A)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DetailLaporanScreen(),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF23533E) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFF8B62B) : const Color(0xFFF4EFE0),
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFF8B62B) : const Color(0xFFF4EFE0),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
