import 'dart:async';

import 'package:busmapcantho/services/places_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart';

class SearchResult {
  final String description;
  final LatLng? latLng;

  SearchResult({required this.description, this.latLng});
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _historyKey = 'search_history';

  final TextEditingController _controller = TextEditingController();
  final PlacesService _placesService = getIt<PlacesService>();

  List<NominatimPlace> _suggestions = [];
  List<String> _history = [];
  Timer? _debounce;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _controller.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _history = prefs.getStringList(_historyKey) ?? [];
    setState(() {});
  }

  Future<void> _saveHistory(String description) async {
    final prefs = await SharedPreferences.getInstance();
    _history.remove(description);
    _history.insert(0, description);
    if (_history.length > 10) {
      _history = _history.sublist(0, 10);
    }
    await prefs.setStringList(_historyKey, _history);
    setState(() {});
  }

  void _onQueryChanged() {
    _debounce?.cancel();
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _fetchSuggestions(text);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    setState(() => _isLoading = true);
    try {
      // Tìm kiếm địa điểm từ API
      final places = await _placesService.searchPlaces(query);

      // Hiển thị gợi ý từ lịch sử nếu không có kết quả tìm kiếm
      if (places.isEmpty) {
        final historySuggestions = _getHistorySuggestions(query);
        setState(() {
          _suggestions = historySuggestions;
          _isLoading = false;
        });
        return;
      }

      // Lọc thêm một lần nữa ở UI để chỉ hiển thị các kết quả có từ khóa trong tên
      final queryLower = query.toLowerCase();
      final filteredPlaces =
          places.where((place) {
            return place.placeName.toLowerCase().contains(queryLower);
          }).toList();

      setState(() {
        _suggestions = filteredPlaces;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('PlacesService.searchPlaces error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('errorFetchingSuggestions'.tr())));
      setState(() => _isLoading = false);
    }
  }

  // Lấy gợi ý từ lịch sử dựa trên truy vấn
  List<NominatimPlace> _getHistorySuggestions(String query) {
    final queryLower = query.toLowerCase();
    final matchingHistory =
        _history
            .where((item) => item.toLowerCase().contains(queryLower))
            .toList();

    // Tạo các đối tượng NominatimPlace từ lịch sử phù hợp
    return matchingHistory
        .map(
          (desc) => NominatimPlace(
            displayName: desc,
            lat: 0, // Thông tin vị trí không có sẵn từ lịch sử
            lon: 0,
          ),
        )
        .toList();
  }

  Future<void> _onSuggestionTap(NominatimPlace place) async {
    final desc = place.displayName;
    await _saveHistory(desc);
    Navigator.of(context).pop<SearchResult>(
      SearchResult(description: desc, latLng: place.toLatLng),
    );
  }

  void _onHistoryTap(String desc) {
    Navigator.of(
      context,
    ).pop<SearchResult>(SearchResult(description: desc, latLng: null));
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    setState(() {
      _history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final showHistory = _controller.text.trim().isEmpty && !_isLoading;
    return Scaffold(
      appBar: AppBar(
        title: Text('search'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'clearHistory'.tr(),
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'enterLocation'.tr(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    setState(() => _suggestions = []);
                  },
                ),
                isDense: true,
              ),
            ),
          ),
          Expanded(child: showHistory ? _buildHistory() : _buildSuggestions()),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('noSuggestions'.tr()),
            const SizedBox(height: 16),
            Text(
              'searchByPlaceName'.tr(), // Thay thế 'tryMoreSpecificQuery'.tr()
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _suggestions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final place = _suggestions[index];

        // Highlight phần văn bản khớp với truy vấn
        final title = _highlightMatchingText(
          place.placeName,
          _controller.text.trim(),
        );

        return ListTile(
          leading: Icon(
            place.lat == 0 && place.lon == 0
                ? Icons.history
                : Icons.location_on,
            color:
                place.lat == 0 && place.lon == 0
                    ? Colors.grey
                    : Colors.red.shade700,
          ),
          title: title,
          subtitle:
              place.address != null
                  ? Text(
                    _formatStructuredAddress(place.address!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  )
                  : null,
          onTap: () => _onSuggestionTap(place),
        );
      },
    );
  }

  // Phương thức để highlight phần văn bản khớp với truy vấn
  Widget _highlightMatchingText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    }

    final queryLower = query.toLowerCase();
    final textLower = text.toLowerCase();

    if (!textLower.contains(queryLower)) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    }

    final startIndex = textLower.indexOf(queryLower);
    final endIndex = startIndex + query.length;

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        children: [
          TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: const TextStyle(
              backgroundColor: Colors.yellow,
              color: Colors.black,
            ),
          ),
          TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }

  String _formatStructuredAddress(Address address) {
    // Tạo danh sách các phần của địa chỉ theo thứ tự mong muốn
    final List<String> parts = [];

    // 1. Số nhà (house_number) nếu có
    if (address.houseNumber != null && address.houseNumber!.isNotEmpty) {
      parts.add(address.houseNumber!);
    }

    // 2. Tên đường
    if (address.road != null && address.road!.isNotEmpty) {
      parts.add(address.road!);
    }

    // 3. Phường/Xã
    if (address.suburb != null && address.suburb!.isNotEmpty) {
      parts.add(address.suburb!);
    }

    // 4. Quận/Huyện
    if (address.district != null && address.district!.isNotEmpty) {
      parts.add('${address.district}');
    } else if (address.county != null && address.county!.isNotEmpty) {
      parts.add(address.county!);
    }

    // 5. Thành phố/Tỉnh (Cần Thơ)
    if (address.city != null && address.city!.isNotEmpty) {
      parts.add(address.city!);
    } else if (address.state != null && address.state!.isNotEmpty) {
      parts.add(address.state!);
    }

    // 6. Mã bưu chính
    if (address.postcode != null && address.postcode!.isNotEmpty) {
      parts.add(address.postcode!);
    }

    // Kết hợp tất cả các phần với dấu phẩy
    return parts.join(', ');
  }

  Widget _buildHistory() {
    if (_history.isEmpty) {
      return Center(child: Text('noHistory'.tr()));
    }
    return ListView.separated(
      itemCount: _history.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final desc = _history[index];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(desc),
          onTap: () => _onHistoryTap(desc),
        );
      },
    );
  }
}
