import 'package:busmapcantho/core/services/notification_snackbar_service.dart';
import 'package:busmapcantho/core/theme/app_theme.dart';
import 'package:busmapcantho/presentation/blocs/map/map_bloc.dart';
import 'package:busmapcantho/presentation/cubits/account/account_cubit.dart';
import 'package:busmapcantho/presentation/cubits/auth/auth_cubit.dart';
import 'package:busmapcantho/presentation/cubits/bus_location/bus_location_cubit.dart';
import 'package:busmapcantho/presentation/cubits/bus_routes/routes_cubit.dart';
import 'package:busmapcantho/presentation/cubits/bus_stops/stop_cubit.dart';
import 'package:busmapcantho/presentation/cubits/directions/directions_cubit.dart';
import 'package:busmapcantho/presentation/cubits/favorites/favorites_cubit.dart';
import 'package:busmapcantho/presentation/cubits/feedback/feedback_cubit.dart';
import 'package:busmapcantho/presentation/cubits/notification/notification_cubit.dart';
import 'package:busmapcantho/presentation/cubits/otp/otp_cubit.dart';
import 'package:busmapcantho/presentation/cubits/password/password_cubit.dart';
import 'package:busmapcantho/presentation/cubits/route_finder/route_finder_cubit.dart';
import 'package:busmapcantho/presentation/cubits/route_stops/route_stops_cubit.dart';
import 'package:busmapcantho/presentation/routes/app_router.dart';
import 'package:busmapcantho/presentation/routes/app_routes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
        BlocProvider<PasswordCubit>(create: (_) => getIt<PasswordCubit>()),
        BlocProvider<RoutesCubit>(create: (_) => getIt<RoutesCubit>()),
        BlocProvider<FavoritesCubit>(create: (_) => getIt<FavoritesCubit>()),
        BlocProvider<MapBloc>(create: (_) => getIt<MapBloc>()),
        BlocProvider<DirectionsCubit>(create: (_) => getIt<DirectionsCubit>()),
        BlocProvider<FeedbackCubit>(create: (_) => getIt<FeedbackCubit>()),
        BlocProvider<OtpCubit>(create: (_) => getIt<OtpCubit>()),
        BlocProvider<BusLocationCubit>(
          create: (_) => getIt<BusLocationCubit>(),
        ),
        BlocProvider<StopCubit>(create: (_) => getIt<StopCubit>()),
        BlocProvider<NotificationCubit>(
          create: (_) => getIt<NotificationCubit>(),
        ),
        BlocProvider<NotificationCubit>(create: (_) => getIt<NotificationCubit>()),
        BlocProvider<RouteStopsCubit>(create: (_) => getIt<RouteStopsCubit>()),
        BlocProvider<RouteFinderCubit>(create: (_) => getIt<RouteFinderCubit>()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          final router = AppRouter.router;
          if (state is AuthUnauthenticated) {
            // Get current route from the router delegate to avoid context issues
            final String currentRoute = router.routerDelegate.currentConfiguration.uri.toString();
            final authRoutes = [
              AppRoutes.signIn,
              AppRoutes.signUp,
              AppRoutes.forgotPassword,
              AppRoutes.verify,
              AppRoutes.splash
            ];
            if (!authRoutes.contains(currentRoute)) {
              while (router.canPop()) {
                router.pop();
              }
              router.go(AppRoutes.signIn);
            }
          }
        },
        child: MaterialApp.router(
          title: 'appTitle'.tr(),
          theme: AppTheme.light,
          darkTheme: AppTheme.light,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          scaffoldMessengerKey: NotificationSnackBarService.scaffoldMessengerKey,
          locale: context.locale,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
