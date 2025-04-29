import 'package:busmapcantho/configs/secure_config.dart';
import 'package:flutter/services.dart';

class ConfigChannel {
  static const platform = MethodChannel('dz.duyphan.busmapcantho/config');

  static Future<void> init() async {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'getGoogleMapsKey') {
        return await SecureConfig.getGoogleMapsKey();
      }
      throw MissingPluginException('Method not implemented');
    });
  }
}