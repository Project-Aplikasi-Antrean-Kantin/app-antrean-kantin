import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/model/fitur_model.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/views/home/pages/login/login_page.dart';
import 'package:testgetdata/views/home/pages/navbar_home.dart';

import 'login_page_test.mocks.dart';

@GenerateMocks([AuthProvider])
void main() {
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
  group('LoginPage Tests', () {
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = MockAuthProvider();
      // Mock the user property to return a valid user
      when(mockAuthProvider.user).thenReturn(UserModel(
        nama: 'Test User',
        token: 'dummy-token',
        permission: ['read beranda'],
        email: 'email@email.com',
        menu: mockMenu,
      ));
    });

    Widget createTestWidget() {
      return ChangeNotifierProvider<AuthProvider>(
        create: (_) => mockAuthProvider,
        child: MaterialApp(
          home: const LoginPage(),
          routes: {
            '/beranda': (context) => const NavbarHome(pageIndex: 0),
          },
        ),
      );
    }

    testWidgets('Displays error message when email or password is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final loginButton = find.text('Masuk');

      await tester.tap(loginButton);
      await tester.pump();

      expect(find.text('Harap isi data terlebih dahulu'), findsOneWidget);
    });

    testWidgets('Calls login method on valid input',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      final loginButton = find.text('Masuk');

      await tester.enterText(emailField, 'adam@gmail.com');
      await tester.enterText(passwordField, 'adam1234');

      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      verify(mockAuthProvider.login('adam@gmail.com', 'adam1234')).called(1);
    });
  });
}
