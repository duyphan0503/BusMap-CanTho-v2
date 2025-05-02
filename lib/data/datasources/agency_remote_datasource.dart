import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/agency.dart';

@lazySingleton
class AgencyRemoteDatasource {
  final SupabaseClient _client;

  AgencyRemoteDatasource([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  Future<List<Agency>> getAgencies() async {
    try {
      final response = await _client
          .from('agencies')
          .select()
          .order('name');
      
      return response.map((data) => Agency.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to load agencies: $e');
    }
  }

  Future<Agency> getAgencyById(String id) async {
    try {
      final response = await _client
          .from('agencies')
          .select()
          .eq('id', id)
          .single();
      
      return Agency.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load agency: $e');
    }
  }
}
