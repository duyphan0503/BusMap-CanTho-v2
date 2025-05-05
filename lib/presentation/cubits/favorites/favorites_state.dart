part of 'favorites_cubit.dart';

class FavoritesState {
  final List<BusRoute> favoriteRoutes;
  final List<UserFavorite> favoriteStops;
  
  final bool isLoadingRoutes;
  final bool isLoadingStops;
  
  final String? routesError;
  final String? stopsError;
  final String? actionError;

  const FavoritesState({
    this.favoriteRoutes = const [],
    this.favoriteStops = const [],
    this.isLoadingRoutes = false,
    this.isLoadingStops = false,
    this.routesError,
    this.stopsError,
    this.actionError,
  });

  bool get isLoading => isLoadingRoutes || isLoadingStops;

  FavoritesState copyWith({
    List<BusRoute>? favoriteRoutes,
    List<UserFavorite>? favoriteStops,
    bool? isLoadingRoutes,
    bool? isLoadingStops,
    String? routesError,
    String? stopsError,
    String? actionError,
  }) {
    return FavoritesState(
      favoriteRoutes: favoriteRoutes ?? this.favoriteRoutes,
      favoriteStops: favoriteStops ?? this.favoriteStops,
      isLoadingRoutes: isLoadingRoutes ?? this.isLoadingRoutes,
      isLoadingStops: isLoadingStops ?? this.isLoadingStops,
      routesError: routesError,
      stopsError: stopsError,
      actionError: actionError,
    );
  }
}
