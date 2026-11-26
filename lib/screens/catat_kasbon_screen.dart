import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/barang_model.dart';
import '../models/item_keranjang.dart';
import '../models/kasbon_model.dart';
import '../models/pengguna_model.dart';
import '../models/transaksi_model.dart';
import '../utils/formatters.dart';

/// SIMWAR — Catat Kasbon Baru (Pemilik & Penjaga)
/// Figma node: 2073:2342 (Pemilik) & 2073:3643 (Penjaga)
class CatatKasbonScreen extends StatefulWidget {
  final PenggunaModel? pengguna;
  const CatatKasbonScreen({super.key, this.pengguna});

  @override
  State<CatatKasbonScreen> createState() => _CatatKasbonScreenState();
}

class _CatatKasbonScreenState extends State<CatatKasbonScreen> {
  static const Color _bgLayar = Color(0xFFF4EFE0);
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _hijauMuda = Color(0xFFE3EFE8);
  static const Color _abuTeks = Color(0xFF6E7468);
  static const Color _borderGaris = Color(0xFFE4DCC3);

  final TextEditingController _namaPelangganCtrl = TextEditingController();
  final List<ItemKeranjang> _items = [];

  int get _totalKasbon => _items.fold(0, (sum, i) => sum + i.subtotal);
  int get _totalBarang => _items.fold(0, (sum, i) => sum + i.jumlah);

  @override
  void dispose() {
    _namaPelangganCtrl.dispose();
    super.dispose();
  }

  void _tambahBarangManual() {
    final katalog = BarangStore.instance.semua;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tambah Barang Kasbon',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: _hijauTua),
              ),
              const SizedBox(height: 12),
              if (katalog.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Belum ada barang di katalog warung. Tambahkan barang di Kelola Barang terlebih dahulu.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 13, color: _abuTeks),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 340),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: katalog.length,
                    itemBuilder: (_, index) {
                      final b = katalog[index];
                      final idxItem = _items.indexWhere((i) => i.id == b.id);
                      final qtyDiDaftar = idxItem != -1 ? _items[idxItem].jumlah : 0;
                      final sisaTersedia = b.stok - qtyDiDaftar;
                      final habis = sisaTersedia <= 0;
                      return ListTile(
                        title: Text(b.nama, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '${SimwarFormatter.rupiah(b.hargaJual)} · Sisa stok: ${b.stok} ${b.satuan}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: habis ? const Color(0xFFC8401E) : _abuTeks,
                          ),
                        ),
                        trailing: Icon(
                          Icons.add_circle,
                          color: habis ? Colors.grey : _hijauAksi,
                        ),
                        onTap: () {
                          if (habis) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Stok ${b.nama} tidak mencukupi (tersisa ${b.stok})'),
                                backgroundColor: const Color(0xFFC8401E),
                              ),
                            );
                            return;
                          }
                          setState(() {
                            if (idxItem != -1) {
                              _items[idxItem].jumlah++;
                            } else {
                              _items.add(ItemKeranjang(
                                id: b.id,
                                nama: b.nama,
                                harga: b.hargaJual,
                                jumlah: 1,
                                satuan: b.satuan,
                              ));
                            }
                          });
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _simpanKasbon() async {
    final nama = _namaPelangganCtrl.text.trim();
    if (nama.isEmpty || _items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi nama pelanggan dan barang yang dikasbon'),
          backgroundColor: Color(0xFFC8401E),
        ),
      );
      return;
    }

    for (final item in _items) {
      final barangIdx = BarangStore.instance.semua.indexWhere((b) => b.id == item.id);
      if (barangIdx != -1 && BarangStore.instance.semua[barangIdx].stok < item.jumlah) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stok ${item.nama} tersisa ${BarangStore.instance.semua[barangIdx].stok}, tidak cukup untuk ${item.jumlah} ${item.satuan}',
            ),
            backgroundColor: const Color(0xFFC8401E),
          ),
        );
        return;
      }
    }

    // 1. Kurangi stok barang di Kelola Barang & Supabase
    for (final item in _items) {
      await BarangStore.instance.kurangiStokAsync(item.id, item.nama, item.jumlah);
    }

    // 2. Simpan ke KasbonStore
    final catatan = 'Belanja ${_items.length} jenis · $_totalBarang barang';
    KasbonStore.instance.tambahKasbon(nama, _totalKasbon, catatan);

    // 3. Simpan ke Riwayat Transaksi Warung
    final now = DateTime.now();
    final trx = TransaksiModel(
      id: now.millisecondsSinceEpoch.toString(),
      kode: 'TRX-${(TransaksiStore.instance.semua.length + 1).toString().padLeft(4, "0")}',
      waktu: '${now.hour.toString().padLeft(2, "0")}.${now.minute.toString().padLeft(2, "0")}',
      tanggal: SimwarFormatter.tanggalPendek(now),
      kasir: widget.pengguna?.nama.isNotEmpty == true ? widget.pengguna!.nama : 'Pemilik',
      metode: 'Kasbon',
      status: 'Selesai',
      namaPelanggan: nama,
      total: _totalKasbon,
      items: List.from(_items),
    );
    TransaksiStore.instance.tambahTransaksi(trx);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Kasbon Berhasil Dicatat!',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _hijauTua),
        ),
        content: Text(
          'Kasbon atas nama $nama senilai ${SimwarFormatter.rupiah(_totalKasbon)} berhasil disimpan dan stok barang telah diperbarui.',
          style: GoogleFonts.inter(color: _abuTeks),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _hijauAksi,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
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

                  // ── Header Title & Subtitle ──────────────────────────────
                  Text(
                    'Catat kasbon',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _hijauTua,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih pelanggan, lalu masukkan barangnya',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _abuTeks,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Field Nama Pelanggan ─────────────────────────────────
                  Text(
                    'Nama pelanggan',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _hijauTua,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _hijauAksi, width: 1.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _namaPelangganCtrl,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _hijauTua,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Ketik nama pelanggan...',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Daftar Barang yang Dikasbon ──────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Barang yang dikasbon',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _hijauTua,
                        ),
                      ),
                      Text(
                        '${_items.length} jenis · $_totalBarang barang',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _abuTeks,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_items.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _borderGaris, width: 1),
                      ),
                      child: Text(
                        'Belum ada barang yang ditambahkan. Tekan tombol di bawah untuk memilih barang dari katalog.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 12, color: _abuTeks),
                      ),
                    ),

                  ..._items.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _borderGaris, width: 1),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.nama,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _hijauTua,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.jumlah} × ${SimwarFormatter.rupiah(item.harga)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: _abuTeks,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            SimwarFormatter.rupiah(item.subtotal),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _hijauTua,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              setState(() => _items.removeAt(idx));
                            },
                            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 12),
                  // Tombol Tambah Barang
                  OutlinedButton.icon(
                    onPressed: _tambahBarangManual,
                    icon: const Icon(Icons.add, color: _hijauAksi),
                    label: Text(
                      '+ Tambah barang lain',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: _hijauAksi,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _hijauAksi),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Total & Tombol Simpan Kasbon ──────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _hijauMuda,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Kasbon',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _hijauTua,
                          ),
                        ),
                        Text(
                          SimwarFormatter.rupiah(_totalKasbon),
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _hijauAksi,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _simpanKasbon,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hijauAksi,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'Simpan kasbon',
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
