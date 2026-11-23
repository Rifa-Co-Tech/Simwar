import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/barang_masuk_model.dart';
import '../models/barang_model.dart';
import '../models/pengguna_model.dart';
import '../utils/formatters.dart';

/// SIMWAR — Form Catat Barang Masuk (Distributor & Titipan Warga)
/// Figma node: 2224:93
class CatatBarangMasukScreen extends StatefulWidget {
  final PenggunaModel? pengguna;
  const CatatBarangMasukScreen({super.key, this.pengguna});

  @override
  State<CatatBarangMasukScreen> createState() => _CatatBarangMasukScreenState();
}

class _CatatBarangMasukScreenState extends State<CatatBarangMasukScreen> {
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

  JenisBarangMasuk _jenisDipilih = JenisBarangMasuk.distributor;
  final TextEditingController _pemasokCtrl = TextEditingController();
  final TextEditingController _noFakturCtrl = TextEditingController();
  final TextEditingController _catatanCtrl = TextEditingController();

  StatusBayarPasokan _statusBayar = StatusBayarPasokan.lunas;
  DateTime _tglJatuhTempo = DateTime.now().add(const Duration(days: 7));

  final List<BarangMasukItem> _items = [];

  // Pemasok umum untuk shortcut klik cepat
  final List<String> _distributorCepat = [
    'PT Indomarco Adi Prima',
    'Grosir Berkah Utama',
    'PT Mayora Indah',
    'Danone Aqua Tirta',
  ];

  final List<String> _penitipCepat = [
    'Bu Siti (Kue & Gorengan)',
    'Bu Tejo (Peyek & Kerupuk)',
    'Pak Joko (Roti & Jajanan)',
    'Mbak Dewi (Donat Kentang)',
  ];

