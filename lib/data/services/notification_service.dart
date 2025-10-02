import 'dart:convert';
import 'package:nextlead/core/config/airtable_config.dart';
import 'package:nextlead/data/models/notification_model.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String _baseUrl = 'https://api.airtable.com/v0';
  static const String _apiKey = AirtableConfig.apiKey;
  static const String _baseId = AirtableConfig.baseId;

  // Use the dedicated Notifications table
  static const String _notificationsTable = AirtableConfig.notificationsTable;

  final http.Client _client = http.Client();

  // Headers for Airtable API requests
  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };

  /// Get all notifications for a user
  Future<List<NotificationModel>> getNotifications(String userId) async {
    // In a real implementation, you would filter by user ID
    // For now, we'll return all records as notifications
    const url = '$_baseUrl/$_baseId/$_notificationsTable';
    final response = await _client.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final records = data['records'] as List<dynamic>;

      return records.map((record) {
        final fields = record['fields'] as Map<String, dynamic>;
        return NotificationModel(
          id: record['id'] as String,
          title: fields['Title'] as String? ?? 'Notification',
          body: fields['Content'] as String? ?? '',
          payload: fields['Payload'] as String?,
          createdAt: DateTime.parse(
              fields['Created'] as String? ?? DateTime.now().toIso8601String()),
          isRead: fields['IsRead'] as bool? ?? false,
        );
      }).toList();
    } else {
      throw Exception('Failed to load notifications: ${response.statusCode}');
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    final url = '$_baseUrl/$_baseId/$_notificationsTable/$notificationId';
    final body = json.encode({
      'fields': {
        'IsRead': true,
      }
    });

    final response =
        await _client.patch(Uri.parse(url), headers: _headers, body: body);

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to mark notification as read: ${response.statusCode}');
    }
  }

  /// Create a new notification
  Future<NotificationModel> createNotification(
      NotificationModel notification) async {
    const url = '$_baseUrl/$_baseId/$_notificationsTable';
    final body = json.encode({
      'fields': {
        'Title': notification.title,
        'Content': notification.body,
        'Payload': notification.payload,
        'Created': notification.createdAt.toIso8601String(),
        'IsRead': notification.isRead,
      }
    });

    final response =
        await _client.post(Uri.parse(url), headers: _headers, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final record = data['records'][0]; // Assuming single record creation
      final fields = record['fields'] as Map<String, dynamic>;

      return NotificationModel(
        id: record['id'] as String,
        title: fields['Title'] as String,
        body: fields['Content'] as String,
        payload: fields['Payload'] as String?,
        createdAt: DateTime.parse(fields['Created'] as String),
        isRead: fields['IsRead'] as bool? ?? false,
      );
    } else {
      throw Exception('Failed to create notification: ${response.statusCode}');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    final url = '$_baseUrl/$_baseId/$_notificationsTable/$notificationId';
    final response = await _client.delete(Uri.parse(url), headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification: ${response.statusCode}');
    }
  }
}
