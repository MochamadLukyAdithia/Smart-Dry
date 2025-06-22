class NotificationModel {
  final int id_notifikasi;
  final int? id_pengeringan;
  final String title;
  final String pesan;
  final DateTime waktu;
  final NotificationType type;

  NotificationModel({
    this.id_pengeringan,
    required this.id_notifikasi,
    required this.title,
    required this.pesan,
    required this.waktu,
    required this.type,
  });

  // Factory constructor to create from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id_notifikasi: json['id_notifikasi'] as int,
      id_pengeringan: json['id_pengeringan'] as int?,
      title: json['title'] as String,
      pesan: json['pesan'] as String,
      waktu: DateTime.parse(json['waktu'] as String),
      type: _getNotificationTypeFromString(json['type'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id_notifikasi': id_notifikasi,
      'id_pengeringan': id_pengeringan,
      'title': title,
      'pesan': pesan,
      'waktu': waktu.toIso8601String(),
      'type': type.toString().split('.').last,
    };
  }

  static NotificationType _getNotificationTypeFromString(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'success':
        return NotificationType.success;
      case 'warning':
        return NotificationType.warning;
      case 'error':
        return NotificationType.error;
      case 'info':
      default:
        return NotificationType.info;
    }
  }
}

enum NotificationType {
  info,
  success,
  warning,
  error,
}