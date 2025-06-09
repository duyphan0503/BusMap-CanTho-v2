import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/notification_local_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../cubits/notification/notification_cubit.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/notification_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Map<String, String>>> _localFuture;
  NotificationCubit? _cubit;
  bool _hasServerNotifications = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNotifications();
  }

  void _loadNotifications() {
    _localFuture = NotificationLocalService().getNotifications();
    try {
      _cubit = context.read<NotificationCubit>();
      _hasServerNotifications = true;
      _cubit?.loadNotifications();
    } catch (e) {
      _hasServerNotifications = false;
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'notifications'.tr(),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'clearAll'.tr(),
            color: AppColors.error,
            onPressed: () => _showClearConfirmationDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryMedium,
        backgroundColor: AppColors.cardBackground,
        onRefresh: _refreshAll,
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLocalNotifications(theme),
                  _buildServerNotifications(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add this new method to match the style in favorites_screen.dart
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withAlpha(200),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.primaryDark,
        unselectedLabelColor: Colors.white,
        labelStyle: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'localNotifications'.tr()),
          Tab(text: 'serverNotifications'.tr()),
        ],
      ),
    );
  }

  Future<void> _showClearConfirmationDialog(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('clearNotificationsTitle'.tr()),
            content: Text('clearNotificationsConfirm'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text('cancel'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: Text('clear'.tr()),
              ),
            ],
          ),
    );

    if (!mounted) return;

    if (confirmed == true) {
      await NotificationLocalService().clearNotifications();
      if (_hasServerNotifications) {
        await _cubit?.clearAllNotifications();
      }
      setState(() {
        _localFuture = NotificationLocalService().getNotifications();
      });
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('notificationsCleared'.tr())),
      );
    }
  }

  Widget _buildServerNotifications(ThemeData theme) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is NotificationLoaded && state.notifications.isNotEmpty) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: state.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder:
                (context, index) => NotificationItem.server(
                  notification: state.notifications[index],
                  onDelete: () async {
                    await _cubit?.deleteNotification(
                      state.notifications[index].id,
                    );
                    setState(() {});
                  },
                ),
          );
        }
        return _buildEmptyState(theme);
      },
    );
  }

  Widget _buildLocalNotifications(ThemeData theme) {
    return FutureBuilder<List<Map<String, String>>>(
      future: _localFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final localList = snapshot.data ?? [];
        if (localList.isEmpty) {
          return _buildEmptyState(theme);
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: localList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder:
              (context, index) => NotificationItem.local(
                localNotification: localList[index],
                onDelete: () async {
                  // Delete the specific notification at this index
                  await _deleteLocalNotification(index);
                  // Reload notifications
                  setState(() {
                    _localFuture =
                        NotificationLocalService().getNotifications();
                  });
                },
              ),
        );
      },
    );
  }

  // Update this method to use NotificationLocalService instead of direct SharedPreferences
  Future<void> _deleteLocalNotification(int index) async {
    final localNotifications =
        await NotificationLocalService().getNotifications();
    if (localNotifications.isNotEmpty && index < localNotifications.length) {
      final notification = localNotifications[index];
      final time = notification['time'];
      if (time != null) {
        await NotificationLocalService().deleteNotification(time);
        // Reload notifications
        setState(() {
          _localFuture = NotificationLocalService().getNotifications();
        });
      }
    }
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off,
            size: 56,
            color: AppColors.primaryLight,
          ),
          const SizedBox(height: 16),
          Text('noNotifications'.tr(), style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
