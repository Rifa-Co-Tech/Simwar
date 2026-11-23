import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/barang_model.dart';
import '../models/item_keranjang.dart';
import 'barcode_widget.dart';

/// SIMWAR — Modal Pemindai Barcode Kasir dengan Kamera HP Asli & Scanner Gun USB
class PindaiBarcodeModal extends StatefulWidget {
  final List<ItemKeranjang> katalog;
  final Function(ItemKeranjang item) onBarangTerpindai;
  final Function(String barcode)? onBarcodeRawTerdeteksi;

  const PindaiBarcodeModal({
    super.key,
    required this.katalog,
    required this.onBarangTerpindai,
    this.onBarcodeRawTerdeteksi,
  });

  @override
  State<PindaiBarcodeModal> createState() => _PindaiBarcodeModalState();
}

class _PindaiBarcodeModalState extends State<PindaiBarcodeModal>
    with SingleTickerProviderStateMixin {
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _hijauMuda = Color(0xFFE3EFE8);
  static const Color _abuTeks = Color(0xFF6E7468);
  static const Color _borderGaris = Color(0xFFE4DCC3);
  static const Color _kuningAksen = Color(0xFFF8B62B);
  static const Color _merahAksen = Color(0xFFC8401E);

  late AnimationController _animCtrl;
  late Animation<double> _laserAnim;
  final TextEditingController _barcodeInputCtrl = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  final MobileScannerController _scannerCtrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isTorchOn = false;
  String? _pesanError;
  String? _terakhirDipindai;
  DateTime _lastScanTime = DateTime.now().subtract(const Duration(seconds: 5));

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _laserAnim = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scannerCtrl.dispose();
    _animCtrl.dispose();
    _barcodeInputCtrl.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _prosesKodeBarcode(String code) {
    final cleanCode = code.trim();
    if (cleanCode.isEmpty) return;

    // Cegah multi-scan ganda dalam waktu singkat
    final now = DateTime.now();
    if (now.difference(_lastScanTime).inMilliseconds < 1200) return;
    _lastScanTime = now;

    if (widget.onBarcodeRawTerdeteksi != null) {
      widget.onBarcodeRawTerdeteksi!(cleanCode);
      Navigator.pop(context);
      return;
    }

    // Cari di katalog barang
    ItemKeranjang? ditemukan;

    final barangKatalog = BarangStore.instance.semua.firstWhere(
      (b) => b.barcode == cleanCode || b.nama.toLowerCase() == cleanCode.toLowerCase(),
      orElse: () => BarangModel(
        id: '',
        nama: '',
        barcode: '',
        kategori: '',
        hargaBeli: 0,
        hargaJual: 0,
        stok: 0,
      ),
    );

    if (barangKatalog.id.isNotEmpty) {
      ditemukan = ItemKeranjang(
        id: barangKatalog.id,
        nama: barangKatalog.nama,
        harga: barangKatalog.hargaJual,
        jumlah: 1,
      );
    } else {
      final idx = widget.katalog.indexWhere(
        (k) => k.nama.toLowerCase().contains(cleanCode.toLowerCase()),
      );
      if (idx != -1) {
        ditemukan = widget.katalog[idx];
      }
    }

    if (ditemukan != null) {
      widget.onBarangTerpindai(ditemukan);
      setState(() {
        _pesanError = null;
        _terakhirDipindai = '${ditemukan!.nama} dimasukkan ke keranjang!';
        _barcodeInputCtrl.clear();
      });
      _inputFocus.requestFocus();
    } else {
      setState(() {
        _pesanError = 'Kode batang "$cleanCode" tidak ditemukan di katalog.';
        _terakhirDipindai = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final daftarSampel = BarangStore.instance.semua.take(4).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _hijauMuda,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.qr_code_scanner, color: _hijauAksi, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Pemindai Barcode Kamera',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _hijauTua,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Tombol Senter (Flash)
                  IconButton(
                    icon: Icon(
                      _isTorchOn ? Icons.flash_on : Icons.flash_off,
                      color: _isTorchOn ? _kuningAksen : _abuTeks,
                    ),
                    tooltip: 'Senter Kamera',
                    onPressed: () {
                      _scannerCtrl.toggleTorch();
                      setState(() => _isTorchOn = !_isTorchOn);
                    },
                  ),
                  // Tombol Balik Kamera (Depan/Belakang)
                  IconButton(
                    icon: const Icon(Icons.flip_camera_android, color: _hijauTua),
                    tooltip: 'Ganti Kamera',
                    onPressed: () => _scannerCtrl.switchCamera(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: _abuTeks),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 1. Live Camera Viewfinder (MobileScanner Asli)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              height: 220,
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Feed Kamera HP Asli
                  MobileScanner(
                    controller: _scannerCtrl,
                    onDetect: (capture) {
                      for (final barcode in capture.barcodes) {
                        if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
                          _prosesKodeBarcode(barcode.rawValue!);
                          break;
                        }
                      }
                    },
                    errorBuilder: (context, error) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 38),
                              const SizedBox(height: 8),
                              Text(
                                'Kamera aktif di HP Android Anda.\n(Jika izin ditanya, pilih "Izinkan")',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Overlay Kotak Pembidik (Viewfinder Reticle)
                  Container(
                    width: 240,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _hijauAksi, width: 2.5),
                    ),
                  ),

                  // Garis Laser Merah Pemindai Animasi
                  AnimatedBuilder(
                    animation: _laserAnim,
                    builder: (context, child) {
                      return Positioned(
                        top: 40 + (130 * _laserAnim.value),
                        child: Container(
                          width: 220,
                          height: 2.5,
                          decoration: BoxDecoration(
                            color: _merahAksen,
                            boxShadow: [
                              BoxShadow(
                                color: _merahAksen.withValues(alpha: 0.9),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Label Status di Bawah Kamera
                  Positioned(
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.videocam, color: Colors.greenAccent, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Arahkan kamera HP ke kemasan barang',
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Pesan Feedback Berhasil
          if (_terakhirDipindai != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: _hijauMuda,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _hijauAksi.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: _hijauAksi, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _terakhirDipindai!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _hijauTua,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (_pesanError != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8E8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: _merahAksen, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _pesanError!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _merahAksen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 2. Input Scanner Gun USB / Bluetooth / Manual
          TextField(
            controller: _barcodeInputCtrl,
            focusNode: _inputFocus,
            style: GoogleFonts.inter(color: _hijauTua, fontWeight: FontWeight.w600),
            onSubmitted: _prosesKodeBarcode,
            decoration: InputDecoration(
              hintText: 'Atau ketik angka barcode / gunakan scanner gun...',
              hintStyle: GoogleFonts.inter(fontSize: 12, color: _abuTeks.withValues(alpha: 0.7)),
              prefixIcon: const Icon(Icons.barcode_reader, color: _hijauAksi),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_circle_right, color: _hijauAksi),
                onPressed: () => _prosesKodeBarcode(_barcodeInputCtrl.text),
              ),
              filled: true,
              fillColor: const Color(0xFFFBF8EE),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _borderGaris),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _hijauAksi, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 3. Sampel Barcode Cepat
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Klik Cepat Barcode Barang Warung:',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _hijauTua),
            ),
          ),
          const SizedBox(height: 6),

          Expanded(
            child: GridView.builder(
              itemCount: daftarSampel.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, idx) {
                final item = daftarSampel[idx];
                return InkWell(
                  onTap: () => _prosesKodeBarcode(item.barcode),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _borderGaris),
                      boxShadow: [
                        BoxShadow(
                          color: _hijauTua.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.nama,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _hijauTua,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        SimwarBarcodeWidget(
                          barcodeValue: item.barcode,
                          width: 120,
                          height: 34,
                          showText: true,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
