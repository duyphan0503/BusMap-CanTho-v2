import 'package:busmapcantho/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final double elevation;
  final Color? titleColor;
  final Gradient? backgroundGradient;
  final BorderRadius? borderRadius;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.elevation = 0,
    this.titleColor,
    this.backgroundGradient = AppColors.primaryGradient,
    this.borderRadius = const BorderRadius.vertical(bottom: Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTitleColor = titleColor ?? AppColors.textOnPrimary;

    return Container(
      decoration: BoxDecoration(
        gradient: backgroundGradient,
        borderRadius: borderRadius,
      ),
      child: AppBar(
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: effectiveTitleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: leading,
        actions: actions,
        backgroundColor: Colors.transparent,
        elevation: elevation,
        centerTitle: centerTitle,
        iconTheme: theme.appBarTheme.iconTheme?.copyWith(color: AppColors.textOnPrimary),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

