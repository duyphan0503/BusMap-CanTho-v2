import 'package:busmapcantho/data/model/user_favorite.dart';
import 'package:busmapcantho/presentation/cubits/favorites/favorites_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../widgets/favorite_card_widget.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late final FavoritesCubit _favoritesCubit;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _favoritesCubit = context.read<FavoritesCubit>();
    _favoritesCubit.loadAllFavorites();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildAppBar(context),
          const SizedBox(height: 8),
          _buildTabBar(),
          Expanded(
            child: BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, state) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _FavoriteRoutesTab(
                      favorites: state.favoriteUserRoutes,
                      isLoading: state.isLoadingRoutes,
                    ),
                    _FavoriteStopsTab(
                      stops: state.favoriteStops,
                      isLoading: state.isLoadingStops,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
          shape: BoxShape.rectangle,
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'favorites'.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withAlpha(200),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.primaryDark,
        unselectedLabelColor: Colors.white,
        labelStyle: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'favoriteRoutes'.tr()),
          Tab(text: 'favoriteStops'.tr()),
        ],
      ),
    );
  }
}

class _FavoriteRoutesTab extends StatelessWidget {
  final List<UserFavorite> favorites;
  final bool isLoading;

  const _FavoriteRoutesTab({required this.favorites, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return _buildContent(
      context,
      isLoading: isLoading,
      emptyMessage: 'noFavoriteRoutes'.tr(),
      child:
          favorites.isEmpty
              ? _buildEmptyState(context, 'noFavoriteRoutes'.tr())
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: favorites.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder:
                    (context, index) => FavoriteCardWidget(
                      favorite: favorites[index],
                      type: FavoriteType.route,
                      onTap: () {
                        // Navigate to RouteDetailMapScreen
                        final route = context.read<FavoritesCubit>().state.favoriteRoutesDetail.firstWhere((r) => r.id == favorites[index].routeId);
                        context.push('${AppRoutes.routeDetail}/${favorites[index].routeId}', extra: route);
                      },
                      onDelete:
                          () => context
                              .read<FavoritesCubit>()
                              .removeFavoriteRoute(favorites[index].id),
                    ),
              ),
    );
  }
}

class _FavoriteStopsTab extends StatelessWidget {
  final List<UserFavorite> stops;
  final bool isLoading;

  const _FavoriteStopsTab({required this.stops, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return _buildContent(
      context,
      isLoading: isLoading,
      emptyMessage: 'noFavoriteStops'.tr(),
      child:
          stops.isEmpty
              ? _buildEmptyState(context, 'noFavoriteStops'.tr())
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: stops.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder:
                    (context, index) => FavoriteCardWidget(
                      favorite: stops[index],
                      type: FavoriteType.stop,
                      onTap: () {
                        // Navigate to MapScreen and select the stop
                        context.push(AppRoutes.map, extra: stops[index].stopId);
                      },
                      onDelete:
                          () => context
                              .read<FavoritesCubit>()
                              .removeFavoriteStop(stops[index].id),
                    ),
              ),
    );
  }
}

class _DeleteButton extends StatefulWidget {
  final VoidCallback onDelete;

  const _DeleteButton({required this.onDelete});

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onDelete,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    Colors.grey.withAlpha(30),
                    AppColors.error.withAlpha(40),
                    _animation.value,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_rounded,
                  color: AppColors.error,
                  size: 20 + (_animation.value * 2),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Fixed _buildContent to remove ListView.children check
Widget _buildContent(
  BuildContext context, {
  required bool isLoading,
  required String emptyMessage,
  required Widget child,
}) {
  if (isLoading) {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryMedium,
        strokeWidth: 2.5,
      ),
    );
  }
  return child;
}

// Added a separate method for the empty state UI
Widget _buildEmptyState(BuildContext context, String message) {
  final theme = Theme.of(context);
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.favorite_border_rounded,
        size: 64,
        color: AppColors.textSecondary.withAlpha(77), // 0.3*255 ≈ 77
      ),
      const SizedBox(height: 16),
      Text(
        message,
        style: theme.textTheme.titleMedium?.copyWith(
          color: AppColors.textSecondary.withAlpha(153), // 0.6*255 ≈ 153
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}
