import 'package:flutter/material.dart';
import 'package:nominatim_flutter/model/response/nominatim_response.dart';

import '../../../data/datasources/local/favorite_label_storage.dart';
import '../../widgets/common_place_search_widget.dart';

class PickFavoritePlaceScreen extends StatelessWidget {
  final String label;

  const PickFavoritePlaceScreen({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return CommonPlaceSearchScreen(
      mode: PlaceScreenMode.pickFavoritePlace,
      favoriteLabel: label,
      onSuggestionTap: (NominatimResponse place) async {
        final storage = FavoritePlaceStorage();
        final placeWithLabel = {
          'label': label,
          'lat': place.lat,
          'lon': place.lon,
          'display_name': place.displayName,
        };
        await storage.addPlace(placeWithLabel);
        if (context.mounted) Navigator.of(context).pop(place);
      },
      onHistoryTap: (NominatimResponse place) async {
        final storage = FavoritePlaceStorage();
        final placeWithLabel = {
          'label': label,
          'lat': place.lat,
          'lon': place.lon,
          'display_name': place.displayName,
        };
        await storage.addPlace(placeWithLabel);
        if (context.mounted) Navigator.of(context).pop(place);
      },
    );
  }
}
