import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pengaturan_warung_model.dart';
import '../models/pengguna_model.dart';

class AuthService {
  final _client = Supabase.instance.client;

  static const String _keyActiveSession = 'simwar_active_session_v1';
  static const String _keyLocalAccounts = 'simwar_local_accounts_v1';
  static const String _keyRegisteredPemilikPhone = 'simwar_reg_pemilik_hp_v1';
  static const String _keyRegisteredPenjagaPhone = 'simwar_reg_penjaga_hp_v1';

  static String normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'\s+|-'), '').trim();
  }

  /// Ambil sesi pengguna yang masih aktif (untuk auto-login ke dashboard)
  Future<PenggunaModel?> getActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyActiveSession);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is Map) {
          return PenggunaModel.fromMap(Map<String, dynamic>.from(decoded));
        }
      }
    } catch (e) {
      debugPrint('Gagal membaca sesi aktif: $e');
    }
    return null;
  }

  /// Simpan sesi aktif agar saat membuka aplikasi lagi langsung ke Dashboard
  Future<void> saveActiveSession(PenggunaModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyActiveSession, jsonEncode(user.toMap()));
      await _saveRegisteredPhoneForRole(user.peran, user.nomorHp);
    } catch (e) {
      debugPrint('Gagal menyimpan sesi aktif: $e');
    }
  }

  /// Hapus sesi aktif saat pengguna menekan Logout
  Future<void> clearActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyActiveSession);
    } catch (e) {
      debugPrint('Gagal menghapus sesi aktif: $e');
    }
  }

  Future<void> _saveRegisteredPhoneForRole(String peran, String nomorHp) async {
    final cleanHp = normalizePhone(nomorHp);
    if (cleanHp.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    if (peran.toLowerCase() == 'pemilik') {
      await prefs.setString(_keyRegisteredPemilikPhone, cleanHp);
    } else {
      await prefs.setString(_keyRegisteredPenjagaPhone, cleanHp);
    }
  }

  /// Ambil nomor HP terakhir yang pernah didaftarkan / login untuk peran tertentu
  Future<String> getRegisteredPhone(String peran) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = peran.toLowerCase() == 'pemilik'
          ? _keyRegisteredPemilikPhone
          : _keyRegisteredPenjagaPhone;
      return prefs.getString(key) ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Simpan atau perbarui akun di penyimpanan lokal + catat nomor HP terdaftar
  Future<void> saveLocalAccount({
    required PenggunaModel user,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = await _loadLocalAccountsRaw(prefs);
      final cleanHp = normalizePhone(user.nomorHp);

      final idx = list.indexWhere(
        (m) =>
            normalizePhone((m['nomor_hp'] ?? '').toString()) == cleanHp &&
            (m['peran'] ?? '').toString().toLowerCase() ==
                user.peran.toLowerCase(),
      );

      final entry = {
        ...user.toMap(),
        'nomor_hp': cleanHp,
        'password': password,
      };

      if (idx != -1) {
        list[idx] = entry;
      } else {
        list.insert(0, entry);
      }

      await prefs.setString(_keyLocalAccounts, jsonEncode(list));
      await _saveRegisteredPhoneForRole(user.peran, cleanHp);
    } catch (e) {
      debugPrint('Gagal menyimpan akun lokal: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _loadLocalAccountsRaw(
    SharedPreferences prefs,
  ) async {
    final jsonStr = prefs.getString(_keyLocalAccounts);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Ambil daftar akun tim (penjaga/pemilik) dari Supabase + lokal
  Future<List<PenggunaModel>> getTeamAccounts({String? peranFilter}) async {
    final List<PenggunaModel> result = [];
    try {
      final query = _client.from('pengguna').select();
      final rows = await query;
      for (var row in rows) {
        final u = PenggunaModel.fromMap(row);
        if (peranFilter == null ||
            u.peran.toLowerCase() == peranFilter.toLowerCase()) {
          result.add(u);
        }
      }
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      final localRows = await _loadLocalAccountsRaw(prefs);
      for (var row in localRows) {
        final u = PenggunaModel.fromMap(row);
        if (peranFilter != null &&
            u.peran.toLowerCase() != peranFilter.toLowerCase()) {
          continue;
        }
        final cleanHp = normalizePhone(u.nomorHp);
        final exists = result.any(
          (x) =>
              normalizePhone(x.nomorHp) == cleanHp &&
              x.peran.toLowerCase() == u.peran.toLowerCase(),
        );
        if (!exists) {
          result.add(u);
        }
      }
    } catch (_) {}

    return result;
  }

  /// Daftarkan atau perbarui akun pengguna (Pemilik atau Penjaga)
  Future<PenggunaModel> registerOrUpdateAccount({
    required String nama,
    required String nomorHp,
    required String password,
    required String peran,
    String? namaWarung,
  }) async {
    final cleanHp = normalizePhone(nomorHp);
    final roleTitle =
        peran.toLowerCase() == 'pemilik' ? 'Pemilik' : 'Penjaga';
    final effectiveWarung = (namaWarung != null && namaWarung.trim().isNotEmpty)
        ? namaWarung.trim()
        : PengaturanStore.instance.pengaturan.namaWarung;

    PenggunaModel? pengguna;

    try {
      final existing = await _client
          .from('pengguna')
          .select()
          .eq('nomor_hp', cleanHp)
          .maybeSingle();

      if (existing != null) {
        final updated = await _client
            .from('pengguna')
            .update({
              'nama': nama.trim(),
              'password': password,
              'peran': roleTitle,
              'status_aktif': true,
            })
            .eq('nomor_hp', cleanHp)
            .select()
            .single();
        pengguna = PenggunaModel.fromMap({
          ...updated,
          'nama_warung': effectiveWarung,
        });
      } else {
        final inserted = await _client
            .from('pengguna')
            .insert({
              'nama': nama.trim(),
              'nomor_hp': cleanHp,
              'password': password,
              'peran': roleTitle,
              'status_aktif': true,
            })
            .select()
            .single();
        pengguna = PenggunaModel.fromMap({
          ...inserted,
          'nama_warung': effectiveWarung,
        });
      }
    } catch (e) {
      debugPrint('Gagal registrasi ke Supabase (simpan lokal): $e');
    }

    pengguna ??= PenggunaModel(
      id: 'USR-${DateTime.now().millisecondsSinceEpoch}',
      nama: nama.trim(),
      nomorHp: cleanHp,
      peran: roleTitle,
      statusAktif: true,
      namaWarung: effectiveWarung,
    );

    await saveLocalAccount(user: pengguna, password: password);
    return pengguna;
  }

  /// Perbarui profil &/atau password akun di Supabase dan lokal
  Future<PenggunaModel> updateProfileAndPassword({
    required PenggunaModel user,
    String? newPassword,
  }) async {
    final cleanHp = normalizePhone(user.nomorHp);
    final updatedUser = user.copyWith(nomorHp: cleanHp);

    try {
      final numId = int.tryParse(user.id);
      final payload = <String, dynamic>{
        'nama': updatedUser.nama,
        'nomor_hp': cleanHp,
        if (newPassword != null && newPassword.isNotEmpty)
          'password': newPassword,
      };
      if (numId != null) {
        await _client.from('pengguna').update(payload).eq('id_pengguna', numId);
      } else {
        await _client.from('pengguna').update(payload).eq('nomor_hp', cleanHp);
      }
    } catch (e) {
      debugPrint('Gagal update profil ke Supabase: $e');
    }

    // Update di cache lokal
    final prefs = await SharedPreferences.getInstance();
    final list = await _loadLocalAccountsRaw(prefs);
    final idx = list.indexWhere(
      (m) =>
          (m['id'] ?? '').toString() == updatedUser.id ||
          normalizePhone((m['nomor_hp'] ?? '').toString()) == cleanHp,
    );
    final oldPwd = idx != -1 ? (list[idx]['password'] ?? '').toString() : '';
    final pwdToSave =
        (newPassword != null && newPassword.isNotEmpty) ? newPassword : oldPwd;
    await saveLocalAccount(user: updatedUser, password: pwdToSave);
    await saveActiveSession(updatedUser);
    return updatedUser;
  }

  /// Login dengan nomor HP, password, dan peran.
  /// Mengembalikan [PenggunaModel] jika cocok di Supabase atau cache akun terdaftar, null jika salah.
  Future<PenggunaModel?> login({
    required String nomorHp,
    required String password,
    required String peran,
  }) async {
    final cleanHp = normalizePhone(nomorHp);
    final rawHp = nomorHp.trim();

    // 1. Cek di Supabase terlebih dahulu
    try {
      var response = await _client
          .from('pengguna')
          .select()
          .eq('nomor_hp', cleanHp)
          .eq('password', password)
          .ilike('peran', peran)
          .eq('status_aktif', true)
          .maybeSingle();

      if (response == null && cleanHp != rawHp) {
        response = await _client
            .from('pengguna')
            .select()
            .eq('nomor_hp', rawHp)
            .eq('password', password)
            .ilike('peran', peran)
            .eq('status_aktif', true)
            .maybeSingle();
      }

      if (response != null) {
        final warungName = PengaturanStore.instance.pengaturan.namaWarung;
        final user = PenggunaModel.fromMap({
          ...response,
          'nama_warung': warungName,
        });
        await saveLocalAccount(user: user, password: password);
        await saveActiveSession(user);
        return user;
      }
    } catch (e) {
      debugPrint('Login Supabase fallback ke cache lokal: $e');
    }

    // 2. Cek di cache akun terdaftar lokal (untuk mode offline / akun baru lokal)
    try {
      final prefs = await SharedPreferences.getInstance();
      final localRows = await _loadLocalAccountsRaw(prefs);
      for (var row in localRows) {
        final rowHp = normalizePhone((row['nomor_hp'] ?? '').toString());
        final rowPwd = (row['password'] ?? '').toString();
        final rowPeran = (row['peran'] ?? '').toString();
        final active = row['status_aktif'] != false;

        if ((rowHp == cleanHp || rowHp == rawHp) &&
            rowPwd == password &&
            rowPeran.toLowerCase() == peran.toLowerCase() &&
            active) {
          final user = PenggunaModel.fromMap(row);
          await saveActiveSession(user);
          return user;
        }
      }
    } catch (e) {
      debugPrint('Gagal membaca akun lokal saat login: $e');
    }

    return null;
  }
}
