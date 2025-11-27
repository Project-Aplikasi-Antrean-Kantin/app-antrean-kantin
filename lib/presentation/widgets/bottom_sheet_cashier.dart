import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/cart_per_tenant.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page.dart';
import 'package:testgetdata/presentation/views/pembeli/checkout_qris.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_food_page.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

Future<void> showBottomSheetCashier(BuildContext context, TenantModel tenant,
    bool isEdit, String? id, bool? fromCashier) {
  return showModalBottomSheet(
    enableDrag: true,
    backgroundColor: AppColors.backgroundColor,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
    ),
    builder: (BuildContext context) {
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;
      final isWidthLargerThanHeight = screenWidth > screenHeight;

      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: isWidthLargerThanHeight
                        ? screenHeight * 1
                        : screenHeight * 0.6), // BATASI tinggi bottom sheet
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kasir',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF0152BB),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.50,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Consumer<CartProvider>(
                            builder: (context, cartProvider, _) {
                          final activeCart = cartProvider.cart;
                          if (activeCart.isEmpty && Navigator.canPop(context)) {
                            // Future.microtask(() {
                            //   if (Navigator.canPop(context)) {
                            //     Navigator.pop(context);
                            //   }
                            // });
                            return const SizedBox(); // return widget kosong biar nggak error
                          }

                          return ListView.separated(
                              separatorBuilder: (context, index) {
                                return SizedBox(height: 12);
                              },
                              shrinkWrap: true,
                              itemCount: activeCart.length + 1,
                              itemBuilder: (context, i) {
                                if (activeCart.length == i) {
                                  return SizedBox(
                                    height: 12,
                                  );
                                }
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 8,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: ImageByUrl(
                                        key: Key(
                                            '${activeCart[i].menuId}-${activeCart[i].menuNama}'),
                                        url: activeCart[i].menuGambar,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            capitalizeFirstLetter(
                                                activeCart[i].menuNama),
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          activeCart[i].catatan != '' &&
                                                  activeCart[i].catatan != null
                                              ? Text(
                                                  '${activeCart[i].catatan}',
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .blackColor200,
                                                      fontSize: 12),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                )
                                              : Text(
                                                  'Catatan Kosong',
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .blackColor200,
                                                      fontSize: 12),
                                                ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  CustomPageBuilder(
                                                      page: DetailFoodPage(
                                                          cartItem:
                                                              activeCart[i],
                                                          addNewItem: true,
                                                          catatan: activeCart[i]
                                                              .catatan,
                                                          tenant: cartProvider
                                                              .currentTenant!)));
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: AppColors.infoColor,
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: Row(
                                                spacing: 8,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  HugeIcon(
                                                      size: 16,
                                                      icon: HugeIcons
                                                          .strokeRoundedEdit02,
                                                      color:
                                                          AppColors.whiteColor),
                                                  Text('Edit',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: AppColors
                                                            .whiteColor,
                                                        fontSize: 12,
                                                      )),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      spacing: 8,
                                      children: [
                                        Text(
                                          FormatCurrency.intToStringCurrency(
                                              activeCart[i].menuPrice *
                                                  activeCart[i].count),
                                          style: GoogleFonts.poppins(
                                            color: AppColors.blackColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: AppColors.primaryColor,
                                              width: 2,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize
                                                .min, // biar pas dengan isi
                                            children: [
                                              // Tombol -
                                              GestureDetector(
                                                onTap: () => cartProvider
                                                    .removeItemFromTenantCart(
                                                        catatan: activeCart[i]
                                                            .catatan,
                                                        tenant.id.toString(),
                                                        activeCart[i].menuId,
                                                        context),
                                                child: Container(
                                                  width: 28,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    // color: AppColors
                                                    //     .backgroundColor,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(10),
                                                      bottomLeft:
                                                          Radius.circular(10),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '-',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColors
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Counter
                                              Container(
                                                width: 28,
                                                height: 32,
                                                alignment: Alignment.center,
                                                // decoration: BoxDecoration(
                                                //   border: Border.symmetric(
                                                //     vertical: BorderSide(
                                                //       color: AppColors
                                                //           .primaryColor,
                                                //       width: 2,
                                                //     ),
                                                //   ),
                                                // ),
                                                child: TextFormField(
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly,
                                                  ],
                                                  key: ValueKey(
                                                      activeCart[i].count),
                                                  initialValue: activeCart[i]
                                                      .count
                                                      .toString(),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  decoration:
                                                      const InputDecoration(
                                                    border: InputBorder.none,
                                                    isDense: true,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                  ),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                                  onChanged: (value) {
                                                    final intCount =
                                                        int.tryParse(value);
                                                    if (intCount != null &&
                                                        intCount >= 0) {
                                                      cartProvider
                                                          .updateItemCount(
                                                        tenantId: tenant.id
                                                            .toString(),
                                                        menuId: activeCart[i]
                                                            .menuId,
                                                        count: intCount,
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),

                                              // Tombol +
                                              GestureDetector(
                                                onTap: () =>
                                                    cartProvider.addItemToCart(
                                                  catatan:
                                                      activeCart[i].catatan,
                                                  tenantId:
                                                      tenant.id.toString(),
                                                  cart: activeCart[i],
                                                ),
                                                child: Container(
                                                  width: 28,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    // color: AppColors
                                                    //     .backgroundColor,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '+',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColors
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ))
                                  ],
                                );
                              });
                        }),
                      ),
                    ),
                    buildBottomSheetCartList(context, isEdit, id, fromCashier),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}

Widget buildBottomSheetCartList(
    BuildContext context, bool isEdit, String? id, bool? fromCashier) {
  return Consumer3<CartProvider, AuthProvider, KasirProvider>(builder:
      (innerContext, cartProvider, authProvider, kasirProvider, child) {
    final listCart = cartProvider.cart;
    if (listCart.isEmpty) return Container();
    final totalPrice =
        listCart.map((e) => e.menuPrice * e.count).reduce((a, b) => a + b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Harga",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                ),
              ),
              Text(
                FormatCurrency.intToStringCurrency(totalPrice),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              )
            ],
          ),
          PrimaryButton(
            width: 120,
            borderRadius: 12,
            isLoading: cartProvider.submittingCashierTransaction,
            onPressed: () async {
              final internetConnection = await hasInternetAccess();
              final data = jsonEncode({
                "menus": cartProvider.cart.map((x) => x.toJson()).toList(),
              });

              if (!internetConnection) {
                Fluttertoast.showToast(msg: "Tidak ada koneksi internet");
                return;
              }
              try {
                if (isEdit) {
                  if (id != null) {
                    await kasirProvider.updateCashierTransaction(
                        context, authProvider.user.token, data, id);
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  }
                } else {
                  final result = await cartProvider.createCashierTransaction(
                      context, authProvider.user.token);
                  kasirProvider.addCashierTransaction(result);
                  if (Navigator.canPop(context) && fromCashier == true) {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                        context,
                        CustomPageBuilder(
                            page: CheckoutQris(
                          cashierTransaction: result,
                        )));
                  }
                }
              } catch (e) {
                Fluttertoast.showToast(msg: e.toString());
              } finally {}
              Fluttertoast.showToast(msg: "Transaksi berhasil dicatat");
            },
            child: Text(
              isEdit ? "Update Transaksi" : "Catat Transaksi",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  });
}
