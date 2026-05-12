import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/tenant_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/bottom_sheet_cart/bottom_sheet_cart.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_cashier.dart';

class FabMenuTenant extends StatelessWidget {
  final String? cashierTransactionId;
  final bool? fromCashier;
  final TenantModel? currentTenant;
  const FabMenuTenant(
      {super.key,
      this.currentTenant,
      this.cashierTransactionId,
      this.fromCashier});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: cartProvider.totalItemCount > 0
          ? SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: FloatingActionButton(
                key: Key('floatingActionButton${cartProvider.totalItemCount}'),
                onPressed: () async {
                  print(
                      "total item: ${cartProvider.currentTenant!.namaTenant}");
                  bool isThereUnavailableMenu =
                      await cartProvider.removeUnavailableMenusFromCart(
                          cartProvider.currentTenant!.id.toString(),
                          currentTenant?.tenantFoods ?? []);
                  final tenantProvider =
                      Provider.of<TenantProvider>(context, listen: false);
                  if (isThereUnavailableMenu) {
                    print(
                        'terdapat menu yang tidak tersedia ${cartProvider.cart}');
                    Fluttertoast.showToast(
                        msg: 'Terdapat menu yang tidak tersedia',
                        backgroundColor: AppColors.errorColor,
                        textColor: Colors.white);
                    isThereUnavailableMenu = false;
                    return;
                  }
                  if (currentTenant != null &&
                      currentTenant!.emailPemilik == authProvider.user.email) {
                    showBottomSheetCashier(
                        context,
                        currentTenant!,
                        (cashierTransactionId != null),
                        cashierTransactionId,
                        fromCashier);
                    return;
                  }
                  if (currentTenant != null &&
                      currentTenant!.isOnline == false) {
                    Fluttertoast.showToast(
                        msg: 'Tenant tutup',
                        backgroundColor: AppColors.errorColor,
                        textColor: Colors.white);
                    return;
                  }
                  showBottomSheetCart(context, tenantProvider.tenants!,
                      cartProvider.tenantCarts, false);
                  // Navigator.push(context, _buildCartPageRoute());
                },
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildCartButtonContent(cartProvider),
              ),
            )
          : null,
    );
  }

  Widget _buildCartButtonContent(CartProvider cartProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const HugeIcon(icon: Iconsax.bag, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              FormatCurrency.intToStringCurrency(cartProvider.deliveryCost),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            cartProvider.totalItemCount >= 2
                ? "${cartProvider.totalItemCount} items"
                : "${cartProvider.totalItemCount} item",
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
