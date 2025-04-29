import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // TODO: Replace with persistent storage and logic as needed.
  final List<String> favoriteItems = [
    'Station 1',
    'Route B',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('favorites'.tr())),
      body: ListView.builder(
        itemCount: favoriteItems.length,
        itemBuilder: (context, index) {
          final item = favoriteItems[index];
          return ListTile(
            leading: const Icon(Icons.bookmark),
            title: Text(item),
          );
        },
      ),
    );
  }
}
