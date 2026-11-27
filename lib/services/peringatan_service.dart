import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/barang_model.dart';
import '../models/notifikasi_model.dart';
import '../models/pengaturan_warung_model.dart';

/// Model payload untuk peringatan stok/kedaluwarsa
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

/// Service otomatis pemantau stok minimum & kedaluwarsa dengan Android Heads-Up System Notification
class PeringatanService {
  static final PeringatanService instance = PeringatanService._internal();
  factory PeringatanService() => instance;
  PeringatanService._internal();

  static const String _channelId = 'simwar_peringatan_tinggi';
  static const String _channelName = 'Peringatan Stok & Kedaluwarsa';
  static const String _channelDesc =
      'Notifikasi heads-up saat barang hampir kedaluwarsa atau stok menipis';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  final Set<String> _sentOsNotifKeys = {};

  /// Notifier fallback khusus preview Web (di Android langsung tampil sebagai Heads-Up OS)
  final ValueNotifier<PeringatanAlert?> alertBannerAktif = ValueNotifier(null);

  void resetSession() {
    _sentOsNotifKeys.clear();
    alertBannerAktif.value = null;
  }

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _plugin.initialize(
        settings: const InitializationSettings(android: androidInit),
      );

      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ),
        );
        await androidPlugin.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('Gagal inisialisasi notifikasi sistem Android: $e');
    }
  }

  Future<void> _tampilkanHeadsUpSistem({
    required String dedupKey,
    required String judul,
    required String pesan,
  }) async {
    if (_sentOsNotifKeys.contains(dedupKey)) return;
    _sentOsNotifKeys.add(dedupKey);

    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    await init();
    try {
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        ticker: judul,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.reminder,
        styleInformation: BigTextStyleInformation(pesan),
      );
      await _plugin.show(
        id: dedupKey.hashCode & 0x7FFFFFFF,
        title: judul,
        body: pesan,
        notificationDetails: NotificationDetails(android: androidDetails),
      );
    } catch (e) {
      debugPrint('Gagal menampilkan notifikasi heads-up Android: $e');
    }
  }

  /// Menjalankan pemindaian seluruh barang di toko
  void periksaSemuaPeringatan() {
    final cfg = PengaturanStore.instance.pengaturan;
    final barangList = BarangStore.instance.semua;
    final batasHariExp =
        cfg.hariPeringatanKedaluwarsa > 0 ? cfg.hariPeringatanKedaluwarsa : 3;
    PeringatanAlert? alertTerpenting;

    for (final b in barangList) {
      // ── 1. Cek Kedaluwarsa: <= 3 hari (atau sesuai pengaturan warung) ─────
      if (cfg.notifKedaluwarsa && b.tglKedaluwarsa != null) {
        final sisaHari = b.sisaHariKedaluwarsa;
        if (sisaHari <= batasHariExp) {
          String statusPesan;
          if (sisaHari < 0) {
            statusPesan =
                'Sudah kedaluwarsa sejak ${-sisaHari} hari lalu! Segera tarik dari rak.';
          } else if (sisaHari == 0) {
            statusPesan =
                'Kedaluwarsa HARI INI! Segera lakukan retur / diskon obral.';
          } else {
            statusPesan =
                'Tersisa $sisaHari hari sebelum kedaluwarsa. Periksa rak display!';
          }

          final dedupId =
              'exp_${b.id}_${DateTime.now().year}_${DateTime.now().month}_${DateTime.now().day}';
          final judulExp = 'Peringatan Kedaluwarsa: ${b.nama}';
          final notif = NotifikasiModel(
            id: dedupId,
            judul: judulExp,
            pesan: statusPesan,
            waktu: DateTime.now(),
            kategori: KategoriNotif.stok,
            routeTarget: 'stok',
            isRead: false,
          );
          NotifikasiStore.instance.tambahNotifikasi(notif);
          _tampilkanHeadsUpSistem(
            dedupKey: dedupId,
            judul: judulExp,
            pesan: statusPesan,
          );

          alertTerpenting ??= PeringatanAlert(
            id: notif.id,
            judul: 'Peringatan Kedaluwarsa',
            pesan: '${b.nama} — $statusPesan',
            namaBarang: b.nama,
            isKedaluwarsa: true,
            sisa: sisaHari,
            waktu: DateTime.now(),
          );
        }
      }

      // ── 2. Cek Stok Menipis: stok <= batasMin (default 10) ────────────────
      final batasStok = b.batasMin > 0 ? b.batasMin : cfg.batasStokDefault;
      if (cfg.notifStokMenipis && b.stok <= batasStok) {
        final String statusPesan = b.stok == 0
            ? 'Stok ${b.nama} kosong (0 ${b.satuan})! Segera restok.'
            : 'Sisa stok ${b.nama} tinggal ${b.stok} ${b.satuan} (batas min. $batasStok). Segera tambah ke Rencana Belanja.';

        final dedupId =
            'stok_${b.id}_${b.stok}_${DateTime.now().year}_${DateTime.now().month}_${DateTime.now().day}';
        final judulStok =
            b.stok == 0 ? 'Stok Habis: ${b.nama}' : 'Stok Menipis: ${b.nama}';
        final notif = NotifikasiModel(
          id: dedupId,
          judul: judulStok,
          pesan: statusPesan,
          waktu: DateTime.now(),
          kategori: KategoriNotif.stok,
          routeTarget: 'stok',
          isRead: false,
        );
        NotifikasiStore.instance.tambahNotifikasi(notif);
        _tampilkanHeadsUpSistem(
          dedupKey: dedupId,
          judul: judulStok,
          pesan: statusPesan,
        );

        alertTerpenting ??= PeringatanAlert(
          id: notif.id,
          judul: b.stok == 0 ? 'Stok Habis!' : 'Stok Menipis (≤ $batasStok)',
          pesan: statusPesan,
          namaBarang: b.nama,
          isKedaluwarsa: false,
          sisa: b.stok,
          waktu: DateTime.now(),
        );
      }
    }

    if (kIsWeb && alertTerpenting != null) {
      alertBannerAktif.value = alertTerpenting;
    }
  }

  void dismissAlert() {
    alertBannerAktif.value = null;
  }
}
