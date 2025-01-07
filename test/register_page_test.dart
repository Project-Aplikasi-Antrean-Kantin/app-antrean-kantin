import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/views/home/pages/register/register_page.dart';
import 'package:testgetdata/provider/auth_provider.dart';

void main() {
  group('RegisterPage Widget Tests', () {
    testWidgets('should show error when email is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => AuthProvider(),
            child: const RegisterPage(),
          ),
        ),
      );

      // Simulate user interaction
      await tester.tap(find.text('Daftar sekarang'));
      await tester.pump();

      // Verify that the form shows an error for email field
      expect(find.text('Harap isi email terlebih dahulu'), findsOneWidget);
    });

    testWidgets('should show error when password is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => AuthProvider(),
            child: const RegisterPage(),
          ),
        ),
      );

      // Fill other fields except password
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'test@example.com');

      // Attempt to submit form
      await tester.tap(find.text('Daftar sekarang'));
      await tester.pump();

      // Verify that the form shows an error for password field
      expect(find.text('Harap isi password terlebih dahulu'), findsOneWidget);
    });

    testWidgets('should show error when passwords do not match',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => AuthProvider(),
            child: const RegisterPage(),
          ),
        ),
      );

      // Fill fields but make passwords not match
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(find.byType(TextFormField).at(3), 'password321');

      // Attempt to submit form
      await tester.tap(find.text('Daftar sekarang'));
      await tester.pump();

      // Verify that the form shows an error for password mismatch
      expect(find.text('Password tidak cocok'), findsOneWidget);
    });

    testWidgets('should submit form successfully when all inputs are valid',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => AuthProvider(),
            child: const RegisterPage(),
          ),
        ),
      );

      // Fill all fields with valid inputs
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(find.byType(TextFormField).at(3), 'password123');

      // Attempt to submit form
      await tester.tap(find.text('Daftar sekarang'));
      await tester.pump();

      // Verify that form submission happens (if any page navigation or change occurs)
      // Adjust this line to verify the correct behavior based on what happens after submit
      expect(find.text('Daftar Berhasil'),
          findsOneWidget); // This is an example, adjust as needed
    });
  });
}
