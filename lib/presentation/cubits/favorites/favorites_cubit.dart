import 'package:busmapcantho/data/model/bus_route.dart';
import 'package:busmapcantho/data/model/user_favorite.dart';
import 'package:busmapcantho/data/repositories/favorite_route_repository.dart';
import 'package:busmapcantho/data/repositories/user_favorite_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'favorites_state.dart';

@injectable
class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoriteRouteRepository _favoriteRouteRepository;
  final UserFavoriteRepository _userFavoriteRepository;

  FavoritesCubit(this._favoriteRouteRepository, this._userFavoriteRepository)
    : super(const FavoritesState());

  Future<void> loadAllFavorites() async {
    emit(
      state.copyWith(
        isLoadingRoutes: true,
        isLoadingStops: true,
        routesError: null,
        stopsError: null,
      ),
    );

    await Future.wait([loadFavoriteRoutes(), loadFavoriteStops()]);
  }

  // Load only favorite routes
  Future<void> loadFavoriteRoutes() async {
    if (state.isLoadingRoutes) return;

    emit(state.copyWith(isLoadingRoutes: true, routesError: null));

    try {
      final routes = await _favoriteRouteRepository.getFavoriteRoutes();
      emit(
        state.copyWith(
          favoriteRoutes: routes,
          isLoadingRoutes: false,
          routesError: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingRoutes: false, routesError: e.toString()));
    }
  }

  Future<void> loadFavoriteStops() async {
    if (state.isLoadingStops) return;

    emit(state.copyWith(isLoadingStops: true, stopsError: null));

    try {
      final stops = await _userFavoriteRepository.getFavorites();
      emit(
        state.copyWith(
          favoriteStops: stops,
          isLoadingStops: false,
          stopsError: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingStops: false, stopsError: e.toString()));
    }
  }

  // Add a route to favorites
  Future<void> addFavoriteRoute(String routeId) async {
    try {
      await _favoriteRouteRepository.saveFavoriteRoute(routeId);
      await loadFavoriteRoutes();
    } catch (e) {
      emit(state.copyWith(actionError: e.toString()));
      debugPrint('Error adding favorite route: $e');
    }
  }

  // Remove a route from favorites
  Future<void> removeFavoriteRoute(String routeId) async {
    try {
      await _favoriteRouteRepository.removeFavoriteRoute(routeId);
      await loadFavoriteRoutes();
    } catch (e) {
      emit(state.copyWith(actionError: e.toString()));
    }
  }

  // Check if a route is favorited
  bool isRouteFavorite(String routeId) {
    return state.favoriteRoutes.any((route) => route.id == routeId);
  }

  // Add a stop to favorites
  Future<void> addFavoriteStop({
    required String stopId,
    required String label,
    String type = 'stop',
  }) async {
    try {
      await _userFavoriteRepository.addFavorite(
        stopId: stopId,
        label: label,
        type: type,
      );
      await loadFavoriteStops();
    } catch (e) {
      emit(state.copyWith(actionError: e.toString()));
      debugPrint('Error adding favorite stop: $e');
    }
  }

  // Remove a stop from favorites
  Future<void> removeFavoriteStop(String favoriteId) async {
    try {
      await _userFavoriteRepository.removeFavorite(favoriteId);
      await loadFavoriteStops();
    } catch (e) {
      emit(state.copyWith(actionError: e.toString()));
    }
  }

  // Check if a stop is favorited
  bool isStopFavorite(String stopId) {
    return state.favoriteStops.any((favorite) => favorite.stopId == stopId);
  }

  // Get favorite ID for a stop if it exists
  String? getFavoriteIdForStop(String stopId) {
    final favorite = state.favoriteStops
        .where((f) => f.stopId == stopId)
        .cast<UserFavorite?>()
        .firstWhere((f) => f != null, orElse: () => null);
    return favorite?.id;
  }
}

