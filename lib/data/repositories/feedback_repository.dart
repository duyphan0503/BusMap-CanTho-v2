import 'package:injectable/injectable.dart';

import '../datasources/feedback_remote_datasource.dart';
import '../model/feedback.dart';

@lazySingleton
class FeedbackRepository {
  final FeedbackRemoteDatasource _remoteDatasource;

  FeedbackRepository(this._remoteDatasource);

  Future<void> submitFeedback({
    required String routeId,
    required int rating,
    String? content,
  }) {
    return _remoteDatasource.submitFeedback(
      routeId: routeId,
      rating: rating,
      content: content,
    );
  }

  Future<List<FeedbackModel>> getFeedbacksByRouteExcludingCurrentUser(
    String routeId,
  ) {
    return _remoteDatasource.getFeedbacksByRouteExcludingCurrentUser(routeId);
  }

  Future<FeedbackModel?> getCurrentUserFeedbackForRoute(String routeId) {
    return _remoteDatasource.getCurrentUserFeedbackForRoute(routeId);
  }

  Future<void> updateFeedback({
    required String feedbackId,
    required int rating,
    String? content,
  }) {
    return _remoteDatasource.updateFeedback(
      feedbackId: feedbackId,
      rating: rating,
      content: content,
    );
  }
}
