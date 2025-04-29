/*
import 'dart:async';
import 'dart:io';

import 'package:busmapcantho/gen/assets.gen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin {
  // Constants
  static const String _userLocationMarkerId = 'user_location';
  static const String _selectedRoutePolylineId = 'selected_route';
  static const double _initialZoom = 13.0;
  static const double _locationZoom = 16.0;
  static const double _minZoom = 10.0;
  static const double _maxZoom = 18.0;

  // Center of Can Tho
  static const LatLng _canThoCenter = LatLng(10.025817, 105.7470982);

  // Bounds for Can Tho area
  static final LatLngBounds _canThoBounds = LatLngBounds(
    southwest: const LatLng(9.9, 105.6),
    northeast: const LatLng(10.2, 105.9),
  );

  // Map state
  final Set<Marker> _busMarkers = {};
  final Set<Marker> _userMarkers = {};
  final Set<Polyline> _polylines = {};
  bool _autoCenterCamera = true;
  String? _locationErrorMessage;
  String? _connectionErrorMessage;
  BitmapDescriptor? _userIcon;
  BitmapDescriptor? _busIcon;

  // Controllers and streams
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _lastKnownPosition;
  Timer? _busLocationTimer;
  bool _isOnline = true;

  // Location settings for accurate tracking
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _setupCustomMarker();
    _checkInternetConnection();
    _startBusLocationUpdates();
  }

  Future<void> _setupCustomMarker() async {
    _userIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      Assets.images.myLocation.path,
    );
    _busIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    if (_lastKnownPosition != null) {
      _updateUserMarker(
        LatLng(_lastKnownPosition!.latitude, _lastKnownPosition!.longitude),
      );
    }
  }

  Future<void> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          _connectionErrorMessage = null;
          _isOnline = true;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        _connectionErrorMessage =
            'No internet connection. Map tiles may not load.';
        _isOnline = false;
      });
    }
  }

  void _startBusLocationUpdates() {
    _busLocationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_isOnline) return;

      final state = context.read<BusMapBloc>().state;
      if (state is BusMapLoaded && state.selectedRoute != null) {
        // Only fetch locations for selected route
        context.read<BusMapBloc>().add(
          FetchBusLocation(state.selectedRoute!.id),
        );
      }
    });
  }

  void _initializeMap() {
    _loadLastKnownLocation();
    _setupUserLocationTracking();
    if (_isOnline) {
      context.read<BusMapBloc>().add(FetchAllBusStops());
      context.read<BusMapBloc>().add(FetchBusRoutes());
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No internet connection')));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<BusMapBloc, BusMapState>(
      listener: (context, state) {
        if (state is BusMapLoaded && state.currentBusLocations != null) {
          // Handle bus location updates
          final newMarkers = <Marker>{};

          for (final location in state.currentBusLocations!) {
            final route = state.routes.firstWhere(
              (r) => r.id == location.routeId,
              orElse: () => BusRoute(),
            );

            if (route.id.isNotEmpty) {
              final position = LatLng(location.latitude, location.longitude);
              final marker = Marker(
                markerId: MarkerId('bus_${location.busId}_${location.routeId}'),
                position: position,
                infoWindow: InfoWindow(
                  title: route.name,
                  snippet:
                      'Time to arrive: ${location.timeToArrive ~/ 60} min\nStatus: ${location.status}',
                ),
                icon:
                    _busIcon ??
                    BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue,
                    ),
                zIndex: 1,
              );
              newMarkers.add(marker);
            }
          }

          setState(() {
            _busMarkers.clear(); // Clear old markers
            _busMarkers.addAll(newMarkers);
          });
        } else if (state is BusStopLoaded) {
          // Show bus stop details
          _showBusStopDetails(context, state.busStop);
        }
      },
      builder: (context, state) {
        final Set<Marker> allMarkers = {..._busMarkers, ..._userMarkers};
        bool showStops = true;
        bool hasMore = false;
        int nextOffset = 0;
        int limit = 100;

        if (state is AllBusStopsLoaded) {
          showStops = state.areStopsVisible;
          hasMore = state.hasMore;
          nextOffset = state.offset + state.limit;
          limit = state.limit;
          if (showStops) {
            allMarkers.addAll(state.stopMarkers);
          }
        }

        final Set<Polyline> allPolylines = {..._polylines};
        if (state is BusMapLoaded &&
            state.selectedRoute != null &&
            state.routeStops.isNotEmpty) {
          // Add marker for route start
          if (state.routeStops.isNotEmpty) {
            final firstStop = state.routeStops.first;
            allMarkers.add(
              Marker(
                markerId: const MarkerId(_selectedRoutePolylineId),
                position: LatLng(firstStop.latitude, firstStop.longitude),
                infoWindow: InfoWindow(title: state.selectedRoute!.name),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
              ),
            );
          }

          // Create polyline for route
          final routePoints =
              state.routeStops
                  .map((stop) => LatLng(stop.latitude, stop.longitude))
                  .toList();
          allPolylines.add(
            Polyline(
              polylineId: const PolylineId(_selectedRoutePolylineId),
              points: routePoints,
              color: Colors.blue,
              width: 4,
            ),
          );
        }

        return Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: _canThoCenter,
                zoom: _initialZoom,
              ),
              markers: allMarkers,
              polylines: allPolylines,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: true,
              onCameraMoveStarted: () {
                if (_autoCenterCamera) {
                  setState(() => _autoCenterCamera = false);
                }
              },
              cameraTargetBounds: CameraTargetBounds(_canThoBounds),
              minMaxZoomPreference: const MinMaxZoomPreference(
                _minZoom,
                _maxZoom,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: FloatingActionButton.small(
                heroTag: 'toggle_stops',
                onPressed: () {
                  context.read<BusMapBloc>().add(
                    ToggleBusStopsVisibility(!showStops),
                  );
                },
                tooltip: showStops ? 'hideStops'.tr() : 'showStops'.tr(),
                child: Icon(showStops ? Icons.location_off : Icons.location_on),
              ),
            ),
            Positioned(
              bottom: 80,
              right: 10,
              child: FloatingActionButton.small(
                heroTag: 'locate_and_center',
                onPressed: _locateAndCenter,
                tooltip:
                    _autoCenterCamera
                        ? 'disableAutoCenter'.tr()
                        : 'enableAutoCenter'.tr(),
                backgroundColor:
                    _autoCenterCamera
                        ? Theme.of(context).primaryColor
                        : Colors.white,
                child: Icon(
                  _autoCenterCamera
                      ? Icons.center_focus_strong
                      : Icons.center_focus_weak,
                ),
              ),
            ),
            if (hasMore)
              Positioned(
                bottom: 120,
                right: 10,
                child: FloatingActionButton.small(
                  heroTag: 'load_more',
                  onPressed: () {
                    context.read<BusMapBloc>().add(
                      FetchAllBusStops(offset: nextOffset, limit: limit),
                    );
                  },
                  tooltip: 'loadMore'.tr(),
                  child: const Icon(Icons.add),
                ),
              ),
            if (state is BusMapLoading ||
                (state is AllBusStopsLoaded && state.isLoadingMore))
              const Positioned(
                bottom: 20,
                right: 20,
                child: CircularProgressIndicator(),
              ),
            if (state is BusMapError)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Card(
                  color: Colors.red.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(state.message),
                  ),
                ),
              ),
            if (_locationErrorMessage != null)
              Positioned(
                top: 60,
                left: 20,
                right: 20,
                child: Card(
                  color: Colors.red.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(_locationErrorMessage!),
                  ),
                ),
              ),
            if (_connectionErrorMessage != null)
              Positioned(
                top: 100,
                left: 20,
                right: 20,
                child: Card(
                  color: Colors.orange.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(_connectionErrorMessage!),
                  ),
                ),
              ),
            if (state is BusMapLoaded)
              Positioned(
                bottom: 20,
                left: 20,
                right: 80,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('Select a route'),
                        value: state.selectedRoute?.id,
                        items:
                            state.routes.map((route) {
                              return DropdownMenuItem<String>(
                                value: route.id,
                                child: Text(
                                  route.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                        onChanged: (routeId) {
                          if (routeId != null) {
                            context.read<BusMapBloc>().add(
                              SelectBusRoute(routeId),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showBusStopDetails(BuildContext context, BusStop busStop) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(busStop.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Routes: ${busStop.routes.join(", ")}'),
              const SizedBox(height: 8),
              const Text('Upcoming Buses:'),
              const SizedBox(height: 8),
              if (busStop.busTimes.isEmpty)
                const Text('No upcoming buses.')
              else
                ...busStop.busTimes.map((busTime) {
                  return ListTile(
                    title: Text('Bus ID: ${busTime.busId}'),
                    subtitle: Text(
                      'Route ID: ${busTime.routeId}\n'
                      'Time to arrive: ${busTime.timeToArrive ~/ 60} min',
                    ),
                  );
                }),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _locateAndCenter() async {
    setState(() {
      _autoCenterCamera = !_autoCenterCamera;
    });

    try {
      final position = await Geolocator.getCurrentPosition();
      _onPositionUpdate(position);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (_lastKnownPosition != null && mounted) {
        final userPosition = LatLng(
          _lastKnownPosition!.latitude,
          _lastKnownPosition!.longitude,
        );
        _animateCameraToPosition(userPosition);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('usingCachedLocation'.tr())));
      } else if (mounted) {
        setState(() {
          _locationErrorMessage = 'locationError'.tr();
        });
      }
    }
  }

  Future<void> _loadLastKnownLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('last_lat');
      final lng = prefs.getDouble('last_lng');

      if (lat != null && lng != null) {
        final position = Position(
          latitude: lat,
          longitude: lng,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );

        setState(() {
          _lastKnownPosition = position;
        });
        _updateUserMarker(LatLng(lat, lng));
      }
    } catch (e) {
      debugPrint('Error loading cached location: $e');
    }
  }

  Future<void> _saveCurrentLocation(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('last_lat', position.latitude);
      await prefs.setDouble('last_lng', position.longitude);
    } catch (e) {
      debugPrint('Error caching location: $e');
    }
  }

  Future<void> _setupUserLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationErrorMessage = 'locationServicesDisabled'.tr();
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationErrorMessage = 'locationPermissionDenied'.tr();
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationErrorMessage = 'locationPermanentlyDenied'.tr();
      });
      return;
    }

    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    ).listen(
      _onPositionUpdate,
      onError: _onPositionError,
      cancelOnError: false,
    );

    try {
      final position = await Geolocator.getCurrentPosition();
      _onPositionUpdate(position);
    } catch (e) {
      debugPrint('Error getting initial position: $e');
      setState(() {
        _locationErrorMessage = 'locationError'.tr();
      });
    }
  }

  void _onPositionUpdate(Position position) {
    setState(() {
      _locationErrorMessage = null;
      _lastKnownPosition = position;
    });

    final userPosition = LatLng(position.latitude, position.longitude);
    _updateUserMarker(userPosition);
    _saveCurrentLocation(position);

    if (_autoCenterCamera) {
      _animateCameraToPosition(userPosition);
    }
  }

  void _onPositionError(dynamic error) {
    debugPrint('Position stream error: $error');
    setState(() {
      _locationErrorMessage = 'locationUpdateError'.tr();
    });
  }

  void _updateUserMarker(LatLng position) {
    if (position.latitude.isFinite && position.longitude.isFinite) {
      setState(() {
        _userMarkers.clear();
        _userMarkers.add(
          Marker(
            markerId: const MarkerId(_userLocationMarkerId),
            position: position,
            infoWindow: InfoWindow(title: 'yourLocation'.tr()),
            icon:
                _userIcon ??
                BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
            zIndex: 2,
          ),
        );
      });
    }
  }

  void _animateCameraToPosition(LatLng position) {
    final lat = position.latitude.clamp(
      _canThoBounds.southwest.latitude,
      _canThoBounds.northeast.latitude,
    );
    final lng = position.longitude.clamp(
      _canThoBounds.southwest.longitude,
      _canThoBounds.northeast.longitude,
    );
    final boundedPosition = LatLng(lat, lng);

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: boundedPosition, zoom: _locationZoom),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(target: _canThoCenter, zoom: _initialZoom),
      ),
    );
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _busLocationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}
*/
