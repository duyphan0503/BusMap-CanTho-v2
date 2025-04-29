import 'package:busmapcantho/presentation/screens/auth/otp_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/account/account_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/search_screen.dart';
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
          /*          GoRoute(
            path: AppRoutes.map,
            builder: (context, state) => const MapScreen(),
          ),*/
          /*          GoRoute(
            path: AppRoutes.directions,
            builder: (context, state) => const DirectionsScreen(),
          ),*/
          /*GoRoute(
            path: AppRoutes.busRoutes,
            builder: (context, state) => const BusRoutesScreen(),
          ),
          GoRoute(
            path: AppRoutes.routeDetails,
            builder: (context, state) {
              final routeId = state.pathParameters['routeId']!;
              return RouteDetailsScreen(routeId: routeId);
            },
          ),*/
          GoRoute(
            path: AppRoutes.search,
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: AppRoutes.favorites,
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: AppRoutes.account,
            builder: (context, state) => const AccountScreen(),
          ),
          /*GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.about,
            builder: (context, state) => const AboutScreen(),
          ),
          GoRoute(
            path: AppRoutes.help,
            builder: (context, state) => const HelpScreen(),
          ),*/
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
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: 'Routes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.home)) return 0;
    if (location.startsWith(AppRoutes.map)) return 1;
    if (location.startsWith(AppRoutes.busRoutes)) return 2;
    if (location.startsWith(AppRoutes.favorites)) return 3;
    if (location.startsWith(AppRoutes.account)) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.map);
        break;
      case 2:
        context.go(AppRoutes.busRoutes);
        break;
      case 3:
        context.go(AppRoutes.favorites);
        break;
      case 4:
        context.go(AppRoutes.account);
        break;
    }
  }
}
