import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/popular_search.dart';

class PopularSearchRemoteDatasource {
  final SupabaseClient _client;

  PopularSearchRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  Future<List<PopularSearch>> getPopularSearches() async {
    final response = await _client
        .from('popular_searches')
        .select()
        .order('count', ascending: false);
    return (response as List).map((e) => PopularSearch.fromJson(e)).toList();
  }

  Future<void> incrementPopularSearch(String keyword) async {
    // Tăng count nếu có, chưa có thì tạo mới
    final existing =
        await _client
            .from('popular_searches')
            .select()
            .eq('keyword', keyword)
            .maybeSingle();
    if (existing != null) {
      await _client
          .from('popular_searches')
          .update({'count': (existing['count'] as int) + 1})
          .eq('id', existing['id']);
    } else {
      await _client.from('popular_searches').insert({
        'keyword': keyword,
        'count': 1,
      });
    }
  }
}
