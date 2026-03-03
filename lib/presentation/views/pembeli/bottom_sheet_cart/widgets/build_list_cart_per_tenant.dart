import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/bottom_sheet_cart/widgets/build_cart_per_tenant.dart';

class BuildListCartPerTenant extends StatelessWidget {
  final bool fromCartPage;
  final List<TenantModel> tenants;
  final CartProvider cartProvider;
  const BuildListCartPerTenant(
      {super.key,
      required this.fromCartPage,
      required this.tenants,
      required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: cartProvider.tenantCarts.entries.expand((entry) {
          final tenantId = entry.key;
          final cartPerTenant = entry.value;

          final tenant =
              tenants.firstWhereOrNull((t) => t.id == int.parse(tenantId));
          print(
              "tenant: $tenant, cartProvider.tenantCarts: ${cartProvider.tenantCarts}");
          if (tenant == null) return [Container()];

          if (cartPerTenant.cartMenuList!.isEmpty) {
            return [
              Container(),
            ];
          }

          return [
            BuildCartPerTenant(
                cartPerTenant: cartPerTenant,
                fromCartPage: fromCartPage,
                tenant: tenant,
                cartProvider: cartProvider)
          ];
        }).toList(),
      ),
    );
  }
}
