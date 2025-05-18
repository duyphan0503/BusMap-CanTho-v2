import 'package:injectable/injectable.dart';

import '../../../data/repositories/feedback_repository.dart';


@injectable
class SendFeedbackUseCase {
  final FeedbackRepository _repo;

  SendFeedbackUseCase(this._repo);

  Future<void> call({
    required String routeId,
    required int rating,
    String? content,
  }) =>
      _repo.submitFeedback(routeId: routeId, rating: rating, content: content);
}
