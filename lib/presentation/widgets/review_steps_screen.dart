import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as osm;

import '../routes/app_routes.dart';

class ReviewStepsScreen extends StatelessWidget {
  final osm.LatLng start;
  final osm.LatLng end;

  const ReviewStepsScreen({
    super.key,
    required this.start,
    required this.end,
  });

  @override
  Widget build(BuildContext context) {
    // Chỉ chuyển hướng về DirectionsMapScreen với overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.home);
      }
    });
    
    // Return một widget loading trong khi chờ chuyển hướng
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
