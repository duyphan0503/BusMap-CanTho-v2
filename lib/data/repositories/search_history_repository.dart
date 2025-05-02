import 'package:injectable/injectable.dart';

import '../datasources/search_history_remote_datasource.dart';
import '../model/search_history.dart';

@lazySingleton
class SearchHistoryRepository {
  final SearchHistoryRemoteDatasource _remoteDatasource;

  SearchHistoryRepository(this._remoteDatasource);

  // Get search history for the current authenticated user
  Future<List<SearchHistory>> getSearchHistory() {
    return _remoteDatasource.getSearchHistory();
  }

  // Add a search query to history for the current authenticated user
  Future<void> addSearchHistory(String keyword) {
    return _remoteDatasource.addSearchHistory(keyword);
  }

  // Clear all search history for the current authenticated user
  Future<void> clearSearchHistory() {
    return _remoteDatasource.clearSearchHistory();
  }
  
  // Deprecated methods - use the auth-aware methods above
  Future<List<SearchHistory>> getUserSearchHistory(String userId) {
    return getSearchHistory();
  }
  
  Future<void> clearUserSearchHistory(String userId) {
    return clearSearchHistory();
  }
}
