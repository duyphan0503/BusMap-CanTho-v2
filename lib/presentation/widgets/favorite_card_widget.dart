import 'package:busmapcantho/data/model/user_favorite.dart';
import 'package:busmapcantho/presentation/cubits/favorites/favorites_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../data/model/bus_route.dart';
import '../../data/model/bus_stop.dart';

enum FavoriteType { route, stop }

class FavoriteCardWidget extends StatelessWidget {
  final UserFavorite favorite;
  final FavoriteType type;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const FavoriteCardWidget({
    super.key,
    required this.favorite,
    required this.type,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      buildWhen:
          (prev, curr) =>
              prev.favoriteRoutesDetail != curr.favoriteRoutesDetail ||
              prev.favoriteStopsDetail != curr.favoriteStopsDetail,
      builder: (context, state) {
        if (type == FavoriteType.route) {
          BusRoute? route;
          try {
            route = state.favoriteRoutesDetail.firstWhere((r) => r.id == favorite.routeId);
          } catch (_) {
            route = null;
          }
          if (route == null) {
            return _buildCard(
              context,
              icon: Icons.directions_bus,
              title: favorite.label ?? '',
              subtitle: '',
              extra: null,
              isLoading: true,
            );
          }
          final stops = route.stops;
          final startStop = stops.isNotEmpty ? stops.first.stop.name : '';
          final endStop = stops.length > 1 ? stops.last.stop.name : '';
          final fare = route.fareInfo ?? '';
          return _buildCard(
            context,
            icon: Icons.directions_bus,
            title: route.routeName,
            subtitle: startStop.isNotEmpty && endStop.isNotEmpty ? '$startStop - $endStop' : (route.description ?? ''),
            extra: fare.isNotEmpty ? fare : null,
            isLoading: false,
          );
        } else {
          BusStop? stop;
          try {
            stop = state.favoriteStopsDetail.firstWhere((s) => s.id == favorite.stopId);
          } catch (_) {
            stop = null;
          }
          if (stop == null) {
            return _buildCard(
              context,
              icon: Icons.location_on,
              title: favorite.label ?? favorite.stopId ?? '',
              subtitle: '',
              extra: null,
              isLoading: true,
            );
          }
          final title = stop.name;
          final subtitle = stop.address ?? '';
          return _buildCard(
            context,
            icon: Icons.location_on,
            title: title,
            subtitle: subtitle,
            extra: null,
            isLoading: false,
          );
        }
      },
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    String? extra,
    bool isLoading = false,
  }) {
    final theme = Theme.of(context);
    return Opacity(
      opacity: isLoading ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.secondaryLight.withAlpha(90),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withAlpha(18),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: AppColors.primaryLight.withAlpha(30),
            highlightColor: AppColors.primaryLight.withAlpha(15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryLightest,
                          AppColors.primaryMedium,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryMedium.withAlpha(32),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.secondaryDark.withAlpha(180),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (extra != null && extra.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              extra,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.primaryMedium,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (isLoading)
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryMedium,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(Icons.delete_rounded, color: AppColors.error),
                      onPressed: isLoading ? null : onDelete,
                      tooltip: 'removeFavorite'.tr(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
