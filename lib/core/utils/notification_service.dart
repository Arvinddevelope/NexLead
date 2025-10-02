import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone data
    tz.initializeTimeZones();
    
    // Android initialization settings
    const androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization settings
    const iosInitializationSettings = DarwinInitializationSettings();
    
    // Initialization settings for both platforms
    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    
    // Initialize the plugin
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        onNotificationTap(response.payload);
      },
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'nexlead_channel',
      'NexLead CRM Channel',
      channelDescription: 'Channel for NexLead CRM notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(scheduledTime, tz.local);
    
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'nexlead_channel',
      'NexLead CRM Channel',
      channelDescription: 'Channel for NexLead CRM notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZDate,
      platformChannelSpecifics,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void onNotificationTap(String? payload) {
    // Handle notification tap event
    // This could navigate to a specific screen based on payload
    if (payload != null) {
      // Handle navigation based on payload
      // For example: navigator.pushNamed(payload);
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}