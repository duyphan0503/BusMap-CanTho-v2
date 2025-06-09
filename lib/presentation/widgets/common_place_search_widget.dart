import 'dart:async';
import 'dart:convert';

import 'package:busmapcantho/core/services/notification_snackbar_service.dart';
import 'package:busmapcantho/core/services/places_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nominatim_flutter/model/response/nominatim_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../routes/app_routes.dart';

class CommonPlaceSearchScreen extends StatefulWidget {
  final String? favoriteLabel;
  final FutureOr<void> Function(NominatimResponse)? onPicked;
  final PlaceScreenMode mode;
  final Widget? favoriteLabelWidget;
  final FutureOr<void> Function(NominatimResponse)? onSuggestionTap;
  final FutureOr<void> Function(NominatimResponse)? onHistoryTap;

  const CommonPlaceSearchScreen({
    super.key,
    this.favoriteLabel,
    this.onPicked,
    this.mode = PlaceScreenMode.routeFinder,
    this.favoriteLabelWidget,
    this.onSuggestionTap,
    this.onHistoryTap,
  });

  @override
  State<CommonPlaceSearchScreen> createState() =>
      _CommonPlaceSearchScreenState();
}

enum PlaceScreenMode { routeFinder, pickFavoritePlace }

class _CommonPlaceSearchScreenState extends State<CommonPlaceSearchScreen> {
  static const _historyKey = 'search_history';

  final TextEditingController _controller = TextEditingController();
  final PlacesService _placesService = getIt<PlacesService>();

