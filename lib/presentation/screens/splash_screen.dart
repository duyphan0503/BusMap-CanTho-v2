import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../gen/assets.gen.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate initialization delay
    await Future.delayed(const Duration(seconds: 2));

    // Check user login status
    final bool isLoggedIn = await _checkLoginStatus();

    if (mounted) {
      // Navigate based on login status
      if (isLoggedIn) {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.signIn);
      }
    }
  }

  Future<bool> _checkLoginStatus() async {
    // TODO: Implement actual login status check
    return false; // Default to not logged in
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            height: size.height - (isLandscape ? 0 : 0),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  Assets.animations.busAnimation,
                  width: isLandscape ? size.width * 0.6 : size.width * 0.8,
                  height: isLandscape ? size.height * 0.4 : size.height * 0.5,
                ),
                SizedBox(height: isLandscape ? 16 : 24),

                // App name
                const Text(
                  'Bus Map Cần Thơ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: isLandscape ? 24 : 48),

                // Loading indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
