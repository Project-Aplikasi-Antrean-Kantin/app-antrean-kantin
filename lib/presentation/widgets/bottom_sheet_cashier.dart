import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/checkout_qris.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_food_page/detail_food_page.dart';
import 'package:testgetdata/presentation/widgets/custom_form_field.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/organisms/item_cart/item_cart.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

Future<void> showBottomSheetCashier(BuildContext parentContext,
    TenantModel tenant, bool isEdit, String? id, bool? fromCashier) {
  return showModalBottomSheet(
    enableDrag: true,
    backgroundColor: AppColors.backgroundColor,
    context: parentContext,
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
          key: const Key('bottomSheetCashier'),
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
                            Future.microtask(() {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            });
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
                                final item = activeCart[i];

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
                                      tenantId: tenant.id.toString(),
                                      cart: item,
                                    );
                                  },
                                  onDecrement: () {
                                    cartProvider.removeItemFromTenantCart(
                                      catatan: item.catatan,
                                      tenant.id.toString(),
                                      item.menuId,
                                      context,
                                    );
                                  },
                                  onCountChanged: (count) {
                                    cartProvider.updateItemCount(
                                      tenantId: tenant.id.toString(),
                                      menuId: item.menuId,
                                      count: count,
                                    );
                                  },
                                );
                              });
                        }),
                      ),
                    ),
                    buildBottomSheetCartList(
                        context, isEdit, id, fromCashier, parentContext),
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

Future<String?> showInputNameDialog(BuildContext dialogContext) {
  final controller = TextEditingController();

  return showDialog<String>(
    context: dialogContext,
    barrierDismissible: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.backgroundColor,

            // 🔥 TITLE DENGAN TOMBOL CLOSE
            titlePadding: const EdgeInsets.fromLTRB(24, 16, 8, 0),
            title: Stack(
              children: [
                Center(
                  child: Text(
                    'Nama Pemesan',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: -12,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(ctx); // ❌ close dialog tanpa value
                    },
                  ),
                ),
              ],
            ),

            content: CustomTextFormField(
              withBottomPadding: false,
              hintText: "Masukkan Nama",
              controller: controller,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r"[a-zA-Z\s]"),
                ),
              ],
              onChanged: (_) {
                setState(() {});
              },
            ),
            actions: [
              PrimaryButton(
                borderRadius: 16,
                waitingText: "Isi nama",
                isEnabled: controller.text.trim().isNotEmpty,
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isEmpty) return;
                  Navigator.pop(ctx, name); // ✅ close + return value
                },
                child: Text(
                  'Pesan Sekarang',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget buildBottomSheetCartList(BuildContext context, bool isEdit, String? id,
    bool? fromCashier, BuildContext parentContext) {
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
            key: const Key('submitCashierTransactionButton'),
            width: 120,
            borderRadius: 12,
            isLoading: cartProvider.submittingCashierTransaction,
            onPressed: () async {
              try {
                final namaPemesan = await showInputNameDialog(context);

                if (namaPemesan == null) return;

                final result = await cartProvider.createCashierTransaction(
                  context,
                  authProvider.user.token,
                  namaPemesan, // 👈 PASS KE API
                );

                kasirProvider.addCashierTransaction(result);

                // ============================
                // 3️⃣ TUTUP BOTTOM SHEET
                // ============================
                Navigator.pop(context); // context bottom sheet

                if (fromCashier == true) {
                  Navigator.pushReplacement(
                    parentContext,
                    CustomPageBuilder(
                      page: CheckoutQris(cashierTransaction: result),
                    ),
                  );
                } else {
                  Navigator.push(
                    parentContext,
                    CustomPageBuilder(
                      page: CheckoutQris(cashierTransaction: result),
                    ),
                  );
                }

                Fluttertoast.showToast(msg: "Transaksi berhasil dicatat");
              } catch (e) {
                Fluttertoast.showToast(msg: e.toString());
              }
            },
            child: Text(
              isEdit ? "Update Transaksi" : "Bayar",
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
