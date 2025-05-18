import 'package:injectable/injectable.dart';

import '../datasources/feedback_remote_datasource.dart';
import '../model/feedback.dart';

@lazySingleton
class FeedbackRepository {
  final FeedbackRemoteDatasource _remote;

  FeedbackRepository(this._remote);

  Future<void> submitFeedback({
    required String routeId,
    required int rating,
    String? content,
  }) => _remote.submitFeedback(
    routeId: routeId,
    rating: rating,
    content: content,
  );

  Future<void> updateFeedback({
    required String feedbackId,
    required int rating,
    String? content,
  }) => _remote.updateFeedback(
    feedbackId: feedbackId,
    rating: rating,
    content: content,
  );

  Future<List<FeedbackModel>> getFeedbacksByRouteExcludingCurrentUser(
    String routeId,
  ) => _remote.getFeedbacksByRouteExcludingCurrentUser(routeId);

  Future<FeedbackModel?> getCurrentUserFeedbackForRoute(String routeId) =>
      _remote.getCurrentUserFeedbackForRoute(routeId);
}
