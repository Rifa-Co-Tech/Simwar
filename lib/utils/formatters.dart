/// SIMWAR — Helper Pemformatan Mata Uang & Tanggal
/// Dibuat mandiri agar tidak bergantung pada locale eksternal
class SimwarFormatter {
  /// Format nominal integer ke bentuk standar Rupiah: Rp 1.800.000
  static String rupiah(int nominal) {
    if (nominal == 0) return 'Rp 0';
    final bool isNegative = nominal < 0;
    final String absStr = nominal.abs().toString();
    final StringBuffer buffer = StringBuffer();

    int count = 0;
    for (int i = absStr.length - 1; i >= 0; i--) {
      buffer.write(absStr[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }

    final String reversed = buffer.toString().split('').reversed.join('');
    return '${isNegative ? "-Rp " : "Rp "}$reversed';
  }

  /// Format tanggal & waktu real-time ke format Indonesia: "26 Nov 2026, 21:58 WIB"
  static String tanggal(DateTime dt) {
    const List<String> namaBulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final local = dt.toLocal();
    final String hari = local.day.toString().padLeft(2, '0');
    final String bulan = namaBulan[local.month - 1];
    final int tahun = local.year;
    final String jam = local.hour.toString().padLeft(2, '0');
    final String menit = local.minute.toString().padLeft(2, '0');
    final offsetHours = local.timeZoneOffset.inHours;
    final zona = offsetHours == 7
        ? ' WIB'
        : offsetHours == 8
            ? ' WITA'
            : offsetHours == 9
                ? ' WIT'
                : '';
    return '$hari $bulan $tahun, $jam:$menit$zona';
  }

  /// Format jam:menit real-time ("21:58")
  static String jamMenit(DateTime dt) {
    final local = dt.toLocal();
    final String jam = local.hour.toString().padLeft(2, '0');
    final String menit = local.minute.toString().padLeft(2, '0');
    return '$jam:$menit';
  }

  /// Format ringkas header real-time ("Kam, 26 Nov · 21:58")
  static String hariTanggalSingkat(DateTime dt) {
    const List<String> namaHari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const List<String> namaBulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final local = dt.toLocal();
    final hari = namaHari[local.weekday - 1];
    final bulan = namaBulan[local.month - 1];
    return '$hari, ${local.day} $bulan · ${jamMenit(local)}';
  }

  /// Format tanggal pendek tanpa jam: "26 November 2026"
  static String tanggalPendek(DateTime dt) {
    const List<String> namaBulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final local = dt.toLocal();
    return '${local.day} ${namaBulan[local.month - 1]} ${local.year}';
  }
}
