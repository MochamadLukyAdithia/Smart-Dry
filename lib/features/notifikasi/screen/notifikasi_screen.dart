import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_dry/core/theme/AppColor.dart';
import 'package:smart_dry/features/notifikasi/controller/notifikasi_controller.dart';
import 'package:smart_dry/features/notifikasi/model/notifikasi_model.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      // Initialize push notifications
      await NotifikasiController.initializePushNotifications();

      // Set up realtime listener callback
      NotifikasiController.onNotificationUpdate = () {
        if (mounted) {
          setState(() {});
        }
      };

      // Fetch initial notifications
      await NotifikasiController.fetchNotifications();

      // Setup realtime listener
      NotifikasiController.setupRealtimeListener();

      setState(() {
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Gagal memuat notifikasi: $e';
      });
    }
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      isLoading = true;
    });

    try {
      await NotifikasiController.fetchNotifications();
      setState(() {
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Gagal memuat notifikasi: $e';
      });
    }
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
            onPressed: () async {
              Navigator.pop(context);

              try {
                await NotifikasiController.clearAllNotifications();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Semua notifikasi telah dihapus'),
                      backgroundColor: Appcolor.splashColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus notifikasi: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus'),
          ),
        ],
        backgroundColor: Appcolor.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _deleteNotification(
      int index, NotificationModel notification) async {
    try {
      await NotifikasiController.deleteNotification(notification.id_notifikasi);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notifikasi dihapus'),
            backgroundColor: Appcolor.splashColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus notifikasi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    NotifikasiController.dispose();
    super.dispose();
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
          if (NotifikasiController.notifications.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear_all, color: Appcolor.splashColor),
              onPressed: _clearAllNotifications,
              tooltip: 'Hapus Semua',
            ),
          IconButton(
            icon: Icon(Icons.refresh, color: Appcolor.splashColor),
            onPressed: _refreshNotifications,
            tooltip: 'Refresh',
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
                child: Row(
                  children: [
                    Text(
                      "Notifikasi",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Appcolor.splashColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (NotifikasiController.notifications.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Appcolor.splashColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${NotifikasiController.notifications.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isLoading)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Memuat notifikasi...'),
                      ],
                    ),
                  ),
                )
              else if (errorMessage != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshNotifications,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (NotifikasiController.notifications.isEmpty)
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
                        const SizedBox(height: 8),
                        Text(
                          'Notifikasi baru akan muncul di sini',
                          style: TextStyle(
                            fontSize: 14,
                            color: Appcolor.different.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshNotifications,
                    child: ListView.builder(
                      itemCount: NotifikasiController.notifications.length,
                      itemBuilder: (context, index) {
                        final notification =
                            NotifikasiController.notifications[index];
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
                            _deleteNotification(index, notification);
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
                                  color:
                                      NotifikasiController.getNotificationColor(
                                              notification.type)
                                          .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  NotifikasiController.getNotificationIcon(
                                      notification.type),
                                  color:
                                      NotifikasiController.getNotificationColor(
                                          notification.type),
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Appcolor.splashColor,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    notification.pesan,
                                    style: TextStyle(
                                      color: Appcolor.different,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: NotifikasiController
                                                  .getNotificationColor(
                                                      notification.type)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          notification.type
                                              .toString()
                                              .split('.')
                                              .last
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: NotifikasiController
                                                .getNotificationColor(
                                                    notification.type),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        NotifikasiController.formatwaktu(
                                            notification.waktu),
                                        style: TextStyle(
                                          color: Appcolor.different
                                              .withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                _showNotificationDetail(notification);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationDetail(NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: NotifikasiController.getNotificationColor(
                            notification.type)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    NotifikasiController.getNotificationIcon(notification.type),
                    color: NotifikasiController.getNotificationColor(
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: NotifikasiController.getNotificationColor(
                            notification.type)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    notification.type.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      color: NotifikasiController.getNotificationColor(
                          notification.type),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Message
            Text(
              notification.pesan,
              style: TextStyle(
                fontSize: 16,
                color: Appcolor.different,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            // Timestamp
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Appcolor.different.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  NotifikasiController.formatDetailwaktu(notification.waktu),
                  style: TextStyle(
                    fontSize: 14,
                    color: Appcolor.different.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await _deleteNotification(0, notification);
                    },
                    child: const Text('Hapus'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Appcolor.splashColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
