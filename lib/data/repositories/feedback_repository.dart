import 'package:injectable/injectable.dart';

import '../datasources/feedback_remote_datasource.dart';
import '../model/feedback.dart';

@lazySingleton
class FeedbackRepository {
  final FeedbackRemoteDatasource _remoteDatasource;

  FeedbackRepository(this._remoteDatasource);

  // Submit feedback (current authenticated user)
  Future<void> submitFeedback(String content) {
    return _remoteDatasource.submitFeedback(content);
  }

  // Only for admin users
  Future<List<FeedbackModel>> getAllFeedback() {
    return _remoteDatasource.getAllFeedback();
  }
  
  // This method is deprecated as it requires auth now
  Future<List<FeedbackModel>> getFeedbacksByUser(String userId) async {
    // Current user ID is automatically used from auth
    throw UnimplementedError('Use getAllFeedback() with admin role instead');
  }
}
