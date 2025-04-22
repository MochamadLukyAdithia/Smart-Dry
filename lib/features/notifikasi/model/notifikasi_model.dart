
class NotificationModel {
  final int id_notifikasi;
  final int? id_pengeringan;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;

  NotificationModel({
     this.id_pengeringan,
    required this.id_notifikasi,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.type,
  });
}

enum NotificationType {
  info,
  success,
  warning,
  error,
}