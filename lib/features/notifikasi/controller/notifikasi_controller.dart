import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_dry/features/notifikasi/model/notifikasi_model.dart';

class NotifikasiController {
  static List<NotificationModel> notifications = [];

  static Future<void> fetchNotifications() async {
    // Simulate loading from database
    await Future.delayed(const Duration(seconds: 1));

    notifications = [
      NotificationModel(
        id_notifikasi: 1,
        title: 'Suhu Tinggi Terdeteksi',
        message:
            'Suhu mesin pengering telah mencapai batas maksimum yang ditentukan (45°C)',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.warning,
      ),
      NotificationModel(
        id_notifikasi: 2,
        title: 'Proses Pengeringan Selesai',
        message:
            'Siklus pengeringan telah selesai. Silakan ambil pakaian Anda dari mesin.',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        type: NotificationType.success,
      ),
      NotificationModel(
        id_notifikasi: 5,
        title: 'Koneksi Terputus',
        message:
            'Koneksi dengan mesin pengering terputus. Periksa koneksi WiFi Anda.',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        type: NotificationType.error,
      ),
      NotificationModel(
        id_notifikasi: 6,
        title: 'Pembaruan Aplikasi',
        message:
            'Versi baru aplikasi SmartDry tersedia. Perbarui sekarang untuk fitur terbaru.',
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
        type: NotificationType.info,
      ),
    ];
  }

  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return DateFormat('dd MMM yyyy').format(timestamp);
    }
  }

  static String formatDetailTimestamp(DateTime timestamp) {
    return DateFormat('dd MMMM yyyy, HH:mm').format(timestamp);
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
        return Colors.blue; // Replace with Appcolor.dayColor if needed
    }
  }
}