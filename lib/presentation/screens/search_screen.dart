import 'package:flutter/material.dart';
import 'package:busmapcantho/services/api_service.dart' as api;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final api.ApiService _apiService = api.ApiService();
  List<api.Route> _routes = [];

  void _search() async {
    final start = _startController.text;
    final end = _endController.text;
    final routes = await _apiService.searchRoutes(start, end);
    setState(() => _routes = routes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Routes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _startController,
              decoration: InputDecoration(labelText: 'Start Location'),
            ),
            TextField(
              controller: _endController,
              decoration: InputDecoration(labelText: 'End Location'),
            ),
            ElevatedButton(onPressed: _search, child: Text('Search')),
            Expanded(
              child: ListView.builder(
                itemCount: _routes.length,
                itemBuilder: (context, index) {
                  final route = _routes[index];
                  return ListTile(
                    title: Text('Route ${index + 1}: ${route.name}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
