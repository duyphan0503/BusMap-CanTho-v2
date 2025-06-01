import 'package:busmapcantho/data/model/bus_route.dart';
import 'package:busmapcantho/presentation/widgets/route_card_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../cubits/bus_routes/routes_cubit.dart';
import '../../cubits/favorites/favorites_cubit.dart';
import '../../routes/app_routes.dart';

class BusRoutesScreen extends StatefulWidget {
  const BusRoutesScreen({super.key});

  @override
  State<BusRoutesScreen> createState() => _BusRoutesScreenState();
}

class _BusRoutesScreenState extends State<BusRoutesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final RoutesCubit _routesCubit;
  late final FavoritesCubit _favoritesCubit;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _routesCubit = context.read<RoutesCubit>();
    _favoritesCubit = context.read<FavoritesCubit>();
    _loadData();
  }

  void _loadData() {
    _routesCubit.loadAllRoutes();
    _favoritesCubit.loadFavoriteRoutes();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _searchQuery = '';
        _searchController.clear();
      });
      if (_tabController.index == 1) {
        context.read<FavoritesCubit>().loadFavoriteRoutes();
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          _buildTabBar(theme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _RoutesTab(
                  isAllRoutes: true,
                  searchQuery: _searchQuery,
                  tabController: _tabController,
                  loadData: _loadData,
                  searchController: _searchController,
                ),
                _RoutesTab(
                  isAllRoutes: false,
                  searchQuery: _searchQuery,
                  tabController: _tabController,
                  loadData: _loadData,
                  searchController: _searchController,
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.scaffoldBackground,
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
      ),
      toolbarHeight: 72,
      title: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: SizedBox(height: 44, child: _buildSearchBar(theme)),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return TextField(
      controller: _searchController,
      style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: 'searchRoutes'.tr(),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: theme.colorScheme.onSurface.withAlpha(153),
        ),
        prefixIcon:
            _searchQuery.isNotEmpty
                ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    size: 18,
                    color: AppColors.primaryMedium,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
                : null,
        suffixIcon: const Icon(
          Icons.search,
          size: 20,
          color: AppColors.primaryMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryLight,
            width: 1.5,
          ),
        ),
        filled: true,
        fillColor: theme.cardColor,
        isDense: true,
        contentPadding: const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: 16,
          right: 0,
        ),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
        if (value.isNotEmpty) {
          context.read<RoutesCubit>().searchRoutes(value);
        }
      },
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withAlpha(30),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 40,
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryMedium.withAlpha(40),
                blurRadius: 6,
              ),
            ],
          ),
          labelColor: AppColors.primaryDark,
          unselectedLabelColor: Colors.white,
          labelStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          tabs: [
            Tab(
              height: 28,
              child: Text('allRoutes'.tr(), textAlign: TextAlign.center),
            ),
            Tab(
              height: 28,
              child: Text('favorites'.tr(), textAlign: TextAlign.center),
            ),
          ],
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _RoutesTab extends StatelessWidget {
  final bool isAllRoutes;
  final String searchQuery;
  final TabController tabController;
  final VoidCallback loadData;
  final TextEditingController searchController;

  const _RoutesTab({
    required this.isAllRoutes,
    required this.searchQuery,
    required this.tabController,
    required this.loadData,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favoritesState) {
        return BlocBuilder<RoutesCubit, RoutesState>(
          builder: (context, routesState) {
            List<BusRoute> routesToShow = [];
            bool isLoading = false;
            String errorMessage = '';

            if (searchQuery.isNotEmpty) {
              routesToShow = routesState.searchResults;
              isLoading = routesState.isSearching;
              errorMessage = routesState.searchError ?? '';
            } else if (isAllRoutes) {
              routesToShow = routesState.allRoutes;
              isLoading = routesState.isLoadingAll;
              errorMessage = routesState.allRoutesError ?? '';
            } else {
              isLoading = favoritesState.isLoadingRoutes;
              errorMessage = favoritesState.routesError ?? '';
              routesToShow =
                  favoritesState.favoriteUserRoutes
                      .map(
                        (fav) => routesState.allRoutes.firstWhere(
                          (r) => r.id == fav.routeId,
                        ),
                      )
                      .whereType<BusRoute>()
                      .toList();
            }

            if (isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryMedium,
                ),
              );
            }

            if (errorMessage.isNotEmpty) {
              final displayError = _formatErrorMessage(errorMessage, context);
              return _ErrorState(message: displayError, onRetry: loadData);
            }

            if (routesToShow.isEmpty) {
              return _EmptyState(
                isAllRoutes: isAllRoutes,
                searchQuery: searchQuery,
                tabController: tabController,
              );
            }

            return RefreshIndicator(
              color: AppColors.primaryMedium,
              onRefresh: () async {
                loadData();
                if (!isAllRoutes) {
                  context.read<FavoritesCubit>().loadFavoriteRoutes();
                }
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                itemCount: routesToShow.length,
                itemBuilder: (context, index) {
                  final route = routesToShow[index];
                  return RouteCardWidget(
                    route: route,
                    stops: routesState.routeStopsMap[route.id],
                    onTap: () {
                      context.push(
                        '${AppRoutes.routeDetail}/${route.id}',
                        extra: route,
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  String _formatErrorMessage(String error, BuildContext context) {
    if (error.contains("Failed to load bus stops")) {
      return 'errorLoadingBusStops'.tr();
    } else if (error.contains("Failed to load bus routes")) {
      return 'errorLoadingRoutes'.tr();
    } else if (error.contains("Failed to load favorites")) {
      return 'errorLoadingFavorites'.tr();
    } else if (error.contains("Failed to search")) {
      return 'errorSearching'.tr();
    } else {
      return 'errorGeneric'.tr();
    }
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMedium,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: onRetry,
            child: Text('tryAgain'.tr()),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isAllRoutes;
  final String searchQuery;
  final TabController tabController;

  const _EmptyState({
    required this.isAllRoutes,
    required this.searchQuery,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searchQuery.isNotEmpty
                ? Icons.search_off
                : isAllRoutes
                ? Icons.directions_bus
                : Icons.favorite_border,
            size: 48,
            color: AppColors.primaryDark.withAlpha((0.4 * 255).toInt()),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isNotEmpty
                ? 'noSearchResults'.tr()
                : isAllRoutes
                ? 'noRoutesAvailable'.tr()
                : 'noFavoriteRoutes'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          if (!isAllRoutes && searchQuery.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryMedium,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () => tabController.animateTo(0),
                child: Text('browseRoutes'.tr()),
              ),
            ),
        ],
      ),
    );
  }
}
