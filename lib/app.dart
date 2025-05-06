import 'package:busmapcantho/core/theme/app_theme.dart';
import 'package:busmapcantho/presentation/cubits/account/account_cubit.dart';
import 'package:busmapcantho/presentation/cubits/auth/auth_cubit.dart';
import 'package:busmapcantho/presentation/cubits/directions/directions_cubit.dart';
import 'package:busmapcantho/presentation/cubits/favorites/favorites_cubit.dart';
import 'package:busmapcantho/presentation/cubits/map/map_cubit.dart';
import 'package:busmapcantho/presentation/cubits/routes/routes_cubit.dart';
import 'package:busmapcantho/presentation/routes/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';

class BusMapCanThoApp extends StatefulWidget {
  const BusMapCanThoApp({super.key});

  @override
  State<BusMapCanThoApp> createState() => _BusMapCanThoAppState();
}

class _BusMapCanThoAppState extends State<BusMapCanThoApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
        BlocProvider<AccountCubit>(create: (_) => getIt<AccountCubit>()),
        BlocProvider<RoutesCubit>(create: (_) => getIt<RoutesCubit>()),
        BlocProvider<FavoritesCubit>(create: (_) => getIt<FavoritesCubit>()),
        BlocProvider<MapCubit>(create: (_) => getIt<MapCubit>()),
        BlocProvider<DirectionsCubit>(create: (_) => getIt<DirectionsCubit>()),
      ],
      child: MaterialApp.router(
        title: 'appTitle'.tr(),
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        // EasyLocalization support
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        // Router configuration
        routerConfig: AppRouter.router,
      ),
    );
  }
}