  @override
  void dispose() {
    _pemasokCtrl.dispose();
    _noFakturCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  int get _grandTotal => _items.fold(0, (sum, i) => sum + i.subtotal);

  @override
  Widget build(BuildContext context) {
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
          'Catat Barang Masuk',
          style: GoogleFonts.inter(
            color: _hijauTua,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Selector Jenis Pasokan (Distributor vs Titipan Warga)
            _buildJenisSelector(),
            const SizedBox(height: 20),

            // 2. Info Pemasok / Penitip
            _buildCardWrapper(
              title: _jenisDipilih == JenisBarangMasuk.distributor
                  ? 'Data Distributor / Pemasok'
                  : 'Data Warga Penitip (Konsinyasi)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _jenisDipilih == JenisBarangMasuk.distributor
                        ? 'Nama Distributor / Toko Grosir'
                        : 'Nama Warga Penitip',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _hijauTua,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _pemasokCtrl,
                    style: GoogleFonts.inter(color: _hijauTua),
                    decoration: InputDecoration(
                      hintText: _jenisDipilih == JenisBarangMasuk.distributor
                          ? 'Cth: PT Indomarco, Grosir Berkah'
                          : 'Cth: Bu Siti (Pastel & Risol)',
                      hintStyle: GoogleFonts.inter(color: _abuTeks.withValues(alpha: 0.6)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _borderInput),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _borderInput),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _hijauAksi, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Chip rekomendasi cepat
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: (_jenisDipilih == JenisBarangMasuk.distributor
                            ? _distributorCepat
                            : _penitipCepat)
                        .map((nama) {
                      return ActionChip(
                        label: Text(
                          nama,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: _hijauTua,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: _hijauMuda,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        onPressed: () {
                          setState(() {
                            _pemasokCtrl.text = nama;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // No Faktur / No HP
                  Text(
                    _jenisDipilih == JenisBarangMasuk.distributor
                        ? 'No. Faktur / Surat Jalan (Opsional)'
                        : 'No. WhatsApp / HP Penitip',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _hijauTua,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _noFakturCtrl,
                    keyboardType: _jenisDipilih == JenisBarangMasuk.titipan
                        ? TextInputType.phone
                        : TextInputType.text,
                    style: GoogleFonts.inter(color: _hijauTua),
                    decoration: InputDecoration(
                      hintText: _jenisDipilih == JenisBarangMasuk.distributor
                          ? 'Cth: INV-2026-9901'
                          : 'Cth: 0812-3456-7890',
                      hintStyle: GoogleFonts.inter(color: _abuTeks.withValues(alpha: 0.6)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _borderInput),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _borderInput),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _hijauAksi, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Daftar Barang yang Masuk
            _buildCardWrapper(
              title: 'Daftar Barang Masuk',
              trailing: TextButton.icon(
                onPressed: _showTambahBarangDialog,
                icon: const Icon(Icons.add_circle, color: _hijauAksi, size: 20),
                label: Text(
                  'Tambah Item',
                  style: GoogleFonts.inter(
                    color: _hijauAksi,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              child: Column(
                children: [
                  if (_items.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2_outlined, color: _abuTeks.withValues(alpha: 0.5), size: 44),
                          const SizedBox(height: 8),
                          Text(
                            'Belum ada barang ditambahkan',
                            style: GoogleFonts.inter(color: _abuTeks, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Klik "+ Tambah Item" untuk memasukkan pasokan',
                            style: GoogleFonts.inter(
                              color: _hijauAksi,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Divider(color: _borderGaris, height: 16),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _hijauMuda,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: _hijauTua,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.namaBarang,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      color: _hijauTua,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.jumlah} ${item.satuan} × ${SimwarFormatter.rupiah(item.hargaBeli)}',
                                    style: GoogleFonts.inter(
                                      color: _abuTeks,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (item.hargaJual != null)
                                    Text(
                                      'Jual: ${SimwarFormatter.rupiah(item.hargaJual!)}/unit',
                                      style: GoogleFonts.inter(
                                        color: _hijauAksi,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              SimwarFormatter.rupiah(item.subtotal),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                color: _hijauTua,
                                fontSize: 13,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: _merahAksen, size: 20),
                              onPressed: () {
                                setState(() {
                                  _items.removeAt(index);
                                });
                              },
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Status Pembayaran Pasokan
            _buildCardWrapper(
              title: 'Status Pembayaran',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_jenisDipilih == JenisBarangMasuk.distributor) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildPilihanStatus(
                            label: 'Lunas (Tunai/Transfer)',
                            isSelected: _statusBayar == StatusBayarPasokan.lunas,
                            onTap: () => setState(() => _statusBayar = StatusBayarPasokan.lunas),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPilihanStatus(
                            label: 'Tempo (Hutang Dagang)',
                            isSelected: _statusBayar == StatusBayarPasokan.tempo,
                            onTap: () => setState(() => _statusBayar = StatusBayarPasokan.tempo),
                          ),
                        ),
                      ],
                    ),
                    if (_statusBayar == StatusBayarPasokan.tempo) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF6EA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _kuningAksen.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jatuh Tempo Pembayaran:',
                                  style: GoogleFonts.inter(fontSize: 11, color: _abuTeks),
                                ),
                                Text(
                                  SimwarFormatter.tanggal(_tglJatuhTempo),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _hijauTua,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: _pilihTanggalJatuhTempo,
                              child: const Text('Ubah Tanggal', style: TextStyle(color: _hijauAksi)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _hijauMuda,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderGaris),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.handshake_outlined, color: _hijauAksi, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sistem Konsinyasi (Bagi Hasil)',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: _hijauTua,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Pembayaran disetor ke penitip saat sore hari sesuai jumlah yang laku terjual.',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: _abuTeks,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 5. Catatan Tambahan
            _buildCardWrapper(
              title: 'Catatan (Opsional)',
              child: TextField(
                controller: _catatanCtrl,
                maxLines: 2,
                style: GoogleFonts.inter(color: _hijauTua),
                decoration: InputDecoration(
                  hintText: 'Cth: Barang dicek lengkap, dus tidak penyok, dll',
                  hintStyle: GoogleFonts.inter(color: _abuTeks.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _borderInput),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _borderInput),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _hijauAksi, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 6. Tombol Simpan & Ringkasan Nilai
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _borderGaris),
                boxShadow: [
                  BoxShadow(
                    color: _hijauTua.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Nilai Pasokan (${_items.length} item):',
                        style: GoogleFonts.inter(fontSize: 13, color: _abuTeks),
                      ),
                      Text(
                        SimwarFormatter.rupiah(_grandTotal),
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _hijauTua,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _simpanBarangMasuk,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hijauAksi,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Simpan Barang Masuk',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildJenisSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE4DCC3),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _jenisDipilih = JenisBarangMasuk.distributor;
                  _statusBayar = StatusBayarPasokan.lunas;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _jenisDipilih == JenisBarangMasuk.distributor ? _hijauTua : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Pasokan Distributor',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _jenisDipilih == JenisBarangMasuk.distributor ? Colors.white : _hijauTua,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _jenisDipilih = JenisBarangMasuk.titipan;
                  _statusBayar = StatusBayarPasokan.konsinyasi;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _jenisDipilih == JenisBarangMasuk.titipan ? _hijauTua : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Titipan Warga',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _jenisDipilih == JenisBarangMasuk.titipan ? Colors.white : _hijauTua,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardWrapper({required String title, required Widget child, Widget? trailing}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderGaris),
        boxShadow: [
          BoxShadow(
            color: _hijauTua.withValues(alpha: 0.05),
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
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _hijauTua,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildPilihanStatus({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? _hijauMuda : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _hijauAksi : _borderInput,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? _hijauTua : _abuTeks,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pilihTanggalJatuhTempo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tglJatuhTempo,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: _hijauAksi),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _tglJatuhTempo = picked);
    }
  }

  void _showTambahBarangDialog() {
    final namaCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '10');
    final satuanCtrl = TextEditingController(text: 'pcs');
    final hargaBeliCtrl = TextEditingController();
    final hargaJualCtrl = TextEditingController();
    String? selectedFromCatalogId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
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
                          'Tambah Barang Pasokan',
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
                    const SizedBox(height: 12),

                    // Pilih Cepat Dari Katalog
                    Text(
                      'Pilih Dari Katalog Warung (Atau Ketik Baru)',
                      style: GoogleFonts.inter(fontSize: 12, color: _abuTeks),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: BarangStore.instance.semua.take(6).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final b = BarangStore.instance.semua[i];
                          final isSelected = selectedFromCatalogId == b.id;
                          return ChoiceChip(
                            label: Text(b.nama, style: const TextStyle(fontSize: 11)),
                            selected: isSelected,
                            selectedColor: _hijauMuda,
                            onSelected: (val) {
                              setModalState(() {
                                if (val) {
                                  selectedFromCatalogId = b.id;
                                  namaCtrl.text = b.nama;
                                  satuanCtrl.text = b.satuan;
                                  hargaBeliCtrl.text = b.hargaBeli.toString();
                                  hargaJualCtrl.text = b.hargaJual.toString();
                                } else {
                                  selectedFromCatalogId = null;
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Nama Barang
                    TextField(
                      controller: namaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Barang',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Jumlah & Satuan
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: qtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Jumlah',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: satuanCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Satuan (pcs/dus)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Harga Beli & Harga Jual
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: hargaBeliCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: _jenisDipilih == JenisBarangMasuk.distributor
                                  ? 'Harga Beli/Modal'
                                  : 'Harga Setor Penitip',
                              border: const OutlineInputBorder(),
                              prefixText: 'Rp ',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: hargaJualCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Harga Jual Eceran',
                              border: OutlineInputBorder(),
                              prefixText: 'Rp ',
                            ),
                          ),
                        ),
                      ],
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
                          if (namaCtrl.text.trim().isEmpty) return;
                          final qty = int.tryParse(qtyCtrl.text) ?? 1;
                          final beli = int.tryParse(hargaBeliCtrl.text) ?? 0;
                          final jual = int.tryParse(hargaJualCtrl.text);

                          setState(() {
                            _items.add(
                              BarangMasukItem(
                                barangId: selectedFromCatalogId ?? 'AUTO-${DateTime.now().millisecondsSinceEpoch}',
                                namaBarang: namaCtrl.text.trim(),
                                jumlah: qty,
                                satuan: satuanCtrl.text.trim(),
                                hargaBeli: beli,
                                hargaJual: jual,
                              ),
                            );
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text('Tambahkan ke Daftar', style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _simpanBarangMasuk() {
    if (_pemasokCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan nama pemasok / penitip!'),
          backgroundColor: _merahAksen,
        ),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan minimal 1 item barang yang masuk!'),
          backgroundColor: _merahAksen,
        ),
      );
      return;
    }

    final newBarangMasuk = BarangMasukModel(
      id: 'BM-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().millisecondsSinceEpoch % 1000}',
      tanggal: DateTime.now(),
      jenis: _jenisDipilih,
      namaPemasok: _pemasokCtrl.text.trim(),
      noFaktur: _noFakturCtrl.text.trim().isEmpty ? null : _noFakturCtrl.text.trim(),
      items: List.from(_items),
      totalNilai: _grandTotal,
      statusBayar: _statusBayar,
      jatuhTempo: _statusBayar == StatusBayarPasokan.tempo ? _tglJatuhTempo : null,
      catatan: _catatanCtrl.text.trim().isEmpty ? null : _catatanCtrl.text.trim(),
      dicatatOleh: widget.pengguna?.nama ?? 'Pemilik',
    );

    BarangMasukStore.instance.tambahBarangMasuk(newBarangMasuk);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: _hijauAksi, size: 54),
            const SizedBox(height: 14),
            Text(
              'Barang Masuk Berhasil Dicatat!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _hijauTua,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Stok ${_items.length} item barang telah otomatis diperbarui di katalog warung.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: _abuTeks),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // pop dialog
              Navigator.pop(context); // pop screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _hijauAksi,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('OK, Kembali'),
          ),
        ],
      ),
    );
  }
}
