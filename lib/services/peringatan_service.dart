import 'package:flutter/foundation.dart';
import '../models/barang_model.dart';
import '../models/notifikasi_model.dart';
import '../models/pengaturan_warung_model.dart';

/// Model payload untuk notifikasi heads-up di atas layar HP
class PeringatanAlert {
  final String id;
  final String judul;
  final String pesan;
  final String namaBarang;
  final bool isKedaluwarsa;
  final int sisa;
  final DateTime waktu;

  const PeringatanAlert({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.namaBarang,
    required this.isKedaluwarsa,
    required this.sisa,
    required this.waktu,
  });
}

/// Service otomatis untuk memantau stok <= 10 dan kedaluwarsa <= 3 hari
class PeringatanService {
  static final PeringatanService instance = PeringatanService._internal();
  factory PeringatanService() => instance;
  PeringatanService._internal();

  /// Notifier untuk banner heads-up di atas layar HP
  final ValueNotifier<PeringatanAlert?> alertBannerAktif = ValueNotifier(null);

  /// Menjalankan pemindaian seluruh barang di toko
  void periksaSemuaPeringatan() {
    final cfg = PengaturanStore.instance.pengaturan;
    final barangList = BarangStore.instance.semua;
    PeringatanAlert? alertTerpenting;

    for (final b in barangList) {
      // ── 1. Cek Kedaluwarsa: <= 3 hari ─────────────────────────
      if (cfg.notifKedaluwarsa && b.tglKedaluwarsa != null) {
        final sisaHari = b.sisaHariKedaluwarsa;
        if (sisaHari <= 3) {
          String statusPesan;
          if (sisaHari < 0) {
            statusPesan = 'Sudah kedaluwarsa sejak ${-sisaHari} hari lalu! Segera tarik dari rak.';
          } else if (sisaHari == 0) {
            statusPesan = 'Kedaluwarsa HARI INI! Segera lakukan retur / diskon obral.';
          } else {
            statusPesan = 'Tersisa $sisaHari hari sebelum kedaluwarsa. Periksa rak display!';
          }

          final notif = NotifikasiModel(
            id: 'exp_${b.id}_${DateTime.now().day}',
            judul: 'Kedaluwarsa Segera: ${b.nama}',
            pesan: statusPesan,
            waktu: DateTime.now(),
            kategori: KategoriNotif.stok,
            routeTarget: 'stok',
            isRead: false,
          );
          NotifikasiStore.instance.tambahNotifikasi(notif);

          // Utamakan peringatan kedaluwarsa untuk banner atas layar
          alertTerpenting ??= PeringatanAlert(
            id: notif.id,
            judul: '🔴 Peringatan Kedaluwarsa',
            pesan: '${b.nama} — $statusPesan',
            namaBarang: b.nama,
            isKedaluwarsa: true,
            sisa: sisaHari,
            waktu: DateTime.now(),
          );
        }
      }

      // ── 2. Cek Stok Menipis: stok <= 10 ─────────────────────────
      if (cfg.notifStokMenipis && b.stok <= 10) {
        final String statusPesan = b.stok == 0
            ? 'Stok kosong (0 ${b.satuan})! Pelanggan tidak dapat membeli.'
            : 'Sisa stok tinggal ${b.stok} ${b.satuan} (batas min. 10). Segera tambah ke Rencana Belanja.';

        final notif = NotifikasiModel(
          id: 'stok_${b.id}_${DateTime.now().day}',
          judul: b.stok == 0 ? 'Stok Habis: ${b.nama}' : 'Stok Menipis: ${b.nama}',
          pesan: statusPesan,
          waktu: DateTime.now(),
          kategori: KategoriNotif.stok,
          routeTarget: 'stok',
          isRead: false,
        );
        NotifikasiStore.instance.tambahNotifikasi(notif);

        // Jika belum ada alert kedaluwarsa, tampilkan alert stok
        alertTerpenting ??= PeringatanAlert(
          id: notif.id,
          judul: b.stok == 0 ? '🔴 Stok Habis!' : '⚠️ Stok Menipis (≤ 10)',
          pesan: '${b.nama}: $statusPesan',
          namaBarang: b.nama,
          isKedaluwarsa: false,
          sisa: b.stok,
          waktu: DateTime.now(),
        );
      }
    }

    if (alertTerpenting != null) {
      alertBannerAktif.value = alertTerpenting;
    }
  }

  void dismissAlert() {
    alertBannerAktif.value = null;
  }
}
