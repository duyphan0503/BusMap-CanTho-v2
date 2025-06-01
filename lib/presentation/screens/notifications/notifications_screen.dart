import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/notification_local_service.dart';
import '../../../core/services/notification_snackbar_service.dart';
import '../../cubits/notification/notification_cubit.dart';
import '../../widgets/notification_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<Map<String, String>>> _localFuture;
  NotificationCubit? _cubit;
  bool _hasServerNotifications = false;

  @override
  void initState() {
    super.initState();
    _localFuture = NotificationLocalService().getNotifications();
    try {
      _cubit = context.read<NotificationCubit>();
      _hasServerNotifications = true;
      _cubit?.loadNotifications();
    } catch (e) {
      _hasServerNotifications = false;
      debugPrint('NotificationCubit not available: $e');
    }
  }

  Future<void> _refreshAll() async {
    setState(() {
      _localFuture = NotificationLocalService().getNotifications();
    });
    if (_hasServerNotifications) {
      await _cubit?.loadNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('notifications'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'clearAll'.tr(),
            onPressed: () async {
              await NotificationLocalService().clearNotifications();
              if (_hasServerNotifications) {
                await _cubit?.clearAllNotifications();
              }
              setState(() {
                _localFuture = NotificationLocalService().getNotifications();
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: FutureBuilder<List<Map<String, String>>>(
          future: _localFuture,
          builder: (context, localSnap) {
            if (_hasServerNotifications) {
              // Show both local and server notifications if available
              return _buildWithServerNotifications(localSnap);
            } else {
              // Show only local notifications
              return _buildLocalNotificationsOnly(localSnap);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLocalNotificationsOnly(AsyncSnapshot<List<Map<String, String>>> localSnap) {
    if (localSnap.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    final localList = localSnap.data ?? [];

    if (localList.isEmpty) {
      return Center(child: Text('noNotifications'.tr()));
    }

    final children = <Widget>[];

    children.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          'Local Notifications',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );

    children.addAll(
      localList.map(
            (item) => NotificationItem.local(localNotification: item),
      ),
    );

    return ListView(children: children);
  }

  Widget _buildWithServerNotifications(AsyncSnapshot<List<Map<String, String>>> localSnap) {
    return BlocConsumer<NotificationCubit, NotificationState>(
      listener: (context, state) {
        if (state is NotificationError) {
          context.showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        if (state is NotificationLoading && localSnap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final localList = localSnap.data ?? [];
        final serverList = state is NotificationLoaded ? state.notifications : [];
        final children = <Widget>[];

        // Add local notifications section
        if (localList.isNotEmpty) {
          children.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Local Notifications',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          );
          children.addAll(
            localList.map(
                  (item) => NotificationItem.local(localNotification: item),
            ),
          );
        }

        // Add server notifications section
        if (serverList.isNotEmpty) {
          children.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Server Notifications',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          );
          children.addAll(
            serverList.map(
                  (notif) => Dismissible(
                key: Key(notif.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  await _cubit?.deleteNotification(notif.id);
                  return true;
                },
                child: NotificationItem.server(
                  notification: notif,
                  onDelete: () => _cubit?.deleteNotification(notif.id),
                ),
              ),
            ),
          );
        }

        if (children.isEmpty) {
          return Center(child: Text('noNotifications'.tr()));
        }

        return ListView(children: children);
      },
    );
  }
}