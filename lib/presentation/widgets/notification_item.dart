import 'package:busmapcantho/data/model/notification.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final AppNotification? notification;
  final Map<String, String>? localNotification;
  final VoidCallback? onDelete;

  const NotificationItem.server({
    required this.notification,
    this.onDelete,
    super.key,
  }) : localNotification = null;

  const NotificationItem.local({required this.localNotification, super.key})
    : notification = null,
      onDelete = null;

  @override
  Widget build(BuildContext context) {
    final title = notification?.message ?? localNotification!['title']!;
    final time =
        notification != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(notification!.sentAt)
            : DateFormat(
              'dd/MM/yyyy HH:mm',
            ).format(DateTime.parse(localNotification!['time']!));
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(time, style: const TextStyle(fontSize: 12)),
        trailing:
            onDelete != null
                ? IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'delete'.tr(),
                  onPressed: onDelete,
                )
                : null,
      ),
    );
  }
}
