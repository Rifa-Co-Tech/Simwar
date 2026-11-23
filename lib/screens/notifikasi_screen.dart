import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/notifikasi_model.dart';
import '../models/pengguna_model.dart';
import 'barang_masuk_screen.dart';
import 'kotak_masuk_screen.dart';
import 'laporan_saya_screen.dart';
import 'riwayat_transaksi_screen.dart';
import 'stok_screen.dart';

/// SIMWAR — Pusat Notifikasi & Pemberitahuan Real-Time Warung
/// Figma nodes: 2073:4338 & 2073:4002
class NotifikasiScreen extends StatefulWidget {
  final PenggunaModel pengguna;
  const NotifikasiScreen({super.key, required this.pengguna});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
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

  String _tabFilter = 'Semua'; // 'Semua' | 'Belum Dibaca' | 'Stok' | 'Transaksi' | 'Laporan'

  bool get _isPemilik => widget.pengguna.peran.toLowerCase() == 'pemilik';

  List<NotifikasiModel> get _filteredList {
    final store = NotifikasiStore.instance;
    List<NotifikasiModel> list = store.semua;

    if (_tabFilter == 'Belum Dibaca') {
      list = list.where((n) => !n.isRead).toList();
    } else if (_tabFilter == 'Stok') {
      list = list.where((n) => n.kategori == KategoriNotif.stok).toList();
    } else if (_tabFilter == 'Transaksi') {
      list = list.where((n) => n.kategori == KategoriNotif.transaksi).toList();
    } else if (_tabFilter == 'Laporan') {
      list = list.where((n) => n.kategori == KategoriNotif.laporan).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final store = NotifikasiStore.instance;
    final unread = store.unreadCount;

    return Scaffold(
      backgroundColor: _bgLayar,
      appBar: AppBar(
        backgroundColor: _bgLayar,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _hijauTua, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifikasi Warung',
          style: GoogleFonts.inter(
            color: _hijauTua,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (unread > 0)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  store.tandaiSemuaDibaca();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua notifikasi ditandai telah dibaca'),
                    backgroundColor: _hijauAksi,
                  ),
                );
              },
              icon: const Icon(Icons.done_all, color: _hijauAksi, size: 18),
              label: Text(
                'Baca Semua',
                style: GoogleFonts.inter(
                  color: _hijauAksi,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 1. Filter Chips
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Semua', store.semua.length),
                const SizedBox(width: 8),
                _buildFilterChip('Belum Dibaca', unread),
                const SizedBox(width: 8),
                _buildFilterChip('Stok', store.semua.where((n) => n.kategori == KategoriNotif.stok).length),
                const SizedBox(width: 8),
                _buildFilterChip('Transaksi', store.semua.where((n) => n.kategori == KategoriNotif.transaksi).length),
                const SizedBox(width: 8),
                _buildFilterChip('Laporan', store.semua.where((n) => n.kategori == KategoriNotif.laporan).length),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 2. Daftar Notifikasi
          Expanded(
            child: _filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 54, color: _abuTeks.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada notifikasi di kategori ini',
                          style: GoogleFonts.inter(color: _abuTeks, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: _filteredList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final notif = _filteredList[index];
                      return Dismissible(
                        key: Key(notif.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          padding: const EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: _merahAksen,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
                        ),
                        onDismissed: (_) {
                          store.hapusNotifikasi(notif.id);
                        },
                        child: _buildNotifCard(notif),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _tabFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _tabFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _hijauTua : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? _hijauTua : _borderGaris),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : _hijauTua,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? _kuningAksen : _hijauMuda,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _hijauTua,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotifCard(NotifikasiModel notif) {
    Color iconBg;
    Color iconColor;
    IconData icon;

    switch (notif.kategori) {
      case KategoriNotif.stok:
        iconBg = const Color(0xFFFEF3C7);
        iconColor = const Color(0xFFB45309);
        icon = Icons.warning_amber_rounded;
        break;
      case KategoriNotif.transaksi:
        iconBg = _hijauMuda;
        iconColor = _hijauAksi;
        icon = Icons.receipt_long_outlined;
        break;
      case KategoriNotif.laporan:
        iconBg = const Color(0xFFDBEAFE);
        iconColor = const Color(0xFF1D4ED8);
        icon = Icons.chat_bubble_outline;
        break;
      case KategoriNotif.pasokan:
        iconBg = const Color(0xFFFEE2E2);
        iconColor = _merahAksen;
        icon = Icons.local_shipping_outlined;
        break;
    }

    return GestureDetector(
      onTap: () => _handleNotifClick(notif),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : const Color(0xFFFBF8EE),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: notif.isRead ? _borderGaris : _hijauAksi.withValues(alpha: 0.4),
            width: notif.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _hijauTua.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Kategori
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),

            // Konten Pesan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.judul,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: _hijauTua,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.pesan,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: notif.isRead ? _abuTeks : _hijauTua.withValues(alpha: 0.85),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notif.waktuRelatif,
                        style: GoogleFonts.inter(fontSize: 11, color: _abuTeks.withValues(alpha: 0.7)),
                      ),
                      Text(
                        'Lihat rincian →',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _hijauAksi,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotifClick(NotifikasiModel notif) {
    setState(() {
      NotifikasiStore.instance.tandaiDibaca(notif.id);
    });

    if (notif.routeTarget == 'stok') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StokScreen(pengguna: widget.pengguna)),
      );
    } else if (notif.routeTarget == 'laporan') {
      if (_isPemilik) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => KotakMasukScreen(pengguna: widget.pengguna)),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LaporanSayaScreen(pengguna: widget.pengguna)),
        );
      }
    } else if (notif.routeTarget == 'transaksi') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RiwayatTransaksiScreen(pengguna: widget.pengguna)),
      );
    } else if (notif.routeTarget == 'barang_masuk') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BarangMasukScreen(pengguna: widget.pengguna)),
      );
    }
  }
}
