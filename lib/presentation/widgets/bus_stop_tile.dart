import 'package:busmapcantho/data/model/bus_stop.dart';
import 'package:flutter/material.dart';

class BusStopTile extends StatelessWidget {
  final BusStop stop;
  final double? distanceInMeters;
  final VoidCallback? onTap;
  final bool selected;
  final Widget? trailing;

  const BusStopTile({
    super.key,
    required this.stop,
    this.distanceInMeters,
    this.onTap,
    this.selected = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Background for selected / normal
    final bgColor = selected ? colors.primary.withAlpha(26) : colors.surface;

    // Title style: primary text color
    final titleStyle = textTheme.titleLarge?.copyWith(color: colors.onSurface);

    // Subtitle style: secondary text color
    final subtitleStyle = textTheme.bodyMedium?.copyWith(
      color: colors.onSurface.withAlpha(150),
    );

    return Container(
      color: bgColor,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          Icons.location_on,
          color: selected ? colors.primary : colors.onSurface,
        ),
        title: Text(stop.name, style: titleStyle),
        subtitle: _buildSubtitle(subtitleStyle),
        trailing: trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget? _buildSubtitle(TextStyle? style) {
    if (distanceInMeters == null) return null;
    final meters = distanceInMeters!;
    final text =
        meters >= 1000
            ? '${(meters / 1000).toStringAsFixed(1)}km'
            : '${meters.toStringAsFixed(0)}m';
    return Text(text, style: style);
  }
}
