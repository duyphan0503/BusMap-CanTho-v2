import '../../../data/model/search_history.dart';
import '../../../data/repositories/search_history_repository.dart';

class AddSearchHistoryUseCase {
  final SearchHistoryRepository _repo;
  AddSearchHistoryUseCase(this._repo);

  Future<void> call(SearchHistory history) =>
      _repo.addSearchHistory(history);
}