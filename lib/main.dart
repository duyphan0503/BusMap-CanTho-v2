import 'package:busmapcantho/configs/supabase_config.dart';
import 'package:busmapcantho/core/di/injection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'configs/config_channel.dart';
import 'configs/secure_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await initSupabase();
  configureDependencies();
  await EasyLocalization.ensureInitialized();
  await SecureConfig.initialize();
  await ConfigChannel.init();

  final prefs = await SharedPreferences.getInstance();
  final saveLocale = prefs.getString('locale') ?? 'en';

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('vi')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: Locale(saveLocale),
      child: const BusMapCanThoApp(),
    ),
  );
}
