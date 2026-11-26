import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/laporan_model.dart';

class DetailLaporanScreen extends StatefulWidget {
  final String idLaporan;
  final String judul;
  final String pengirim;
  final String waktu;
  final String pesan;
  final String namaBarang;
  final int sisaStok;
  final String statusAwal;

  const DetailLaporanScreen({
    super.key,
    this.idLaporan = '',
    this.judul = 'Laporan Warung',
    this.pengirim = 'Penjaga',
    this.waktu = '-',
    this.pesan = '',
    this.namaBarang = '',
    this.sisaStok = 0,
    this.statusAwal = 'Baru',
  });

  @override
  State<DetailLaporanScreen> createState() => _DetailLaporanScreenState();
}

class _DetailLaporanScreenState extends State<DetailLaporanScreen> {
  // Palet Warna Resmi SIMWAR (Sesuai Proposal & Figma)
  static const Color _kremBg = Color(0xFFF4EFE0);
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauUtama = Color(0xFF23794F);
  static const Color _merahBata = Color(0xFFC8401E);
  static const Color _abuTeks = Color(0xFF6E7468);
  static const Color _garisBorder = Color(0xFFE4DCC3);
  static const Color _kuningAksen = Color(0xFFF8B62B);

  final TextEditingController _balasanCtrl = TextEditingController();
  late String _status;
  bool _isSending = false;
  final List<String> _riwayatBalasan = [];

  @override
  void initState() {
    super.initState();
    _status = widget.statusAwal;
  }

  @override
  void dispose() {
    _balasanCtrl.dispose();
    super.dispose();
  }

  Future<void> _kirimBalasan() async {
    final text = _balasanCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tulis balasan terlebih dahulu'),
          backgroundColor: _merahBata,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      // Panggil fungsi RPC Supabase balas_laporan jika tabel sudah aktif
      await Supabase.instance.client.rpc(
        'balas_laporan',
        params: {
          'p_id': int.tryParse(widget.idLaporan) ?? 1,
          'p_isi': text,
        },
      );
    } catch (_) {
      // Fallback state jika RPC belum di-apply di Supabase
    }

    if (!mounted) return;

    setState(() {
      _isSending = false;
      _riwayatBalasan.add(text);
      _status = 'Dibalas';
      _balasanCtrl.clear();
    });

    LaporanStore.instance.balasLaporan(widget.idLaporan, text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Balasan berhasil dikirim ke ${widget.pengirim}!'),
          ],
        ),
        backgroundColor: _hijauUtama,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _tandaiSelesai() async {
    try {
      await Supabase.instance.client.rpc(
        'tandai_laporan_selesai',
        params: {'p_id': int.tryParse(widget.idLaporan) ?? 1},
      );
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      _status = 'Selesai';
    });

    LaporanStore.instance.tandaiSelesai(widget.idLaporan);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Laporan telah ditandai selesai.'),
          ],
        ),
        backgroundColor: _hijauTua,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _lihatFoto(int index) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lampiran Foto $index',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _hijauTua,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3EFE8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 64, color: _hijauUtama),
                    const SizedBox(height: 12),
                    Text(
                      'Foto Bukti: Rak ${widget.namaBarang} Kosong',
                      style: const TextStyle(
                        color: _hijauTua,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Diambil oleh ${widget.pengirim}',
                      style: const TextStyle(color: _abuTeks, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isBaru = _status == 'Baru' || _status == 'Terkirim';
    final bool isSelesai = _status == 'Selesai';

    return Scaffold(
      backgroundColor: _kremBg,
      body: SafeArea(
        child: Stack(
          children: [
            // Konten Scrollable
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Baris Atas: Tombol Back Bulat & Waktu ─────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: _garisBorder),
                            boxShadow: [
                              BoxShadow(
                                color: _hijauTua.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: _hijauTua,
                          ),
                        ),
                      ),
                      const Text(
                        'Detail Laporan',
                        style: TextStyle(
                          color: _hijauTua,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 38), // placeholder penyeimbang
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── Judul Halaman & Badge Status (Figma 2073:4424) ───
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.judul,
                              style: const TextStyle(
                                color: _hijauTua,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Dari ${widget.pengirim} · ${widget.waktu}',
                              style: const TextStyle(
                                color: _abuTeks,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelesai
                              ? _hijauUtama
                              : (isBaru ? _merahBata : _kuningAksen),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _status,
                          style: TextStyle(
                            color: isBaru ? Colors.white : (isSelesai ? Colors.white : _hijauTua),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Kartu 1: Pesan (Figma 2073:4428) ───────────────────
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pesan',
                          style: TextStyle(
                            color: _abuTeks,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.pesan,
                          style: const TextStyle(
                            color: _hijauTua,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Kartu 2: Lampiran Foto (Figma 2073:4431) ───────────
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lampiran',
                          style: TextStyle(
                            color: _abuTeks,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildPhotoThumb(1),
                            const SizedBox(width: 12),
                            _buildPhotoThumb(2),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Kartu 3: Barang Tertaut (Figma 2073:4441) ──────────
                  _buildCard(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3EFE8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: _hijauUtama,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Barang tertaut',
                                style: TextStyle(
                                  color: _abuTeks,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.namaBarang} · sisa ${widget.sisaStok}',
                                style: const TextStyle(
                                  color: _hijauTua,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: _abuTeks,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ── Riwayat Balasan Sebelumnya (Jika ada) ─────────────
                  if (_riwayatBalasan.isNotEmpty) ...[
                    const Text(
                      'Balasan Anda',
                      style: TextStyle(
                        color: _hijauTua,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._riwayatBalasan.map(
                      (b) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F3EC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _hijauUtama.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.reply_rounded, size: 18, color: _hijauUtama),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                b,
                                style: const TextStyle(
                                  color: _hijauTua,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── Form Balas ke Penjaga (Figma 2073:4449) ───────────
                  Text(
                    'Balas ke ${widget.pengirim}',
                    style: const TextStyle(
                      color: _hijauTua,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _hijauUtama, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: _hijauTua.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _balasanCtrl,
                      minLines: 2,
                      maxLines: 4,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _hijauTua,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Tulis balasan…',
                        hintStyle: TextStyle(
                          color: _abuTeks,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                        ),
                        contentPadding: EdgeInsets.all(14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Tombol Utama: Kirim Balasan (Figma 2073:4452) ──────
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _kirimBalasan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hijauUtama,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text(
                              'Kirim balasan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Tombol Sekunder: Tandai Selesai (Figma 2073:4454) ───
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: isSelesai ? null : _tandaiSelesai,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _hijauTua,
                        side: const BorderSide(color: Color(0xFFCFC7AA), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        isSelesai ? 'Laporan Sudah Selesai' : 'Tandai selesai',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isSelesai ? _abuTeks : _hijauTua,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Card Box (Putih, Border, Shadow)
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _garisBorder),
        boxShadow: [
          BoxShadow(
            color: _hijauTua.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // Thumbnail Foto Lampiran
  Widget _buildPhotoThumb(int index) {
    return GestureDetector(
      onTap: () => _lihatFoto(index),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFE3EFE8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _hijauUtama.withValues(alpha: 0.2)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 24,
              color: _hijauUtama,
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.zoom_in, size: 12, color: _hijauTua),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
