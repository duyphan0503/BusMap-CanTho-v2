import '../datasources/search_history_remote_datasource.dart';
import '../model/search_history.dart';

class SearchHistoryRepository {
  final SearchHistoryRemoteDatasource _remoteDatasource;

  SearchHistoryRepository([SearchHistoryRemoteDatasource? remoteDatasource])
      : _remoteDatasource = remoteDatasource ?? SearchHistoryRemoteDatasource();

  Future<List<SearchHistory>> getUserSearchHistory(String userId) {
    return _remoteDatasource.getUserSearchHistory(userId);
  }

  Future<void> addSearchHistory(SearchHistory history) {
    return _remoteDatasource.addSearchHistory(history);
  }

  Future<void> clearUserSearchHistory(String userId) {
    return _remoteDatasource.clearUserSearchHistory(userId);
  }
}