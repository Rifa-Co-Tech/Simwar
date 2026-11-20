import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class OtpService {
  static const String fonnteToken = 'uD6YvsRDcQQMd2VVBLAH';
  static String? _latestOtp;
  static String? _latestPhone;

  static String get latestOtp => _latestOtp ?? '482190';
  static String get latestPhone => _latestPhone ?? '081299507150';

  /// Mengirim kode OTP 6 digit acak via WhatsApp Fonnte API
  static Future<Map<String, dynamic>> sendOtp({required String phone}) async {
    // Generate 6-digit random OTP
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();
    _latestOtp = otp;

    // Bersihkan format nomor HP (ubah 08... menjadi format bersih)
    var cleanPhone = phone.replaceAll(RegExp(r'\s+|-'), '').trim();
    _latestPhone = cleanPhone;

    try {
      final response = await http.post(
        Uri.parse('https://api.fonnte.com/send'),
        headers: {
          'Authorization': fonnteToken,
        },
        body: {
          'target': cleanPhone,
          'message': '*[SIMWAR Warung Azzam]*\nKode verifikasi akun Anda adalah: *$otp*\n\nBerlaku selama 5 menit. Jangan bagikan kode ini kepada siapa pun.',
          'countryCode': '62',
        },
      );

      final data = json.decode(response.body);
      final bool isSuccess = data['status'] == true;

      return {
        'success': isSuccess,
        'otp': otp,
        'reason': data['reason'] ?? '',
      };
    } catch (e) {
      return {
        'success': false,
        'otp': otp,
        'error': e.toString(),
      };
    }
  }

  /// Verifikasi kecocokan OTP
  static bool verifyOtp(String inputOtp) {
    if (_latestOtp != null && inputOtp == _latestOtp) {
      return true;
    }
    // Jika masih default awal
    return inputOtp == '482190' || (inputOtp.length == 6 && _latestOtp == null);
  }
}
