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

  /// Format tanggal & waktu ke format khas Indonesia: "22 Nov 2026, 19:30 WIB"
  static String tanggal(DateTime dt) {
    const List<String> namaBulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final String hari = dt.day.toString().padLeft(2, '0');
    final String bulan = namaBulan[dt.month - 1];
    final int tahun = dt.year;
    final String jam = dt.hour.toString().padLeft(2, '0');
    final String menit = dt.minute.toString().padLeft(2, '0');
    return '$hari $bulan $tahun, $jam:$menit WIB';
  }

  /// Format tanggal pendek tanpa jam: "22 November 2026"
  static String tanggalPendek(DateTime dt) {
    const List<String> namaBulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${dt.day} ${namaBulan[dt.month - 1]} ${dt.year}';
  }
}
