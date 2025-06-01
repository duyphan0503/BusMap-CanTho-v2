import 'package:busmapcantho/presentation/screens/auth/otp_verification_screen.dart';
import 'package:busmapcantho/presentation/screens/home/directions_map_screen.dart';
import 'package:busmapcantho/presentation/screens/notifications/notifications_screen.dart';
import 'package:busmapcantho/presentation/screens/route_stops/route_stops_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../../core/theme/app_colors.dart';
import '../../data/model/bus_route.dart';
import '../../data/model/bus_stop.dart';
import '../screens/account/account_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/bus_routes/bus_routes_screen.dart';
import '../screens/bus_routes/route_detail_map_screen.dart';
import '../screens/bus_stops/nearby_stops_screen.dart';
import '../screens/favorite/favorites_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/map_screen.dart';
import '../screens/home/pick_location_screen.dart';
import '../screens/home/route_finder_screen.dart';
import '../screens/home/search_screen.dart';
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
        path: AppRoutes.map,
        builder: (context, state) => const MapScreen(showBackButton: true),
      ),
      GoRoute(
        path: AppRoutes.directions,
        builder: (context, state) {
          final BusStop stop = state.extra as BusStop;
          return DirectionsMapScreen(stop: stop);
        },
      ),
      GoRoute(
        path: AppRoutes.busRoutes,
        builder: (context, state) => const BusRoutesScreen(),
      ),
      GoRoute(
        path: AppRoutes.nearbyStops,
        builder: (context, state) => const NearbyStopsScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => SearchScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.routeDetail}/:routeId',
        builder: (context, state) {
          final busRoute = state.extra as BusRoute;
          return RouteDetailMapScreen(route: busRoute);
        },
      ),
      GoRoute(
        path: AppRoutes.routeStops,
        builder: (context, state) {
          final BusStop stop = state.extra as BusStop;
          return RouteStopsScreen(stop: stop);
        },
      ),
      GoRoute(
        path: AppRoutes.routeFinder,
        builder: (context, state) => const RouteFinderScreen(),
      ),
      GoRoute(
        path: AppRoutes.pickLocationOnMap,
        builder: (context, state) => PickLocationScreen(),
      ),
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
          GoRoute(
            path: AppRoutes.notifications,
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
class ScaffoldWithBottomNav extends StatefulWidget {
  final Widget child;

  const ScaffoldWithBottomNav({super.key, required this.child});

  @override
  State<ScaffoldWithBottomNav> createState() => _ScaffoldWithBottomNavState();
}

class _ScaffoldWithBottomNavState extends State<ScaffoldWithBottomNav> {
  static final List<String> _tabs = [
    AppRoutes.home,
    AppRoutes.notifications,
    AppRoutes.favorites,
    AppRoutes.account,
  ];

  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    NotificationsScreen(),
    FavoritesScreen(),
    AccountScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.toString();
    final idx = _tabs.indexWhere((tab) => location.startsWith(tab));
    if (idx != -1 && idx != _currentIndex) {
      setState(() {
        _currentIndex = idx;
      });
    }
  }

  void _onItemTapped(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    context.go(_tabs[index]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SalomonBottomBar(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
            unselectedItemColor:
                theme.bottomNavigationBarTheme.unselectedItemColor,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            items: [
              SalomonBottomBarItem(
                icon: Icon(
                  Icons.home_outlined,
                  color: theme.bottomNavigationBarTheme.unselectedItemColor,
                ),
                activeIcon: Icon(
                  Icons.home,
                  color: theme.bottomNavigationBarTheme.selectedItemColor,
                ),
                title: Text(
                  'home'.tr(),
                  style: TextStyle(
                    color: theme.bottomNavigationBarTheme.selectedItemColor,
                  ),
                ),
              ),
              SalomonBottomBarItem(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: theme.bottomNavigationBarTheme.unselectedItemColor,
                ),
                activeIcon: Icon(
                  Icons.notifications,
                  color: theme.bottomNavigationBarTheme.selectedItemColor,
                ),
                title: Text(
                  'notifications'.tr(),
                  style: TextStyle(
                    color: theme.bottomNavigationBarTheme.selectedItemColor,
                  ),
                ),
              ),
              SalomonBottomBarItem(
                icon: Icon(
                  Icons.favorite_outline,
                  color: theme.bottomNavigationBarTheme.unselectedItemColor,
                ),
                activeIcon: Icon(
                  Icons.favorite,
                  color: theme.bottomNavigationBarTheme.selectedItemColor,
                ),
                title: Text(
                  'favorites'.tr(),
                  style: TextStyle(
                    color: theme.bottomNavigationBarTheme.selectedItemColor,
                  ),
                ),
              ),
              SalomonBottomBarItem(
                icon: Icon(
                  Icons.person_outline,
                  color: theme.bottomNavigationBarTheme.unselectedItemColor,
                ),
                activeIcon: Icon(
                  Icons.person,
                  color: theme.bottomNavigationBarTheme.selectedItemColor,
                ),
                title: Text(
                  'account'.tr(),
                  style: TextStyle(
                    color: theme.bottomNavigationBarTheme.selectedItemColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
