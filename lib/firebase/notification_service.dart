import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'local_notification_service.dart'; // import di sini

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // perlu jika memakai Firestore/Services lain
  print("Handling background message: ${message.messageId}");
}

class NotificationService {
  static Future<void> initializeAppNotification(BuildContext context) async {
    await Firebase.initializeApp();

    final messaging = FirebaseMessaging.instance;

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Init local notif
    LocalNotificationService.initialize(context);

    // Listen foreground notif
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received in foreground: ${message.notification?.title}');
      LocalNotificationService.showNotification(message);
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
}
