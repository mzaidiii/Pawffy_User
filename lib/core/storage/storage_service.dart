import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: tokenKey);
  }

  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: userIdKey, value: userId);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: userIdKey);
  }

  static Future<void> markBookingReviewed(String bookingId) async {
    await _storage.write(key: 'reviewed_booking_$bookingId', value: 'true');
  }

  static Future<bool> isBookingReviewed(String bookingId) async {
    final val = await _storage.read(key: 'reviewed_booking_$bookingId');
    return val == 'true';
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
