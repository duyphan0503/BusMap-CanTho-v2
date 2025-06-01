import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/feedback.dart';

@lazySingleton
class FeedbackRemoteDatasource {
  final SupabaseClient _client;

  FeedbackRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  // Generate a feedback ID with format fb_XXXX
  Future<String> _generateFeedbackId() async {
    try {
      // Get the count of existing feedback to generate a new ID
      final result = await _client
          .from('feedback')
          .select('id')
          .order('created_at', ascending: false)
          .limit(1);

      int nextId = 1;
      if (result.isNotEmpty) {
        final lastId = result[0]['id'] as String;
        // Extract numeric part, assuming format is fb_XXXX
        final match = RegExp(r'fb_(\d+)').firstMatch(lastId);
        if (match != null && match.groupCount >= 1) {
          nextId = int.parse(match.group(1)!) + 1;
        }
      }

      // Format with leading zeros
      return 'fb_${nextId.toString().padLeft(4, '0')}';
    } catch (e) {
      // Fallback to timestamp-based ID if query fails
      return 'fb_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

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

      // Generate a new feedback ID
      final feedbackId = await _generateFeedbackId();

      await _client.from('feedback').insert([
        {
          'id': feedbackId,
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
        final fullName =
            (m['users'] != null && m['users'] is Map<String, dynamic>)
                ? (m['users'] as Map<String, dynamic>)['full_name']
                : null;
        return FeedbackModel.fromMap({...m, 'user_name': fullName});
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

      // The RLS policy will ensure only the owner can update
      await _client
          .from('feedback')
          .update({'rating': rating, 'content': content})
          .eq('id', feedbackId);
    } catch (e) {
      throw Exception('Failed to update feedback: $e');
    }
  }
}
