import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/feedback.dart';

@lazySingleton
class FeedbackRemoteDatasource {
  final SupabaseClient _client;

  FeedbackRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  Future<void> submitFeedback({
    required String routeId,
    required int rating,
    String? content,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('Not authenticated');
      }

      await _client.from('feedback').insert([
        {
          'route_id': routeId,
          'user_id': user.id,
          'rating': rating,
          'content': content,
        },
      ]).select();
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
    }
  }

  Future<List<FeedbackModel>> getFeedbacksByRouteExcludingCurrentUser(
    String routeId,
  ) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');
      final response = await _client
          .from('feedback')
          .select('*,users:user_id(full_name)')
          .eq('route_id', routeId)
          .neq('user_id', user.id)
          .order('created_at', ascending: false);
      final data = response as List<dynamic>;
      return data.map((item) {
        final m = item as Map<String, dynamic>;
        final fullName = (m['users'] as Map<String, dynamic>)['full_name'];
        return FeedbackModel.fromMap({
          ...m,
          'user_name': fullName,
        });
      }).toList();
    } catch (e) {
      debugPrint('Error fetching feedback: $e');
      throw Exception(
        'Failed to get feedback for route (excluding current user): $e',
      );
    }
  }

  Future<FeedbackModel?> getCurrentUserFeedbackForRoute(String routeId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');
      final res = await _client
          .from('feedback')
          .select()
          .eq('route_id', routeId)
          .eq('user_id', user.id)
          .limit(1);
      if (res.isEmpty) return null;
      return FeedbackModel.fromMap(res.first);
    } catch (e) {
      throw Exception('Failed to get user feedback for route: $e');
    }
  }

  Future<void> updateFeedback({
    required String feedbackId,
    required int rating,
    String? content,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('Not authenticated');
      }
      final existing = await _client
          .from('feedback')
          .select()
          .eq('id', feedbackId)
          .eq('user_id', user.id)
          .limit(1);
      if (existing.isEmpty) {
        throw Exception('Feedback not found or not owned by user');
      }
      await _client
          .from('feedback')
          .update({
            'rating': rating,
            'content': content,
            'created_at': DateTime.now().toIso8601String(),
          })
          .eq('id', feedbackId);
    } catch (e) {
      throw Exception('Failed to update feedback: $e');
    }
  }
}
