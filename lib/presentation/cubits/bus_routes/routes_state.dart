part of 'routes_cubit.dart';

class RoutesState extends Equatable {
  final List<BusRoute> allRoutes;
  final List<BusRoute> favoriteRoutes;
  final List<BusRoute> searchResults;
  final Map<String, List<BusStop>> routeStopsMap;
  final Map<String, Map<int, List<LatLng>>>
  routeGeometryMap; // Added field for route geometries

  final bool isLoadingAll;
  final bool isLoadingFavorites;
  final bool isSearching;

  final String? allRoutesError;
  final String? favoritesError;
  final String? searchError;
  final String? favoriteActionError;

  const RoutesState({
    this.allRoutes = const [],
    this.favoriteRoutes = const [],
    this.searchResults = const [],
    this.routeStopsMap = const {},
    this.routeGeometryMap = const {}, // Added default value
    this.isLoadingAll = false,
    this.isLoadingFavorites = false,
    this.isSearching = false,
    this.allRoutesError,
    this.favoritesError,
    this.searchError,
    this.favoriteActionError,
  });

  RoutesState copyWith({
    List<BusRoute>? allRoutes,
    List<BusRoute>? favoriteRoutes,
    List<BusRoute>? searchResults,
    Map<String, List<BusStop>>? routeStopsMap,
    Map<String, Map<int, List<LatLng>>>? routeGeometryMap, // Added parameter
    bool? isLoadingAll,
    bool? isLoadingFavorites,
    bool? isSearching,
    String? allRoutesError,
    String? favoritesError,
    String? searchError,
    String? favoriteActionError,
  }) {
    return RoutesState(
      allRoutes: allRoutes ?? this.allRoutes,
      favoriteRoutes: favoriteRoutes ?? this.favoriteRoutes,
      searchResults: searchResults ?? this.searchResults,
      routeStopsMap: routeStopsMap ?? this.routeStopsMap,
      routeGeometryMap:
          routeGeometryMap ?? this.routeGeometryMap, // Added field
      isLoadingAll: isLoadingAll ?? this.isLoadingAll,
      isLoadingFavorites: isLoadingFavorites ?? this.isLoadingFavorites,
      isSearching: isSearching ?? this.isSearching,
      allRoutesError: allRoutesError,
      favoritesError: favoritesError,
      searchError: searchError,
      favoriteActionError: favoriteActionError,
    );
  }

  @override
  List<Object?> get props => [
    allRoutes,
    favoriteRoutes,
    searchResults,
    routeStopsMap,
    routeGeometryMap, // Added to props
    isLoadingAll,
    isLoadingFavorites,
    isSearching,
    allRoutesError,
    favoritesError,
    searchError,
    favoriteActionError,
  ];
}
