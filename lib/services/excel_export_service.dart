import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/analisis_laba_model.dart';
import '../models/transaksi_model.dart';

/// SIMWAR — Layanan Ekspor Spreadsheet Excel (.xlsx) Resmi Warung
class ExcelExportService {
  static Future<File?> eksporLaporanKeExcel({
    required int totalOmset,
    required int totalLaba,
    required int totalTransaksi,
    required String periode,
  }) async {
    try {
      final excel = Excel.createExcel();

      // ── SHEET 1: Ringkasan Eksekutif ──────────────────────────────────────
      final sheetRingkasan = excel['Ringkasan'];
      excel.setDefaultSheet('Ringkasan');

      sheetRingkasan.appendRow([TextCellValue('LAPORAN PENJUALAN & KEUANGAN WARUNG AZZAM')]);
      sheetRingkasan.appendRow([TextCellValue('Sistem Informasi Manajemen Warung (SIMWAR)')]);
      sheetRingkasan.appendRow([TextCellValue('Periode Laporan:'), TextCellValue(periode)]);
      sheetRingkasan.appendRow([TextCellValue('Tanggal Unduh:'), TextCellValue(DateTime.now().toString().split('.')[0])]);
      sheetRingkasan.appendRow([TextCellValue('')]);

      sheetRingkasan.appendRow([TextCellValue('METRIK UTAMA'), TextCellValue('NILAI (RP / JUMLAH)')]);
      sheetRingkasan.appendRow([TextCellValue('Total Omset Penjualan'), IntCellValue(totalOmset)]);
      sheetRingkasan.appendRow([TextCellValue('Total Laba Bersih Warung'), IntCellValue(totalLaba)]);
      sheetRingkasan.appendRow([TextCellValue('Margin Keuntungan Toko'), TextCellValue('${((totalLaba / (totalOmset > 0 ? totalOmset : 1)) * 100).toStringAsFixed(1)}%')]);
      sheetRingkasan.appendRow([TextCellValue('Total Transaksi Selesai'), IntCellValue(totalTransaksi)]);
      sheetRingkasan.appendRow([TextCellValue('')]);

      sheetRingkasan.appendRow([TextCellValue('BREAKDOWN METODE BAYAR'), TextCellValue('PORSI'), TextCellValue('NOMINAL')]);
      final pStats = LaporanService.instance.getMetodeBayarStats(periode);
      for (var ps in pStats) {
        sheetRingkasan.appendRow([
          TextCellValue(ps.metode),
          TextCellValue('${ps.persen.toStringAsFixed(1)}%'),
          IntCellValue(ps.totalNominal),
        ]);
      }

      // ── SHEET 2: Laba & Performa per Produk ────────────────────────────────
      final sheetProduk = excel['Laba per Produk'];
      sheetProduk.appendRow([
        TextCellValue('Nama Barang'),
        TextCellValue('Kategori'),
        TextCellValue('Harga Beli (Modal)'),
        TextCellValue('Harga Jual'),
        TextCellValue('Margin per Pcs'),
        TextCellValue('Margin (%)'),
        TextCellValue('Total Terjual (Qty)'),
        TextCellValue('Total Omset (Rp)'),
        TextCellValue('Total Laba Bersih (Rp)'),
      ]);

      for (var p in LaporanService.instance.semuaProduk) {
        sheetProduk.appendRow([
          TextCellValue(p.nama),
          TextCellValue(p.kategori),
          IntCellValue(p.hargaBeli),
          IntCellValue(p.hargaJual),
          IntCellValue(p.labaPerUnit),
          TextCellValue('${p.marginPersen.toStringAsFixed(1)}%'),
          IntCellValue(p.terjual),
          IntCellValue(p.totalOmset),
          IntCellValue(p.totalLaba),
        ]);
      }

      // ── SHEET 3: Riwayat Transaksi Kasir ──────────────────────────────────
      final sheetTrx = excel['Riwayat Transaksi'];
      sheetTrx.appendRow([
        TextCellValue('No. Transaksi'),
        TextCellValue('Tanggal'),
        TextCellValue('Jam'),
        TextCellValue('Kasir'),
        TextCellValue('Metode Bayar'),
        TextCellValue('Status'),
        TextCellValue('Total Belanja (Rp)'),
      ]);

      for (var t in TransaksiStore.instance.semua) {
        sheetTrx.appendRow([
          TextCellValue(t.kode),
          TextCellValue(t.tanggal),
          TextCellValue(t.waktu),
          TextCellValue(t.kasir),
          TextCellValue(t.metode),
          TextCellValue(t.status),
          IntCellValue(t.total),
        ]);
      }

      final bytes = excel.save();
      if (bytes == null) return null;

      // Di Android / iOS / Desktop: simpan ke berkas dokumen
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/Laporan_SIMWAR_Warung_Azzam.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Bagikan langsung via native Android Share Sheet (WhatsApp, Email, Drive, Excel Viewer)
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
        text: '📊 Laporan Keuangan SIMWAR Warung Azzam (.xlsx)',
        subject: 'Laporan Keuangan Warung Azzam',
      );

      return file;
    } catch (e) {
      debugPrint('Error ekspor excel: $e');
      return null;
    }
  }
}
