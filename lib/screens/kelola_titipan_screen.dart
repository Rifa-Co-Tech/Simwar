import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/barang_masuk_model.dart';
import '../models/barang_model.dart';
import '../models/pengguna_model.dart';
import '../utils/formatters.dart';

/// SIMWAR — Modul Khusus: Kelola Titipan Warga (Konsinyasi)
/// Dirancang untuk mengelola produk titipan (kue basah, gorengan, jajanan pasar, peyek, dll.),
/// mencatat penerimaan pagi, memantau penjualan harian, melakukan rekap sisa retur sore hari,
/// serta pembagian hasil keuntungan dan penyetoran uang ke mitra warga.
class KelolaTitipanScreen extends StatefulWidget {
  final PenggunaModel? pengguna;
  const KelolaTitipanScreen({super.key, this.pengguna});

  @override
  State<KelolaTitipanScreen> createState() => _KelolaTitipanScreenState();
}

class _KelolaTitipanScreenState extends State<KelolaTitipanScreen> {
  static const Color _bgLayar = Color(0xFFF4EFE0);
  static const Color _hijauTua = Color(0xFF14372D);
  static const Color _hijauAksi = Color(0xFF23794F);
  static const Color _hijauMuda = Color(0xFFE3EFE8);
  static const Color _abuTeks = Color(0xFF6E7468);
  static const Color _borderGaris = Color(0xFFE4DCC3);
  static const Color _borderInput = Color(0xFFCFC7AA);
  static const Color _kuningAksen = Color(0xFFF8B62B);
  static const Color _merahAksen = Color(0xFFC8401E);

  String _tabDipilih = 'Aktif'; // 'Aktif', 'Mitra', 'Selesai'

