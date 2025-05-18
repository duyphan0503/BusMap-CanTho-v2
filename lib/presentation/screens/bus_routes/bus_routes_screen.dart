import 'package:busmapcantho/data/model/bus_route.dart';
import 'package:busmapcantho/presentation/screens/bus_routes/route_detail_map_screen.dart';
import 'package:busmapcantho/presentation/widgets/route_card_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../cubits/bus_location/bus_location_cubit.dart';
import '../../cubits/bus_routes/routes_cubit.dart';
import '../../cubits/favorites/favorites_cubit.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('busRoutes'.tr()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(88),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'searchRoutes'.tr(),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                            : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    if (value.isNotEmpty) {
                      context.read<RoutesCubit>().searchRoutes(value);
                    }
                  },
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'allRoutes'.tr()),
                  Tab(text: 'favorites'.tr()),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRoutesTab(isAllRoutes: true),
          _buildRoutesTab(isAllRoutes: false),
        ],
      ),
    );
  }

  Widget _buildRoutesTab({required bool isAllRoutes}) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favoritesState) {
        return BlocBuilder<RoutesCubit, RoutesState>(
          builder: (context, routesState) {
            List<BusRoute> routesToShow = [];
            bool isLoading = false;
            String errorMessage = '';

            if (_searchQuery.isNotEmpty) {
              routesToShow = routesState.searchResults;
              isLoading = routesState.isSearching;
              errorMessage = routesState.searchError ?? '';
            } else if (isAllRoutes) {
              routesToShow = routesState.allRoutes;
              isLoading = routesState.isLoadingAll;
              errorMessage = routesState.allRoutesError ?? '';
            } else {
              // Favorite Routes tab: use FavoritesCubit state to map favorites to actual BusRoute
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
              return const Center(child: CircularProgressIndicator());
            }

            if (errorMessage.isNotEmpty) {
              final displayError = _formatErrorMessage(errorMessage);
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        displayError,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: Text('tryAgain'.tr()),
                    ),
                  ],
                ),
              );
            }

            if (routesToShow.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _searchQuery.isNotEmpty
                          ? Icons.search_off
                          : isAllRoutes
                          ? Icons.directions_bus
                          : Icons.favorite_border,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'noSearchResults'.tr()
                          : isAllRoutes
                          ? 'noRoutesAvailable'.tr()
                          : 'noFavoriteRoutes'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (!isAllRoutes && _searchQuery.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: ElevatedButton(
                          onPressed: () => _tabController.animateTo(0),
                          child: Text('browseRoutes'.tr()),
                        ),
                      ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadData();
                if (!isAllRoutes) {
                  context.read<FavoritesCubit>().loadFavoriteRoutes();
                }
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                itemCount: routesToShow.length,
                itemBuilder: (context, index) {
                  final route = routesToShow[index];
                  final isFavorite = _favoritesCubit.getFavoriteIdForRoute(route.id) != null;
                  final favoriteId =
                      isFavorite
                          ? _favoritesCubit.getFavoriteIdForRoute(route.id)
                          : null;
                  return RouteCardWidget(
                    route: route,
                    stops: routesState.routeStopsMap[route.id],
                    isFavorite: isFavorite,
                    onFavoriteToggle: () async {
                      if (isFavorite && favoriteId != null) {
                        _favoritesCubit.removeFavoriteRoute(favoriteId);
                      } else {
                        _favoritesCubit.addFavoriteRoute(route.id);
                      }
                    },
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => getIt<BusLocationCubit>()..subscribe(route.id),
                            child: RouteDetailMapScreen(route: route),
                          ),
                        ),
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

  String _formatErrorMessage(String error) {
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
