import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService._initializeNotificationChannels();
  await NotificationService._showNotification(message);
  print("Background message: ${message.messageId}");
  print("Notification payload: ${message.data}");
  log("TEKO BG");
}

class NotificationService {
  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static const _defaultChannel = AndroidNotificationChannel(
    'fcm_fallback_notification_channel',
    'Miscellaneous',
    description: 'Default notification channel',
    importance: Importance.high,
    playSound: true,
  );

  static const _tenantChannel = AndroidNotificationChannel(
    'tenant_channel',
    'Tenant Notification',
    description: 'Notifikasi untuk Tenant',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('tnt_fdlb'),
  );

  static const _driverChannel = AndroidNotificationChannel(
    'driver_fdlb_channel',
    'Driver Notification',
    description: 'Notifikasi untuk Driver',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('drv_fdlb'),
  );

  static Future<void> _initializeNotificationChannels() async {
    final androidImpl =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(_defaultChannel);
    await androidImpl?.createNotificationChannel(_tenantChannel);
    await androidImpl?.createNotificationChannel(_driverChannel);
    print("Notification channels initialized");
  }

  static Future<void> initialize() async {
    await Firebase.initializeApp();
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    String? fcmToken = await messaging.getToken();
    print('FCM Token: $fcmToken');

    messaging.onTokenRefresh.listen((newToken) {
      print('FCM Token Refreshed: $newToken');
    }).onError((err) {
      print('Error getting FCM token: $err');
    });

    await messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        print('Notification tapped: ${response.payload}');
      },
    );

    await _initializeNotificationChannels();

    FirebaseMessaging.onMessage.listen((message) {
      print('Foreground message: ${message.data}');
      _showNotification(message);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // static Future<void> _showNotification(RemoteMessage message) async {
  //   // Ambil title dan body dari data, bukan dari message.notification
  //   final data = message.data;
  //   final String? title = data['title'] ?? 'Notifikasi';
  //   final String? body = data['body'] ?? '';

  //   // Pilih channel berdasarkan title
  //   AndroidNotificationChannel channel = _defaultChannel;
  //   if (title != null && title.toLowerCase().contains('pesanan masuk')) {
  //     channel = _tenantChannel;
  //   } else if (title != null &&
  //       title.toLowerCase().contains('ada pesanan siap diantar')) {
  //     channel = _driverChannel;
  //   }

  //   print(
  //       "Showing notification with channel: ${channel.id}, sound: ${channel.sound}");

  //   final androidDetails = AndroidNotificationDetails(
  //     channel.id,
  //     channel.name,
  //     channelDescription: channel.description,
  //     importance: channel.importance,
  //     priority: Priority.max,
  //     playSound: channel.playSound,
  //     sound: channel.sound,
  //     icon: '@mipmap/ic_launcher',
  //     enableVibration: true,
  //     visibility: NotificationVisibility.public,
  //     enableLights: true,
  //   );

  //   final platformDetails = NotificationDetails(android: androidDetails);

  //   await _notificationsPlugin.show(
  //     title.hashCode ^ body.hashCode,
  //     title,
  //     body,
  //     platformDetails,
  //     payload: data.toString(),
  //   );
  // }
  static Future<void> _showNotification(RemoteMessage message) async {
    // Ambil title dan body dari data saja
    final data = message.data;
    final String? title = data['title'];
    final String? body = data['body'];

    // Debug logging
    print('=== NOTIFICATION DEBUG ===');
    print('Message ID: ${message.messageId}');
    print('Raw data: ${message.data}');
    print('Extracted title: "$title"');
    print('Extracted body: "$body"');
    print('========================');

    // VALIDASI: Jangan tampilkan notifikasi jika title dan body kosong/null
    if ((title == null || title.trim().isEmpty) &&
        (body == null || body.trim().isEmpty)) {
      print('❌ Notification cancelled: both title and body are empty');
      return;
    }

    // Gunakan fallback hanya jika salah satu kosong
    final String finalTitle = (title != null && title.trim().isNotEmpty)
        ? title.trim()
        : 'Notifikasi';
    final String finalBody =
        (body != null && body.trim().isNotEmpty) ? body.trim() : '';

    print('Final notification - Title: "$finalTitle", Body: "$finalBody"');

    // Pilih channel berdasarkan title
    AndroidNotificationChannel channel = _defaultChannel;
    if (finalTitle.toLowerCase().contains('pesanan masuk')) {
      channel = _tenantChannel;
    } else if (finalTitle.toLowerCase().contains('ada pesanan siap diantar')) {
      channel = _driverChannel;
    }

    print("Using channel: ${channel.id}, sound: ${channel.sound}");

    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: Priority.max,
      playSound: channel.playSound,
      sound: channel.sound,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      visibility: NotificationVisibility.public,
      enableLights: true,
    );

    final platformDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      finalTitle.hashCode ^ finalBody.hashCode,
      finalTitle,
      finalBody,
      platformDetails,
      payload: data.toString(),
    );

    print('✅ Notification shown successfully');
  }
}
