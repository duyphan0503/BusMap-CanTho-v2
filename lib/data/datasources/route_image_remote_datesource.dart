import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/route_image.dart';

class RouteImageRemoteDatasource {
  final SupabaseClient _client;

  RouteImageRemoteDatasource([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  Future<List<RouteImage>> getImagesByRouteId(String routeId) async {
    final response = await _client
        .from('route_images')
        .select()
        .eq('route_id', routeId);
    return (response as List).map((e) => RouteImage.fromJson(e)).toList();
  }

  Future<void> addRouteImage(RouteImage image) async {
    await _client.from('route_images').insert(image.toJson());
  }

  Future<void> deleteRouteImage(String id) async {
    await _client.from('route_images').delete().eq('id', id);
  }
}