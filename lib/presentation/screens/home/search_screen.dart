import 'dart:async';
import 'dart:convert';

import 'package:busmapcantho/core/services/notification_snackbar_service.dart';
import 'package:busmapcantho/core/services/places_service.dart';
import 'package:busmapcantho/presentation/cubits/route_finder/route_finder_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../cubits/route_finder/route_finder_state.dart';
import '../../routes/app_routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _historyKey = 'search_history';

  RouteFinderCubit get _routeFinderCubit => context.read<RouteFinderCubit>();

  final TextEditingController _controller = TextEditingController();
  final PlacesService _placesService = getIt<PlacesService>();

  List<NominatimPlace> _suggestions = [];
  List<NominatimPlace> _history = [];
  Timer? _debounce;
  bool _isLoading = false;

  // List of favorite labels (example: School, Home, Office)
  final List<String> _favoriteLabels = ['School', 'Home', 'Office'];
  String? _selectedLabel;

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
    final raw = prefs.getStringList(_historyKey) ?? [];
    _history =
        raw.map((e) {
          final m = jsonDecode(e);
          return NominatimPlace(
            displayName: m['displayName'],
            lat: m['lat'],
            lon: m['lon'],
            address: null,
          );
        }).toList();
    setState(() {});
  }

  Future<void> _saveHistory(NominatimPlace place) async {
    final prefs = await SharedPreferences.getInstance();
    _history.removeWhere((h) => h.displayName == place.displayName);
    _history.insert(0, place);
    if (_history.length > 10) _history = _history.sublist(0, 10);
    final raw =
        _history
            .map(
              (h) => jsonEncode({
                'displayName': h.displayName,
                'lat': h.lat,
                'lon': h.lon,
              }),
            )
            .toList();
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
      final places = await _placesService.searchPlaces(query);

      if (places.isEmpty) {
        final historySuggestions = _getHistorySuggestions(query);
        setState(() {
          _suggestions = historySuggestions;
          _isLoading = false;
        });
        return;
      }

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
      if (mounted) {
        context.showErrorSnackBar('errorFetchingSuggestions'.tr());
      }
      setState(() => _isLoading = false);
    }
  }

  List<NominatimPlace> _getHistorySuggestions(String query) {
    final queryLower = query.toLowerCase();
    final matchingHistory =
        _history
            .where(
              (item) => item.displayName.toLowerCase().contains(queryLower),
            )
            .toList();

    return matchingHistory
        .map(
          (desc) => NominatimPlace(
            displayName: desc.displayName,
            lat: desc.lat,
            lon: desc.lon,
          ),
        )
        .toList();
  }

  Future<void> _onSuggestionTap(NominatimPlace place) async {
    await _saveHistory(place);
    final selectionType = _routeFinderCubit.state.selectionType;
    final latLng = place.toLatLng;

    if (selectionType == LocationSelectionType.start) {
      _routeFinderCubit.setStart(name: place.displayName, latLng: latLng);
    } else {
      _routeFinderCubit.setEnd(name: place.displayName, latLng: latLng);
    }
    _routeFinderCubit.resetSelection();

    if (mounted) {
      if (selectionType == LocationSelectionType.start ||
          selectionType == LocationSelectionType.end) {
        context.pop();
      } else {
        context.push(AppRoutes.routeFinder);
      }
    }
  }

  void _onHistoryTap(NominatimPlace place) {
    final selectionType = _routeFinderCubit.state.selectionType;
    final latLng = place.toLatLng;

    if (selectionType == LocationSelectionType.start) {
      _routeFinderCubit.setStart(name: place.displayName, latLng: latLng);
    } else {
      _routeFinderCubit.setEnd(name: place.displayName, latLng: latLng);
    }
    _routeFinderCubit.resetSelection();

    if (mounted) {
      if (selectionType != LocationSelectionType.none) {
        context.pop();
      } else {
        context.push(AppRoutes.routeFinder);
      }
    }
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    setState(() {
      _history.clear();
    });
  }

  // Map label to icon
  IconData _iconForLabel(String label) {
    switch (label) {
      case 'School':
        return Icons.school;
      case 'Home':
        return Icons.home;
      case 'Office':
        return Icons.work;
      default:
        return Icons.label;
    }
  }

  void _onAddFavoritePlace() async {
    final theme = Theme.of(context);
    final TextEditingController nameController = TextEditingController(
      text: _controller.text.trim(),
    );
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: theme.cardColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'enterFavoritePlaceName'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'enterPlaceName'.tr(),
                    prefixIcon: Icon(Icons.label, color: theme.iconTheme.color),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        textStyle: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      child: Text('close'.tr()),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.label,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'addedFavoritePlace'.tr(
                                        args: [
                                          name,
                                          _selectedLabel ??
                                              _favoriteLabels.first,
                                        ],
                                      ),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.onPrimary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: theme.colorScheme.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                          setState(() {
                            _controller.clear();
                            _selectedLabel = null;
                          });
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        textStyle: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: Text('confirm'.tr()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteLabelSelector() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        height: 40,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withAlpha((0.06 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _favoriteLabels.length + 1, // +1 for add button
          separatorBuilder: (_, __) => const SizedBox(width: 4),
          itemBuilder: (context, index) {
            if (index < _favoriteLabels.length) {
              final label = _favoriteLabels[index];
              final isSelected = label == _selectedLabel;
              return ChoiceChip(
                avatar: Icon(
                  _iconForLabel(label),
                  size: 20,
                  color:
                      isSelected
                          ? theme.colorScheme.primary
                          : theme.iconTheme.color,
                ),
                label: Text('favoriteLabel$label'.tr()),
                labelPadding: const EdgeInsets.only(left: 2, right: 8),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _selectedLabel = label);
                },
                selectedColor: theme.colorScheme.primary.withAlpha(
                  (0.15 * 255).toInt(),
                ),
                backgroundColor: theme.colorScheme.surface,
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      isSelected
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyMedium?.color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color:
                        isSelected
                            ? theme.colorScheme.primary
                            : theme.dividerColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                elevation: 0,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            } else {
              // Add button at the end
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Material(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _onAddFavoritePlace,
                    child: Container(
                      height: 30,
                      width: 30,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.add,
                        color: theme.colorScheme.onPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildPickOnMapButton() {
    final theme = Theme.of(context);
    final selectionType = _routeFinderCubit.state.selectionType;

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
            );
            if (mounted && result == true) {
              if (selectionType != LocationSelectionType.none) {
                context.pop();
              } else {
                context.go(AppRoutes.routeFinder);
              }
            }
          },
        ),
      ),
    );
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
          _buildFavoriteLabelSelector(),
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
        final title = _highlightMatchingText(
          place.placeName,
          _controller.text.trim(),
          theme,
        );
        return ListTile(
          leading: Icon(
            place.lat == 0 && place.lon == 0
                ? Icons.history
                : Icons.location_on,
            color:
                place.lat == 0 && place.lon == 0
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
              backgroundColor: AppColors.primaryLight.withValues(
                alpha: (0.3 * 255).toDouble(),
              ),
              color: AppColors.primaryDark,
            ),
          ),
          TextSpan(text: text.substring(endIndex)),
        ],
      ),
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
        return ListTile(
          leading: const Icon(Icons.history, color: AppColors.primaryMedium),
          title: Text(
            _getAbbreviatedName(place.displayName),
            style: theme.textTheme.bodyLarge,
          ),
          onTap: () => _onHistoryTap(place),
        );
      },
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

  String _formatStructuredAddress(Address address) {
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
}
