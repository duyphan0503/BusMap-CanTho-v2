import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class GradientBorderWidget extends StatelessWidget {
  final Color borderColor;
  final double borderWidth;
  final Widget? child;
  final double borderRadius;
  final double gradientWidth;

  const GradientBorderWidget({
    super.key,
    this.borderColor = AppColors.primaryLight,
    this.borderWidth = 2.0,
    this.child,
    this.borderRadius = 8.0,
    this.gradientWidth = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _InwardGradientPainter(
        borderColor: borderColor,
        borderWidth: borderWidth,
        borderRadius: borderRadius,
        gradientWidth: gradientWidth,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        child: Padding(
          padding: EdgeInsets.all(borderWidth),
          child: child,
        ),
      ),
    );
  }
}

class _InwardGradientPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double gradientWidth;

  _InwardGradientPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.gradientWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final RRect outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    // 1. Top
    final Rect topRect = Rect.fromLTWH(0, 0, size.width, gradientWidth);
    _drawInwardGradient(
      canvas,
      topRect,
      Alignment.topCenter,
      Alignment.bottomCenter,
      outer,
      [
        borderColor.withAlpha(217), // 0.85 * 255
        borderColor.withAlpha(102), // 0.4 * 255
        borderColor.withAlpha(0),
      ],
      [0.0, 0.7, 1.0],
    );

    // 2. Bottom
    final Rect bottomRect = Rect.fromLTWH(0, size.height - gradientWidth, size.width, gradientWidth);
    _drawInwardGradient(
      canvas,
      bottomRect,
      Alignment.bottomCenter,
      Alignment.topCenter,
      outer,
      [
        borderColor.withAlpha(217),
        borderColor.withAlpha(102),
        borderColor.withAlpha(0),
      ],
      [0.0, 0.7, 1.0],
    );

    // 3. Left
    final Rect leftRect = Rect.fromLTWH(0, 0, gradientWidth, size.height);
    _drawInwardGradient(
      canvas,
      leftRect,
      Alignment.centerLeft,
      Alignment.centerRight,
      outer,
      [
        borderColor.withAlpha(217),
        borderColor.withAlpha(102),
        borderColor.withAlpha(0),
      ],
      [0.0, 0.7, 1.0],
    );

    // 4. Right
    final Rect rightRect = Rect.fromLTWH(size.width - gradientWidth, 0, gradientWidth, size.height);
    _drawInwardGradient(
      canvas,
      rightRect,
      Alignment.centerRight,
      Alignment.centerLeft,
      outer,
      [
        borderColor.withAlpha(217),
        borderColor.withAlpha(102),
        borderColor.withAlpha(0),
      ],
      [0.0, 0.7, 1.0],
    );
  }

  void _drawInwardGradient(
      Canvas canvas,
      Rect rect,
      Alignment begin,
      Alignment end,
      RRect clipArea,
      List<Color> colors,
      List<double> stops,
      ) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: begin,
        end: end,
        colors: colors,
        stops: stops,
      ).createShader(rect);

    canvas.save();
    canvas.clipRRect(clipArea);
    canvas.drawRect(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}