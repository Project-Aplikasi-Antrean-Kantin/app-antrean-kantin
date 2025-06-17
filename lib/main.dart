import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/firebase/notification_service.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/coin_provider.dart';
import 'package:testgetdata/presentation/provider/delivery_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/provider/katalog_menu_provider.dart';
import 'package:testgetdata/presentation/provider/order_provider.dart';
import 'package:testgetdata/presentation/provider/tenant_provider.dart';
import 'package:testgetdata/presentation/provider/topup_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/home_page.dart';
import 'package:testgetdata/presentation/views/penjual/kasir_page.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page_as_role.dart';
import 'package:testgetdata/presentation/views/profile/profile_page.dart';
import 'package:testgetdata/presentation/widgets/sukses_order.dart';
import 'package:testgetdata/presentation/views/pembeli/login_page.dart';
import 'package:testgetdata/presentation/views/pengantar/delivery_page.dart';
import 'package:testgetdata/presentation/views/pembeli/register_page.dart';
import 'package:testgetdata/presentation/widgets/splash_screen.dart';
import 'package:testgetdata/presentation/views/penjual/katalog_menu_page.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_tenant.dart';
import 'package:firebase_core/firebase_core.dart';

// // Background messages firebase
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   // await Firebase.initializeApp();

//   print("Handling a background message: ${message.messageId}");
// }

// void main() async {
//   runApp(const MyApp());
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//       // options: DefaultFirebaseOptions.currentPlatform,
//       );
//   final notificationSettings =
//       await FirebaseMessaging.instance.requestPermission(provisional: true);

//   String? token = await FirebaseMessaging.instance.getToken();
//   print(token);
//   FirebaseMessaging.instance.getToken().then((token) {
//     print("Token: $token");
//   });

//   FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
//     // TODO: If necessary send token to application server.

//     // Note: This callback is fired at each app startup and whenever a new
//     // token is generated.
//   }).onError((err) {
//     // Error getting token.
//   });
//   await FirebaseMessaging.instance.setAutoInitEnabled(true);
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   messaging.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );

//   NotificationSettings settings = await messaging.requestPermission(
//     alert: true,
//     announcement: true,
//     badge: true,
//     carPlay: true,
//     criticalAlert: true,
//     provisional: true,
//     sound: true,
//   );

//   print('User granted permission: ${settings.authorizationStatus}');
//   // Foreground messages
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print('Got a message whilst in the foreground!');
//     print('Message data: ${message.data}');

//     if (message.notification != null) {
//       print('Message also contained a notification: ${message.notification}');
//     }
//   });

//   // Background messages
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
// }

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> setupNotificationChannels() async {
  const tenant_channel = AndroidNotificationChannel(
    'tenant_channel',
    'Tenant Notification',
    description: 'Notifikasi untuk tenant',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('tnt_fdlb'),
  );

  const driver_fdlb_channel = AndroidNotificationChannel(
    'driver_fdlb_channel',
    'Driver Notification',
    description: 'Notifikasi untuk driver',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('drv_fdlb'),
  );

  final plugin = FlutterLocalNotificationsPlugin();
  final androidImpl = plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();

  await androidImpl?.createNotificationChannel(tenant_channel);
  await androidImpl?.createNotificationChannel(driver_fdlb_channel);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await setupNotificationChannels();
  await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => KatalogMenuProvider()),
        ChangeNotifierProvider(create: (_) => KasirProvider()),
        ChangeNotifierProvider(create: (_) => CoinProvider()),
        ChangeNotifierProvider(create: (_) => TenantProvider()),
        ChangeNotifierProvider(create: (_) => TopupProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => DeliveryProvider()),
      ],
      child: MaterialApp(
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
        title: 'FoodLab',
        theme: ThemeData(
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        // home: ProfilePage(),
        // initialRoute: '/',
        routes: {
          // '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginPage(),
          '/daftar': (context) => const RegisterPage(),
          '/beranda': (context) => const HomePage(),
          '/pengantaran': (context) => const PerluPengantaran(),
          '/pesanan': (context) => const PesananTenant(),
          '/sukses_order': (context) => const OrderSuccess(),
          '/riwayat': (context) => const RiwayatPageAsRole(),
          '/profile': (context) => const ProfilePage(),
          '/katalog_menu': (context) => const KatalogMenu(),
          '/kasir': (context) => const KasirPage(),
        },
      ),
    );
  }
}
