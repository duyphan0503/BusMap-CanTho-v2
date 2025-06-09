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
    final statusBarHeight = MediaQuery.of(context).padding.top;

    const double desiredGapPortrait = 16.0;
    const double desiredGapLandscape = 16.0;

    final double topSpacerHeightPortrait =
        statusBarHeight + _appBarHeight + desiredGapPortrait;
    final double topSpacerHeightLandscape =
        statusBarHeight + _appBarHeight + desiredGapLandscape;

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
                    SizedBox(height: topSpacerHeightLandscape),
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
                SizedBox(height: topSpacerHeightPortrait), // Adjusted spacer
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

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        left: HomeScreen._horizontalPadding,
        right: HomeScreen._horizontalPadding,
        top: 8,
        bottom: 16,
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
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'quickAccess'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              LayoutBuilder(
                builder: (context, constraints) {
                  final needsScrolling =
                      features.length > 4; // Example threshold
                  final totalSpacing =
                      HomeScreen._tileSpacing * (features.length - 1);
                  final availableWidth = constraints.maxWidth;

                  final rowHeight = HomeScreen._tileWidth + 8;

                  if (!needsScrolling) {
                    final itemWidth =
                        (availableWidth - totalSpacing) / features.length;
                    return SizedBox(
                      height: rowHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                            features.map((f) {
                              return SizedBox(
                                width: itemWidth,
                                height: HomeScreen._tileWidth,
                                child: FeatureTile(
                                  icon: f.icon,
                                  label: f.label,
                                  onTap: () => onFeatureTap(f.route),
                                ),
                              );
                            }).toList(),
                      ),
                    );
                  } else {
                    return SizedBox(
                      height: rowHeight,
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.horizontal,
                        itemCount: features.length,
                        separatorBuilder:
                            (_, __) =>
                                const SizedBox(width: HomeScreen._tileSpacing),
                        itemBuilder: (context, index) {
                          final f = features[index];
                          return SizedBox(
                            width: HomeScreen._tileWidth,
                            height: HomeScreen._tileWidth,
                            child: FeatureTile(
                              icon: f.icon,
                              label: f.label,
                              onTap: () => onFeatureTap(f.route),
                            ),
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
    );
  }
}

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
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
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
                    constraints: const BoxConstraints(),
                    onPressed: () => context.go(AppRoutes.map),
                    icon: const Icon(Icons.open_in_full),
                    iconSize: 24,
                    color: AppColors.textOnPrimary,
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
