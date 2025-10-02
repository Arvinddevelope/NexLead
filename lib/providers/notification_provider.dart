import 'package:flutter/material.dart';
import 'package:nextlead/data/models/notification_model.dart';
import 'package:nextlead/data/repositories/notification_repository.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationRepository _notificationRepository;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String _errorMessage = '';

  NotificationProvider(this._notificationRepository);

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  /// Load all notifications for the current user
  Future<void> loadNotifications(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _notifications = await _notificationRepository.getNotifications(userId);
      // Sort by creation date, newest first
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationRepository.markAsRead(notificationId);

      // Update the local notification
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Create a new notification
  Future<void> createNotification(NotificationModel notification) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newNotification =
          await _notificationRepository.createNotification(notification);
      _notifications.insert(
          0, newNotification); // Add to the beginning of the list
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _notificationRepository.deleteNotification(notificationId);

      // Remove from the local list
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      // Mark all unread notifications as read
      for (var notification in _notifications) {
        if (!notification.isRead) {
          await markAsRead(notification.id);
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
