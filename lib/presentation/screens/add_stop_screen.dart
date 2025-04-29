/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class AddStopScreen extends StatefulWidget {
  const AddStopScreen({super.key});

  @override
  State<AddStopScreen> createState() => _AddStopScreenState();
}

class _AddStopScreenState extends State<AddStopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _longController = TextEditingController();

  final List<String> _selectedRoutes = [];
  List<String> _availableRoutes = [];
  bool _isLoading = false;
  bool _useCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  Future<void> _fetchRoutes() async {
    setState(() => _isLoading = true);
    try {
      final routesSnapshot =
          await FirebaseFirestore.instance.collection('routes').get();
      final routes = routesSnapshot.docs.map((doc) => doc.id).toList();
      setState(() {
        _availableRoutes = routes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${'fetchError'.tr()}: $e')));
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latController.text = position.latitude.toString();
        _longController.text = position.longitude.toString();
        _useCurrentLocation = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('locationError'.tr())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('addStop'.tr())),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'stopName'.tr(),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'stopNameRequired'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: InputDecoration(
                        labelText: 'latitude'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'latitudeRequired'.tr();
                        }
                        try {
                          final lat = double.parse(value);
                          if (lat < -90 || lat > 90) {
                            return 'invalidLatitude'.tr();
                          }
                        } catch (_) {
                          return 'invalidLatitude'.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _longController,
                      decoration: InputDecoration(
                        labelText: 'longitude'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'longitudeRequired'.tr();
                        }
                        try {
                          final lng = double.parse(value);
                          if (lng < -180 || lng > 180) {
                            return 'invalidLongitude'.tr();
                          }
                        } catch (_) {
                          return 'invalidLongitude'.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: Text('useCurrentLocation'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _useCurrentLocation ? Colors.green : null,
                ),
              ),
              const SizedBox(height: 16),
              Text('selectRoutes'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView.builder(
                  itemCount: _availableRoutes.length,
                  itemBuilder: (context, index) {
                    final route = _availableRoutes[index];
                    return CheckboxListTile(
                      title: Text(route),
                      value: _selectedRoutes.contains(route),
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedRoutes.add(route);
                          } else {
                            _selectedRoutes.remove(route);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveStop,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('saveStop'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveStop() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRoutes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('selectAtLeastOneRoute'.tr())),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final latitude = double.parse(_latController.text);
      final longitude = double.parse(_longController.text);

      final stopData = {
        'name': _nameController.text,
        'latitude': GeoPoint(latitude, longitude),
        'longitude': GeoPoint(latitude, longitude), // Keep for compatibility
        'routes': _selectedRoutes,
        'bus_times': [] // Empty initially
      };

      // Use 'stops' collection instead of 'stops' based on backend code
      await FirebaseFirestore.instance.collection('stops').add(stopData);

      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('stopSaved'.tr())),
        );
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'saveError'.tr()}: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }
}
*/
