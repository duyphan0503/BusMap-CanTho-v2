import 'package:injectable/injectable.dart';

import '../../../data/model/feedback.dart';
import '../../../data/repositories/feedback_repository.dart';


@injectable
class GetFeedbacksByRouteExcludingCurrentUserUseCase {
  final FeedbackRepository _repo;

  GetFeedbacksByRouteExcludingCurrentUserUseCase(this._repo);

  Future<List<FeedbackModel>> call(String routeId) =>
      _repo.getFeedbacksByRouteExcludingCurrentUser(routeId);
}