  @override
  Widget build(BuildContext context) {
    final store = BarangMasukStore.instance;
    final titipanList = store.titipanOnly;
    final aktifList = titipanList.where((t) => !t.sudahDisetorKePenitip).toList();
    final selesaiList = titipanList.where((t) => t.sudahDisetorKePenitip).toList();

    // Hitung total finansial konsinyasi
    int totalSetorAktif = 0;
    int totalUntungWarungAktif = 0;

    for (var t in aktifList) {
      for (var it in t.items) {
        final b = BarangStore.instance.semua.firstWhere(
          (item) =>
              item.id == it.barangId ||
              item.nama.trim().toLowerCase() == it.namaBarang.trim().toLowerCase(),
          orElse: () => BarangModel(
            id: '',
            nama: it.namaBarang,
            barcode: '',
            kategori: 'Makanan',
            hargaBeli: it.hargaBeli,
            hargaJual: it.hargaJual ?? it.hargaBeli,
            stok: it.jumlah,
          ),
        );
        final int terjual = (it.jumlah - b.stok).clamp(0, it.jumlah);
        totalSetorAktif += terjual * it.hargaBeli;
        final margin = (b.hargaJual - it.hargaBeli);
        totalUntungWarungAktif += terjual * (margin > 0 ? margin : 0);
      }
    }

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
          'Kelola Titipan Warga',
          style: GoogleFonts.inter(
            color: _hijauTua,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaDialogTambahTitipan,
        backgroundColor: _hijauAksi,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          '+ Catat Titipan Baru',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 1. Hero Summary Card ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _hijauTua,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: _hijauTua.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
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
                          const Icon(Icons.handshake_outlined, color: _kuningAksen, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Kemitraan Konsinyasi Warga',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFB9CFC4),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${aktifList.length} Titipan Aktif',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hak Setor ke Penitip',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFFB9CFC4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              SimwarFormatter.rupiah(totalSetorAktif),
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: _kuningAksen,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Siap diserahkan sore ini',
                              style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF8BAA9B)),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 42, color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bagi Hasil Warung',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFFB9CFC4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              SimwarFormatter.rupiah(totalUntungWarungAktif),
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Laba bersih warung',
                              style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF8BAA9B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 2. Tab Filter ─────────────────────────────────────────────
            Row(
              children: [
                _buildTabButton('Aktif', 'Titipan Hari Ini (${aktifList.length})'),
                const SizedBox(width: 8),
                _buildTabButton('Mitra', 'Mitra Warga'),
                const SizedBox(width: 8),
                _buildTabButton('Selesai', 'Riwayat (${selesaiList.length})'),
              ],
            ),
            const SizedBox(height: 16),

            // ── 3. Content per Tab ────────────────────────────────────────
            if (_tabDipilih == 'Aktif')
              _buildTabAktif(aktifList)
            else if (_tabDipilih == 'Mitra')
              _buildTabMitra(titipanList)
            else
              _buildTabSelesai(selesaiList),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String key, String label) {
    final bool isSelected = _tabDipilih == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabDipilih = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _hijauTua : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? _hijauTua : _borderGaris),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : _hijauTua,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab 1: Titipan Aktif / Hari Ini ───────────────────────────────────────
  Widget _buildTabAktif(List<BarangMasukModel> list) {
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _borderGaris),
        ),
        child: Column(
          children: [
            const Icon(Icons.bakery_dining_outlined, size: 54, color: _borderInput),
            const SizedBox(height: 14),
            Text(
              'Belum ada titipan barang aktif hari ini.',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _hijauTua),
            ),
            const SizedBox(height: 6),
            Text(
              'Klik tombol "+ Catat Titipan Baru" di bawah untuk mencatat kue, jajanan, atau produk titipan warga yang masuk.',
              style: GoogleFonts.inter(fontSize: 12, color: _abuTeks, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: list.map((item) => _buildTitipanCard(item, isAktif: true)).toList(),
    );
  }

  // ── Tab 2: Daftar Mitra Warga ─────────────────────────────────────────────
  Widget _buildTabMitra(List<BarangMasukModel> allTitipan) {
    final Map<String, Map<String, dynamic>> mitraMap = {};
    for (var t in allTitipan) {
      final key = t.namaPemasok.trim();
      if (!mitraMap.containsKey(key)) {
        mitraMap[key] = {
          'nama': t.namaPemasok,
          'noHp': t.noFaktur ?? '-',
          'totalKali': 0,
          'produk': <String>{},
        };
      }
      mitraMap[key]!['totalKali'] = (mitraMap[key]!['totalKali'] as int) + 1;
      for (var it in t.items) {
        (mitraMap[key]!['produk'] as Set<String>).add(it.namaBarang);
      }
    }

    final mitraList = mitraMap.values.toList();

    if (mitraList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _borderGaris),
        ),
        child: Center(
          child: Text(
            'Belum ada mitra penitip yang terdaftar.',
            style: GoogleFonts.inter(color: _abuTeks, fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      children: mitraList.map((m) {
        final produkSet = m['produk'] as Set<String>;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _borderGaris),
            boxShadow: [
              BoxShadow(
                color: _hijauTua.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _hijauMuda,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(Icons.person, color: _hijauAksi, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m['nama'],
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _hijauTua,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'No. HP: ${m['noHp']}',
                      style: GoogleFonts.inter(fontSize: 12, color: _abuTeks),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Produk: ${produkSet.join(", ")}',
                      style: GoogleFonts.inter(fontSize: 11, color: _hijauAksi, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _hijauMuda,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${m['totalKali']}x Titip',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: _hijauAksi),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Tab 3: Riwayat Titipan Selesai Disetor ────────────────────────────────
  Widget _buildTabSelesai(List<BarangMasukModel> list) {
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _borderGaris),
        ),
        child: Center(
          child: Text(
            'Belum ada riwayat titipan yang diselesaikan.',
            style: GoogleFonts.inter(color: _abuTeks, fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      children: list.map((item) => _buildTitipanCard(item, isAktif: false)).toList(),
    );
  }

  // ── Card Titipan ──────────────────────────────────────────────────────────
  Widget _buildTitipanCard(BarangMasukModel item, {required bool isAktif}) {
    int totalSetor = 0;
    int totalUntung = 0;

    for (var it in item.items) {
      final b = BarangStore.instance.semua.firstWhere(
        (elem) =>
            elem.id == it.barangId ||
            elem.nama.trim().toLowerCase() == it.namaBarang.trim().toLowerCase(),
        orElse: () => BarangModel(
          id: '',
          nama: it.namaBarang,
          barcode: '',
          kategori: 'Makanan',
          hargaBeli: it.hargaBeli,
          hargaJual: it.hargaJual ?? it.hargaBeli,
          stok: it.jumlah,
        ),
      );
      final int terjual = (it.jumlah - b.stok).clamp(0, it.jumlah);
      totalSetor += terjual * it.hargaBeli;
      final margin = (b.hargaJual - it.hargaBeli);
      totalUntung += terjual * (margin > 0 ? margin : 0);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderGaris),
        boxShadow: [
          BoxShadow(
            color: _hijauTua.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Nama Penitip & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _hijauMuda,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person_pin, color: _hijauAksi, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.namaPemasok,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _hijauTua,
                              ),
                            ),
                            Text(
                              item.noFaktur != null && item.noFaktur!.isNotEmpty
                                  ? 'WA/HP: ${item.noFaktur}'
                                  : SimwarFormatter.tanggal(item.tanggal),
                              style: GoogleFonts.inter(fontSize: 11, color: _abuTeks),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAktif ? const Color(0xFFFEF3C7) : _hijauMuda,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAktif ? 'Menunggu Setor' : '✓ Selesai Disetor',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isAktif ? const Color(0xFFB45309) : _hijauAksi,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: _borderGaris, height: 1),
            const SizedBox(height: 12),

            // Item-item barang titipan
            ...item.items.map((it) {
              final b = BarangStore.instance.semua.firstWhere(
                (elem) =>
                    elem.id == it.barangId ||
                    elem.nama.trim().toLowerCase() == it.namaBarang.trim().toLowerCase(),
                orElse: () => BarangModel(
                  id: '',
                  nama: it.namaBarang,
                  barcode: '',
                  kategori: 'Makanan',
                  hargaBeli: it.hargaBeli,
                  hargaJual: it.hargaJual ?? it.hargaBeli,
                  stok: it.jumlah,
                ),
              );
              final int terjual = (it.jumlah - b.stok).clamp(0, it.jumlah);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            it.namaBarang,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _hijauTua,
                            ),
                          ),
                          Text(
                            'Harga Setor ${SimwarFormatter.rupiah(it.hargaBeli)} · Jual ${SimwarFormatter.rupiah(it.hargaJual ?? it.hargaBeli)}',
                            style: GoogleFonts.inter(fontSize: 11, color: _abuTeks),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$terjual / ${it.jumlah} ${it.satuan} laku',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _hijauAksi,
                          ),
                        ),
                        Text(
                          'Sisa stok: ${b.stok}',
                          style: GoogleFonts.inter(fontSize: 10, color: _abuTeks),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),
            // Rincian Pembayaran
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _bgLayar,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Uang Setor Penitip:', style: GoogleFonts.inter(fontSize: 11, color: _abuTeks)),
                      Text(
                        SimwarFormatter.rupiah(totalSetor),
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: _merahAksen),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Untung Warung:', style: GoogleFonts.inter(fontSize: 11, color: _abuTeks)),
                      Text(
                        SimwarFormatter.rupiah(totalUntung),
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: _hijauAksi),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tombol Aksi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _bagikanKeWhatsApp(item, totalSetor, totalUntung),
                    icon: const Icon(Icons.share, size: 16, color: _hijauAksi),
                    label: Text(
                      'Kirim WA',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12, color: _hijauAksi),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _hijauAksi),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (isAktif) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _bukaDialogRekapSore(item),
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: Text(
                        'Rekap & Setor',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hijauAksi,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialog: + Catat Titipan Baru ──────────────────────────────────────────
  void _bukaDialogTambahTitipan() {
    final namaPenitipCtrl = TextEditingController();
    final noHpCtrl = TextEditingController();
    final namaBarangCtrl = TextEditingController();
    final hargaSetorCtrl = TextEditingController();
    final hargaJualCtrl = TextEditingController();
    final jumlahCtrl = TextEditingController(text: '20');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
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
                const SizedBox(height: 16),
                Text(
                  'Catat Titipan Warga Baru',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _hijauTua,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Barang otomatis masuk ke inventaris dan dapat langsung dijual di Kasir.',
                  style: GoogleFonts.inter(fontSize: 12, color: _abuTeks),
                ),
                const SizedBox(height: 16),

                // Nama Penitip & No HP
                TextField(
                  controller: namaPenitipCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Mitra Penitip',
                    hintText: 'Misal: Bu Siti (Kue Basah)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noHpCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor WhatsApp / HP',
                    hintText: 'Misal: 0812-3456-7890',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Nama Barang
                TextField(
                  controller: namaBarangCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Makanan / Produk Titipan',
                    hintText: 'Misal: Risoles Mayo, Pastel Sayur',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Jumlah Masuk
                TextField(
                  controller: jumlahCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Jumlah Titip Masuk (Pcs)',
                    hintText: '20',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Harga Setor & Harga Jual
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: hargaSetorCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Harga Setor (Rp)',
                          hintText: '2000',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: hargaJualCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Harga Jual (Rp)',
                          hintText: '2500',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tombol Simpan
                ElevatedButton(
                  onPressed: () {
                    final namaPenitip = namaPenitipCtrl.text.trim();
                    final namaBarang = namaBarangCtrl.text.trim();
                    final setor = int.tryParse(hargaSetorCtrl.text.trim()) ?? 0;
                    final jual = int.tryParse(hargaJualCtrl.text.trim()) ?? (setor + 500);
                    final jumlah = int.tryParse(jumlahCtrl.text.trim()) ?? 10;

                    if (namaPenitip.isEmpty || namaBarang.isEmpty || setor <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lengkapi nama penitip, nama barang, dan harga setor!'),
                          backgroundColor: _merahAksen,
                        ),
                      );
                      return;
                    }

                    final model = BarangMasukModel(
                      id: 'TITIP-${DateTime.now().millisecondsSinceEpoch}',
                      tanggal: DateTime.now(),
                      jenis: JenisBarangMasuk.titipan,
                      namaPemasok: namaPenitip,
                      noFaktur: noHpCtrl.text.trim(),
                      totalNilai: setor * jumlah,
                      statusBayar: StatusBayarPasokan.konsinyasi,
                      dicatatOleh: widget.pengguna?.nama ?? 'Penjaga',
                      sudahDisetorKePenitip: false,
                      items: [
                        BarangMasukItem(
                          barangId: 'item-titip-${DateTime.now().millisecondsSinceEpoch}',
                          namaBarang: namaBarang,
                          jumlah: jumlah,
                          satuan: 'pcs',
                          hargaBeli: setor,
                          hargaJual: jual,
                        ),
                      ],
                    );

                    BarangMasukStore.instance.tambahBarangMasuk(model);
                    Navigator.pop(ctx);
                    setState(() {});

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Titipan "$namaBarang" dari $namaPenitip berhasil dicatat!'),
                        backgroundColor: _hijauAksi,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hijauAksi,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Simpan Titipan Masuk',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Dialog: Rekap Sore & Selesaikan Setoran ───────────────────────────────
  void _bukaDialogRekapSore(BarangMasukModel item) {
    int totalSetor = 0;
    int totalUntung = 0;

    for (var it in item.items) {
      final b = BarangStore.instance.semua.firstWhere(
        (elem) =>
            elem.id == it.barangId ||
            elem.nama.trim().toLowerCase() == it.namaBarang.trim().toLowerCase(),
        orElse: () => BarangModel(
          id: '',
          nama: it.namaBarang,
          barcode: '',
          kategori: 'Makanan',
          hargaBeli: it.hargaBeli,
          hargaJual: it.hargaJual ?? it.hargaBeli,
          stok: it.jumlah,
        ),
      );
      final int terjual = (it.jumlah - b.stok).clamp(0, it.jumlah);
      totalSetor += terjual * it.hargaBeli;
      final margin = (b.hargaJual - it.hargaBeli);
      totalUntung += terjual * (margin > 0 ? margin : 0);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Selesaikan Setoran Titipan',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: _hijauTua),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mitra: ${item.namaPemasok}',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _hijauTua),
            ),
            const SizedBox(height: 10),
            Text(
              'Pastikan uang tunai sebesar ${SimwarFormatter.rupiah(totalSetor)} sudah siap diserahkan kepada penitip.',
              style: GoogleFonts.inter(fontSize: 13, color: _abuTeks, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _hijauMuda,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Untung Warung:', style: GoogleFonts.inter(fontSize: 12, color: _hijauTua)),
                  Text(
                    SimwarFormatter.rupiah(totalUntung),
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: _hijauAksi),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.inter(color: _abuTeks)),
          ),
          ElevatedButton(
            onPressed: () {
              BarangMasukStore.instance.selesaikanKonsinyasi(item.id, item.sisaRetur ?? 0);
              Navigator.pop(ctx);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Setoran titipan ${item.namaPemasok} telah ditandai lunas!'),
                  backgroundColor: _hijauAksi,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _hijauAksi,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tandai Lunas Disetor'),
          ),
        ],
      ),
    );
  }

  // ── Share / Kirim Rekap ke WhatsApp ───────────────────────────────────────
  void _bagikanKeWhatsApp(BarangMasukModel item, int totalSetor, int totalUntung) {
    final buffer = StringBuffer();
    buffer.writeln('📋 *REKAP TITIPAN KONSINYASI WARUNG AZZAM*');
    buffer.writeln('----------------------------------------');
    buffer.writeln('👤 *Mitra:* ${item.namaPemasok}');
    buffer.writeln('📅 *Tanggal:* ${SimwarFormatter.tanggal(item.tanggal)}');
    buffer.writeln('----------------------------------------');

    for (var it in item.items) {
      final b = BarangStore.instance.semua.firstWhere(
        (elem) =>
            elem.id == it.barangId ||
            elem.nama.trim().toLowerCase() == it.namaBarang.trim().toLowerCase(),
        orElse: () => BarangModel(
          id: '',
          nama: it.namaBarang,
          barcode: '',
          kategori: 'Makanan',
          hargaBeli: it.hargaBeli,
          hargaJual: it.hargaJual ?? it.hargaBeli,
          stok: it.jumlah,
        ),
      );
      final int terjual = (it.jumlah - b.stok).clamp(0, it.jumlah);
      buffer.writeln('• ${it.namaBarang}:');
      buffer.writeln('  - Titip: ${it.jumlah} ${it.satuan}');
      buffer.writeln('  - Terjual: $terjual ${it.satuan}');
      buffer.writeln('  - Sisa Retur: ${b.stok} ${it.satuan}');
      buffer.writeln('  - Harga Setor: ${SimwarFormatter.rupiah(it.hargaBeli)} / pcs');
    }

    buffer.writeln('----------------------------------------');
    buffer.writeln('💵 *TOTAL HAK SETOR:* ${SimwarFormatter.rupiah(totalSetor)}');
    buffer.writeln('Status: ${item.sudahDisetorKePenitip ? "Lunas Disetor" : "Siap Diambil/Disetor Sore Ini"}');
    buffer.writeln('\n_Terima kasih atas kerja samanya dengan Warung Azzam!_');

    Share.share(
      buffer.toString(),
      subject: 'Rekap Titipan ${item.namaPemasok}',
    );
  }
}
