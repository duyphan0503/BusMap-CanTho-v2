import 'package:busmapcantho/core/services/notification_snackbar_service.dart';
import 'package:busmapcantho/core/theme/app_colors.dart';
import 'package:busmapcantho/gen/assets.gen.dart';
import 'package:busmapcantho/presentation/routes/app_routes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/feature_tile.dart';
import 'map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double _horizontalPadding = 16;
  static const double _tileSpacing = 12;
  static const double _tileWidth = 80;
  static const double _appBarHeight = 60.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<_Feature> features = _buildFeatures(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isPortrait =
              MediaQuery.of(context).orientation == Orientation.portrait;
          if (!isPortrait) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.scaffoldBackgroundColor,
                    AppColors.backgroundLight,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: _appBarHeight + 16),
                    _SearchBar(onTap: () => context.push(AppRoutes.search)),
                    _FeatureSection(
                      features: features,
                      onFeatureTap:
                          (route) => _navigateToFeature(context, route),
                    ),
                    const SizedBox(height: 16),
                    _MapPreview(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          }
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.scaffoldBackgroundColor,
                  AppColors.backgroundLight,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: _appBarHeight + 16),
                _SearchBar(onTap: () => context.push(AppRoutes.search)),
                _FeatureSection(
                  features: features,
                  onFeatureTap: (route) => _navigateToFeature(context, route),
                ),
                const SizedBox(height: 16),
                Expanded(child: _MapPreview()),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds the list of features for quick access.
  List<_Feature> _buildFeatures(BuildContext context) => [
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
    _Feature(icon: Icons.map, label: 'mapView'.tr(), route: AppRoutes.map),
    _Feature(
      icon: Icons.location_searching_outlined,
      label: 'findWay'.tr(),
      route: AppRoutes.routeFinder,
    ),
  ];

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return PreferredSize(
      preferredSize: const Size.fromHeight(_appBarHeight),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'appTitle'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leadingWidth: 90,
          leading: Container(
            padding: const EdgeInsets.only(left: 8),
            alignment: Alignment.center,
            child: Image.asset(
              Assets.images.logo.path,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  /// Handles navigation logic for feature tiles.
  void _navigateToFeature(BuildContext context, String route) {
    if (route == AppRoutes.map) {
      context.push(route);
    } else if (route == AppRoutes.directions) {
      context.showInfoSnackBar('selectDestinationFirst'.tr());
      context.push(AppRoutes.map);
    } else {
      context.push(route);
    }
  }
}

/// Widget for the search bar on the home screen.
class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: HomeScreen._horizontalPadding,
        vertical: 16,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'searchLocation'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withAlpha(150),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.primary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget for the quick access feature section.
class _FeatureSection extends StatelessWidget {
  final List<_Feature> features;
  final ValueChanged<String> onFeatureTap;

  const _FeatureSection({required this.features, required this.onFeatureTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: HomeScreen._horizontalPadding,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppColors.primaryLightest.withAlpha(50),
                AppColors.secondaryLightest.withAlpha(50),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text(
                    'quickAccess'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth =
                        constraints.maxWidth -
                        (HomeScreen._horizontalPadding * 2);
                    final needsScrolling = features.length > 4;
                    if (!needsScrolling) {
                      final totalSpacing =
                          HomeScreen._tileSpacing * (features.length - 1);
                      final dynamicItemWidth =
                          (availableWidth - totalSpacing) / features.length;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: HomeScreen._horizontalPadding,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:
                              features
                                  .map(
                                    (f) => SizedBox(
                                      width: dynamicItemWidth,
                                      height: HomeScreen._tileWidth + 16,
                                      child: FeatureTile(
                                        icon: f.icon,
                                        label: f.label,
                                        onTap: () => onFeatureTap(f.route),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      );
                    } else {
                      return SizedBox(
                        height: HomeScreen._tileWidth + 16,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: HomeScreen._horizontalPadding,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: features.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(
                                width: HomeScreen._tileSpacing,
                              ),
                          itemBuilder: (context, index) {
                            final f = features[index];
                            return FeatureTile(
                              icon: f.icon,
                              label: f.label,
                              onTap: () => onFeatureTap(f.route),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget for the live map preview section.
class _MapPreview extends StatelessWidget {
  const _MapPreview();

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return SizedBox(
      height: isPortrait ? null : 300.0,
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: HomeScreen._horizontalPadding,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(gradient: AppColors.primaryGradient),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.map_outlined,
                    color: AppColors.textOnPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'liveMap'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => context.go(AppRoutes.map),
                    icon: const Icon(Icons.open_in_full),
                    iconSize: 24,
                  ),
                ],
              ),
            ),
            const Expanded(child: MapScreen(showBackButton: false)),
          ],
        ),
      ),
    );
  }
}

/// Model for a feature tile.
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
