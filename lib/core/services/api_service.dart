import 'dart:convert';

import 'package:http/http.dart' as http;

class Route {
  final String id;
  final String name;

  Route({required this.id, required this.name});

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(id: json['id'], name: json['name']);
  }
}

class ApiService {
  Future<List<Route>> searchRoutes(String start, String end) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/search-routes'),
        headers: {'Content-Type': 'application/json'},
        body: {'start': start, 'end': end},
      );

      if (response.statusCode == 200) {
        return (json.decode(response.body)['routes'] as List)
            .map((route) => Route.fromJson(route))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}
