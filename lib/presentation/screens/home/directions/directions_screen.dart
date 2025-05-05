/*
import 'dart:async';

import 'package:busmapcantho/presentation/screens/home/map/map_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../cubits/directions/directions_cubit.dart';
import '../../../routes/app_routes.dart';

class DirectionsScreen extends StatefulWidget {
  const DirectionsScreen({super.key});

  @override
  State<DirectionsScreen> createState() => _DirectionsScreenState();
}

class _DirectionsScreenState extends State<DirectionsScreen> {
  final _endController = TextEditingController();
  LatLng? _startLatLng;
  final Completer<GoogleMapController> _mapCtrl = Completer();
  final _directionsCubit = DirectionsCubit();
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initCurrentLocation();
  }

  Future<void> _initCurrentLocation() async {
    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _startLatLng = LatLng(pos.latitude, pos.longitude);
    });
  }

  void _onFindRoute() {
    if (_startLatLng == null) return;
    final text = _endController.text.trim();
    // Expect format "lat,lng"
    final parts = text.split(',');
    if (parts.length != 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Enter destination as "lat,lng"')));
      return;
    }
    final lat = double.tryParse(parts[0]);
    final lng = double.tryParse(parts[1]);
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid coordinates')));
      return;
    }
    _directionsCubit.getRoute(_startLatLng!, LatLng(lat, lng));
  }

  void _onNearestStop() {
    context.push(AppRoutes.home); // or your nearest-stop route
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _directionsCubit,
      child: Scaffold(
        appBar: AppBar(title: Text('directions'.tr())),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Start field (read-only)
                  Expanded(
                    child: TextFormField(
                      initialValue:
                          _startLatLng == null
                              ? 'Loading...'
                              : '${_startLatLng!.latitude.toStringAsFixed(5)},'
                                  '${_startLatLng!.longitude.toStringAsFixed(5)}',
                      decoration: InputDecoration(
                        labelText: 'start'.tr(),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // End field
                  Expanded(
                    child: TextField(
                      controller: _endController,
                      decoration: InputDecoration(
                        labelText: 'end'.tr(),
                        hintText: 'lat,lng',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _onFindRoute,
                  icon: const Icon(Icons.search),
                  label: Text('findRoute'.tr()),
                ),
              ),
            ),
            // Map + route polyline
            Expanded(
              child: BlocConsumer<DirectionsCubit, DirectionsState>(
                listener: (_, state) {
                  if (state is DirectionsError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                  if (state is DirectionsLoaded) {
                    final poly = Polyline(
                      polylineId: const PolylineId('route'),
                      points: state.polylinePoints,
                      color: Colors.blue,
                      width: 5,
                    );
                    setState(() {
                      _polylines = {poly};
                    });
                    _mapCtrl.future.then((c) {
                      if (state.polylinePoints.isEmpty) return;

                      // Find the min/max lat/lng to create the bounds
                      double minLat = double.infinity;
                      double maxLat = -double.infinity;
                      double minLng = double.infinity;
                      double maxLng = -double.infinity;

                      for (var point in state.polylinePoints) {
                        if (point.latitude < minLat) minLat = point.latitude;
                        if (point.latitude > maxLat) maxLat = point.latitude;
                        if (point.longitude < minLng) minLng = point.longitude;
                        if (point.longitude > maxLng) maxLng = point.longitude;
                      }

                      final bounds = LatLngBounds(
                        southwest: LatLng(minLat, minLng),
                        northeast: LatLng(maxLat, maxLng),
                      );

                      c.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
                    });
                  }
                },
                builder: (_, state) {
                  return MapScreen();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
