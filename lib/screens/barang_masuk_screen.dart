import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/barang_masuk_model.dart';
import '../models/pengguna_model.dart';
import '../utils/formatters.dart';
import 'catat_barang_masuk_screen.dart';

/// SIMWAR — Modul Barang Masuk (Distributor & Titipan Warga)
/// Figma node: 2224:2
class BarangMasukScreen extends StatefulWidget {
  final PenggunaModel? pengguna;
  const BarangMasukScreen({super.key, this.pengguna});

  @override
  State<BarangMasukScreen> createState() => _BarangMasukScreenState();
}

class _BarangMasukScreenState extends State<BarangMasukScreen> {
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

  String _tabDipilih = 'Semua'; // 'Semua' | 'Distributor' | 'Titipan'
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<BarangMasukModel> get _filteredList {
    final store = BarangMasukStore.instance;
    List<BarangMasukModel> list;
    if (_tabDipilih == 'Distributor') {
      list = store.distributorOnly;
    } else if (_tabDipilih == 'Titipan') {
      list = store.titipanOnly;
    } else {
      list = store.semua;
    }

    final q = _searchCtrl.text.toLowerCase().trim();
    if (q.isEmpty) return list;

    return list.where((item) {
      final matchSupplier = item.namaPemasok.toLowerCase().contains(q);
      final matchFaktur = item.noFaktur?.toLowerCase().contains(q) ?? false;
      final matchItem = item.items.any((i) => i.namaBarang.toLowerCase().contains(q));
      return matchSupplier || matchFaktur || matchItem;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final store = BarangMasukStore.instance;

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
          'Barang Masuk',
          style: GoogleFonts.inter(
            color: _hijauTua,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Metric Summary Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Pasokan Bulan Ini',
                    value: SimwarFormatter.rupiah(store.totalNilaiBulanIni),
                    color: _hijauTua,
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Titipan Aktif',
                    value: '${store.titipanAktifCount} Mitra',
                    color: const Color(0xFFD97706),
                    icon: Icons.handshake_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Faktur Tempo',
                    value: '${store.fakturTempoCount} Belum Lunas',
                    color: _merahAksen,
                    icon: Icons.pending_actions_outlined,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 2. Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.inter(color: _hijauTua, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari distributor, penitip, atau nama barang...',
                hintStyle: GoogleFonts.inter(color: _abuTeks.withValues(alpha: 0.7), fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: _abuTeks, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _borderGaris),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _borderGaris),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _hijauAksi, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 3. Tab Filter
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterTab('Semua', store.semua.length),
                const SizedBox(width: 8),
                _buildFilterTab('Distributor', store.distributorOnly.length),
                const SizedBox(width: 8),
                _buildFilterTab('Titipan', store.titipanOnly.length),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4. Daftar Barang Masuk
          Expanded(
            child: _filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 54, color: _abuTeks.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada data barang masuk',
                          style: GoogleFonts.inter(color: _abuTeks, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
                    itemCount: _filteredList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _filteredList[index];
                      return _buildBarangMasukCard(item);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CatatBarangMasukScreen(pengguna: widget.pengguna),
            ),
          );
          setState(() {}); // refresh after return
        },
        backgroundColor: _hijauAksi,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          'Catat Barang Masuk',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 10, color: _abuTeks),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, int count) {
    final isSelected = _tabDipilih == label;
    return GestureDetector(
      onTap: () => setState(() => _tabDipilih = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _hijauTua : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _hijauTua : _borderGaris),
        ),
        child: Row(
          children: [
            Text(
              label == 'Titipan' ? 'Titipan Warga' : label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : _hijauTua,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
        ),
      ),
    );
  }

  Widget _buildBarangMasukCard(BarangMasukModel item) {
    final isDist = item.isDistributor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderGaris),
        boxShadow: [
          BoxShadow(
            color: _hijauTua.withValues(alpha: 0.05),
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
            // Header: Badge Jenis & Status Bayar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDist ? _hijauMuda : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isDist ? Icons.local_shipping_outlined : Icons.handshake_outlined,
                        size: 14,
                        color: isDist ? _hijauAksi : const Color(0xFFB45309),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isDist ? 'Distributor' : 'Titipan Warga',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDist ? _hijauAksi : const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBayarBadge(item),
              ],
            ),
            const SizedBox(height: 10),

            // Nama Pemasok / Penitip
            Text(
              item.namaPemasok,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _hijauTua,
              ),
            ),
            const SizedBox(height: 4),

