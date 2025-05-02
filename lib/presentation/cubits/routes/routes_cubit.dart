import 'package:busmapcantho/data/model/bus_route.dart';
import 'package:busmapcantho/data/repositories/bus_route_repository.dart';
import 'package:busmapcantho/data/repositories/favorite_route_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'routes_state.dart';

@injectable
class RoutesCubit extends Cubit<RoutesState> {
  final BusRouteRepository _busRouteRepository;
  final FavoriteRouteRepository _favoriteRouteRepository;

  RoutesCubit(this._busRouteRepository, this._favoriteRouteRepository)
    : super(const RoutesState());

  Future<void> loadAllRoutes() async {
    emit(state.copyWith(isLoadingAll: true, allRoutesError: null));

    try {
      final routes = await _busRouteRepository.getAllBusRoutes();
      emit(state.copyWith(allRoutes: routes, isLoadingAll: false));
    } catch (e) {
      emit(state.copyWith(isLoadingAll: false, allRoutesError: e.toString()));
    }
  }

  Future<void> loadFavoriteRoutes() async {
    emit(state.copyWith(isLoadingFavorites: true, favoritesError: null));

    try {
      final routes = await _favoriteRouteRepository.getFavoriteRoutes();
      emit(state.copyWith(favoriteRoutes: routes, isLoadingFavorites: false));
    } catch (e) {
      emit(
        state.copyWith(isLoadingFavorites: false, favoritesError: e.toString()),
      );
    }
  }

  Future<void> searchRoutes(String query) async {
    if (query.isEmpty) {
      emit(
        state.copyWith(
          searchResults: const [],
          isSearching: false,
          searchError: null,
        ),
      );
      return;
    }

    emit(state.copyWith(isSearching: true, searchError: null));

    try {
      final results = await _busRouteRepository.searchBusRoutes(query);
      emit(state.copyWith(searchResults: results, isSearching: false));
    } catch (e) {
      emit(state.copyWith(isSearching: false, searchError: e.toString()));
    }
  }

  Future<void> addFavoriteRoute(String routeId) async {
    try {
      await _favoriteRouteRepository.saveFavoriteRoute(routeId);
      await loadFavoriteRoutes();
    } catch (e) {
      emit(state.copyWith(favoriteActionError: e.toString()));
    }
  }

  Future<void> removeFavoriteRoute(String routeId) async {
    try {
      await _favoriteRouteRepository.removeFavoriteRoute(routeId);
      await loadFavoriteRoutes();
    } catch (e) {
      emit(state.copyWith(favoriteActionError: e.toString()));
    }
  }
}
