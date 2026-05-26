import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Menyimpan ID notifikasi yang sudah pernah ditampilkan di System Drawer agar tidak duplikat
  // Set ini bertahan selama sesi app, tapi tidak persisten antar restart.
  // Ini disengaja: saat app restart, notif lama tidak ditampilkan lagi (karena sudah pernah dilihat).
  // Notif BARU (ID baru dari backend) akan selalu ditampilkan meskipun sesi masih berjalan.
  static final Set<int> _shownNotificationIds = {};

  // Menyimpan status preferensi notifikasi dari pengguna
  static bool isEnabled = true;

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    try {
      await _localNotificationsPlugin.initialize(settings: initializationSettings);
      debugPrint('NotificationService successfully initialized.');

      // Request permission on Android 13+ (API 33+)
      final androidPlugin = _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint('Notification permission granted: $granted');
      }
    } catch (e) {
      debugPrint('Failed to initialize NotificationService: $e');
    }
  }

  /// Menandai ID notif sebagai sudah ditampilkan tanpa benar-benar menampilkannya.
  /// Digunakan saat app pertama kali load untuk "pre-populate" set ID yang sudah ada
  /// di backend (supaya tidak ditampilkan sebagai notif baru).
  static void markAsShown(int id) {
    _shownNotificationIds.add(id);
  }

  /// Membersihkan semua ID yang tersimpan, sehingga notif berikutnya akan diperlakukan
  /// sebagai "baru". Digunakan saat user melakukan refresh manual.
  static void clearShownIds() {
    _shownNotificationIds.clear();
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!isEnabled) {
      debugPrint('Notification is disabled by user preference, skipping: $title');
      return;
    }
    // Jika sudah pernah ditampilkan, lewati untuk mencegah spamming
    if (_shownNotificationIds.contains(id)) return;
    _shownNotificationIds.add(id);

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'executive_dashboard_channel',
      'Executive Dashboard Notifications',
      channelDescription: 'Real-time notifications for the Executive Dashboard',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    try {
      await _localNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );
      debugPrint('Successfully shown OS system notification: $title');
    } catch (e) {
      debugPrint('Failed to show OS notification: $e');
    }
  }
}
