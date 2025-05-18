import 'package:injectable/injectable.dart';

import '../../../data/model/feedback.dart';
import '../../../data/repositories/feedback_repository.dart';

@injectable
class GetCurrentUserFeedbackForRouteUseCase {
  final FeedbackRepository _repo;

  GetCurrentUserFeedbackForRouteUseCase(this._repo);

  Future<FeedbackModel?> call(String routeId) =>
      _repo.getCurrentUserFeedbackForRoute(routeId);
}
