import '../models/barang_masuk_model.dart';
import '../models/barang_model.dart';
import '../models/kasbon_model.dart';
import '../models/laporan_model.dart';
import '../models/notifikasi_model.dart';
import '../models/pengaturan_warung_model.dart';
import '../models/pengguna_model.dart';
import '../models/rencana_belanja_model.dart';
import '../models/transaksi_model.dart';
import 'auth_service.dart';
import 'peringatan_service.dart';

/// Mengelola reset & pemuatan ulang seluruh store lokal sesuai akun warung aktif.
class SessionDataService {
  static void resetAllStoresInMemory() {
    PengaturanStore.instance.resetInMemory();
    BarangStore.instance.resetInMemory();
    TransaksiStore.instance.resetInMemory();
    KasbonStore.instance.resetInMemory();
    BarangMasukStore.instance.resetInMemory();
    RencanaBelanjaStore.instance.resetInMemory();
    LaporanStore.instance.resetInMemory();
    NotifikasiStore.instance.resetInMemory();
    PeringatanService.instance.resetSession();
  }

  static Future<void> loadAllForUser(PenggunaModel user) async {
    AuthService.setActiveScopeForUser(user);
    resetAllStoresInMemory();
    await Future.wait([
      PengaturanStore.instance.muatDariLocalStorage(),
      BarangStore.instance.muatDariLocalStorage(),
      TransaksiStore.instance.muatDariLocalStorage(),
      KasbonStore.instance.muatDariLocalStorage(),
      BarangMasukStore.instance.muatDariLocalStorage(),
      RencanaBelanjaStore.instance.muatDariLocalStorage(),
      LaporanStore.instance.muatDariLocalStorage(),
      NotifikasiStore.instance.muatDariLocalStorage(),
    ]);
  }

  static Future<void> clearForLogout() async {
    resetAllStoresInMemory();
    await AuthService().clearActiveSession();
  }
}
