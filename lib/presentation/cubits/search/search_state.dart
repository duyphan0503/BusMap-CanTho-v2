part of 'search_cubit.dart';

class SearchState extends Equatable {
  final String query;
  final List<BusRoute> routeResults;
  final List<BusStop> stopResults;
  final List<SearchHistory> searchHistory;
  final List<NominatimResponse> placeResults;

  final bool isLoading;
  final bool isLoadingHistory;
  final bool isLoadingPlaces;

  final String? error;
  final String? historyError;
  final String? placeError;

  const SearchState({
    this.query = '',
    this.routeResults = const [],
    this.stopResults = const [],
    this.searchHistory = const [],
    this.placeResults = const [],
    this.isLoading = false,
    this.isLoadingHistory = false,
    this.isLoadingPlaces = false,
    this.error,
    this.historyError,
    this.placeError,
  });

  SearchState copyWith({
    String? query,
    List<BusRoute>? routeResults,
    List<BusStop>? stopResults,
    List<SearchHistory>? searchHistory,
    List<NominatimResponse>? placeResults,
    bool? isLoading,
    bool? isLoadingHistory,
    bool? isLoadingPlaces,
    String? error,
    String? historyError,
    String? placeError,
  }) {
    return SearchState(
      query: query ?? this.query,
      routeResults: routeResults ?? this.routeResults,
      stopResults: stopResults ?? this.stopResults,
      searchHistory: searchHistory ?? this.searchHistory,
      placeResults: placeResults ?? this.placeResults,
      isLoading: isLoading ?? this.isLoading,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      isLoadingPlaces: isLoadingPlaces ?? this.isLoadingPlaces,
      error: error,
      historyError: historyError,
      placeError: placeError,
    );
  }

  @override
  List<Object?> get props => [
    query,
    routeResults,
    stopResults,
    searchHistory,
    placeResults,
    isLoading,
    isLoadingHistory,
    isLoadingPlaces,
    error,
    historyError,
    placeError,
  ];
}
