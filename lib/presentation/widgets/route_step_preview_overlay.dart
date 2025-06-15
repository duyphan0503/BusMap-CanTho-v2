import 'package:flutter/material.dart';

import '../../../core/services/osrm_service.dart';

class RouteStepPreviewOverlay extends StatelessWidget {
  final List<Map<String, dynamic>> steps;
  final int currentStepIndex;
  final int totalSteps;
  final VoidCallback onClose;
  final VoidCallback? onPrevStep;
  final VoidCallback? onNextStep;

  const RouteStepPreviewOverlay({
    super.key,
    required this.steps,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.onClose,
    this.onPrevStep,
    this.onNextStep,
  });

  @override
  Widget build(BuildContext context) {
    final step = steps[currentStepIndex];
    final instruction = step['instruction'] ?? '';
    final distance =
        step['distance'] != null
            ? '${(step['distance'] / 1000).toStringAsFixed(2)} km'
            : '';
    final duration =
        step['duration'] != null
            ? '${(step['duration'] / 60).ceil()} phút'
            : '';
    final streetName = step['street_name'] ?? '';

    // Determine icon type and color
    DirectionIconType iconType;
    if (step['icon_type'] is DirectionIconType) {
      iconType = step['icon_type'] as DirectionIconType;
    } else {
      iconType = DirectionIconType.continue_;
    }

    DirectionIconColorType colorType;
    if (step['icon_color'] is DirectionIconColorType) {
      colorType = step['icon_color'] as DirectionIconColorType;
    } else {
      colorType = DirectionIconColorType.default_;
    }

    IconData directionIcon = _getIconForType(iconType);
    Color iconColor = _getColorForType(colorType);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Instruction panel at the top, below appBar
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step indicator with direction icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(directionIcon, color: iconColor, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        instruction,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                if (streetName.isNotEmpty ||
                    distance.isNotEmpty ||
                    duration.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 48, top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (streetName.isNotEmpty)
                          Text(streetName, style: TextStyle(fontSize: 14)),
                        if (distance.isNotEmpty || duration.isNotEmpty)
                          Text(
                            '$distance ${distance.isNotEmpty && duration.isNotEmpty ? '•' : ''} $duration',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Step counter text
                Text(
                  'Bước ${currentStepIndex + 1} / $totalSteps',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Methods to get the appropriate icon and color for direction types
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
