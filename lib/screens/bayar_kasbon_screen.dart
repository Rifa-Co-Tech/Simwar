import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/kasbon_model.dart';
import '../models/pengguna_model.dart';
import '../models/transaksi_model.dart';
import '../utils/formatters.dart';

/// SIMWAR — Bayar Kasbon (Pemilik & Penjaga)
/// Figma node: 2233:2 (Pemilik) & 2245:2 (Penjaga)
class BayarKasbonScreen extends StatefulWidget {
  final PelangganKasbonModel pelanggan;
  final PenggunaModel? pengguna;

  const BayarKasbonScreen({
    super.key,
    required this.pelanggan,
    this.pengguna,
  });

  @override
  State<BayarKasbonScreen> createState() => _BayarKasbonScreenState();
}

class _BayarKasbonScreenState extends State<BayarKasbonScreen> {
  static const Color _bgLayar = Color(0xFFF4EFE0);
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _hijauMuda = Color(0xFFE3EFE8);
  static const Color _abuTeks = Color(0xFF6E7468);
  static const Color _borderGaris = Color(0xFFE4DCC3);
  static const Color _borderInput = Color(0xFFCFC7AA);
  static const Color _kuningAksen = Color(0xFFF8B62B);

  String _metode = 'Tunai'; // 'Tunai' | 'QRIS'
  late int _nominalBayar;
  late final TextEditingController _nominalCtrl;

  @override
  void initState() {
    super.initState();
    _nominalBayar = widget.pelanggan.totalUtang > 100000 ? 100000 : widget.pelanggan.totalUtang;
    _nominalCtrl = TextEditingController(text: SimwarFormatter.rupiah(_nominalBayar));
  }

  @override
  void dispose() {
    _nominalCtrl.dispose();
    super.dispose();
  }

  int get _sisaUtangSetelahBayar {
    final sisa = widget.pelanggan.totalUtang - _nominalBayar;
    return sisa > 0 ? sisa : 0;
  }

  void _pilihPreset(int nominal) {
    setState(() {
      _nominalBayar = nominal;
      _nominalCtrl.text = SimwarFormatter.rupiah(_nominalBayar);
    });
  }

