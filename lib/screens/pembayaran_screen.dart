import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/barang_model.dart';
import '../models/item_keranjang.dart';
import '../models/pengguna_model.dart';
import '../models/transaksi_model.dart';
import '../utils/formatters.dart';
import 'transaksi_berhasil_screen.dart';

/// SIMWAR — Kasir: Pembayaran (Figma node 2029:83 [Tunai] & 2052:3 [QRIS])
class PembayaranScreen extends StatefulWidget {
  final List<ItemKeranjang> items;
  final int totalTagihan;
  final PenggunaModel? pengguna;

  const PembayaranScreen({
    super.key,
    required this.items,
    required this.totalTagihan,
    this.pengguna,
  });

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  static const Color _bgLayar = Color(0xFFF4EFE0);
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _hijauMuda = Color(0xFFE3EFE8);
  static const Color _abuTeks = Color(0xFF6E7468);
  static const Color _borderInput = Color(0xFFCFC7AA);
  static const Color _kuningAksen = Color(0xFFF8B62B);
  static const Color _teksMuted = Color(0xFFB9CFC4);

  String _metode = 'Tunai'; // 'Tunai' | 'QRIS'
  final TextEditingController _uangCtrl = TextEditingController();
  int _uangDiterima = 0;

  @override
  void initState() {
    super.initState();
    // Default uang diterima = uang pas atau pembulatan terdekat
    _uangDiterima = _defaultUangPas(widget.totalTagihan);
    _uangCtrl.text = _formatNumberOnly(_uangDiterima);
  }

  int _defaultUangPas(int total) {
    if (total <= 10000) return 10000;
    if (total <= 20000) return 20000;
    if (total <= 50000) return 50000;
    if (total <= 100000) return 100000;
    return total;
  }

  String _formatRupiah(int nominal) {
    return SimwarFormatter.rupiah(nominal);
  }

  String _formatNumberOnly(int nominal) {
    final str = SimwarFormatter.rupiah(nominal);
    return str.replaceAll('Rp ', '');
  }

  int get _kembalian {
    final diff = _uangDiterima - widget.totalTagihan;
    return diff > 0 ? diff : 0;
  }

  int get _totalBarang {
    return widget.items.fold(0, (sum, i) => sum + i.jumlah);
  }

  void _pilihPreset(int nominal) {
    setState(() {
      _uangDiterima = nominal;
      _uangCtrl.text = _formatNumberOnly(nominal);
    });
  }

