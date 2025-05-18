import 'package:busmapcantho/presentation/screens/auth/otp_verification_screen.dart';
import 'package:busmapcantho/presentation/screens/home/directions/directions_map_screen.dart';
import 'package:busmapcantho/presentation/screens/notifications/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/model/bus_route.dart';
import '../../data/model/bus_stop.dart';
import '../screens/account/account_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/bus_routes/route_detail_map_screen.dart';
import '../screens/bus_stops/nearby_stops_screen.dart';
import '../screens/favorite/favorites_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/search/search_screen.dart';
import '../screens/splash_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      // Auth and splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.verify,
        builder: (context, state) {
          final Map<String, dynamic> extra =
              state.extra as Map<String, dynamic>;
          return OtpVerificationScreen(email: extra['email']);
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) {
          final Map<String, dynamic> extra =
              state.extra as Map<String, dynamic>;
          return ForgotPasswordScreen(email: extra['email'] ?? "");
        },
      ),
      GoRoute(
        path: AppRoutes.directionsToStop,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final BusStop stop = state.extra as BusStop;
          return DirectionsMapScreen(stop: stop);
        },
      ),
      GoRoute(
        path: AppRoutes.nearbyStops,
        builder: (context, state) => const NearbyStopsScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.routeDetail}/:routeId',
        builder: (context, state) {
          final busRoute = state.extra as BusRoute;
          return RouteDetailMapScreen(route: busRoute);
        },
      ),
      // Main app shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithBottomNav(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(path: AppRoutes.notifications,
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: AppRoutes.favorites,
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: AppRoutes.account,
            builder: (context, state) => const AccountScreen(),
          ),
        ],
      ),
    ],
  );
}

// Scaffold with bottom navigation
class ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNav({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.home)) return 0;
    if (location.startsWith(AppRoutes.notifications)) return 1;
    if (location.startsWith(AppRoutes.favorites)) return 2;
    if (location.startsWith(AppRoutes.account)) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.notifications);
        break;
      case 2:
        context.go(AppRoutes.favorites);
        break;
      case 3:
        context.go(AppRoutes.account);
        break;
    }
  }
}
