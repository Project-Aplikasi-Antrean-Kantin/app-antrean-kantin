import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testgetdata/model/tenant_model.dart';
import 'package:testgetdata/views/home/widgets/list_tenant.dart';

void main() {
  group('ListTenant Widget Test', () {
    testWidgets('should display tenants correctly',
        (WidgetTester tester) async {
      // Mock data
      final mockUrl = 'http://165.22.98.55';
      final mockTenants = [
        TenantModel(
          id: 7,
          namaTenant: "Bakso Pak Galih",
          namaKavling: "M16",
          namaGambar: "/images/dummy.jpeg",
          deletedAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: 7,
          jamBuka: "08:00:00",
          jamTutup: "20:00:00",
          gambar: "",
          range: null,
          tenantFoods: [],
        ),
      ];

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListTenant(
              url: mockUrl,
              foundTenant: mockTenants,
            ),
          ),
        ),
      );

      // Verify the list is displayed
      expect(find.text('Bakso Pak Galih'), findsOneWidget);
      expect(find.text('M16'), findsOneWidget);

      // Verify images are displayed
      expect(find.byType(Container), findsWidgets);
    });
  });
}
