/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../services/directions_service.dart';
import '../../../../services/location_service.dart';
import '../../../../services/places_service.dart';
import '../../../blocs/directions/directions_bloc.dart';

class DirectionsScreen extends StatelessWidget {
  const DirectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => DirectionsBloc(
            locationService: LocationService(),
            placesService: PlacesService(),
            directionsService: DirectionsService(),
          )..add(FetchCurrentLocationEvent()),
      child: const DirectionsScreenView(),
    );
  }
}

class DirectionsScreenView extends StatefulWidget {
  const DirectionsScreenView({super.key});

  @override
  State<DirectionsScreenView> createState() => _DirectionsScreenViewState();
}

class _DirectionsScreenViewState extends State<DirectionsScreenView> {
  GoogleMapController? _mapController;
  final _startController = TextEditingController(text: 'Vị trí hiện tại');
  final _destinationController = TextEditingController();
  Set<Polyline> _polylines = {};

  @override
  void dispose() {
    _startController.dispose();
    _destinationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Bản đồ
          BlocBuilder<DirectionsBloc, DirectionsState>(
            builder: (context, state) {
              if (state.currentLocation == null) {
                return const Center(child: CircularProgressIndicator());
              }

              _polylines =
                  state.polylinePoints.isNotEmpty
                      ? {
                        Polyline(
                          polylineId: const PolylineId('route'),
                          points: state.polylinePoints,
                          color: Colors.blue,
                          width: 5,
                        ),
                      }
                      : {};

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: state.currentLocation!,
                  zoom: 14,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                polylines: _polylines,
                markers: {
                  if (state.currentLocation != null)
                    Marker(
                      markerId: const MarkerId('current_location'),
                      position: state.currentLocation!,
                      infoWindow: const InfoWindow(title: 'Vị trí hiện tại'),
                    ),
                  if (state.destination != null)
                    Marker(
                      markerId: const MarkerId('destination'),
                      position: state.destination!,
                      infoWindow: const InfoWindow(title: 'Điểm đến'),
                    ),
                },
              );
            },
          ),

          // Thanh tìm kiếm
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _startController,
                            decoration: const InputDecoration(
                              hintText: 'Đi từ',
                              border: InputBorder.none,
                            ),
                            readOnly: true,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.swap_vert),
                          onPressed: () {
                            context.read<DirectionsBloc>().add(
                              SwapLocationsEvent(),
                            );
                            final temp = _startController.text;
                            _startController.text = _destinationController.text;
                            _destinationController.text = temp;
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Icon(Icons.flag, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _destinationController,
                            decoration: const InputDecoration(
                              hintText: 'Đến',
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                context.read<DirectionsBloc>().add(
                                  SearchDestinationEvent(value),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    // Gợi ý địa điểm
                    BlocBuilder<DirectionsBloc, DirectionsState>(
                      builder: (context, state) {
                        if (state.destinationSuggestions.isNotEmpty) {
                          return Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: state.destinationSuggestions.length,
                              itemBuilder: (context, index) {
                                final suggestion =
                                    state.destinationSuggestions[index];
                                return ListTile(
                                  title: Text(suggestion.description ?? ''),
                                  onTap: () {
                                    _destinationController.text =
                                        suggestion.description ?? '';
                                    context.read<DirectionsBloc>().add(
                                      SelectDestinationEvent(
                                        suggestion.placeId ?? '',
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Nút "Tìm đường"
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                final state = context.read<DirectionsBloc>().state;
                if (state.currentLocation != null &&
                    state.destination != null) {
                  context.read<DirectionsBloc>().add(
                    FindDirectionsEvent(
                      state.currentLocation!,
                      state.destination!,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng chọn điểm đi và điểm đến'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'TÌM ĐƯỜNG',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Bottom sheet hiển thị thông tin tuyến đường
          BlocBuilder<DirectionsBloc, DirectionsState>(
            builder: (context, state) {
              if (state.polylinePoints.isNotEmpty &&
                  state.distance != null &&
                  state.duration != null) {
                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tuyến đường tới ${state.destination != null ? _destinationController.text : ''}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.directions, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text('Khoảng cách: ${state.distance}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.timer, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text('Thời gian: ${state.duration}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.directions_bus,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            const Text('Số chuyến: 2'), // Giả lập dữ liệu
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
*/
