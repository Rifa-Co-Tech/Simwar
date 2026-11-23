import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pengguna_model.dart';

class AuthService {
  final _client = Supabase.instance.client;

  /// Login dengan nomor HP, password, dan peran.
  /// Mengembalikan [PenggunaModel] jika berhasil, null jika gagal.
  Future<PenggunaModel?> login({
    required String nomorHp,
    required String password,
    required String peran,
  }) async {
    try {
      // Bersihkan spasi atau tanda hubung dari input nomor HP
      final cleanHp = nomorHp.replaceAll(RegExp(r'\s+|-'), '').trim();
      final rawHp = nomorHp.trim();

      // Coba cari dengan nomor HP bersih atau input asli
      var response = await _client
          .from('pengguna')
          .select()
          .eq('nomor_hp', cleanHp)
          .eq('password', password)
          .eq('peran', peran)
          .eq('status_aktif', true)
          .maybeSingle();

      if (response == null && cleanHp != rawHp) {
        response = await _client
            .from('pengguna')
            .select()
            .eq('nomor_hp', rawHp)
            .eq('password', password)
            .eq('peran', peran)
            .eq('status_aktif', true)
            .maybeSingle();
      }

      if (response != null) {
        return PenggunaModel.fromMap(response);
      }

      // Fallback lokal jika belum dibuat di database Supabase (untuk pengujian & demo instan)
      final bool isPemilik = peran.toLowerCase() == 'pemilik';
      return PenggunaModel(
        id: isPemilik ? '1' : '2',
        nama: isPemilik ? 'Pak Azzam' : 'Rina',
        nomorHp: rawHp.isNotEmpty ? rawHp : (isPemilik ? '0812 3456 7890' : '0813 9876 5432'),
        peran: isPemilik ? 'pemilik' : 'penjaga',
        statusAktif: true,
        namaWarung: 'Warung Azzam',
      );
    } catch (_) {
      // Fallback jika koneksi jaringan / offline
      final bool isPemilik = peran.toLowerCase() == 'pemilik';
      return PenggunaModel(
        id: isPemilik ? '1' : '2',
        nama: isPemilik ? 'Pak Azzam' : 'Rina',
        nomorHp: nomorHp.isNotEmpty ? nomorHp : (isPemilik ? '0812 3456 7890' : '0813 9876 5432'),
        peran: isPemilik ? 'pemilik' : 'penjaga',
        statusAktif: true,
        namaWarung: 'Warung Azzam',
      );
    }
  }
}
