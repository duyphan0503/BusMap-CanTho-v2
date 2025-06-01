import 'package:flutter/material.dart';

import 'direction_mode.dart';
import 'direction_steps_list.dart';

class DirectionsBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> steps;
  final Map<String, String> durations;
  final Map<String, String> distances;
  final String selectedMode;
  final ValueChanged<String> onModeChanged;
  final void Function(int stepIndex)? onStepTap; // Thêm callback

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
  final _modes = const [
    DirectionMode('car', Icons.directions_car, 'Car', isDefault: true),
    DirectionMode('walk', Icons.directions_walk, 'Walk'),
    DirectionMode('motorbike', Icons.two_wheeler, 'Motorbike'),
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
    return Align(
      alignment: Alignment.bottomCenter,
      child: DraggableScrollableSheet(
        initialChildSize: 0.3,
        minChildSize: 0.25,
        maxChildSize: 0.5,
        snap: true,
        snapSizes: const [0.3, 0.5],
        builder: (context, scrollController) {
          return _buildBottomSheetContent(context, scrollController);
        },
      ),
    );
  }

  Widget _buildBottomSheetContent(
      BuildContext context,
      ScrollController scrollController,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onVerticalDragUpdate: (details) {
              scrollController.position.moveTo(
                scrollController.position.pixels - details.delta.dy,
                duration: const Duration(milliseconds: 100),
                curve: Curves.ease,
              );
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [_buildDragHandle(), _buildHeader(context)],
            ),
          ),
          _buildTabBar(context),
          _buildTabContent(scrollController),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 2),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Theme.of(context).scaffoldBackgroundColor,
      width: double.infinity,
      child: Text(
        _modes[_tabController.index].label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TabBar(
        controller: _tabController,
        tabs: _modes.asMap().entries.map((entry) {
          final mode = entry.value;
          final duration = widget.durations[mode.key] ?? '-';
          return Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(mode.icon, size: 20),
                const SizedBox(width: 4),
                Text(
                  duration,
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        }).toList(),
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).primaryColor,
        indicatorWeight: 3,
      ),
    );
  }

  Widget _buildTabContent(ScrollController scrollController) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: _modes.asMap().entries.map((entry) {
          final mode = entry.value;
          return DirectionStepsList(
            distance: widget.distances[mode.key],
            duration: widget.durations[mode.key],
            steps: widget.steps,
            scrollController: scrollController,
            onStepTap: widget.onStepTap, // truyền callback
          );
        }).toList(),
      ),
    );
  }
}
