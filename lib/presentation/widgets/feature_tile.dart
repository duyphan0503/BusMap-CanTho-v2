import 'package:flutter/material.dart';

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  /// Diameter of the icon circle
  final double circleSize;
  /// Max width of each tile (affects wrapping)
  final double maxWidth;
  final Color? circleColor;
  final Color? iconColor;
  final TextStyle? labelStyle;

  const FeatureTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.circleSize = 56,
    this.maxWidth = 80,
    this.circleColor,
    this.iconColor,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon inside a circle
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                color: circleColor ?? theme.colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: circleSize * 0.5,
                color: iconColor ?? theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            // Label below, wraps text
            Text(
              label,
              style: labelStyle ??
                  theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
