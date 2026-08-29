import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class _OtpEntry {
  final String code;
  final DateTime expiresAt;
  _OtpEntry(this.code, this.expiresAt);
}

class BrevoOtpService {
  BrevoOtpService._();
  static final BrevoOtpService instance = BrevoOtpService._();

  static const _apiKey = String.fromEnvironment('BREVO_API_KEY', defaultValue: '');
  static const _sendUrl = 'https://api.brevo.com/v3/smtp/email';
  static const _otpLength = 6;
  static const _otpTtlMinutes = 5;

  final Map<String, _OtpEntry> _store = {};

  String _generateCode() {
    final rng = Random.secure();
    return List.generate(_otpLength, (_) => rng.nextInt(10)).join();
  }

  Future<void> sendOtp(String email) async {
    final code = _generateCode();
    _store[email] = _OtpEntry(
      code,
      DateTime.now().add(const Duration(minutes: _otpTtlMinutes)),
    );

    final body = jsonEncode({
      'sender': {'name': 'ShipLink', 'email': 'noreply@shiplink.app'},
      'to': [
        {'email': email}
      ],
      'subject': 'Your ShipLink Verification Code',
      'htmlContent': '''
<!DOCTYPE html>
<html>
<body style="font-family: Arial, sans-serif; background: #f4f4f7; padding: 30px;">
  <div style="max-width: 480px; margin: auto; background: white; border-radius: 12px; padding: 32px; text-align: center;">
    <h2 style="color: #111827;">ShipLink</h2>
    <p style="color: #6B7280; font-size: 15px;">Your verification code is</p>
    <div style="font-size: 36px; font-weight: bold; letter-spacing: 8px; color: #111827; margin: 20px 0;">$code</div>
    <p style="color: #6B7280; font-size: 13px;">This code expires in $_otpTtlMinutes minutes.<br>If you didn't request this, please ignore this email.</p>
  </div>
</body>
</html>''',
    });

    final response = await http.post(
      Uri.parse(_sendUrl),
      headers: {
        'accept': 'application/json',
        'content-type': 'application/json',
        'api-key': _apiKey,
      },
      body: body,
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to send verification email (${response.statusCode})');
    }
  }

  /// Returns true if the OTP is valid for [email].
  bool verifyOtp(String email, String code) {
    final entry = _store[email];
    if (entry == null) return false;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _store.remove(email);
      return false;
    }
    if (entry.code != code) return false;
    _store.remove(email);
    return true;
  }

  bool isOtpPending(String email) {
    final entry = _store[email];
    if (entry == null) return false;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _store.remove(email);
      return false;
    }
    return true;
  }

  int remainingSeconds(String email) {
    final entry = _store[email];
    if (entry == null) return 0;
    final diff = entry.expiresAt.difference(DateTime.now()).inSeconds;
    if (diff <= 0) {
      _store.remove(email);
      return 0;
    }
    return diff;
  }
}