  List<NominatimResponse> _suggestions = [];
  List<NominatimResponse> _history = [];
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
    List<String> raw = prefs.getStringList(_historyKey) ?? [];
    _history =
        raw.map((e) {
          final Map<String, dynamic> m = jsonDecode(e);
          return NominatimResponse(
            displayName: m['display_name'],
            lat: m['lat'],
            lon: m['lon'],
          );
        }).toList();
    setState(() {});
  }

  Future<void> _saveHistory(NominatimResponse place) async {
    final prefs = await SharedPreferences.getInstance();
    _history.removeWhere((h) => h.lat == place.lat && h.lon == place.lon);
    _history.insert(0, place);
    if (_history.length > 10) _history = _history.sublist(0, 10);
    final List<String> raw =
        _history.map((h) {
          return jsonEncode({
            'display_name': h.displayName,
            'lat': h.lat,
            'lon': h.lon,
          });
        }).toList();
    await prefs.setStringList(_historyKey, raw);
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
      var places = await _placesService.searchPlaces(query);
      if (places.isEmpty) {
        // fallback to history
        final historySug =
            _history
                .where(
                  (h) =>
                      h.displayName?.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ??
                      false,
                )
                .toList();
        setState(() {
          _suggestions = historySug;
          _isLoading = false;
        });
        return;
      }
      final filtered =
          places
              .where(
                (p) => p.placeName.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
      setState(() {
        _suggestions = filtered;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('errorFetchingSuggestions'.tr());
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onSuggestionTap(NominatimResponse place) async {
    if (widget.onSuggestionTap != null) {
      await widget.onSuggestionTap!(place);
      return;
    }
    await _saveHistory(place);
    if (widget.onPicked != null) {
      await widget.onPicked!(place);
      return;
    }
  }

  Future<void> _onHistoryTap(NominatimResponse place) async {
    if (widget.onHistoryTap != null) {
      await widget.onHistoryTap!(place);
      return;
    }
    if (widget.onPicked != null) {
      await widget.onPicked!(place);
      return;
    }
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    setState(() => _history.clear());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showHistory = _controller.text.trim().isEmpty && !_isLoading;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        toolbarHeight: 72,
        leadingWidth: 36,
        title: _buildSearchBarTitle(theme),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (widget.favoriteLabelWidget != null) widget.favoriteLabelWidget!,
          buildPickOnMapButton(),
          if (showHistory && _history.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                top: 8,
                left: 8,
                right: 8,
                bottom: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'searchHistory'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_sweep,
                      color: AppColors.primaryMedium,
                    ),
                    tooltip: 'clearHistory'.tr(),
                    onPressed: _clearHistory,
                  ),
                ],
              ),
            ),
          Expanded(
            child:
                showHistory
                    ? _buildHistoryList(theme)
                    : _buildSuggestions(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBarTitle(ThemeData theme) {
    return Center(
      child: SizedBox(
        height: 44,
        width: MediaQuery.of(context).size.width - 56,
        child: TextField(
          controller: _controller,
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: 'enterLocation'.tr(),
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
            prefixIcon:
                _controller.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        size: 18,
                        color: AppColors.primaryMedium,
                      ),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _suggestions = []);
                      },
                    )
                    : null,
            suffixIcon: const Icon(
              Icons.search,
              size: 20,
              color: AppColors.primaryMedium,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primaryLight,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: theme.cardColor,
            isDense: true,
            contentPadding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 16,
              right: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPickOnMapButton() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: Icon(Icons.map, color: theme.colorScheme.onPrimary),
          label: Text(
            'pickOnMapButton'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            textStyle: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            elevation: 2,
          ),
          onPressed: () async {
            final result = await context.push<bool?>(
              AppRoutes.pickLocationOnMap,
              extra: {'addToLabelMode': true, 'label': widget.favoriteLabel},
            );
            if (result == true && mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSuggestions(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryMedium),
      );
    }

    if (_suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('noSuggestions'.tr(), style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Text(
              'searchByPlaceName'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(
                  alpha: (0.6 * 255).toDouble(),
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _suggestions.length,
      separatorBuilder:
          (_, __) => Divider(height: 1, color: AppColors.dividerColor),
      itemBuilder: (context, index) {
        final place = _suggestions[index];
        final coords = place.toLatLng;
        final isHistory = coords.latitude == 0.0 && coords.longitude == 0.0;

        final title = _highlightMatchingText(
          place.placeName,
          _controller.text.trim(),
          theme,
        );

        return ListTile(
          leading: Icon(
            isHistory ? Icons.history : Icons.location_on,
            color:
                isHistory
                    ? theme.colorScheme.onSurface.withAlpha(180)
                    : AppColors.primaryMedium,
          ),
          title: title,
          subtitle:
              place.address != null
                  ? Text(
                    _formatStructuredAddress(place.address!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  )
                  : null,
          onTap: () => _onSuggestionTap(place),
        );
      },
    );
  }

  Widget _buildHistoryList(ThemeData theme) {
    if (_history.isEmpty) {
      return Center(
        child: Text('noHistory'.tr(), style: theme.textTheme.bodyMedium),
      );
    }
    return ListView.separated(
      itemCount: _history.length,
      separatorBuilder:
          (_, __) => Divider(height: 1, color: AppColors.dividerColor),
      itemBuilder: (context, index) {
        final place = _history[index];
        final display = place.placeName;
        return ListTile(
          leading: const Icon(Icons.history, color: AppColors.primaryMedium),
          title: Text(
            _getAbbreviatedName(display),
            style: theme.textTheme.bodyLarge,
          ),
          onTap: () => _onHistoryTap(place),
        );
      },
    );
  }

  Widget _highlightMatchingText(String text, String query, ThemeData theme) {
    if (query.isEmpty) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
      );
    }
    final queryLower = query.toLowerCase();
    final textLower = text.toLowerCase();
    if (!textLower.contains(queryLower)) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
      );
    }
    final startIndex = textLower.indexOf(queryLower);
    final endIndex = startIndex + query.length;
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        children: [
          TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: theme.textTheme.bodyLarge?.copyWith(
              backgroundColor: Colors.yellowAccent.withAlpha(100),
              color: AppColors.error,
            ),
          ),
          TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }

  String _getAbbreviatedName(String fullAddress) {
    // Extract text before the first comma
    final firstComma = fullAddress.indexOf(',');
    if (firstComma > 0) {
      return fullAddress.substring(0, firstComma).trim();
    }
    return fullAddress;
  }

  String _formatStructuredAddress(Map<String, dynamic>? address) {
    final parts = <String>[];

    // 1. Số nhà (house_number) nếu có
    final houseNumber = address?['house_number'] as String?;
    if (houseNumber?.isNotEmpty ?? false) {
      parts.add(houseNumber!);
    }

    // 2. Tên đường
    final road = address?['road'] as String?;
    if (road?.isNotEmpty ?? false) {
      parts.add(road!);
    }

    // 3. Phường/Xã
    final suburb = address?['suburb'] as String?;
    if (suburb?.isNotEmpty ?? false) {
      parts.add(suburb!);
    }

    // 4. Quận/Huyện
    final district = address?['district'] as String?;
    final county = address?['county'] as String?;
    if (district?.isNotEmpty ?? false) {
      parts.add(district!);
    } else if (county?.isNotEmpty ?? false) {
      parts.add(county!);
    }

    // 5. Thành phố/Tỉnh
    final city = address?['city'] as String?;
    final state = address?['state'] as String?;
    if (city?.isNotEmpty ?? false) {
      parts.add(city!);
    } else if (state?.isNotEmpty ?? false) {
      parts.add(state!);
    }

    // 6. Mã bưu chính
    final postcode = address?['postcode'] as String?;
    if (postcode?.isNotEmpty ?? false) {
      parts.add(postcode!);
    }

    return parts.join(', ');
  }
}
