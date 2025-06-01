import 'package:busmapcantho/data/model/bus_route.dart';
import 'package:busmapcantho/data/model/bus_stop.dart';
import 'package:busmapcantho/domain/usecases/bus_routes/get_all_bus_routes_usecase.dart';
import 'package:busmapcantho/domain/usecases/bus_routes/search_bus_routes_usecase.dart';
import 'package:busmapcantho/domain/usecases/favorite/get_favorite_routes_usecase.dart';
import 'package:busmapcantho/domain/usecases/route_stops/get_route_stops_as_bus_stops_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

part 'routes_state.dart';

@injectable
class RoutesCubit extends Cubit<RoutesState> {
  final GetAllBusRoutesUseCase _getAllBusRoutesUseCase;
  final GetRouteStopsAsBusStopsUseCase _getRouteStopsAsBusStopsUseCase;
  final SearchBusRoutesUseCase _searchBusRoutesUseCase;
  final GetFavoriteRoutesUseCase _getFavoriteRoutesUseCase;
  final Logger _logger;

  RoutesCubit(
    this._getAllBusRoutesUseCase,
    this._getRouteStopsAsBusStopsUseCase,
    this._searchBusRoutesUseCase,
    this._getFavoriteRoutesUseCase,
    this._logger,
  ) : super(const RoutesState());

  Future<void> loadAllRoutes() async {
    emit(state.copyWith(isLoadingAll: true, allRoutesError: null));
    try {
      final routes = await _getAllBusRoutesUseCase();
      final Map<String, List<BusStop>> routeStopsMap = {};
      for (final route in routes) {
        try {
          final stops = await _getRouteStopsAsBusStopsUseCase(route.id, 0);
          routeStopsMap[route.id] = stops;
        } catch (e, stack) {
          _logger.e('Failed to load stops for route ${route.id}: $e\n$stack');
        }
      }
      emit(
        state.copyWith(
          allRoutes: routes,
          routeStopsMap: routeStopsMap,
          isLoadingAll: false,
        ),
      );
    } catch (e, stack) {
      _logger.e('Failed to load all routes: $e\n$stack');
      emit(
        state.copyWith(
          isLoadingAll: false,
          allRoutesError: 'Không thể tải danh sách tuyến. Vui lòng thử lại.',
        ),
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
      final results = await _searchBusRoutesUseCase(query);
      final Map<String, List<BusStop>> updatedRoutesMap = Map.from(
        state.routeStopsMap,
      );
      for (final route in results) {
        if (!updatedRoutesMap.containsKey(route.id)) {
          try {
            final stops = await _getRouteStopsAsBusStopsUseCase(route.id, 0);
            updatedRoutesMap[route.id] = stops;
          } catch (e, stack) {
            _logger.e(
              'Failed to load stops for search result ${route.id}: $e\n$stack',
            );
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
    } catch (e, stack) {
      _logger.e('Failed to search routes: $e\n$stack');
      emit(
        state.copyWith(
          isSearching: false,
          searchError: 'Không thể tìm kiếm tuyến.',
        ),
      );
    }
  }
}
