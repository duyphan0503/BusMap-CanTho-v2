import 'package:flutter/material.dart';

import '../../core/services/osrm_service.dart';

class DirectionStepsList extends StatelessWidget {
  final List<Map<String, dynamic>> steps;
  final String? distance, duration;
  final ScrollController scrollController;
  final void Function(int stepIndex)? onStepTap;

  const DirectionStepsList({
    super.key,
    required this.steps,
    required this.distance,
    required this.duration,
    required this.scrollController,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryItem(),
          ...steps.asMap().entries.map((entry) {
            final stepIndex = entry.key;
            return Column(
              children: [
                const Divider(height: 1),
                _buildDirectionStep(entry.value, stepIndex),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  duration ?? '-',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '(${distance ?? '-'})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            Text(
              '(Tuyến đường ngắn nhất)',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionStep(Map<String, dynamic> step, int stepIndex) {
    final hasDetails = step['distance'] != null && step['duration'] != null;
    final subtitle =
        hasDetails
            ? '${(step['distance'] / 1000).toStringAsFixed(2)} km • ${(step['duration'] / 60).ceil()} phút'
            : null;

    final String? streetName = step['street_name'];
    final String detailedSubtitle =
        subtitle != null
            ? (streetName != null && streetName.isNotEmpty
                ? '$subtitle • $streetName'
                : subtitle)
            : (streetName ?? '');

    DirectionIconType iconType;
    if (step['icon_type'] is DirectionIconType) {
      iconType = step['icon_type'] as DirectionIconType;
    } else {
      iconType = DirectionIconType.continue_;
    }

    IconData directionIcon = _getIconForType(iconType);

    DirectionIconColorType colorType;
    if (step['icon_color'] is DirectionIconColorType) {
      colorType = step['icon_color'] as DirectionIconColorType;
    } else {
      colorType = DirectionIconColorType.default_;
    }

    Color iconColor = _getColorForType(colorType);

    final exitNumber = step['exit_number'];
    final String? exitInfo =
        exitNumber != null ? 'Lối ra số $exitNumber' : null;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      minVerticalPadding: 6,
      dense: true,
      leading: Icon(directionIcon, color: iconColor),
      title: Text(
        step['instruction'] ?? '',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (detailedSubtitle.isNotEmpty)
            Text(
              detailedSubtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (exitInfo != null)
            Text(
              exitInfo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
        ],
      ),
      trailing:
          step['location'] != null
              ? const Icon(
                Icons.radio_button_checked,
                size: 12,
                color: Colors.red,
              )
              : null,
      onTap: onStepTap != null ? () => onStepTap!(stepIndex) : null,
    );
  }

  IconData _getIconForType(DirectionIconType type) {
    switch (type) {
      case DirectionIconType.turnLeft:
        return Icons.turn_left;
      case DirectionIconType.turnRight:
        return Icons.turn_right;
      case DirectionIconType.turnSlightLeft:
        return Icons.turn_slight_left;
      case DirectionIconType.turnSlightRight:
        return Icons.turn_slight_right;
      case DirectionIconType.straight:
        return Icons.arrow_upward;
      case DirectionIconType.roundabout:
        return Icons.roundabout_left;
      case DirectionIconType.place:
        return Icons.place;
      case DirectionIconType.forkLeft:
        return Icons.fork_left;
      case DirectionIconType.forkRight:
        return Icons.fork_right;
      case DirectionIconType.uTurn:
        return Icons.u_turn_left;
      case DirectionIconType.start:
        return Icons.trip_origin;
      case DirectionIconType.merge:
        return Icons.merge_type;
      case DirectionIconType.exit:
        return Icons.exit_to_app;
      case DirectionIconType.continue_:
        return Icons.arrow_right_alt;
    }
  }

  Color _getColorForType(DirectionIconColorType type) {
    switch (type) {
      case DirectionIconColorType.turn:
        return Colors.blue;
      case DirectionIconColorType.straight:
        return Colors.blue;
      case DirectionIconColorType.special:
        return Colors.purple;
      case DirectionIconColorType.destination:
        return Colors.red;
      case DirectionIconColorType.start:
        return Colors.green;
      case DirectionIconColorType.default_:
        return Colors.black54;
    }
  }
}
