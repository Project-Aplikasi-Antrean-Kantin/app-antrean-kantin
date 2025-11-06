import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  await NotificationService.showNotification(message, true);
  if (message.notification?.title?.contains('Chat') ?? false) {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.reload();

    final unreadMessages = sharedPreferences.getString('unread');

    // Ambil angka terakhir dari title
    final transaksiIdStr = message.notification!.title!.split(' ').last.trim();
    final transaksiId = int.tryParse(transaksiIdStr);

    if (transaksiId == null) {
      return;
    }

    String newUnread;
    if (unreadMessages != null) {
      final List<int> unreadMessagesList = unreadMessages
          .split(',')
          .where((e) => e.trim().isNotEmpty)
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>() // buang null
          .toList();

      if (!unreadMessagesList.contains(transaksiId)) {
        unreadMessagesList.add(transaksiId);
      }

      newUnread = unreadMessagesList.join(',');
    } else {
      newUnread = transaksiId.toString();
    }

    await sharedPreferences.setString('unread', newUnread);
    await sharedPreferences.setString('available_chat', newUnread);
  }

  if (message.notification?.title?.contains('Pesanan Selesai') ?? false) {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.reload();

    final unreadMessages = sharedPreferences.getString('unread');
    final availableChat = sharedPreferences.getString('available_chat');
    sharedPreferences.setBool('user_review', true);
    final transaksiIdStr = message.notification!.body!.split(' ')[1].trim();
    final transaksiId = int.tryParse(transaksiIdStr);

    if (transaksiId == null) {
      return;
    }

    if (unreadMessages != null) {
      final List<int> unreadMessagesList = unreadMessages
          .split(',')
          .where((e) => e.trim().isNotEmpty)
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>() // buang null
          .toList();

      if (!unreadMessagesList.contains(transaksiId)) {
        unreadMessagesList.remove(transaksiId);
      }
      if (unreadMessagesList.isEmpty) {
        sharedPreferences.remove('unread');
        return;
      }
    }
    if (availableChat != null) {
      final List<int> availableChatList = availableChat
          .split(',')
          .where((e) => e.trim().isNotEmpty)
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>() // buang null
          .toList();

      if (!availableChatList.contains(transaksiId)) {
        availableChatList.remove(transaksiId);
      }
      if (availableChatList.isEmpty) {
        sharedPreferences.remove('available_chat');
        return;
      }
    }
  }

  if (message.notification?.title?.contains('Tenant Sibuk') ?? false) {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.reload();
    sharedPreferences.setString("tenant_sibuk", "true");
  }

  if (message.notification?.title?.contains('Tenant sudah tidak sibuk') ??
      false) {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.reload();
    sharedPreferences.remove("tenant_sibuk");
  }

  if (message.notification?.title?.contains('Top-up Berhasil') ?? false) {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.reload();
    sharedPreferences.remove("current_va");
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static AndroidNotificationDetails _getLocalNotificationDetails(
      String channelKey) {
    String sound = 'tnt_fdlb';
    String channelName = 'Fallback Notifications';
    String channelDescription = 'Fallback channel for unsupported devices';

    if (channelKey == 'tenant_channel') {
      sound = 'tnt_fdlb';
      channelName = 'Tenant Notification';
      channelDescription = 'Notifikasi untuk Tenant';
    } else if (channelKey == 'driver_fdlb_channel') {
      sound = 'drv_fdlb';
      channelName = 'Driver Notification';
      channelDescription = 'Notifikasi untuk Driver';
    }

    return AndroidNotificationDetails(
      channelKey,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(sound),
      enableVibration: true,
      enableLights: true,
    );
  }

  static Future<void> initialize() async {
    await Firebase.initializeApp();
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    final androidPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(AndroidNotificationChannel(
        'tenant_channel',
        'Tenant Notification',
        description: 'Notifikasi untuk Tenant',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('tnt_fdlb'),
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ));

      await androidPlugin.createNotificationChannel(AndroidNotificationChannel(
        'driver_fdlb_channel',
        'Driver Notification',
        description: 'Notifikasi untuk Driver',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('drv_fdlb'),
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ));
    }

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

    // Get and print FCM token
    String? fcmToken = await messaging.getToken();

    messaging.onTokenRefresh.listen((newToken) {}).onError((err) {});

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

    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    // Request notification permission for Awesome Notifications
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      log('Foreground message: ${message.data}');
      showNotification(message, false);
    });

    // // Handle notification tap
    // AwesomeNotifications().actionStream.listen((action) {
    //   log('Notification tapped: ${action.payload}');
    // });

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> showNotification(
      RemoteMessage message, bool isBackground) async {
    // Extract title and body from message data
    final data = message.data;
    final String? title = data['title'];
    final String? body = data['body'];
    // final String? channelKey = data['channel_id'];

    // Debug logging

    // Validation: Skip notification if both title and body are empty/null
    if ((title == null || title.trim().isEmpty) &&
        (body == null || body.trim().isEmpty)) {
      return;
    }

    // Use fallback if either title or body is empty
    final String finalTitle = (title != null && title.trim().isNotEmpty)
        ? title.trim()
        : 'Notifikasi';
    final String finalBody =
        (body != null && body.trim().isNotEmpty) ? body.trim() : '';

    // Select channel based on title
    String channelKey = 'fcm_fallback_notification_channel';
    if (finalTitle.toLowerCase().contains('pesanan masuk')) {
      channelKey = 'tenant_channel';
    } else if (finalTitle.toLowerCase().contains('ada pesanan siap diantar')) {
      channelKey = 'driver_fdlb_channel';
    }

    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (isAllowed) {
      if (isBackground) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            wakeUpScreen: true,
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
            channelKey: channelKey,
            // title: finalTitle,
            // body: finalBody,
            payload: Map<String, String>.from(data),
            notificationLayout: NotificationLayout.Default,
            displayOnForeground: true,
            displayOnBackground: true,
          ),
        );
      } else {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            wakeUpScreen: true,
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
      }
    } else {
      // Fallback to flutter_local_notifications
      final androidDetails = _getLocalNotificationDetails(channelKey);
      final platformDetails = NotificationDetails(android: androidDetails);

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        finalTitle,
        finalBody,
        platformDetails,
        payload: finalBody,
      );
    }

    // Show notification using Awesome Notifications

    log('✅ Notification shown successfully');
  }
}
