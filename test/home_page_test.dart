import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/data/model/fitur_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/provider/auth_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/home_page.dart';
import 'login_page_test.mocks.dart';

// @GenerateMocks([AuthProvider])
void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
  });

  final mockMenu = [
    FiturModel(
      id: 1,
      nama: 'heci',
      kategori: 'makanan',
      urutan: 1,
      aktif: 1,
    ),
    FiturModel(
      id: 1,
      nama: 'es teh',
      kategori: 'minuman',
      urutan: 2,
      aktif: 1,
    ),
    FiturModel(
      id: 1,
      nama: 'kentang goreng',
      kategori: 'snack',
      urutan: 3,
      aktif: 1,
    ),
  ];

  Widget createWidgetUnderTest({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
      ],
      child: MaterialApp(home: child),
    );
  }

  group('HomePage Widget Tests', () {
    testWidgets('Displays progress indicator while loading tenants',
        (tester) async {
      when(mockAuthProvider.user).thenReturn(
        UserModel(
          nama: 'Test User',
          token: 'dummy-token',
          permission: ['read beranda'],
          email: 'email@email.com',
          menu: mockMenu,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(child: const HomePage()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Displays tenant list when data is available', (tester) async {
      when(mockAuthProvider.user).thenReturn(
        UserModel(
          nama: 'Test User',
          token: 'dummy-token',
          permission: ['read beranda'],
          email: 'email@email.com',
          menu: mockMenu,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(child: const HomePage()));
      await tester.pump(); // Trigger FutureBuilder

      expect(find.text("Halo Test User!"), findsOneWidget);
      expect(find.text("Mau makan apa hari ini?"), findsOneWidget);
    });
  });
}