  void _konfirmasiPembayaran() {
    if (_nominalBayar <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nominal pembayaran yang valid'),
          backgroundColor: Color(0xFFC8401E),
        ),
      );
      return;
    }

    // 1. Potong kasbon di KasbonStore
    KasbonStore.instance.bayarKasbon(widget.pelanggan.id, _nominalBayar, _metode);

    // 2. Catat ke Riwayat Transaksi Warung
    final trx = TransaksiModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      kode: 'TRX-${(140 + TransaksiStore.instance.semua.length).toString().padLeft(4, "0")}',
      waktu: '${DateTime.now().hour.toString().padLeft(2, "0")}.${DateTime.now().minute.toString().padLeft(2, "0")}',
      tanggal: 'Hari ini',
      kasir: widget.pengguna?.nama.isNotEmpty == true ? widget.pengguna!.nama : 'Rina',
      metode: 'Kasbon',
      status: 'Selesai',
      namaPelanggan: widget.pelanggan.nama,
      total: _nominalBayar,
    );
    TransaksiStore.instance.tambahTransaksi(trx);

    // 3. Dialog konfirmasi sukses
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Pembayaran Berhasil Dicatat!',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _hijauTua),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pelanggan: ${widget.pelanggan.nama}', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Nominal Dibayar: ${SimwarFormatter.rupiah(_nominalBayar)}', style: GoogleFonts.inter(color: _hijauAksi, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Sisa Utang: ${SimwarFormatter.rupiah(_sisaUtangSetelahBayar)}', style: GoogleFonts.inter(color: _abuTeks)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Kembali ke Detail Kasbon
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _hijauAksi,
              foregroundColor: Colors.white,
            ),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLayar,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
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
                      const SizedBox(width: 14),
                      Text(
                        'Bayar kasbon',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _hijauTua,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Hero Card Sisa Utang (Figma 342x100) ──────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                              'Sisa utang · ${widget.pelanggan.nama}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFB9CFC4),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              SimwarFormatter.rupiah(widget.pelanggan.totalUtang),
                              style: GoogleFonts.inter(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: _kuningAksen,
                              ),
                            ),
                          ],
                        ),
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
                              '${widget.pelanggan.jumlahTransaksi} transaksi',
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
                  ),
                  const SizedBox(height: 24),

                  // ── Metode Pembayaran: Tunai vs QRIS ──────────────────────
                  Text(
                    'Metode pembayaran',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _hijauTua,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Opsi Tunai
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _metode = 'Tunai'),
                          child: Container(
                            height: 76,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: _metode == 'Tunai' ? _hijauMuda : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _metode == 'Tunai' ? _hijauAksi : _borderInput,
                                width: _metode == 'Tunai' ? 2 : 1.5,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          'assets/icons/ikon-cash-24x24-23794F.svg',
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Tunai',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: _hijauTua,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_metode == 'Tunai')
                                  Positioned(
                                    right: 0,
                                    top: 10,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: _hijauAksi,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          'assets/icons/ikon-check-12x12-FFFFFF.svg',
                                          width: 12,
                                          height: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Opsi QRIS
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _metode = 'QRIS'),
                          child: Container(
                            height: 76,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: _metode == 'QRIS' ? _hijauMuda : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _metode == 'QRIS' ? _hijauAksi : _borderInput,
                                width: _metode == 'QRIS' ? 2 : 1.5,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFE8D2),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          'assets/icons/ikon-qr-24x24-6E7468.svg',
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'QRIS',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: _hijauTua,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_metode == 'QRIS')
                                  Positioned(
                                    right: 0,
                                    top: 10,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: _hijauAksi,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          'assets/icons/ikon-check-12x12-FFFFFF.svg',
                                          width: 12,
                                          height: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Nominal Dibayar ──────────────────────────────────────
                  Text(
                    'Nominal dibayar',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _hijauTua,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _hijauAksi, width: 1.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _nominalCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
                        final numVal = int.tryParse(digits) ?? 0;
                        setState(() => _nominalBayar = numVal);
                      },
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _hijauTua,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Chip Presets: Lunasi semua | Rp 100.000 | Rp 50.000
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _pilihPreset(widget.pelanggan.totalUtang),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _nominalBayar == widget.pelanggan.totalUtang ? _hijauAksi : Colors.white,
                            borderRadius: BorderRadius.circular(17),
                            border: Border.all(color: _hijauAksi, width: 1.5),
                          ),
                          child: Text(
                            'Lunasi semua',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _nominalBayar == widget.pelanggan.totalUtang ? Colors.white : _hijauTua,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (widget.pelanggan.totalUtang >= 100000)
                        GestureDetector(
                          onTap: () => _pilihPreset(100000),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _nominalBayar == 100000 ? _hijauAksi : Colors.white,
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(color: _borderInput, width: 1),
                            ),
                            child: Text(
                              'Rp 100.000',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _nominalBayar == 100000 ? Colors.white : _hijauTua,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (widget.pelanggan.totalUtang >= 50000)
                        GestureDetector(
                          onTap: () => _pilihPreset(50000),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _nominalBayar == 50000 ? _hijauAksi : Colors.white,
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(color: _borderInput, width: 1),
                            ),
                            child: Text(
                              'Rp 50.000',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _nominalBayar == 50000 ? Colors.white : _hijauTua,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Sisa Utang Setelah Dibayar (Figma 342x76) ────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: _hijauMuda,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sisa utang setelah dibayar',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _hijauAksi,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              SimwarFormatter.rupiah(_sisaUtangSetelahBayar),
                              style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: _hijauAksi,
                              ),
                            ),
                          ],
                        ),
                        SvgPicture.asset(
                          'assets/icons/ikon-cash-28x28-23794F.svg',
                          width: 28,
                          height: 28,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Tombol Selesai / Lanjut Verifikasi ────────────────────
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _konfirmasiPembayaran,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hijauAksi,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'Konfirmasi pembayaran kasbon',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
    );
  }
}
