import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:godarna/models/notification_model.dart';

class NotificationsService {
  static final NotificationsService _instance = NotificationsService._internal();
  factory NotificationsService() => _instance;
  NotificationsService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> initialize() async {
    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();

    // Listen to Supabase realtime notifications
    _listenToNotifications();
  }

  Future<void> _requestPermissions() async {
    await _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();
    
    await _localNotifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _listenToNotifications() {
    _supabase
        .channel('notifications')
        .on(
          RealtimeListenTypes.postgresChanges,
          ChannelFilter(
            event: 'INSERT',
            schema: 'public',
            table: 'notifications',
          ),
          (payload, [ref]) {
            _handleNewNotification(payload);
          },
        )
        .subscribe();
  }

  void _handleNewNotification(Map<String, dynamic> payload) {
    final notification = NotificationModel.fromJson(payload['new']);
    _showLocalNotification(notification);
  }

  Future<void> _showLocalNotification(NotificationModel notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'godarna_notifications',
      'GoDarna Notifications',
      channelDescription: 'Notifications from GoDarna app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.message,
      platformChannelSpecifics,
      payload: notification.data?.toString(),
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    if (response.payload != null) {
      // Navigate to appropriate screen based on notification data
      print('Notification tapped: ${response.payload}');
    }
  }

  // Send notification to specific user
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'info',
    Map<String, dynamic>? data,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'data': data,
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Send notification to multiple users
  Future<void> sendNotificationToUsers({
    required List<String> userIds,
    required String title,
    required String message,
    String type = 'info',
    Map<String, dynamic>? data,
  }) async {
    try {
      final notifications = userIds.map((userId) => {
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'data': data,
      }).toList();

      await _supabase.from('notifications').insert(notifications);
    } catch (e) {
      print('Error sending notifications: $e');
    }
  }

  // Get user notifications
  Future<List<NotificationModel>> getUserNotifications() async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', _supabase.auth.currentUser?.id)
          .order('created_at', ascending: false);

      return response.map((json) => NotificationModel.fromJson(json)).toList();
  } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', _supabase.auth.currentUser?.id);
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('user_id', _supabase.auth.currentUser?.id)
          .eq('is_read', false);

      return response.count ?? 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', _supabase.auth.currentUser?.id);
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }
}