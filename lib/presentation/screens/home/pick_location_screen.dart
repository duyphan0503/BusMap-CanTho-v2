import 'dart:async';

import 'package:busmapcantho/core/services/places_service.dart';
import 'package:busmapcantho/data/datasources/local/favorite_label_storage.dart';
import 'package:busmapcantho/presentation/widgets/bus_map_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../cubits/route_finder/route_finder_cubit.dart';
import '../../cubits/route_finder/route_finder_state.dart';
import '../../widgets/custom_app_bar.dart';

class PickLocationScreen extends StatefulWidget {
  final String? label;
  final bool addToLabelMode;

  const PickLocationScreen({
    super.key,
    this.label,
    this.addToLabelMode = false,
  });

  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  RouteFinderCubit get _routeFinderCubit => context.read<RouteFinderCubit>();
  latlong.LatLng? _currentMapCenter;
  String _centerAddress = 'loadingAddress'.tr();
  final PlacesService _placesService = getIt<PlacesService>();
  Timer? _addressDebounce;

  // Dummy values for BusMapWidget
  final _dummyUserLocation = const latlong.LatLng(10.0364634, 105.7875821);

  @override
  void initState() {
    super.initState();
    _currentMapCenter = const latlong.LatLng(
      10.0364634,
      105.7875821,
    ); // Can Tho center
    _fetchAddressForCoordinates(_currentMapCenter!);
  }

  @override
  void dispose() {
    _addressDebounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchAddressForCoordinates(latlong.LatLng coordinates) async {
    setState(() {
      _centerAddress = 'loadingAddress'.tr();
    });
    try {
      final address = await _placesService.getAddressFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );
      if (mounted && address != null) {
        setState(() {
          _centerAddress = address.displayName ?? address.placeName;
        });
      } else if (mounted) {
        setState(() {
          _centerAddress = 'unknownLocation'.tr();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _centerAddress = 'errorFetchingAddress'.tr();
        });
      }
    }
  }

  void _onPickerMapMoved(latlong.LatLng center, bool hasGesture) {
    if (hasGesture) {
      _currentMapCenter = center;
      _addressDebounce?.cancel();
      _addressDebounce = Timer(const Duration(milliseconds: 500), () {
        if (mounted && _currentMapCenter != null) {
          _fetchAddressForCoordinates(_currentMapCenter!);
        }
      });
    }
  }

  Future<void> _saveLocationToLabel(
    latlong.LatLng latLng,
    String address,
  ) async {
    final storage = FavoritePlaceStorage();
    final placeMap = {
      'label': widget.label,
      'display_name': address,
      'lat': latLng.latitude.toString(),
      'lon': latLng.longitude.toString(),
    };
    await storage.savePlaces(
      await storage.loadPlaces()
        ..add(placeMap),
    );
  }

  void _confirmSelection() async {
    if (_currentMapCenter == null) {
      Navigator.of(context).pop(false);
      return;
    }
    final selectionType = _routeFinderCubit.state.selectionType;
    final latLng = latlong.LatLng(
      _currentMapCenter!.latitude,
      _currentMapCenter!.longitude,
    );
    if (widget.addToLabelMode) {
      await _saveLocationToLabel(latLng, _centerAddress);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
      return;
    }
    if (selectionType == LocationSelectionType.start) {
      _routeFinderCubit.setStart(name: _centerAddress, latLng: latLng);
    } else {
      _routeFinderCubit.setEnd(name: _centerAddress, latLng: latLng);
    }
    _routeFinderCubit.resetSelection();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(title: 'pickLocationOnMapTitle'.tr()),
      body: Stack(
        children: [
          BusMapWidget(
            busStops: const [],
            isLoading: false,
            selectedStop: null,
            userLocation: _currentMapCenter ?? _dummyUserLocation,
            onStopSelected: (stop) {},
            onClearSelectedStop: () {},
            refreshStops: () {},
            onCenterUser: () {},
            onDirections: () {},
            onRoutes: (stop) {},
            onPickerMapMoved: _onPickerMapMoved,
          ),
          const Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.location_pin,
              size: 50,
              color: AppColors.primaryDark,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Card(
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _centerAddress,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text('confirmLocation'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed:
                            (_currentMapCenter != null &&
                                    _centerAddress != 'loadingAddress'.tr() &&
                                    _centerAddress !=
                                        'errorFetchingAddress'.tr())
                                ? _confirmSelection
                                : null, // Disable button while loading/error
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
