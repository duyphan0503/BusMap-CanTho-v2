import '../../../data/model/search_history.dart';
import '../../../data/repositories/search_history_repository.dart';

class GetSearchHistoryUseCase {
  final SearchHistoryRepository _repo;
  GetSearchHistoryUseCase(this._repo);

  Future<List<SearchHistory>> call(String userId) =>
      _repo.getUserSearchHistory(userId);
}