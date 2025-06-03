import 'package:busmapcantho/data/model/notification.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NotificationItem extends StatelessWidget {
  final AppNotification? notification;
  final Map<String, String>? localNotification;
  final VoidCallback? onDelete;

  const NotificationItem.server({
    required this.notification,
    this.onDelete,
    super.key,
  }) : localNotification = null;

  const NotificationItem.local({
    required this.localNotification,
    this.onDelete,  // Added onDelete parameter for local notifications
    super.key
  }) : notification = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isServer = notification != null;
    final title = isServer
        ? (notification!.title.isNotEmpty == true ? notification!.title : 'Thông báo')
        : (localNotification!['title'] ?? 'Thông báo');
    final body = isServer
        ? notification!.message
        : (localNotification!['body'] ?? '');
    final time = isServer
        ? DateFormat('dd/MM/yyyy HH:mm').format(notification!.sentAt)
        : DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(localNotification!['time']!));

    // Icon & color by type
    IconData icon = Icons.notifications;
    Color iconBg = AppColors.primaryLight;
    Color cardColor = AppColors.cardBackground;
    if (body.toLowerCase().contains('đến gần') || body.toLowerCase().contains('approaching')) {
      icon = Icons.directions_bus;
      iconBg = AppColors.success;
      cardColor = AppColors.secondaryLightest;
    } else if (body.toLowerCase().contains('đã đến') || body.toLowerCase().contains('arrived')) {
      icon = Icons.location_on;
      iconBg = AppColors.info;
      cardColor = AppColors.info.withOpacity(0.08);
    } else if (body.toLowerCase().contains('rời đi') || body.toLowerCase().contains('departed')) {
      icon = Icons.departure_board;
      iconBg = AppColors.warning;
      cardColor = AppColors.warning.withOpacity(0.08);
    }

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: iconBg.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: iconBg, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  if (body.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
                      child: Text(
                        body,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Text(
                    time,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            // Always show delete icon if onDelete is provided
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                tooltip: 'delete'.tr(),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}