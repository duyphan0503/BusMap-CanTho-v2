// import 'dart:async';
//
// import 'package:busmapcantho/configs/env.dart';
// import 'package:busmapcantho/presentation/screens/home/map/map_screen.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_webservice/places.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});
//
//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   static const _historyKey = 'search_history';
//   final _controller = TextEditingController();
//   final _places = GoogleMapsPlaces(apiKey: googleMapsApiKey);
//   List<Prediction> _suggestions = [];
//   List<String> _history = [];
//   Timer? _debounce;

  // @override
  // void initState() {
  //   super.initState();
  //   _loadHistory();
  // }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _debounce?.cancel();
//     super.dispose();
//   }
//
//   Future<void> _loadHistory() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _history = prefs.getStringList(_historyKey) ?? [];
//     });
//   }
//
//   Future<void> _saveHistory(String description) async {
//     final prefs = await SharedPreferences.getInstance();
//     _history.remove(description);
//     _history.insert(0, description);
//     if (_history.length > 10) {
//       _history = _history.sublist(0, 10);
//     }
//     await prefs.setStringList(_historyKey, _history);
//     setState(() {});
//   }
//
//   void _onQueryChanged(String value) {
//     _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 300), () {
//       _fetchSuggestions(value);
//     });
//   }
//
//   Future<void> _fetchSuggestions(String query) async {
//     if (query.isEmpty) {
//       setState(() {
//         _suggestions = [];
//       });
//       return;
//     }
//
//     try {
//       final response = await _places.autocomplete(
//         query,
//         location: Location(lat: 10.025817, lng: 105.7470982),
//         radius: 100000,
//         components: [Component(Component.country, 'vn')],
//         types: ['geocode', 'establishment'],
//       );
//
//       if (response.isOkay) {
//         setState(() {
//           _suggestions = response.predictions;
//         });
//         debugPrint(
//           'Suggestions: ${response.predictions.map((p) => p.description).toList()}',
//         );
//       } else {
//         debugPrint('Error fetching suggestions: ${response.errorMessage}');
//         setState(() {
//           _suggestions = [];
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${response.errorMessage}')),
//         );
//       }
//     } catch (e) {
//       debugPrint('Exception fetching suggestions: $e');
//       setState(() {
//         _suggestions = [];
//       });
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Exception: $e')));
//     }
//   }
//
//   void _onSuggestionTap(Prediction p) {
//     final desc = p.description ?? '';
//     _saveHistory(desc);
//     Navigator.of(context).pop<String>(desc);
//   }
//
//   void _onHistoryTap(String desc) {
//     Navigator.of(context).pop<String>(desc);
//   }
//
//   void _clearHistory() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_historyKey);
//     setState(() {
//       _history.clear();
//     });
//   }
//
//   Future<void> _selectOnMap() async {
//     final selectedLocation = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => MapSelectionScreen()),
//     );
//     if (selectedLocation != null && selectedLocation is LatLng) {
//       // Chuyển tọa độ thành địa chỉ bằng Reverse Geocoding (tùy chọn)
//       final response = await _places.getDetailsByPlaceId(
//         'ChIJuV7e1J5YNDMRZ9mL8qK8j_Q', // Giả sử Place ID gần Cần Thơ
//         language: 'vi',
//       );
//       if (response.isOkay) {
//         final description =
//             response.result.formattedAddress ?? 'Địa điểm được chọn';
//         _saveHistory(description);
//         Navigator.of(context).pop<String>(description);
//       } else {
//         _saveHistory(
//           'Vị trí: ${selectedLocation.latitude}, ${selectedLocation.longitude}',
//         );
//         Navigator.of(context).pop<String>(
//           'Vị trí: ${selectedLocation.latitude}, ${selectedLocation.longitude}',
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final showHistory = _controller.text.isEmpty;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('search'.tr()),
//         backgroundColor: theme.colorScheme.primary,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.map),
//             onPressed: _selectOnMap,
//             tooltip: 'Chọn trên bản đồ',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: TextField(
//               controller: _controller,
//               onChanged: _onQueryChanged,
//               decoration: InputDecoration(
//                 hintText: 'enterLocation'.tr(),
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 isDense: true,
//               ),
//             ),
//           ),
//           Expanded(child: showHistory ? _buildHistory() : _buildSuggestions()),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSuggestions() {
//     if (_suggestions.isEmpty) {
//       return Center(child: Text('noSuggestions'.tr()));
//     }
//     return ListView.separated(
//       itemCount: _suggestions.length,
//       separatorBuilder: (_, __) => const Divider(height: 1),
//       itemBuilder: (context, i) {
//         final p = _suggestions[i];
//         return ListTile(
//           leading: const Icon(Icons.location_on),
//           title: Text(p.structuredFormatting?.mainText ?? p.description ?? ''),
//           subtitle:
//               p.structuredFormatting?.secondaryText != null
//                   ? Text(p.structuredFormatting!.secondaryText!)
//                   : null,
//           onTap: () => _onSuggestionTap(p),
//         );
//       },
//     );
//   }
//
//   Widget _buildHistory() {
//     if (_history.isEmpty) {
//       return Center(child: Text('noHistory'.tr()));
//     }
//     return Column(
//       children: [
//         Expanded(
//           child: ListView.separated(
//             itemCount: _history.length,
//             separatorBuilder: (_, __) => const Divider(height: 1),
//             itemBuilder: (context, i) {
//               final desc = _history[i];
//               return ListTile(
//                 leading: const Icon(Icons.history),
//                 title: Text(desc),
//                 onTap: () => _onHistoryTap(desc),
//               );
//             },
//           ),
//         ),
//         TextButton.icon(
//           onPressed: _clearHistory,
//           icon: const Icon(Icons.delete_forever),
//           label: Text('clearHistory'.tr()),
//         ),
//       ],
//     );
//   }
// }
//
// // Màn hình chọn địa điểm trên bản đồ
// class MapSelectionScreen extends StatefulWidget {
//   const MapSelectionScreen({super.key});
//
//   @override
//   State<MapSelectionScreen> createState() => _MapSelectionScreenState();
// }
//
// class _MapSelectionScreenState extends State<MapSelectionScreen> {
//   late GoogleMapController _mapController;
//   LatLng? _selectedLocation;
//
//   @override
//   void dispose() {
//     _mapController.dispose();
//     super.dispose();
//   }
//
//   void _onMapTap(LatLng position) {
//     setState(() {
//       _selectedLocation = position;
//     });
//   }
//
//   void _confirmSelection() {
//     if (_selectedLocation != null) {
//       Navigator.pop(context, _selectedLocation);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('selectOnMap'.tr()),
//         actions: [
//           if (_selectedLocation != null)
//             TextButton(
//               onPressed: _confirmSelection,
//               child: Text(
//                 'confirm'.tr(),
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           MapScreen(),
//           if (_selectedLocation != null)
//             Positioned(
//               bottom: 16,
//               left: 16,
//               right: 16,
//               child: Card(
//                 child: ListTile(
//                   title: Text(
//                     'Selected: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
//                   ),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.check),
//                     onPressed: _confirmSelection,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
