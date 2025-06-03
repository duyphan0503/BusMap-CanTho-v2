import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';

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
  final SlidingUpPanelController _panelController = SlidingUpPanelController();
  final _modes = [
    DirectionMode('car', Icons.directions_car, 'car'.tr(), isDefault: true),
    DirectionMode('walk', Icons.directions_walk, 'walk'.tr()),
    DirectionMode('motorbike', Icons.two_wheeler, 'motorbike'.tr()),
  ];

  @override
  void initState() {
    super.initState();
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
    if (_tabController.indexIsChanging) {
      widget.onModeChanged(_modes[_tabController.index].key);
    }
  }

  @override
  void didUpdateWidget(DirectionsBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMode != widget.selectedMode) {
      final index = _modes.indexWhere((m) => m.key == widget.selectedMode);
      if (index >= 0 && index != _tabController.index) {
        _tabController.animateTo(index);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SlidingUpPanelWidget(
      panelController: _panelController,
      controlHeight: 70.0,
      anchor: 0.3,
      upperBound: 0.8,
      enableOnTap: true,
      onTap: () {
        if (!mounted) return; // Prevent calling after dispose
        if (_panelController.status == SlidingUpPanelStatus.expanded) {
          _panelController.collapse();
        } else {
          _panelController.expand();
        }
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: Container(
          decoration: ShapeDecoration(
            color: theme.cardColor,
            shadows: [
              BoxShadow(
                blurRadius: 5.0,
                spreadRadius: 2.0,
                color: const Color(0x11000000),
              ),
            ],
            shape: const RoundedRectangleBorder(),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max, // Sửa từ min thành max để chiếm hết không gian
            children: <Widget>[
              Container(
                color: theme.cardColor,
                alignment: Alignment.center,
                height: 60.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      _modes[_tabController.index].icon,
                      color: theme.primaryColor,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _modes[_tabController.index].label,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              // TabBar
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(28),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerHeight: 2,
                  tabs:
                      _modes.asMap().entries.map((entry) {
                        final mode = entry.value;
                        final duration = widget.durations[mode.key] ?? '-';
                        return Tab(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(mode.icon, size: 20),
                              const SizedBox(height: 2),
                              Text(
                                duration,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  labelColor: theme.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicator: BoxDecoration(
                    color: theme.primaryColor.withAlpha((0.12 * 255).toInt()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorWeight: 2,
                ),
              ),
              // Tab content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                  ),
                  child: _buildTabContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: _modes.asMap().entries.map((entry) {
        final mode = entry.value;
        return DirectionStepsList(
          distance: widget.distances[mode.key],
          duration: widget.durations[mode.key],
          steps: widget.steps,
          scrollController: ScrollController(),
          onStepTap: widget.onStepTap,
        );
      }).toList(),
    );
  }
}
