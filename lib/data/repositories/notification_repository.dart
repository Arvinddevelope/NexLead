import 'package:nextlead/data/models/notification_model.dart';
import 'package:nextlead/data/services/notification_service.dart';

class NotificationRepository {
  final NotificationService _notificationService;

  NotificationRepository(this._notificationService);

  /// Get all notifications for a user
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      return await _notificationService.getNotifications(userId);
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Create a new notification
  Future<NotificationModel> createNotification(
      NotificationModel notification) async {
    try {
      return await _notificationService.createNotification(notification);
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }
}
