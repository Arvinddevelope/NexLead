import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextlead/core/constants/app_colors.dart';
import 'package:nextlead/core/constants/app_texts.dart';
import 'package:nextlead/data/models/notification_model.dart';
import 'package:nextlead/providers/auth_provider.dart';
import 'package:nextlead/providers/notification_provider.dart';
import 'package:nextlead/routes/app_routes.dart';
import 'package:nextlead/ui/components/bottom_nav_bar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    // Load notifications after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  void _loadNotifications() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      notificationProvider.loadNotifications(authProvider.currentUser!.id);
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;

      // Handle navigation based on index
      switch (index) {
        case 0: // Dashboard
          Navigator.pushNamed(context, AppRoutes.dashboard);
          break;
        case 1: // Leads
          Navigator.pushNamed(context, AppRoutes.leads);
          break;
        case 2: // Tasks
          Navigator.pushNamed(context, AppRoutes.tasks);
          break;
        case 3: // Notes/Notifications
          // Already on notifications screen
          break;
        case 4: // Settings
          Navigator.pushNamed(context, AppRoutes.settings);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              final unreadCount = notificationProvider.unreadCount;
              return unreadCount > 0
                  ? IconButton(
                      onPressed: () {
                        notificationProvider.markAllAsRead();
                      },
                      icon: const Icon(Icons.mark_email_read),
                      tooltip: 'Mark all as read',
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer2<NotificationProvider, AuthProvider>(
        builder: (context, notificationProvider, authProvider, child) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notificationProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(notificationProvider.errorMessage),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (authProvider.currentUser != null) {
                        notificationProvider
                            .loadNotifications(authProvider.currentUser!.id);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final notifications = notificationProvider.notifications;

          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: AppColors.gray400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.gray600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You\'ll see notifications here when they arrive',
                    style: TextStyle(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (authProvider.currentUser != null) {
                await notificationProvider
                    .loadNotifications(authProvider.currentUser!.id);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationTile(
                  notification: notification,
                  onTap: () {
                    // Mark as read when tapped
                    if (!notification.isRead) {
                      notificationProvider.markAsRead(notification.id);
                    }

                    // Handle navigation based on payload if needed
                    if (notification.payload != null) {
                      // For example, navigate to a specific screen
                      // Navigator.pushNamed(context, notification.payload!);
                    }
                  },
                  onDelete: () {
                    // Show confirmation dialog
                    _confirmDelete(
                        context, notificationProvider, notification.id);
                  },
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  void _confirmDelete(BuildContext context, NotificationProvider provider,
      String notificationId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Notification'),
          content:
              const Text('Are you sure you want to delete this notification?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppTexts.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                provider.deleteNotification(notificationId);
              },
              child: const Text(AppTexts.delete),
            ),
          ],
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: notification.isRead
                      ? AppColors.gray400
                      : AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        color: AppColors.gray700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(notification.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              // Delete button
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
