import 'package:busmapcantho/data/model/bus_route.dart';
import 'package:busmapcantho/data/model/bus_stop.dart';
import 'package:busmapcantho/data/repositories/bus_route_repository.dart';
import 'package:busmapcantho/data/repositories/favorite_route_repository.dart';
import 'package:busmapcantho/data/repositories/route_stops_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'routes_state.dart';

@injectable
class RoutesCubit extends Cubit<RoutesState> {
  final BusRouteRepository _busRouteRepository;
  final FavoriteRouteRepository _favoriteRouteRepository;
  final RouteStopsRepository _routeStopsRepository;

  RoutesCubit(
    this._busRouteRepository,
    this._favoriteRouteRepository,
    this._routeStopsRepository,
  ) : super(const RoutesState());

  Future<void> loadAllRoutes() async {
    emit(state.copyWith(isLoadingAll: true, allRoutesError: null));

    try {
      final routes = await _busRouteRepository.getAllBusRoutes();

      // Create a new map for route stops
      final Map<String, List<BusStop>> routeStopsMap = {};

      // Load stops for each route
      for (final route in routes) {
        try {
          final stops = await _routeStopsRepository.getRouteStopsAsBusStops(
            route.id,
            0,
          );
          routeStopsMap[route.id] = stops;
        } catch (e) {
          // If loading stops fails for a route, still continue with other routes
          print('Failed to load stops for route ${route.id}: $e');
        }
      }

      emit(
        state.copyWith(
          allRoutes: routes,
          routeStopsMap: routeStopsMap,
          isLoadingAll: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingAll: false, allRoutesError: e.toString()));
    }
  }

  Future<void> loadFavoriteRoutes() async {
    emit(state.copyWith(isLoadingFavorites: true, favoritesError: null));

    try {
      final routes = await _favoriteRouteRepository.getFavoriteRoutes();

      // Add stops to existing route stops map
      final Map<String, List<BusStop>> updatedRoutesMap = Map.from(
        state.routeStopsMap,
      );

      // Load stops for favorite routes if not already loaded
      for (final route in routes) {
        if (!updatedRoutesMap.containsKey(route.id)) {
          try {
            final stops = await _routeStopsRepository.getRouteStopsAsBusStops(
              route.id,
              0,
            );
            updatedRoutesMap[route.id] = stops;
          } catch (e) {
            // Continue if loading stops fails for a route
            print('Failed to load stops for favorite route ${route.id}: $e');
          }
        }
      }

      emit(
        state.copyWith(
          favoriteRoutes: routes,
          routeStopsMap: updatedRoutesMap,
          isLoadingFavorites: false,
        ),
      );
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

      // Add stops to existing route stops map
      final Map<String, List<BusStop>> updatedRoutesMap = Map.from(
        state.routeStopsMap,
      );

      // Load stops for search results if not already loaded
      for (final route in results) {
        if (!updatedRoutesMap.containsKey(route.id)) {
          try {
            final stops = await _routeStopsRepository.getRouteStopsAsBusStops(
              route.id,
              0,
            );
            updatedRoutesMap[route.id] = stops;
          } catch (e) {
            // Continue if loading stops fails for a route
            print('Failed to load stops for search result ${route.id}: $e');
          }
        }
      }

      emit(
        state.copyWith(
          searchResults: results,
          routeStopsMap: updatedRoutesMap,
          isSearching: false,
        ),
      );
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
