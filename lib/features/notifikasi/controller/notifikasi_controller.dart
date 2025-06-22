import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_dry/features/notifikasi/model/notifikasi_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotifikasiController {
  static List<NotificationModel> notifications = [];
  static RealtimeChannel? _channel;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  // Callback untuk update UI
  static VoidCallback? onNotificationUpdate;
  
  // Initialize push notifications
  static Future<void> initializePushNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        print('Notification tapped: ${response.payload}');
      },
    );
    
    // Request notification permissions
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> fetchNotifications() async {
    try {
      final response = await Supabase.instance.client
          .from('Notifikasi')
          .select('*')
          .order('waktu', ascending: false);

      notifications = (response as List)
          .map((data) => NotificationModel.fromJson(data))
          .toList();
      
      print('Fetched ${notifications.length} notifications');
    } catch (e) {
      print('Error fetching notifications: $e');
      notifications = [];
    }
  }

  static void setupRealtimeListener() {
    // Close existing channel if any
    _channel?.unsubscribe();
    
    _channel = Supabase.instance.client
        .channel('notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'Notifikasi',
          callback: (payload) {
            print('New notification received: ${payload.newRecord}');
            _handleNewNotification(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'Notifikasi',
          callback: (payload) {
            print('Notification updated: ${payload.newRecord}');
            _handleUpdateNotification(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'Notifikasi',
          callback: (payload) {
            print('Notification deleted: ${payload.oldRecord}');
            _handleDeleteNotification(payload.oldRecord);
          },
        )
        .subscribe();
  }

  static void _handleNewNotification(Map<String, dynamic> data) {
    try {
      final newNotification = NotificationModel.fromJson(data);
      
      // Add to beginning of list
      notifications.insert(0, newNotification);
      
      // Show push notification
      _showPushNotification(newNotification);
      
      // Trigger UI update
      onNotificationUpdate?.call();
    } catch (e) {
      print('Error handling new notification: $e');
    }
  }

  static void _handleUpdateNotification(Map<String, dynamic> data) {
    try {
      final updatedNotification = NotificationModel.fromJson(data);
      final index = notifications.indexWhere(
        (n) => n.id_notifikasi == updatedNotification.id_notifikasi,
      );
      
      if (index != -1) {
        notifications[index] = updatedNotification;
        onNotificationUpdate?.call();
      }
    } catch (e) {
      print('Error handling updated notification: $e');
    }
  }

  static void _handleDeleteNotification(Map<String, dynamic> data) {
    try {
      final deletedId = data['id_notifikasi'] as int;
      notifications.removeWhere((n) => n.id_notifikasi == deletedId);
      onNotificationUpdate?.call();
    } catch (e) {
      print('Error handling deleted notification: $e');
    }
  }

  static Future<void> _showPushNotification(NotificationModel notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'smart_dry_notifications',
      'Smart Dry Notifications',
      channelDescription: 'Notifications from Smart Dry app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      notification.id_notifikasi,
      notification.title,
      notification.pesan,
      platformChannelSpecifics,
      payload: notification.id_notifikasi.toString(),
    );
  }

  static Future<void> deleteNotification(int id) async {
    try {
      await Supabase.instance.client
          .from('Notifikasi')
          .delete()
          .eq('id_notifikasi', id);
      
      // Remove from local list
      notifications.removeWhere((n) => n.id_notifikasi == id);
      onNotificationUpdate?.call();
    } catch (e) {
      print('Error deleting notification: $e');
      throw e;
    }
  }

  static Future<void> clearAllNotifications() async {
    try {
      // Delete all notifications from database
      await Supabase.instance.client
          .from('Notifikasi')
          .delete()
          .neq('id_notifikasi', 0); // Delete all records
      
      // Clear local list
      notifications.clear();
      onNotificationUpdate?.call();
    } catch (e) {
      print('Error clearing all notifications: $e');
      throw e;
    }
  }

  static void dispose() {
    _channel?.unsubscribe();
    _channel = null;
    onNotificationUpdate = null;
  }

  static String formatwaktu(DateTime waktu) {
    final now = DateTime.now();
    final difference = now.difference(waktu);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return DateFormat('dd MMM yyyy').format(waktu);
    }
  }

  static String formatDetailwaktu(DateTime waktu) {
    return DateFormat('dd MMMM yyyy, HH:mm').format(waktu);
  }

  static IconData getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.warning:
        return Icons.warning_amber;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.info:
      default:
        return Icons.info;
    }
  }

  static Color getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.info:
      default:
        return Colors.blue;
    }
  }
}