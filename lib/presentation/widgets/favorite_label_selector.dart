import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../data/datasources/local/favorite_label_storage.dart';
import '../cubits/route_finder/route_finder_cubit.dart';
import '../cubits/route_finder/route_finder_state.dart';
import '../routes/app_routes.dart';

class FavoriteLabelSelector extends StatefulWidget {
  const FavoriteLabelSelector({super.key});

  @override
  State<FavoriteLabelSelector> createState() => _FavoriteLabelSelectorState();
}

class _FavoriteLabelSelectorState extends State<FavoriteLabelSelector> {
  List<String> favoriteLabels = [];

  @override
  void initState() {
    super.initState();
    _loadLabels();
  }

  Future<void> _loadLabels() async {
    final storage = FavoritePlaceStorage();
    final labels = await storage.loadLabels();
    setState(() {
      favoriteLabels = labels;
    });
  }

  Future<void> _onLabelTap(BuildContext context, String label) async {
    final storage = FavoritePlaceStorage();
    final places = await storage.loadPlaces();
    Map<String, dynamic>? foundPlace;
    for (final p in places) {
      if (p['label'] == label &&
          p['lat'] != null &&
          (p['lng'] != null || p['lon'] != null)) {
        foundPlace = p;
        break;
      }
    }

    // Check if context is still valid before proceeding
    if (!context.mounted) return;

    if (foundPlace == null) {
      final picked = await context.push(
        AppRoutes.pickFavoritePlace,
        extra: label,
      );

      // Check if context is still valid before using setState
      if (!context.mounted) return;

      if (picked != null) {
        setState(() {});
      }
    } else {
      final routeFinderCubit = context.read<RouteFinderCubit>();
      final sel = routeFinderCubit.state.selectionType;
      final lat = double.tryParse(foundPlace['lat'].toString()) ?? 0.0;
      final lng =
          foundPlace['lng'] != null
              ? double.tryParse(foundPlace['lng'].toString())
              : (foundPlace['lon'] != null
                  ? double.tryParse(foundPlace['lon'].toString())
                  : 0.0);
      final displayName = foundPlace['display_name'] as String? ?? label;
      final latLng = LatLng(lat, lng ?? 0.0);
      if (sel == LocationSelectionType.start) {
        routeFinderCubit.setStart(name: displayName, latLng: latLng);
      } else {
        routeFinderCubit.setEnd(name: displayName, latLng: latLng);
      }
      routeFinderCubit.resetSelection();

      if (context.mounted) {
        if (sel == LocationSelectionType.start ||
            sel == LocationSelectionType.end) {
          context.pop();
        } else {
          context.push(AppRoutes.routeFinder);
        }
      }
    }
  }

  Future<void> _onLabelLongPress(BuildContext context, String label) async {
    await showLabelOptionsDialog(
      context: context,
      label: label,
      onUpdatePlace: () async {
        final picked = await context.push(
          AppRoutes.pickFavoritePlace,
          extra: label,
        );
        if (picked != null) {
          setState(() {});
        }
      },
      onDelete: () {
        setState(() {
          favoriteLabels.remove(label);
        });
      },
      onLabelDeleted: () async {
        await _loadLabels();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              color: theme.colorScheme.primary.withAlpha((0.1 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: favoriteLabels.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 4),
          itemBuilder: (context, index) {
            if (index < favoriteLabels.length) {
              return _buildLabelChip(context, favoriteLabels[index]);
            } else {
              return _buildAddButton(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLabelChip(BuildContext context, String label) {
    final theme = Theme.of(context);
    return GestureDetector(
      onLongPress: () => _onLabelLongPress(context, label),
      child: RawChip(
        avatar: Icon(
          FavoritePlaceStorage.iconForLabel(label),
          size: 20,
          color: theme.iconTheme.color,
        ),
        label: Text(
          FavoritePlaceStorage.localizedLabel(label),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSecondary,
          ),
        ),
        labelPadding: const EdgeInsets.only(left: 2, right: 8),
        backgroundColor: theme.primaryColorLight.withAlpha((0.5 * 255).toInt()),
        labelStyle: theme.textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.dividerColor, width: 1),
        ),
        elevation: 0,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        onPressed: () => _onLabelTap(context, label),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final theme = Theme.of(context);
    // Use LayoutBuilder to get the container height and make the button circular
    return LayoutBuilder(
      builder: (context, constraints) {
        final double size = (constraints.maxHeight - 8).clamp(
          28.0,
          40.0,
        ); // 8 for vertical padding
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Material(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(size / 2),
            child: InkWell(
              borderRadius: BorderRadius.circular(size / 2),
              onTap: () async {
                final controller = TextEditingController();
                await showAddFavoritePlaceDialog(
                  context: context,
                  controller: controller,
                  onConfirm: (name) async {
                    final storage = FavoritePlaceStorage();
                    await storage.addPlace({'label': name});
                    await _loadLabels();
                  },
                  existingLabels: favoriteLabels,
                );
              },
              child: Container(
                height: size,
                width: size,
                alignment: Alignment.center,
                child: Icon(
                  Icons.add,
                  color: theme.colorScheme.onPrimary,
                  size: size * 0.7,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Hiển thị hộp thoại tùy chọn khi giữ lâu 1 label
  static Future<void> showLabelOptionsDialog({
    required BuildContext context,
    required String label,
    required VoidCallback onUpdatePlace,
    required VoidCallback? onDelete,
    Future<void> Function()? onLabelDeleted,
  }) async {
    final isDefault = FavoritePlaceStorage.defaultLabels.contains(label);
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: theme.cardColor,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr(
                            'favoriteLabelDialogTitle',
                            args: [FavoritePlaceStorage.localizedLabel(label)],
                          ),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tr('favoriteLabelDialogDescription'),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          textStyle: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(
                          tr('close'),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      if (!isDefault)
                        TextButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            final storage = FavoritePlaceStorage();
                            await storage.removeByLabel(label);
                            if (onLabelDeleted != null) {
                              await onLabelDeleted();
                            }
                            if (onDelete != null) onDelete();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            textStyle: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text(
                            tr('favoriteLabelDialogDelete'),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          onUpdatePlace();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          textStyle: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(
                          tr('favoriteLabelDialogUpdate'),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /// Hiển thị dialog thêm địa điểm yêu thích mới
  static Future<void> showAddFavoritePlaceDialog({
    required BuildContext context,
    required TextEditingController controller,
    required void Function(String name) onConfirm,
    List<String>? existingLabels,
  }) async {
    final theme = Theme.of(context);
    final nameController = TextEditingController(text: controller.text.trim());
    String? errorText;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: theme.cardColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
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
                        prefixIcon: Icon(
                          Icons.label,
                          color: theme.iconTheme.color,
                        ),
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
                        errorText: errorText,
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
                            if (name.isEmpty) return;
                            if (existingLabels != null &&
                                existingLabels
                                    .map((e) => e.toLowerCase())
                                    .contains(name.toLowerCase())) {
                              setState(() {
                                errorText = 'labelAlreadyExists'.tr();
                              });
                              return;
                            }
                            onConfirm(name);
                            Navigator.of(context).pop();
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
      },
    );
  }
}
