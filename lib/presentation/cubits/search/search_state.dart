part of 'search_cubit.dart';

class SearchState extends Equatable {
  final String query;
  final List<BusRoute> routeResults;
  final List<BusStop> stopResults;
  final List<SearchHistory> searchHistory;
  
  final bool isLoading;
  final bool isLoadingHistory;
  
  final String? error;
  final String? historyError;

  const SearchState({
    this.query = '',
    this.routeResults = const [],
    this.stopResults = const [],
    this.searchHistory = const [],
    this.isLoading = false,
    this.isLoadingHistory = false,
    this.error,
    this.historyError,
  });

  SearchState copyWith({
    String? query,
    List<BusRoute>? routeResults,
    List<BusStop>? stopResults,
    List<SearchHistory>? searchHistory,
    bool? isLoading,
    bool? isLoadingHistory,
    String? error,
    String? historyError,
  }) {
    return SearchState(
      query: query ?? this.query,
      routeResults: routeResults ?? this.routeResults,
      stopResults: stopResults ?? this.stopResults,
      searchHistory: searchHistory ?? this.searchHistory,
      isLoading: isLoading ?? this.isLoading,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      error: error,
      historyError: historyError,
    );
  }

  @override
  List<Object?> get props => [
    query,
    routeResults,
    stopResults,
    searchHistory,
    isLoading,
    isLoadingHistory,
    error,
    historyError,
  ];
}
