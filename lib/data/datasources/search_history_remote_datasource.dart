import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/search_history.dart';

class SearchHistoryRemoteDatasource {
  final SupabaseClient _client;

  SearchHistoryRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  Future<List<SearchHistory>> getUserSearchHistory(String userId) async {
    final response = await _client
        .from('search_history')
        .select()
        .eq('user_id', userId)
        .order('searched_at', ascending: false);
    return (response as List).map((e) => SearchHistory.fromJson(e)).toList();
  }

  Future<void> addSearchHistory(SearchHistory history) async {
    await _client.from('search_history').insert(history.toJson());
  }

  Future<void> clearUserSearchHistory(String userId) async {
    await _client.from('search_history').delete().eq('user_id', userId);
  }
}