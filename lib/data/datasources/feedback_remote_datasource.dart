import 'package:busmapcantho/data/model/feedback.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackRemoteDatasource {
  final SupabaseClient _client;

  FeedbackRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  Future<void> sendFeedback(Feedback feedback) async {
    await _client.from('feedback').insert(feedback.toJson());
  }

  Future<List<Feedback>> getAllFeedbacks() async {
    final response = await _client
        .from('feedback')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => Feedback.fromJson(e)).toList();
  }

  Future<void> deleteFeedback(String feedbackId) async {
    await _client.from('feedback').delete().eq('id', feedbackId);
  }

  Future<void> updateFeedbackStatus(String feedbackId, String status) async {
    await _client
        .from('feedback')
        .update({'status': status})
        .eq('id', feedbackId);
  }

  Future<Feedback?> getFeedbacksByUser(String userId) async {
    final response =
        await _client
            .from('feedback')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
    return response != null ? Feedback.fromJson(response) : null;
  }
}
