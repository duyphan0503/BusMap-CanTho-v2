import 'package:busmapcantho/data/model/feedback.dart';

import '../../../data/repositories/feedback_repository.dart';

class SendFeedbackUseCase {
  final FeedbackRepository _repo;
  SendFeedbackUseCase(this._repo);

  Future<void> call(String feedback) => _repo.submitFeedback(feedback);
}