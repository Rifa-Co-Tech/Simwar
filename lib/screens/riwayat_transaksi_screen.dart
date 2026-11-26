import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pengguna_model.dart';
import '../models/transaksi_model.dart';
import '../utils/formatters.dart';

/// SIMWAR — Riwayat Transaksi (Pemilik & Penjaga)
/// Figma node: 2055:463 (Pemilik) & 2073:2716 (Penjaga)
class RiwayatTransaksiScreen extends StatefulWidget {
  final PenggunaModel? pengguna;
  const RiwayatTransaksiScreen({super.key, this.pengguna});

  @override
  State<RiwayatTransaksiScreen> createState() => _RiwayatTransaksiScreenState();
}

class _RiwayatTransaksiScreenState extends State<RiwayatTransaksiScreen> {
  static const Color _bgLayar = Color(0xFFF4EFE0);
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _hijauMuda = Color(0xFFE3EFE8);
  static const Color _abuTeks = Color(0xFF6E7468);
  static const Color _borderGaris = Color(0xFFE4DCC3);
  static const Color _borderInput = Color(0xFFCFC7AA);
  static const Color _kuningAksen = Color(0xFFF8B62B);
  static const Color _merahAksen = Color(0xFFC8401E);

  String _filterMetode = 'Semua'; // 'Semua' | 'Tunai' | 'QRIS' | 'Kasbon'

  List<TransaksiModel> get _daftarTransaksi {
    final semua = TransaksiStore.instance.semua;
    if (_filterMetode == 'Semua') return semua;
    return semua.where((t) => t.metode.toLowerCase() == _filterMetode.toLowerCase()).toList();
  }

  void _tampilkanDetailTransaksi(TransaksiModel trx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _borderInput,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trx.kode,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _hijauTua,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${trx.tanggal} · ${trx.waktu} WIB',
                          style: GoogleFonts.inter(fontSize: 12, color: _abuTeks),
                        ),
                      ],
                    ),
                    _buildBadgeStatus(trx.status),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1, color: Color(0xFFE8E3D1)),
                const SizedBox(height: 14),

                // Daftar Barang
                Text(
                  'Rincian Belanja',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _hijauTua,
                  ),
                ),
                const SizedBox(height: 8),
                ...trx.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.nama} x${item.jumlah}',
                          style: GoogleFonts.inter(fontSize: 13, color: _hijauTua),
                        ),
                        Text(
                          SimwarFormatter.rupiah(item.subtotal),
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _hijauTua),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 1, color: Color(0xFFE8E3D1)),
                const SizedBox(height: 12),

                // Total & Metode
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Metode Pembayaran', style: GoogleFonts.inter(fontSize: 13, color: _abuTeks)),
                    Text(trx.metode, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _hijauTua)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Kasir', style: GoogleFonts.inter(fontSize: 13, color: _abuTeks)),
                    Text(trx.kasir, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _hijauTua)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: _hijauTua),
                    ),
                    Text(
                      SimwarFormatter.rupiah(trx.total),
                      style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: _hijauAksi),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tombol Batalkan Transaksi jika belum batal
                if (trx.status != 'Dibatalkan') ...[
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          TransaksiStore.instance.batalkanTransaksi(trx.id);
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Transaksi ${trx.kode} berhasil dibatalkan.'),
                            backgroundColor: _merahAksen,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _merahAksen, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: Text(
                        'Batalkan Transaksi',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: _merahAksen,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadgeStatus(String status) {
    Color bg;
    Color text;
    if (status == 'Menunggu') {
      bg = _kuningAksen;
      text = _hijauTua;
    } else if (status == 'Dibatalkan') {
      bg = _merahAksen;
      text = Colors.white;
    } else {
      bg = _hijauMuda;
      text = _hijauAksi;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _daftarTransaksi;

    return Scaffold(
      backgroundColor: _bgLayar,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Top Bar ──────────────────────────────────────────────
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _borderGaris),
                          ),
                          child: const Center(
                            child: Icon(Icons.arrow_back_ios_new, size: 18, color: _hijauTua),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Title & Subtitle ─────────────────────────────────────
                  Text(
                    'Transaksi',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _hijauTua,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hari ini · ${SimwarFormatter.tanggalPendek(DateTime.now())}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _abuTeks,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Filter Chips: Semua | Tunai | QRIS | Kasbon ───────────
                  Row(
                    children: ['Semua', 'Tunai', 'QRIS', 'Kasbon'].map((tab) {
                      final bool isSelected = _filterMetode == tab;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _filterMetode = tab),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? _hijauAksi : Colors.white,
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(
                                color: isSelected ? _hijauAksi : _borderInput,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              tab,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : _hijauTua,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // ── Kartu Daftar Transaksi ────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _borderGaris, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF14382E).withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: list.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                _filterMetode == 'Semua'
                                    ? 'Belum ada transaksi di warung.\nSelesaikan transaksi di Kasir untuk melihat riwayat.'
                                    : 'Tidak ada transaksi dengan metode $_filterMetode',
                                style: GoogleFonts.inter(fontSize: 13, color: _abuTeks, height: 1.5),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: list.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, thickness: 1, color: Color(0xFFE8E3D1)),
                            itemBuilder: (ctx, idx) {
                              final trx = list[idx];
                              return _buildTransaksiItem(trx);
                            },
                          ),
                  ),
                  const SizedBox(height: 14),

                  // ── Hint Subtext ─────────────────────────────────────────
                  Text(
                    'Ketuk transaksi untuk ubah atau batalkan.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _abuTeks,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransaksiItem(TransaksiModel trx) {
    return InkWell(
      onTap: () => _tampilkanDetailTransaksi(trx),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${trx.kode} · ${trx.waktu}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _hijauTua,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trx.subteks,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _abuTeks,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  SimwarFormatter.rupiah(trx.total),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _hijauTua,
                  ),
                ),
                if (trx.status != 'Selesai') ...[
                  const SizedBox(height: 6),
                  _buildBadgeStatus(trx.status),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
