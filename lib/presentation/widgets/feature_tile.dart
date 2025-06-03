import 'package:busmapcantho/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../widgets/marquee_text.dart';

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  final Color? iconColor;
  final TextStyle? labelStyle;

  const FeatureTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 100,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.primaryColorLight,
                  width: 1.0,
                  strokeAlign: BorderSide.strokeAlignCenter,
                ),
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.9,
                  colors: [
                    Colors.transparent,
                    AppColors.primaryLightest.withAlpha(50),
                    AppColors.primaryLightest.withAlpha(155),
                  ],
                  stops: const [0.0, 0.6, 1],
                  tileMode: TileMode.clamp,
                ),
              ),
              child: Icon(
                icon,
                size: 25,
                color: iconColor ?? theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: MarqueeText(
                text: label,
                style: labelStyle ??
                    theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                velocity: 30,
                pauseBetweenLoops: const Duration(seconds: 1),
                initialDelay: const Duration(milliseconds: 500),
                gapWidth: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
