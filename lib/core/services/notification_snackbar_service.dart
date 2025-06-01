import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class NotificationSnackBarService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showInfo(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(message, backgroundColor: AppColors.info, icon: Icons.info);
  }

  static void showSuccess(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle,
    );
  }

  static void showError(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(message, backgroundColor: AppColors.error, icon: Icons.error);
  }

  static void _showSnackBar(
    String message, {
    Color backgroundColor = AppColors.primaryDark,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.textOnPrimary),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.textOnPrimary),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}

extension NotificationSnackbarX on BuildContext {
  void showInfoSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    NotificationSnackBarService.showInfo(message, duration: duration);
  }

  void showSuccessSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    NotificationSnackBarService.showSuccess(message, duration: duration);
  }

  void showErrorSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    NotificationSnackBarService.showError(message, duration: duration);
  }
}
