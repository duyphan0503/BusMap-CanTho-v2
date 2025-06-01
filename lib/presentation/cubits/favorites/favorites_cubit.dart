import 'package:busmapcantho/data/model/user_favorite.dart';
import 'package:busmapcantho/domain/usecases/favorite/add_favorite_route_usecase.dart';
import 'package:busmapcantho/domain/usecases/favorite/add_favorite_stop_usecase.dart';
import 'package:busmapcantho/domain/usecases/favorite/get_favorite_routes_usecase.dart';
import 'package:busmapcantho/domain/usecases/favorite/get_favorite_stops_usecase.dart';
import 'package:busmapcantho/domain/usecases/favorite/remove_favorite_usecase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:busmapcantho/data/model/bus_route.dart';
import 'package:busmapcantho/data/model/bus_stop.dart';
import 'package:busmapcantho/domain/usecases/bus_routes/get_bus_route_by_id_usecase.dart';
import 'package:busmapcantho/domain/usecases/bus_stops/get_bus_stop_by_id_usecase.dart';

part 'favorites_state.dart';

@injectable
class FavoritesCubit extends Cubit<FavoritesState> {
  final GetFavoriteRoutesUseCase _getFavoriteRoutesUseCase;
  final GetFavoriteStopsUseCase _getFavoriteStopsUseCase;
  final AddFavoriteRouteUseCase _addFavoriteRouteUseCase;
  final AddFavoriteStopUseCase _addFavoriteStopUseCase;
  final RemoveFavoriteUseCase _removeFavoriteUseCase;
  final GetBusRouteByIdUseCase _getBusRouteByIdUseCase;
  final GetBusStopByIdUseCase _getBusStopByIdUseCase;

  FavoritesCubit(
    this._getFavoriteRoutesUseCase,
    this._getFavoriteStopsUseCase,
    this._addFavoriteRouteUseCase,
    this._addFavoriteStopUseCase,
    this._removeFavoriteUseCase,
    this._getBusRouteByIdUseCase,
    this._getBusStopByIdUseCase,
  ) : super(const FavoritesState());

  Future<void> loadAllFavorites() async {
    emit(
      state.copyWith(
        isLoadingRoutes: true,
        isLoadingStops: true,
        routesError: null,
        stopsError: null,
      ),
    );
    await Future.wait([
      loadFavoriteRoutes(),
      loadFavoriteStops(),
    ]);
    // Sau khi đã có danh sách id, lấy chi tiết
    await _loadFavoriteRoutesDetail();
    await _loadFavoriteStopsDetail();
  }

  Future<void> loadFavoriteRoutes() async {
    emit(state.copyWith(isLoadingRoutes: true, routesError: null));
    try {
      final favoriteUserRoutes = await _getFavoriteRoutesUseCase();
      emit(
        state.copyWith(
          favoriteUserRoutes: favoriteUserRoutes,
          isLoadingRoutes: false,
          routesError: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingRoutes: false, routesError: e.toString()));
    }
  }

  Future<void> loadFavoriteStops() async {
    emit(state.copyWith(isLoadingStops: true, stopsError: null));
    try {
      final stops = await _getFavoriteStopsUseCase();
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

  Future<void> _loadFavoriteRoutesDetail() async {
    final ids = state.favoriteUserRoutes.map((e) => e.routeId).whereType<String>().toList();
    final List<BusRoute> details = [];
    for (final id in ids) {
      final route = await _getBusRouteByIdUseCase(id);
      if (route != null) details.add(route);
    }
    emit(state.copyWith(favoriteRoutesDetail: details));
  }

  Future<void> _loadFavoriteStopsDetail() async {
    final ids = state.favoriteStops.map((e) => e.stopId).whereType<String>().toList();
    final List<BusStop> details = [];
    for (final id in ids) {
      final stop = await _getBusStopByIdUseCase(id);
      if (stop != null) details.add(stop);
    }
    emit(state.copyWith(favoriteStopsDetail: details));
  }

  Future<void> addFavoriteRoute(String routeId, {String? label}) async {
    try {
      await _addFavoriteRouteUseCase(routeId: routeId, label: label);
      await loadFavoriteRoutes();
    } catch (e) {
      emit(state.copyWith(actionError: e.toString()));
      debugPrint('Error adding favorite route: $e');
    }
  }

  Future<void> removeFavoriteRoute(String favoriteId) async {
    try {
      await _removeFavoriteUseCase(favoriteId);
      await loadFavoriteRoutes();
    } catch (e) {
      emit(state.copyWith(actionError: e.toString()));
    }
  }

  bool isRouteFavorite(String routeId) {
    return state.favoriteUserRoutes.any(
      (favorite) => favorite.routeId == routeId,
    );
  }

  String? getFavoriteIdForRoute(String routeId) {
    final matching = state.favoriteUserRoutes.where(
      (f) => f.routeId == routeId,
    );
    return matching.isNotEmpty ? matching.first.id : null;
  }

  Future<void> addFavoriteStop({
    required String stopId,
    String? label,
  }) async {
    try {
      await _addFavoriteStopUseCase(stopId: stopId, label: label);
      await loadFavoriteStops();
    } catch (e) {
      emit(state.copyWith(actionError: e.toString()));
      debugPrint('Error adding favorite stop: $e');
    }
  }

  Future<void> removeFavoriteStop(String favoriteId) async {
    try {
      await _removeFavoriteUseCase(favoriteId);
      await loadFavoriteStops();
    } catch (e) {
      emit(state.copyWith(actionError: e.toString()));
    }
  }

  bool isStopFavorite(String stopId) {
    return state.favoriteStops.any((favorite) => favorite.stopId == stopId);
  }

  String? getFavoriteIdForStop(String stopId) {
    final matching = state.favoriteStops.where((f) => f.stopId == stopId);
    return matching.isNotEmpty ? matching.first.id : null;
  }
}
