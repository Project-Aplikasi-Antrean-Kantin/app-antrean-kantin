import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('[BG Handler] Message received: ${message.data}');

  await Firebase.initializeApp();
  await NotificationService._showNotification(message);
  log('[BG Handler] Notification processed');
}

class NotificationService {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    final messaging = FirebaseMessaging.instance;

    // Request notification permissions
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    log('User granted permission: ${settings.authorizationStatus}');

    // Get and log FCM token
    String? fcmToken = await messaging.getToken();
    log('FCM Token: $fcmToken');

    messaging.onTokenRefresh.listen((newToken) {
      log('FCM Token Refreshed: $newToken');
    }).onError((err) {
      log('Error getting FCM token: $err');
    });

    // Disable foreground notification presentation by Firebase
    await messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    // Initialize Awesome Notifications
    await AwesomeNotifications().initialize(
      null, // Use default icon
      [
        NotificationChannel(
          channelKey: 'fcm_fallback_notification_channel',
          channelName: 'Miscellaneous',
          channelDescription: 'Default notification channel',
          importance: NotificationImportance.Max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          defaultPrivacy: NotificationPrivacy.Public,
        ),
        NotificationChannel(
          channelKey: 'tenant_channel',
          channelName: 'Tenant Notification',
          channelDescription: 'Notifikasi untuk Tenant',
          importance: NotificationImportance.Max,
          playSound: true,
          soundSource: 'resource://raw/tnt_fdlb',
          enableVibration: true,
          enableLights: true,
          defaultPrivacy: NotificationPrivacy.Public,
        ),
        NotificationChannel(
          channelKey: 'driver_fdlb_channel',
          channelName: 'Driver Notification',
          channelDescription: 'Notifikasi untuk Driver',
          importance: NotificationImportance.Max,
          playSound: true,
          soundSource: 'resource://raw/drv_fdlb',
          enableVibration: true,
          enableLights: true,
          defaultPrivacy: NotificationPrivacy.Public,
        ),
      ],
      debug: true,
    );

    // Request notification permission for Awesome Notifications
    await AwesomeNotifications().requestPermissionToSendNotifications();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      log('Foreground message: ${message.data}');
      _showNotification(message);
    });

    // // Handle notification tap
    // AwesomeNotifications().actionStream.listen((action) {
    //   log('Notification tapped: ${action.payload}');
    // });

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    // Extract title and body from message data
    final data = message.data;
    final String? title = data['title'];
    final String? body = data['body'];

    // Debug logging
    log('=== NOTIFICATION DEBUG ===');
    log('Message ID: ${message.messageId}');
    log('Raw data: ${message.data}');
    log('Extracted title: "$title"');
    log('Extracted body: "$body"');
    log('========================');

    // Validation: Skip notification if both title and body are empty/null
    if ((title == null || title.trim().isEmpty) &&
        (body == null || body.trim().isEmpty)) {
      log('❌ Notification cancelled: both title and body are empty');
      return;
    }

    // Use fallback if either title or body is empty
    final String finalTitle = (title != null && title.trim().isNotEmpty)
        ? title.trim()
        : 'Notifikasi';
    final String finalBody =
        (body != null && body.trim().isNotEmpty) ? body.trim() : '';

    log('Final notification - Title: "$finalTitle", Body: "$finalBody"');

    // Select channel based on title
    String channelKey = 'fcm_fallback_notification_channel';
    if (finalTitle.toLowerCase().contains('pesanan masuk')) {
      channelKey = 'tenant_channel';
    } else if (finalTitle.toLowerCase().contains('ada pesanan siap diantar')) {
      channelKey = 'driver_fdlb_channel';
    }

    log('Using channel: $channelKey');

    // Show notification using Awesome Notifications
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: channelKey,
        title: finalTitle,
        body: finalBody,
        payload: Map<String, String>.from(data),
        notificationLayout: NotificationLayout.Default,
        displayOnForeground: true,
        displayOnBackground: true,
      ),
    );

    log('✅ Notification shown successfully');
  }
}
