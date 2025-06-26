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
import 'package:testgetdata/presentation/views/pembeli/login_page.dart';
import 'package:testgetdata/presentation/views/pengantar/delivery_page.dart';
import 'package:testgetdata/presentation/views/pembeli/register_page.dart';
import 'package:testgetdata/presentation/widgets/splash_screen.dart';
import 'package:testgetdata/presentation/views/penjual/katalog_menu_page.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_tenant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:testgetdata/presentation/widgets/sukses_order.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        routes: {
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
