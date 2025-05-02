import 'package:busmapcantho/data/model/bus_route.dart';
import 'package:busmapcantho/presentation/widgets/route_card_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/routes/routes_cubit.dart';
import '../../routes/app_routes.dart';

class BusRoutesScreen extends StatefulWidget {
  const BusRoutesScreen({super.key});

  @override
  State<BusRoutesScreen> createState() => _BusRoutesScreenState();
}

class _BusRoutesScreenState extends State<BusRoutesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Load data when screen initializes
    _loadData();
  }

  void _loadData() {
    context.read<RoutesCubit>().loadAllRoutes();
    context.read<RoutesCubit>().loadFavoriteRoutes();
  }

  void _handleTabChange() {
    // Clear search when switching tabs
    if (_tabController.indexIsChanging) {
      setState(() {
        _searchQuery = '';
        _searchController.clear();
      });
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
              // Search Bar
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
                    // Perform search as user types
                    if (value.isNotEmpty) {
                      context.read<RoutesCubit>().searchRoutes(value);
                    }
                  },
                ),
              ),
              // Tabs
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
          // All Routes Tab
          _buildRoutesTab(isAllRoutes: true),

          // Favorites Tab
          _buildRoutesTab(isAllRoutes: false),
        ],
      ),
    );
  }

  Widget _buildRoutesTab({required bool isAllRoutes}) {
    return BlocBuilder<RoutesCubit, RoutesState>(
      builder: (context, state) {
        // Determine which list to show based on active tab and search query
        List<BusRoute> routesToShow = [];
        bool isLoading = false;
        String errorMessage = '';

        if (_searchQuery.isNotEmpty) {
          // Show search results regardless of tab
          routesToShow = state.searchResults;
          isLoading = state.isSearching;
          errorMessage = state.searchError ?? '';
        } else if (isAllRoutes) {
          // Show all routes
          routesToShow = state.allRoutes;
          isLoading = state.isLoadingAll;
          errorMessage = state.allRoutesError ?? '';
        } else {
          // Show favorites
          routesToShow = state.favoriteRoutes;
          isLoading = state.isLoadingFavorites;
          errorMessage = state.favoritesError ?? '';
        }

        // Handle loading state
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle error state
        if (errorMessage.isNotEmpty) {
          // Format the error message to display in a user-friendly way
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

        // Handle empty state
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

        // Show list of routes
        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: routesToShow.length,
            itemBuilder: (context, index) {
              final route = routesToShow[index];
              final isFavorite = state.favoriteRoutes.any(
                (r) => r.id == route.id,
              );

              return RouteCardWidget(
                route: route,
                isFavorite: isFavorite,
                onFavoriteToggle: () {
                  if (isFavorite) {
                    context.read<RoutesCubit>().removeFavoriteRoute(route.id);
                  } else {
                    context.read<RoutesCubit>().addFavoriteRoute(route.id);
                  }
                },
                onTap: () {
                  context.push('${AppRoutes.routeDetail}/${route.id}');
                },
              );
            },
          ),
        );
      },
    );
  }

  // Helper method to format error messages for display
  String _formatErrorMessage(String error) {
    // Check for specific error patterns
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
