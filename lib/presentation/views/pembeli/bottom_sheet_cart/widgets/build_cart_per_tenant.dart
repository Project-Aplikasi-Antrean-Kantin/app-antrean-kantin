import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/cart_per_tenant.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/bottom_sheet_cart/widgets/header_cart_per_tenant.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_food_page.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/organisms/item_cart/item_cart.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class BuildCartPerTenant extends StatelessWidget {
  final CartPerTenant cartPerTenant;
  final bool fromCartPage;
  final TenantModel tenant;
  final CartProvider cartProvider;
  const BuildCartPerTenant(
      {super.key,
      required this.cartPerTenant,
      required this.fromCartPage,
      required this.tenant,
      required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderCartPerTenant(
              onChecked: cartProvider.selectedCartTenant.any(
                (tenant) => tenant.tenantId == cartPerTenant.tenantId,
              ),
              onCheck: () {
                if (!fromCartPage) {
                  cartProvider.setSelectedCartTenant(cartPerTenant);
                } else {
                  if (cartProvider.totalActiveDriver == 0 &&
                      cartProvider.selectedCartTenant.indexWhere((element) =>
                              element.tenantId == cartPerTenant.tenantId) ==
                          -1) {
                    Fluttertoast.showToast(
                        msg: "Driver tidak tersedia, tidak bisa multi tenant",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        backgroundColor: AppColors.errorColor,
                        textColor: Colors.white);
                  } else {
                    if (tenant.isOnline!) {
                      cartProvider.setSelectedCartTenant(cartPerTenant);
                    } else {
                      Fluttertoast.showToast(
                          msg: "Tenant tutup",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: AppColors.errorColor,
                          textColor: Colors.white);
                    }
                  }
                }
                if (fromCartPage &&
                    cartProvider.selectedCartTenant.length == 0) {
                  {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  }
                }
              },
              tenantName: cartPerTenant.tenantName,
              onTapMore: () async {
                print('cek seh');

                if (tenant.isOnline == false) {
                  Fluttertoast.showToast(
                      msg: 'Tenant tutup',
                      backgroundColor: AppColors.errorColor,
                      textColor: AppColors.backgroundColor);
                  return;
                }
                final internetConnection = await hasInternetAccess();
                if (!internetConnection) {
                  Fluttertoast.showToast(msg: "Tidak ada koneksi internet");
                  return;
                }
                Navigator.push(
                    context,
                    CustomPageBuilder(
                        page: MenuTenant(
                            url:
                                "${MasbroConstants.url}/tenants/${cartPerTenant.tenantId}")));
              }),
          Container(
            padding: const EdgeInsets.only(top: 16, left: 16, bottom: 16),
            child: Column(spacing: 18, children: [
              ...cartPerTenant.cartMenuList!.map((item) {
                print('link gambar ${item.menuGambar}');

                return ItemCart(
                  item: item,
                  onEdit: () {
                    Navigator.push(
                      context,
                      CustomPageBuilder(
                        page: DetailFoodPage(
                          cartItem: item,
                          addNewItem: false,
                          catatan: item.catatan,
                          tenant: tenant,
                        ),
                      ),
                    );
                  },
                  onIncrement: () {
                    cartProvider.addItemToCart(
                      catatan: item.catatan,
                      tenantId: cartPerTenant.tenantId,
                      cart: item,
                    );
                  },
                  onDecrement: () {
                    cartProvider.removeItemFromTenantCart(
                      catatan: item.catatan,
                      cartPerTenant.tenantId,
                      item.menuId,
                      context,
                    );
                  },
                  onCountChanged: (count) {
                    cartProvider.updateItemCount(
                      tenantId: cartPerTenant.tenantId,
                      menuId: item.menuId,
                      count: count,
                    );
                  },
                );
              })
            ]),
          ),
        ],
      ),
    );
  }
}
