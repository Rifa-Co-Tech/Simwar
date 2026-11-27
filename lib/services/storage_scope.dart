/// SIMWAR — Scope penyimpanan per akun warung (Pemilik / Penjaga)
/// Memastikan data lokal tiap nomor HP/warung terisolasi penuh dan tidak bercampur antar akun.
class StorageScope {
  static String _scopeKey = 'default';
  static String get activeScope => _scopeKey;

  static void setScope(String rawOwnerPhone) {
    final clean = rawOwnerPhone
        .replaceAll(RegExp(r'\s+|-'), '')
        .replaceAll(RegExp(r'[^0-9a-zA-Z_]'), '')
        .trim();
    _scopeKey = clean.isNotEmpty ? clean : 'default';
  }

  static void clear() {
    _scopeKey = 'default';
  }

  static String key(String baseKey) => '${baseKey}_$_scopeKey';
}
