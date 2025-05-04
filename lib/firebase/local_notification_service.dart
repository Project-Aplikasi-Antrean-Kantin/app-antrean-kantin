import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context) {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // custom icon bisa diganti di sini

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    _notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {
      // Aksi jika user klik notifikasi (opsional)
      // Navigator.pushNamed(context, '/somepage');
    });
  }

  // static void showNotification(RemoteMessage message) async {
  //   RemoteNotification? notification = message.notification;
  //   AndroidNotification? android = message.notification?.android;

  //   if (notification != null && android != null) {
  //     const AndroidNotificationDetails androidDetails =
  //         AndroidNotificationDetails(
  //       'fcm_fallback_notification_channel', // ID channel
  //       'Miscellaneous', // Nama channel
  //       importance: Importance.max,
  //       priority: Priority.high,
  //       icon: '@mipmap/ic_launcher',
  //     );

  //     const NotificationDetails platformDetails =
  //         NotificationDetails(android: androidDetails);

  //     await _notificationsPlugin.show(
  //       notification.hashCode,
  //       notification.title,
  //       notification.body,
  //       platformDetails,
  //     );
  //   }
  // }

  // notif by role
  // static void showNotification(RemoteMessage message) async {
  //   RemoteNotification? notification = message.notification;
  //   AndroidNotification? android = message.notification?.android;

  //   if (notification != null && android != null) {
  //     final prefs = await SharedPreferences.getInstance();
  //     final roles = prefs.getStringList('roles') ?? [];

  // String channelId = 'fcm_fallback_notification_channel';
  // String channelName = 'Miscellaneous';
  //     // String? sound;

  //     if (roles.contains('tenant')) {
  //       channelId = 'tenant_channel';
  //       channelName = 'Tenant Notifications';
  //       // sound = 'tenant_notif'; // pastikan ada di /res/raw
  //     } else if (roles.contains('driver')) {
  //       channelId = 'driver_channel';
  //       channelName = 'Driver Notifications';
  //       // sound = 'driver_notif'; // pastikan ada di /res/raw
  //     }

  //     AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  //       channelId,
  //       channelName,
  //       channelDescription: 'Notifikasi berdasarkan role pengguna',
  //       importance: Importance.max,
  //       priority: Priority.high,
  //       // sound:
  //       //     sound != null ? RawResourceAndroidNotificationSound(sound) : null,
  //       icon: '@mipmap/ic_launcher',
  //     );

  //     NotificationDetails platformDetails = NotificationDetails(
  //       android: androidDetails,
  //     );

  //     await _notificationsPlugin.show(
  //       notification.hashCode,
  //       notification.title,
  //       notification.body,
  //       platformDetails,
  //     );
  //   }
  // }
  // static void showNotification(RemoteMessage message) async {
  //   RemoteNotification? notification = message.notification;
  //   AndroidNotification? android = message.notification?.android;

  //   if (notification != null && android != null) {
  //     String? title = notification.title?.toLowerCase();

  //     String channelId = 'fcm_fallback_notification_channel';
  //     String channelName = 'Miscellaneous';
  //     String? sound;

  //     if (title != null && title.contains('pesanan masuk')) {
  //       // Tenant menerima pesanan (suara X)
  //       channelId = 'tenant_order_channel';
  //       channelName = 'Tenant Notifications';
  //       sound = 'tnt_fdlb'; // tenant_order.mp3
  //     } else if (title != null && title.contains('pesanan siap diantar')) {
  //       // Tenant bikin pesanan ke tenant lain (suara U)
  //       channelId = 'driver_channel';
  //       channelName = 'Driver Notifications';
  //       sound = 'drv_fdlb'; // user_order.mp3
  //     }

  //     AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  //       channelId,
  //       channelName,
  //       importance: Importance.max,
  //       priority: Priority.high,
  //       playSound: true,
  //       sound:
  //           sound != null ? RawResourceAndroidNotificationSound(sound) : null,
  //       icon: '@mipmap/ic_launcher',
  //     );

  //     NotificationDetails platformDetails =
  //         NotificationDetails(android: androidDetails);

  //     await _notificationsPlugin.show(
  //       notification.hashCode,
  //       notification.title,
  //       notification.body,
  //       platformDetails,
  //     );
  //   }
  // }
  static void showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      String? title = notification.title?.toLowerCase();

      // Default values
      String channelId = 'fcm_fallback_notification_channel';
      String channelName = 'Miscellaneous';
      String? sound;

      // Cek konten untuk atur channel dan suara
      if (title != null && title.contains('pesanan masuk')) {
        channelId = 'tenant_channel';
        channelName = 'Tenant Notification';
        sound = 'tnt_fdlb'; // tenant_order.mp3 (taruh di res/raw/)
      } else if (title != null && title.contains('pesanan siap diantar')) {
        channelId = 'driver_fdlb_channel';
        channelName = 'Driver Notification';
        sound = 'drv_fdlb'; // driver_order.mp3 (taruh di res/raw/)
      }

      // Set Android notification details
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Notifikasi untuk $channelName',
        importance: Importance.max, // Memastikan suara keras
        priority: Priority.high,
        playSound: sound != null,
        sound:
            sound != null ? RawResourceAndroidNotificationSound(sound) : null,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        visibility: NotificationVisibility.public,
        enableLights: true,
      );

      final platformDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformDetails,
      );
    }
  }
}
