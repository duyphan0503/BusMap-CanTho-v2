import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FavoritePlaceStorage {
  static const _placesKey = 'favorite_places';
  static const defaultLabels = ['school', 'home', 'office'];

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  /// Load the list of favorite places (as JSON strings)
  Future<List<Map<String, dynamic>>> loadPlaces() async {
    final raw = await _secure.read(key: _placesKey);
    if (raw == null || raw.isEmpty) return [];
    return raw
        .split('|')
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();
  }

  Future<void> savePlaces(List<Map<String, dynamic>> places) async {
    final joined = places.map(jsonEncode).join('|');
    await _secure.write(key: _placesKey, value: joined);
  }

  Future<bool> addPlace(Map<String, dynamic> place) async {
    final places = await loadPlaces();
    if (places.any(
      (p) =>
          p['label'] == place['label'] &&
          p['lat'] == place['lat'] &&
          p['lon'] == place['lon'],
    )) {
      return false;
    }
    places.add(place);
    await savePlaces(places);
    return true;
  }

  Future<void> removeByLabel(String label) async {
    final places =
        await loadPlaces()
          ..removeWhere((p) => p['label'] == label);
    await savePlaces(places);
  }

  Future<List<String>> loadLabels() async {
    final places = await loadPlaces();
    final allLabels = {
      ...defaultLabels,
      ...places.map((p) => p['label'] as String),
    };
    return allLabels.toList();
  }

  /*/// Check if a label already exists (case-insensitive)
  Future<bool> labelExists(String label) async {
    final places = await loadPlaces();
    for (final p in places) {
      try {
        if (!p.startsWith('{') || !p.contains('label')) {
          continue;
        }

        Map<String, dynamic>? map;
        if (p.isNotEmpty) {
          map = jsonDecode(p) as Map<String, dynamic>;
        }

        if (map != null &&
            map['label'] != null &&
            map['label'].toString().toLowerCase() == label.toLowerCase()) {
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

  /// Add a new favorite place (as JSON string), prevent duplicate label
  Future<bool> addPlaceIfNotExists(String placeJson, String label) async {
    if (await labelExists(label)) return false;
    final places = await loadPlaces();
    places.add(placeJson);
    await savePlaces(places);
    return true;
  }*/

  static String localizedLabel(String key) {
    switch (key.toLowerCase()) {
      case 'school':
        return 'favoriteLabelSchool'.tr();
      case 'home':
        return 'favoriteLabelHome'.tr();
      case 'office':
        return 'favoriteLabelOffice'.tr();
      default:
        return key;
    }
  }

  /// Helper: Get IconData from icon name
  static IconData iconForLabel(String key) {
    switch (key.toLowerCase()) {
      case 'school':
        return Icons.school;
      case 'home':
        return Icons.home;
      case 'office':
        return Icons.work;
      default:
        return Icons.label;
    }
  }
}
