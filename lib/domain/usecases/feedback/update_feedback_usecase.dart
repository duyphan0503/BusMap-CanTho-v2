import 'package:injectable/injectable.dart';

import '../../../data/repositories/feedback_repository.dart';


@injectable
class UpdateFeedbackUseCase {
  final FeedbackRepository _feedbackRepository;

  UpdateFeedbackUseCase(this._feedbackRepository);

  Future<void> call({
    required String feedbackId,
    required int rating,
    String? content,
  }) async {
    await _feedbackRepository.updateFeedback(
      feedbackId: feedbackId,
      rating: rating,
      content: content,
    );
  }
}
