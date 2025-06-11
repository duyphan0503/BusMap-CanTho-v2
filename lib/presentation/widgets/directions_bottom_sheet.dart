import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';

import '../../core/theme/app_colors.dart';
import 'direction_mode.dart';
import 'direction_steps_list.dart';

class DirectionsBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> steps;
  final Map<String, String> durations;
  final Map<String, String> distances;
  final String selectedMode;
  final ValueChanged<String> onModeChanged;
  final void Function(int stepIndex)? onStepTap;

  const DirectionsBottomSheet({
    super.key,
    required this.steps,
    required this.durations,
    required this.distances,
    required this.selectedMode,
    required this.onModeChanged,
    this.onStepTap,
  });

  @override
  State<DirectionsBottomSheet> createState() => _DirectionsBottomSheetState();
}

class _DirectionsBottomSheetState extends State<DirectionsBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SlidingUpPanelController _panelController;
  final _modes = [
    DirectionMode('car', Icons.directions_car, 'car'.tr(), isDefault: true),
    DirectionMode('walk', Icons.directions_walk, 'walk'.tr()),
    DirectionMode('bike', Icons.directions_bike, 'bike'.tr()),
  ];

  bool _isPanelExpanded = false;

  @override
  void initState() {
    super.initState();
    _panelController = SlidingUpPanelController();
    final initialIndex = _modes.indexWhere(
      (m) => m.key == widget.selectedMode || (m.isDefault ?? false),
    );
    _tabController = TabController(
      length: _modes.length,
      vsync: this,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
    );
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging && mounted) {
      widget.onModeChanged(_modes[_tabController.index].key);
    }
  }

  @override
  void didUpdateWidget(DirectionsBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMode != widget.selectedMode && mounted) {
      final index = _modes.indexWhere((m) => m.key == widget.selectedMode);
      if (index >= 0 && index != _tabController.index) {
        _tabController.animateTo(index);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _panelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SlidingUpPanelWidget(
      panelController: _panelController,
      controlHeight: 83.0,
      anchor: 0.35,
      upperBound: 0.83,
      enableOnTap: true,
      onTap: () {
        if (!mounted) return;
        if (_panelController.status == SlidingUpPanelStatus.expanded) {
          _panelController.collapse();
        } else if (_panelController.status == SlidingUpPanelStatus.collapsed ||
            _panelController.status == SlidingUpPanelStatus.anchored) {
          _panelController.expand();
        }
      },
      // Track panel status changes
      onStatusChanged: (status) {
        setState(() {
          _isPanelExpanded = status == SlidingUpPanelStatus.expanded;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 8.0,
              spreadRadius: 2.0,
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Drag handle (only show when not expanded)
            AnimatedOpacity(
              opacity: _isPanelExpanded ? 0.5 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // Header
            SizedBox(
              height: 56.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      _modes[_tabController.index].icon,
                      color: AppColors.primaryMedium,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _modes[_tabController.index].label,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!_isPanelExpanded) ...[
                      const SizedBox(width: 12),
                      Text(
                        widget.durations[_modes[_tabController.index].key] ??
                            '-',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.secondaryDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // TabBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow:
                    _isPanelExpanded
                        ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor, width: 1),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelPadding: EdgeInsets.zero,
                  dividerHeight: 0,
                  tabs:
                      _modes.map((mode) {
                        final duration = widget.durations[mode.key] ?? '-';
                        final distance = widget.distances[mode.key] ?? '-';

                        return Tab(
                          height: _isPanelExpanded ? 72 : 60,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              constraints: BoxConstraints(
                                minHeight: _isPanelExpanded ? 70 : 58,
                                maxWidth: 120,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(mode.icon, size: 22),
                                  const SizedBox(height: 4),
                                  Text(
                                    duration,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (_isPanelExpanded)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        distance,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(fontSize: 11),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                  labelColor: AppColors.primaryMedium,
                  unselectedLabelColor: theme.textTheme.bodyMedium?.color
                      ?.withOpacity(0.7),
                  indicator: BoxDecoration(
                    color: AppColors.primaryMedium.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryMedium.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // Tab content
            Expanded(
              child: Container(
                color: theme.scaffoldBackgroundColor,
                child: TabBarView(
                  controller: _tabController,
                  physics: const ClampingScrollPhysics(),
                  children:
                      _modes.map((mode) {
                        return DirectionStepsList(
                          distance: widget.distances[mode.key],
                          duration: widget.durations[mode.key],
                          steps: widget.steps,
                          scrollController: ScrollController(),
                          onStepTap: widget.onStepTap,
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
