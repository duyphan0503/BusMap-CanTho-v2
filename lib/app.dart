import 'package:busmapcantho/presentation/routes/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class BusMapCanThoApp extends StatefulWidget {
  const BusMapCanThoApp({super.key});

  @override
  State<BusMapCanThoApp> createState() => _BusMapCanThoAppState();
}

class _BusMapCanThoAppState extends State<BusMapCanThoApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'appTitle'.tr(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        primaryColor: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      // EasyLocalization support
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      // Router configuration
      routerConfig: AppRouter.router,
    );
  }
}
