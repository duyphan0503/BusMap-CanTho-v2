import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/feedback.dart';

@lazySingleton
class FeedbackRemoteDatasource {
  final SupabaseClient _client;

  FeedbackRemoteDatasource([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  Future<void> submitFeedback(String content) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to submit feedback');
      }

      await _client.from('feedback').insert({
        'user_id': user.id,
        'content': content,
      });
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
    }
  }

  // Only for admin users
  Future<List<FeedbackModel>> getAllFeedback() async {
    try {
      final response = await _client
          .from('feedback')
          .select('*, user:auth.users(id, email)')
          .order('created_at', ascending: false);
      
      return response.map((data) => FeedbackModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to load feedback: $e');
    }
  }
}