            // Tanggal & No Faktur/HP
            Row(
              children: [
                Text(
                  SimwarFormatter.tanggal(item.tanggal),
                  style: GoogleFonts.inter(fontSize: 11, color: _abuTeks),
                ),
                if (item.noFaktur != null) ...[
                  Text(' • ', style: TextStyle(color: _abuTeks)),
                  Text(
                    item.noFaktur!,
                    style: GoogleFonts.inter(fontSize: 11, color: _abuTeks),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: _borderGaris, height: 1),
            const SizedBox(height: 10),

            // Ringkasan Items
            Column(
              children: item.items.map((i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${i.jumlah} ${i.satuan} ${i.namaBarang}',
                          style: GoogleFonts.inter(fontSize: 12, color: _hijauTua),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        SimwarFormatter.rupiah(i.subtotal),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _hijauTua,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),

            // Footer: Total & Aksi Khusus
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pasokan:',
                      style: GoogleFonts.inter(fontSize: 11, color: _abuTeks),
                    ),
                    Text(
                      SimwarFormatter.rupiah(item.totalNilai),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _hijauTua,
                      ),
                    ),
                  ],
                ),

                // Tombol Aksi Spesifik
                if (item.isTitipan && !item.sudahDisetorKePenitip) ...[
                  ElevatedButton.icon(
                    onPressed: () => _showRekapKonsinyasiDialog(item),
                    icon: const Icon(Icons.calculate_outlined, size: 16),
                    label: const Text('Rekap & Setor', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ] else if (item.statusBayar == StatusBayarPasokan.tempo) ...[
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        BarangMasukStore.instance.tandaiFakturLunas(item.id);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Faktur ${item.namaPemasok} ditandai Lunas!'),
                          backgroundColor: _hijauAksi,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, size: 16, color: _hijauAksi),
                    label: const Text('Tandai Lunas', style: TextStyle(fontSize: 12, color: _hijauAksi)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _hijauAksi),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  Widget _buildStatusBayarBadge(BarangMasukModel item) {
    if (item.statusBayar == StatusBayarPasokan.lunas) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _hijauMuda,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Lunas',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _hijauAksi,
          ),
        ),
      );
    } else if (item.statusBayar == StatusBayarPasokan.tempo) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFDE8E8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 12, color: _merahAksen),
            const SizedBox(width: 4),
            Text(
              'Tempo: ${item.jatuhTempo != null ? SimwarFormatter.tanggal(item.jatuhTempo!) : "7 hari"}',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _merahAksen,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Konsinyasi Aktif',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFB45309),
          ),
        ),
      );
    }
  }

  void _showRekapKonsinyasiDialog(BarangMasukModel item) {
    final returCtrl = TextEditingController(text: '${item.sisaRetur ?? 0}');
    final totalTitip = item.totalItemCount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final retur = int.tryParse(returCtrl.text) ?? 0;
            final laku = (totalTitip - retur).clamp(0, totalTitip);
            // Hitung estimasi setor
            int totalSetor = 0;
            int totalLabaWarung = 0;

            for (var it in item.items) {
              final proporsi = totalTitip > 0 ? (it.jumlah / totalTitip) : 0;
              final lakuItem = (laku * proporsi).round();
              totalSetor += lakuItem * it.hargaBeli;
              if (it.hargaJual != null) {
                totalLabaWarung += lakuItem * (it.hargaJual! - it.hargaBeli);
              }
            }

            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rekap Titipan Konsinyasi',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _hijauTua,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mitra: ${item.namaPemasok}',
                      style: GoogleFonts.inter(fontSize: 13, color: _abuTeks),
                    ),
                    const SizedBox(height: 16),

                    // Rincian Titip Awal vs Retur
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _hijauMuda,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Titipan Awal:', style: GoogleFonts.inter(fontSize: 13, color: _hijauTua)),
                              Text('$totalTitip pcs', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: _hijauTua)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text('Jumlah Retur (Sisa / Basi):', style: GoogleFonts.inter(fontSize: 13, color: _merahAksen)),
                              ),
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 38,
                                  child: TextField(
                                    controller: returCtrl,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    onChanged: (_) => setModalState(() {}),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Laku Terjual:', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: _hijauAksi)),
                              Text('$laku pcs', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: _hijauAksi)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Ringkasan Pembayaran Bagi Hasil
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF6EA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _borderGaris),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Uang Setor ke Penitip:', style: GoogleFonts.inter(fontSize: 13, color: _hijauTua)),
                              Text(
                                SimwarFormatter.rupiah(totalSetor),
                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: _hijauTua),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Laba Bersih Warung:', style: GoogleFonts.inter(fontSize: 12, color: _hijauAksi)),
                              Text(
                                '+ ${SimwarFormatter.rupiah(totalLabaWarung)}',
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: _hijauAksi),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hijauAksi,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          setState(() {
                            BarangMasukStore.instance.selesaikanKonsinyasi(item.id, retur);
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Rekap konsinyasi selesai! Rp ${SimwarFormatter.rupiah(totalSetor)} disetor ke ${item.namaPemasok}.'),
                              backgroundColor: _hijauAksi,
                            ),
                          );
                        },
                        child: const Text('Bayar Setoran & Selesaikan', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
