import 'package:busmapcantho/data/model/feedback.dart';

import '../datasources/feedback_remote_datasource.dart';

class FeedbackRepository {
  final FeedbackRemoteDatasource _remoteDatasource;

  FeedbackRepository([FeedbackRemoteDatasource? remoteDatasource])
    : _remoteDatasource = remoteDatasource ?? FeedbackRemoteDatasource();

  Future<void> submitFeedback(Feedback feedback) {
    return _remoteDatasource.sendFeedback(feedback);
  }

  Future<List<Feedback>> getFeedbacksByUser(String userId) async {
    final feedback = await _remoteDatasource.getFeedbacksByUser(userId);
    return feedback != null ? [feedback] : [];
  }
}