  void _selesaikanPembayaran() {
    if (_metode == 'Tunai' && _uangDiterima < widget.totalTagihan) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uang yang diterima kurang dari total tagihan!'),
          backgroundColor: Color(0xFFC8401E),
        ),
      );
      return;
    }

    // Otomatis kurangi stok setiap barang yang terjual di BarangStore & Supabase
    for (var item in widget.items) {
      BarangStore.instance.kurangiStokAsync(item.id, item.nama, item.jumlah);
    }

    // Simpan ke Riwayat Transaksi Warung
    final trx = TransaksiModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      kode: 'TRX-${(140 + TransaksiStore.instance.semua.length).toString().padLeft(4, "0")}',
      waktu: '${DateTime.now().hour.toString().padLeft(2, "0")}.${DateTime.now().minute.toString().padLeft(2, "0")}',
      tanggal: 'Hari ini',
      kasir: widget.pengguna?.nama.isNotEmpty == true ? widget.pengguna!.nama : 'Rina',
      metode: _metode,
      status: 'Selesai',
      total: widget.totalTagihan,
      items: List.from(widget.items),
    );
    TransaksiStore.instance.tambahTransaksi(trx);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TransaksiBerhasilScreen(
          items: widget.items,
          totalTagihan: widget.totalTagihan,
          uangDiterima: _metode == 'Tunai' ? _uangDiterima : widget.totalTagihan,
          kembalian: _metode == 'Tunai' ? _kembalian : 0,
          metodePembayaran: _metode,
          pengguna: widget.pengguna,
        ),
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
                  // ── 1. Top Bar: Tombol Kembali & Judul ─────────────────
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: _borderInput, width: 1),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/ikon-chevl-18x18-14372D.svg',
                              width: 18,
                              height: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Pembayaran',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _hijauTua,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── 2. Kartu Total Tagihan (Figma 342x100) ─────────────
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
                              'Total tagihan',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _teksMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatRupiah(widget.totalTagihan),
                              style: GoogleFonts.inter(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: _kuningAksen,
                              ),
                            ),
                          ],
                        ),

                        // Badge jumlah barang
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Text(
                              '$_totalBarang barang',
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

                  // ── 3. Pilihan Metode Pembayaran (Tunai / QRIS) ────────
                  Text(
                    'Metode pembayaran',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _hijauTua,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Opsi Tunai
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _metode = 'Tunai'),
                          child: _buildMetodeCard(
                            label: 'Tunai',
                            iconPath: 'assets/icons/ikon-cash-24x24-23794F.svg',
                            isSelected: _metode == 'Tunai',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Opsi QRIS
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _metode = 'QRIS'),
                          child: _buildMetodeCard(
                            label: 'QRIS',
                            iconPath: 'assets/icons/ikon-qr-24x24-6E7468.svg',
                            isSelected: _metode == 'QRIS',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── 4A. KONTEN PEMBAYARAN TUNAI (Figma 2029:83) ────────
                  if (_metode == 'Tunai') ...[
                    Text(
                      'Uang diterima',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _hijauTua,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Input Uang Diterima
                    Container(
                      height: 68,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _hijauAksi, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Rp ',
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: _hijauTua,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _uangCtrl,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: _hijauTua,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (val) {
                                final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
                                final numVal = int.tryParse(clean) ?? 0;
                                setState(() {
                                  _uangDiterima = numVal;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Preset Nominal Uang Cepat
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPresetChip('Uang pas', widget.totalTagihan),
                        _buildPresetChip('Rp 20.000', 20000),
                        _buildPresetChip('Rp 50.000', 50000),
                        _buildPresetChip('Rp 100.000', 100000),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Kartu Kembalian (Figma 342x76)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
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
                                'Kembalian',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: _hijauAksi,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatRupiah(_kembalian),
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
                  ],

                  // ── 4B. KONTEN PEMBAYARAN QRIS (Figma 2052:3) ──────────
                  if (_metode == 'QRIS') ...[
                    Text(
                      'Status pembayaran',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _hijauTua,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Box Menunggu Pembayaran
                    Container(
                      height: 68,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _hijauAksi, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: _hijauAksi,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Menunggu pembayaran…',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _hijauTua,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Info Card QRIS
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _hijauMuda,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pembayaran QRIS',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _hijauAksi,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Minta pembeli scan QRIS warung dengan HP mereka. Transaksi berhasil muncul otomatis begitu uang masuk.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _hijauAksi,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tombol Simulasi Pembayaran Sukses (Testing Interactive)
                    OutlinedButton.icon(
                      onPressed: _selesaikanPembayaran,
                      icon: const Icon(Icons.flash_on, color: _kuningAksen),
                      label: Text(
                        'Simulasi QRIS Sukses (Uang Masuk)',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: _hijauTua,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _hijauAksi),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // ── 5. Tombol Selesaikan Pembayaran ────────────────────
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _selesaikanPembayaran,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hijauAksi,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'Selesaikan pembayaran',
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

  Widget _buildMetodeCard({
    required String label,
    required String iconPath,
    required bool isSelected,
  }) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isSelected ? _hijauMuda : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? _hijauAksi : _borderInput,
          width: isSelected ? 2 : 1.5,
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
                  color: isSelected ? Colors.white : const Color(0xFFEFE8D2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconPath,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? _hijauTua : _abuTeks,
                ),
              ),
            ],
          ),

          // Checkmark bulatan hijau di kanan atas
          if (isSelected)
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
    );
  }

  Widget _buildPresetChip(String label, int nominal) {
    final isMatch = _uangDiterima == nominal;
    return GestureDetector(
      onTap: () => _pilihPreset(nominal),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isMatch ? _hijauAksi : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isMatch ? _hijauAksi : _borderInput,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isMatch ? Colors.white : _hijauTua,
          ),
        ),
      ),
    );
  }
}
