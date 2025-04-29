import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureConfig {
  static const _storage = FlutterSecureStorage();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      print('Error loading .env: $e');
      rethrow;
    }

    final googleMapsKey = dotenv.env['GOOGLE_MAPS_KEY'];
    if (googleMapsKey == null || googleMapsKey.isEmpty) {
      throw Exception('GOOGLE_MAPS_KEY is missing in .env file');
    }

    final existingKey = await _storage.read(key: 'GOOGLE_MAPS_KEY');
    if (existingKey == null || existingKey != googleMapsKey) {
      await _storage.write(key: 'GOOGLE_MAPS_KEY', value: googleMapsKey);
    }

    _isInitialized = true;
  }

  static Future<String> getGoogleMapsKey() async {
    return await _storage.read(key: 'GOOGLE_MAPS_KEY') ?? '';
  }
}