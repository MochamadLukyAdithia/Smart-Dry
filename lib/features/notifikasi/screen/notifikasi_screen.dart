import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_dry/core/theme/AppColor.dart';
import 'package:intl/intl.dart';
import 'package:smart_dry/features/notifikasi/model/notifikasi_model.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  bool isLoading = true;
  List<NotificationModel> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    // Simulate loading from database
    await Future.delayed(const Duration(seconds: 1));

    // This would normally be a database fetch
    setState(() {
      notifications = [
        NotificationModel(
          id_notifikasi: 1,
          title: 'Suhu Tinggi Terdeteksi',
          message:
              'Suhu mesin pengering telah mencapai batas maksimum yang ditentukan (45°C)',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
          type: NotificationType.warning,
        ),
        NotificationModel(
          id_notifikasi: 2,
          title: 'Proses Pengeringan Selesai',
          message:
              'Siklus pengeringan telah selesai. Silakan ambil pakaian Anda dari mesin.',
          timestamp: DateTime.now().subtract(const Duration(hours: 8)),
          isRead: true,
          type: NotificationType.success,
        ),
        NotificationModel(
          id_notifikasi: 5,
          title: 'Koneksi Terputus',
          message:
              'Koneksi dengan mesin pengering terputus. Periksa koneksi WiFi Anda.',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          isRead: true,
          type: NotificationType.error,
        ),
        NotificationModel(
          id_notifikasi: 6,
          title: 'Pembaruan Aplikasi',
          message:
              'Versi baru aplikasi SmartDry tersedia. Perbarui sekarang untuk fitur terbaru.',
          timestamp: DateTime.now().subtract(const Duration(days: 4)),
          isRead: true,
          type: NotificationType.info,
        ),
      ];
      isLoading = false;
    });
  }

  void _markAllAsRead() {
    setState(() {
      notifications = notifications.map((notification) {
        return NotificationModel(
          id_notifikasi: notification.id_notifikasi,
          title: notification.title,
          message: notification.message,
          timestamp: notification.timestamp,
          isRead: true,
          type: notification.type,
        );
      }).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Semua notifikasi telah ditandai sebagai dibaca'),
        backgroundColor: Appcolor.splashColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Semua Notifikasi',
          style: TextStyle(
            color: Appcolor.splashColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus semua notifikasi?',
          style: TextStyle(color: Appcolor.different),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: Appcolor.different),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Appcolor.splashColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                notifications.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Semua notifikasi telah dihapus'),
                  backgroundColor: Appcolor.splashColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
        backgroundColor: Appcolor.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolor.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Appcolor.splashColor),
          onPressed: () {
            context.go('/home');
          },
        ),
        actions: [
          if (notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Appcolor.splashColor),
              onSelected: (value) {
                if (value == 'markAsRead') {
                  _markAllAsRead();
                } else if (value == 'clearAll') {
                  _clearAllNotifications();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'markAsRead',
                  child: Text('Tandai semua dibaca'),
                ),
                const PopupMenuItem(
                  value: 'clearAll',
                  child: Text('Hapus semua'),
                ),
              ],
              color: Colors.white,
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 16),
                child: Text(
                  "Notifikasi",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Appcolor.splashColor,
                  ),
                ),
              ),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (notifications.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 80,
                          color: Appcolor.different.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada notifikasi',
                          style: TextStyle(
                            fontSize: 18,
                            color: Appcolor.different,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Dismissible(
                        key: Key(notification.id_notifikasi.toString()),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          setState(() {
                            notifications.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Notifikasi dihapus'),
                              backgroundColor: Appcolor.splashColor,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Appcolor.different.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _getNotificationColor(notification.type)
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getNotificationIcon(notification.type),
                                color: _getNotificationColor(notification.type),
                                size: 24,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: TextStyle(
                                      fontWeight: notification.isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      color: Appcolor.splashColor,
                                    ),
                                  ),
                                ),
                                if (!notification.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Appcolor.splashColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  notification.message,
                                  style: TextStyle(
                                    color: Appcolor.different,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatTimestamp(notification.timestamp),
                                  style: TextStyle(
                                    color: Appcolor.different.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              // Mark as read when tapped
                              if (!notification.isRead) {
                                setState(() {
                                  final index =
                                      notifications.indexOf(notification);
                                  notifications[index] = NotificationModel(
                                    id_notifikasi: notification.id_notifikasi,
                                    title: notification.title,
                                    message: notification.message,
                                    timestamp: notification.timestamp,
                                    isRead: true,
                                    type: notification.type,
                                  );
                                });
                              }

                              // Show notification details
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (context) => Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: _getNotificationColor(
                                                      notification.type)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              _getNotificationIcon(
                                                  notification.type),
                                              color: _getNotificationColor(
                                                  notification.type),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              notification.title,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Appcolor.splashColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        notification.message,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Appcolor.different,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _formatDetailTimestamp(
                                            notification.timestamp),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Appcolor.different
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Appcolor.splashColor,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Tutup'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
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

  String _formatDetailTimestamp(DateTime timestamp) {
    return DateFormat('dd MMMM yyyy, HH:mm').format(timestamp);
  }

  IconData _getNotificationIcon(NotificationType type) {
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

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.info:
      default:
        return Appcolor.dayColor;
    }
  }
}
