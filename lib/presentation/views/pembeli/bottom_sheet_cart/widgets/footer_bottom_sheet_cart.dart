import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/bottom_sheet_cart/widgets/summary_price.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class FooterBottomSheetCart extends StatelessWidget {
  final List<TenantModel> tenants;

  const FooterBottomSheetCart({super.key, required this.tenants});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (innerContext, cartProvider, child) {
        // gabungkan semua menu dari semua tenant yang ada di selectedCartTenant
        final listCart = cartProvider.selectedCartTenant
            .map((tenantCart) => tenantCart.cartMenuList ?? [])
            .expand((menuList) => menuList)
            .toList();

        if (kDebugMode) print('cek listCart iki loh cak $listCart');

        if (listCart.isEmpty) return const SizedBox.shrink();
        final selectedTenants = tenants.where((tenant) {
          return cartProvider.selectedCartTenant
              .any((cart) => cart.tenantId == tenant.id.toString());
        }).toList();
        final totalPrice = listCart
            .map((e) => e.menuPrice * e.count)
            .fold<int>(0, (a, b) => a + b);

        if (selectedTenants.isEmpty) return const SizedBox.shrink();

        final hasClosedTenant = selectedTenants.any((t) => t.isOnline == false);

        // ambil tenant pertama yang sesuai dengan salah satu tenant di selectedCartTenant

        return Column(
          children: [
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SummaryPrice(totalPrice: totalPrice),
                  PrimaryButton(
                    borderRadius: 16,
                    width: MediaQuery.of(context).size.width / 5,
                    onPressed: () async {
                      final internetConnection = await hasInternetAccess();

                      if (!internetConnection) {
                        Fluttertoast.showToast(
                            msg: "Tidak ada koneksi internet");
                        return;
                      }

                      if (hasClosedTenant) {
                        Fluttertoast.showToast(
                          msg: 'Tenant Tutup',
                          backgroundColor: AppColors.errorColor,
                          textColor: AppColors.whiteColor,
                        );
                        return;
                      }
                      if (cartProvider.totalActiveDriver == 0 &&
                          cartProvider.selectedCartTenant.length > 2) {
                        Fluttertoast.showToast(
                          msg:
                              'Driver tidak tersedia, Mullti tenant hanya mendukung pesan antar',
                          backgroundColor: AppColors.errorColor,
                          textColor: AppColors.whiteColor,
                        );
                        return;
                      }

                      // arahkan ke halaman CartPage tenant terkait
                      Future.delayed(const Duration(milliseconds: 300), () {
                        Navigator.push(
                          context,
                          CustomPageBuilder(
                            page: CartPage(
                              tenantId: selectedTenants.first.id.toString(),
                            ),
                          ),
                        );
                      });
                    },
                    child: Text(
                      "Pesan Sekarang",
                      style: GoogleFonts.poppins(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
