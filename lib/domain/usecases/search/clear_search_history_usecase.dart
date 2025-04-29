import '../../../data/repositories/search_history_repository.dart';

class ClearSearchHistoryUseCase {
  final SearchHistoryRepository _repo;

  ClearSearchHistoryUseCase(this._repo);

  Future<void> call(String userId) => _repo.clearUserSearchHistory(userId);
}
