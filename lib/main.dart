import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'firebase/notification_service.dart';
import 'presentation/provider/auth_provider.dart';
import 'presentation/provider/cart_provider.dart';
import 'presentation/provider/coin_provider.dart';
import 'presentation/provider/delivery_provider.dart';
import 'presentation/provider/history_provider.dart';
import 'presentation/provider/kasir_provider.dart';
import 'presentation/provider/katalog_menu_provider.dart';
import 'presentation/provider/order_provider.dart';
import 'presentation/provider/tenant_provider.dart';
import 'presentation/provider/topup_provider.dart';
import 'presentation/views/pembeli/home_page.dart';
import 'presentation/views/pembeli/login_page.dart';
import 'presentation/views/pembeli/register_page.dart';
import 'presentation/views/pembeli/reset_password_page.dart';
import 'presentation/views/pembeli/riwayat_page_as_role.dart';
import 'presentation/views/penjual/kasir_page.dart';
import 'presentation/views/penjual/katalog_menu_page.dart';
import 'presentation/views/penjual/pesanan_tenant.dart';
import 'presentation/views/pengantar/delivery_page.dart';
import 'presentation/views/profile/profile_page.dart';
import 'presentation/widgets/splash_screen.dart';
import 'presentation/widgets/sukses_order.dart';

final appLinks = AppLinks(); // satu instance saja

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener(); // tak perlu await
  }

  /// Dengarkan deep‑link: initial link + link saat aplikasi hidup
  Future<void> _initDeepLinkListener() async {
    // 1️⃣ link yang mem‑launch aplikasi (cold‑start)
    final initialUri = await appLinks.getInitialLink();
    if (initialUri != null) _handleUri(initialUri);

    // 2️⃣ link yang diterima ketika aplikasi sudah berjalan
    _linkSub = appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (err) => debugPrint('Deep link error: $err'),
    );
  }

  /// Proses URI: ambil token & email, lalu navigasi
  void _handleUri(Uri uri) {
    // contoh path: /reset-password/<token>
    final segments = uri.pathSegments;
    String? token;
    if (segments.length >= 2 && segments[0] == 'reset-password') {
      token = segments[1];
    }

    // query: ?email=...
    final email = uri.queryParameters['email'];

    debugPrint('Deep link  ➜  $uri');
    debugPrint('  token = $token');
    debugPrint('  email = $email');

    if (token != null && email != null) {
      // tunggu navigator siap, lalu ganti seluruh stack
      SchedulerBinding.instance.addPostFrameCallback((_) {
        final ctx =
            navKey.currentContext; // atau gunakan Builder di bawah MaterialApp
        if (ctx != null) {
          Navigator.of(ctx).popUntil((route) => route.isFirst);
          Navigator.of(
            ctx,
          ).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
          Navigator.of(ctx).push(
            MaterialPageRoute(
              builder: (_) => ResetPasswordPage(token: token!, email: email),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

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
        navigatorKey: navKey,
        debugShowCheckedModeBanner: false,
        title: 'FoodLab',
        theme: ThemeData(fontFamily: GoogleFonts.poppins().fontFamily),
        home: const SplashScreen(),
        routes: {
          '/login': (_) => const LoginPage(),
          '/daftar': (_) => const RegisterPage(),
          '/beranda': (_) => const HomePage(),
          '/pengantaran': (_) => const PerluPengantaran(),
          '/pesanan': (_) => const PesananTenant(),
          '/sukses_order': (_) => const OrderSuccess(),
          '/riwayat': (_) => const RiwayatPageAsRole(),
          '/profile': (_) => const ProfilePage(),
          '/katalog_menu': (_) => const KatalogMenu(),
          '/kasir': (_) => const KasirPage(),
        },
      ),
    );
  }
}
