import 'package:busmapcantho/presentation/routes/app_routes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/feature_tile.dart';
import 'map/map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double _horizontalPadding = 16;
  static const double _tileSpacing = 12;
  static const double _tileWidth = 80;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('appTitle'.tr()),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _horizontalPadding,
              vertical: 16,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                context.push(AppRoutes.search);
              },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: theme.inputDecorationTheme.fillColor ?? Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'search'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Feature Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                height: _tileWidth + 16,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
                  scrollDirection: Axis.horizontal,
                  itemCount: _features.length,
                  separatorBuilder: (_, __) => const SizedBox(width: _tileSpacing),
                  itemBuilder: (context, index) {
                    final f = _features[index];
                    return FeatureTile(
                      icon: f.icon,
                      label: f.label,
                      maxWidth: _tileWidth,
                      onTap: () => context.go(f.route),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Map View
          Expanded(
            child: Card(
              margin: const EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              elevation: 2,
              child: const MapScreen(),
            ),
          ),
        ],
      ),
    );
  }

  static final List<_Feature> _features = [
    _Feature(
      icon: Icons.directions_bus,
      label: 'busRoutes'.tr(),
      route: AppRoutes.busRoutes,
    ),
    _Feature(
      icon: Icons.location_on,
      label: 'nearbyStops'.tr(),
      route: AppRoutes.nearbyStops,
    ),
    _Feature(icon: Icons.map, label: 'map'.tr(), route: AppRoutes.map),
    _Feature(
      icon: Icons.directions,
      label: 'directions'.tr(),
      route: AppRoutes.directions,
    ),
    // Add more features as needed
  ];
}

class _Feature {
  final IconData icon;
  final String label;
  final String route;

  const _Feature({
    required this.icon,
    required this.label,
    required this.route,
  });
}