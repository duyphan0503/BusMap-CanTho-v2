import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/search_history.dart';

@lazySingleton
class SearchHistoryRemoteDatasource {
  final SupabaseClient _client;

  SearchHistoryRemoteDatasource([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  Future<List<SearchHistory>> getSearchHistory() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return []; // Return empty list if user not logged in
      }

      final response = await _client
          .from('search_history')
          .select()
          .eq('user_id', user.id)
          .order('searched_at', ascending: false)
          .limit(20);
      
      return response.map((data) => SearchHistory.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to load search history: $e');
    }
  }

  Future<void> addSearchHistory(String keyword) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return; // Do nothing if user not logged in
      }

      await _client.from('search_history').insert({
        'user_id': user.id,
        'keyword': keyword,
      });
    } catch (e) {
      throw Exception('Failed to add search history: $e');
    }
  }

  Future<void> clearSearchHistory() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return; // Do nothing if user not logged in
      }

      await _client
          .from('search_history')
          .delete()
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('Failed to clear search history: $e');
    }
  }
}
