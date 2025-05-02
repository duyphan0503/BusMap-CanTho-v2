import 'package:busmapcantho/presentation/routes/app_routes.dart';
import 'package:busmapcantho/presentation/screens/search_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'map/map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('appTitle'.tr())),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search),
                      const SizedBox(width: 8),
                      Text(
                        'search'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 8.0,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      /*                      _buildFunctionButton(
                        context,
                        Icons.location_on,
                        'nearbyStops'.tr(),
                        () => context.go(AppRoutes.),
                      ),*/
                      /*                      _buildFunctionButton(
                        context,
                        Icons.directions_bus,
                        'busStopsList'.tr(),
                        () => _handleBusStopsList(context),
                      ),*/
                      _buildFunctionButton(
                        context,
                        Icons.bus_alert,
                        'List Bus',
                        () => context.go(AppRoutes.busRoutes),
                      ),
                      _buildFunctionButton(
                        context,
                        Icons.location_on,
                        'nearbyStops'.tr(),
                        () => context.go(AppRoutes.directions),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: MapScreen()),
        ],
      ),
    );
  }

  Widget _buildFunctionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final buttonWidth = (MediaQuery.of(context).size.width - 32) / 4;

    return SizedBox(
      width: buttonWidth,
      // Replace InkWell with GestureDetector to avoid material rendering issues
      child: GestureDetector(
        onTap: () {
          // Use post-frame callback to avoid build phase navigation
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onTap();
          });
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            // Add visual feedback without InkWell
            color: Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
