import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/data/provider/auth_provider.dart';
import 'package:testgetdata/data/provider/cart_provider.dart';
import 'package:testgetdata/data/provider/kasir_provider.dart';
import 'package:testgetdata/data/provider/katalog_menu_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/home_page.dart';
import 'package:testgetdata/presentation/views/penjual/kasir_page.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page_as_role.dart';
import 'package:testgetdata/presentation/widgets/sukses_order.dart';
import 'package:testgetdata/presentation/views/pembeli/profile_page.dart';
import 'package:testgetdata/presentation/views/pembeli/login_page.dart';
import 'package:testgetdata/presentation/views/pengantar/pengantaran_page.dart';
import 'package:testgetdata/presentation/views/pembeli/register_page.dart';
import 'package:testgetdata/presentation/widgets/splash_screen.dart';
import 'package:testgetdata/presentation/views/penjual/katalog_menu_page.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_page.dart';
import 'package:testgetdata/presentation/views/penjual/tambah_menu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/firebase_options.dart';

// Background messages firebase
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final notificationSettings =
      await FirebaseMessaging.instance.requestPermission(provisional: true);

  // String? token = await FirebaseMessaging.instance.getToken();
  // print(token);

  FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    // TODO: If necessary send token to application server.

    // Note: This callback is fired at each app startup and whenever a new
    // token is generated.
  }).onError((err) {
    // Error getting token.
  });
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  // Foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  // Background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
      ],
      child: MaterialApp(
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
        title: 'MasBro',
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
          '/tambah_menu': (context) => const TambahMenuPage(),
          '/kasir': (context) => const KasirPage(),
        },
      ),
    );
  }
}
