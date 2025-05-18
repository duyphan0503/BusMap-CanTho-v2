part of 'favorites_cubit.dart';

class FavoritesState {
  final List<UserFavorite> favoriteUserRoutes;
  final List<UserFavorite> favoriteStops;

  final bool isLoadingRoutes;
  final bool isLoadingStops;

  final String? routesError;
  final String? stopsError;
  final String? actionError;

  const FavoritesState({
    this.favoriteUserRoutes = const [],
    this.favoriteStops = const [],
    this.isLoadingRoutes = false,
    this.isLoadingStops = false,
    this.routesError,
    this.stopsError,
    this.actionError,
  });

  bool get isLoading => isLoadingRoutes || isLoadingStops;

  FavoritesState copyWith({
    List<UserFavorite>? favoriteUserRoutes,
    List<UserFavorite>? favoriteStops,
    bool? isLoadingRoutes,
    bool? isLoadingStops,
    String? routesError,
    String? stopsError,
    String? actionError,
  }) {
    return FavoritesState(
      favoriteUserRoutes: favoriteUserRoutes ?? this.favoriteUserRoutes,
      favoriteStops: favoriteStops ?? this.favoriteStops,
      isLoadingRoutes: isLoadingRoutes ?? this.isLoadingRoutes,
      isLoadingStops: isLoadingStops ?? this.isLoadingStops,
      routesError: routesError,
      stopsError: stopsError,
      actionError: actionError,
    );
  }
}
