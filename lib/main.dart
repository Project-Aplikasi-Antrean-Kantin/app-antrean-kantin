import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/components/sukses_order.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/provider/cart_provider.dart';
import 'package:testgetdata/provider/katalog_menu_provider.dart';
import 'package:testgetdata/views/home/history_page.dart';
import 'package:testgetdata/views/home/home_page.dart';
import 'package:testgetdata/views/home/profile_page.dart';
import 'package:testgetdata/views/login.dart';
import 'package:testgetdata/views/masbro/pengantaran_page.dart';
import 'package:testgetdata/views/register_page.dart';
import 'package:testgetdata/views/splash_screen.dart';
import 'package:testgetdata/views/tenant/pages/pesanan_page.dart';
import 'package:testgetdata/views/tenant/pages/katalog_menu_page.dart';
import 'package:testgetdata/views/tenant/tambah_menu.dart';
import 'package:testgetdata/views/test_riwayat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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

  String? token = await FirebaseMessaging.instance.getToken();
  print(token);

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
          '/sukses_order': (context) => const SuksesOrder(),
          '/riwayat': (context) => const RiwayatPage(),
          '/profile': (context) => const ProfilePage(),
          '/katalog_menu': (context) => const KatalogMenu(),
          '/tambah_menu': (context) => const TambahMenuPage(),
        },
      ),
    );
  }
}

// home: Consumer<AuthProvider>(
        //   builder: (context, provider, child) {
        //     return const LoginPage();

        //     // return FutureBuilder<String>(
        //     //   future: provider.user.token,
        //     //   builder: (context, snapshot) {
        //     //     return HomePage();
        //     //     // if (snapshot.hasData) {
        //     //     //   print(snapshot.data!);
        //     //     //   if (snapshot.data!.isEmpty)
        //     //     //     return Login();
        //     //     //   else if (snapshot.data! == 'Dosen') {
        //     //     //     return HomePage();
        //     //     //   } else {
        //     //     //     // massbro
        //     //     //     return Masbro();
        //     //     //   }
        //     //     // } else {
        //     //     //   // halaman masbro
        //     //     //   return Login();
        //     //     // }
        //     //   },
        //     // );
        //   },
        // ),

// import 'package:flutter/material.dart';
// import 'package:testgetdata/views/masbro/pengantaran.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       // title: 'Menu Page Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       // home: PerluPengantaran(),
//       home: PerluPengantaran(),
//     );
//   }
// }
