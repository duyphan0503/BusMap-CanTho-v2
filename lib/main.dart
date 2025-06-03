import 'package:busmapcantho/configs/supabase_config.dart';
import 'package:busmapcantho/core/di/injection.dart';
import 'package:busmapcantho/domain/repositories/auth_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FMTCObjectBoxBackend().initialise();
  await FMTCStore('mapStore').manage.create();

  // Configure DI
  configureDependencies();

  await initSupabase();
  await EasyLocalization.ensureInitialized();

  await getIt<AuthRepository>().initAuthListener();

  final prefs = await SharedPreferences.getInstance();
  final saveLocale = prefs.getString('locale') ?? 'vi';

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
