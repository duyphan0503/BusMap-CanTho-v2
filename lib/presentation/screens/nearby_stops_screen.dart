import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NearbyStopsScreen extends StatelessWidget {
  const NearbyStopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement user location fetching and real distance calculations.
    return Scaffold(
      appBar: AppBar(title: Text('nearbyStops'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Stop 1'),
              subtitle: Text('500 m away'),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Stop 2'),
              subtitle: Text('750 m away'),
            ),
          ],
        ),
      ),
    );
  }
}
