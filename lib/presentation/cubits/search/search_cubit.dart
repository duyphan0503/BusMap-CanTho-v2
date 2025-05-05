import 'package:busmapcantho/data/model/bus_route.dart';
import 'package:busmapcantho/data/model/bus_stop.dart';
import 'package:busmapcantho/data/model/search_history.dart';
import 'package:busmapcantho/data/repositories/bus_route_repository.dart';
import 'package:busmapcantho/data/repositories/bus_stop_repository.dart';
import 'package:busmapcantho/data/repositories/search_history_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'search_state.dart';

@injectable
class SearchCubit extends Cubit<SearchState> {
  final BusRouteRepository _busRouteRepository;
  final BusStopRepository _busStopRepository;
  final SearchHistoryRepository _searchHistoryRepository;

  SearchCubit(
    this._busRouteRepository,
    this._busStopRepository,
    this._searchHistoryRepository,
  ) : super(const SearchState());

  // Search for both routes and stops
  Future<void> search(String query) async {
    if (query.isEmpty) {
      emit(const SearchState());
      return;
    }

    emit(state.copyWith(
      query: query,
      isLoading: true,
      error: null,
    ));

    try {
      // Search for routes and stops in parallel
      final routesFuture = _busRouteRepository.searchBusRoutes(query);
      final stopsFuture = _busStopRepository.searchBusStops(query);

      final results = await Future.wait([routesFuture, stopsFuture]);
      final routes = results[0] as List<BusRoute>;
      final stops = results[1] as List<BusStop>;

      // Save search to history
      await _searchHistoryRepository.addSearchHistory(query);

      emit(state.copyWith(
        routeResults: routes,
        stopResults: stops,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  // Load search history
  Future<void> loadSearchHistory() async {
    emit(state.copyWith(isLoadingHistory: true));

    try {
      final history = await _searchHistoryRepository.getSearchHistory();
      emit(state.copyWith(
        searchHistory: history,
        isLoadingHistory: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingHistory: false,
        historyError: e.toString(),
      ));
    }
  }

  // Clear search history
  Future<void> clearSearchHistory() async {
    emit(state.copyWith(isLoadingHistory: true));

    try {
      await _searchHistoryRepository.clearSearchHistory();
      emit(state.copyWith(
        searchHistory: const [],
        isLoadingHistory: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingHistory: false,
        historyError: e.toString(),
      ));
    }
  }
}
