import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_food_page.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

Future<void> showBottomSheetCart(BuildContext context,
    List<TenantModel> tenants, Map<String, CartPerTenant> cart) {
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

      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              final isCartBenarBenarKosong = cart.isEmpty ||
                  cart.values.every((tenantCart) =>
                      tenantCart.cartMenuList == null ||
                      tenantCart.cartMenuList!.isEmpty);

              return ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight:
                        screenHeight * 0.6), // BATASI tinggi bottom sheet
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Keranjang',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF0152BB),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.50,
                      ),
                    ),
                    const SizedBox(height: 8),
                    isCartBenarBenarKosong
                        ? Column(
                            spacing: 8,
                            children: [
                              Image(
                                width: MediaQuery.of(context).size.width / 2,
                                image: const AssetImage(
                                    "assets/images/404-Not-Found.png"),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2,
                                child: Text(
                                    'Keranjang kamu kosong nih, yuk pesan menu!',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        color: AppColors.blackColor400)),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Pesan sekarang',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              )
                            ],
                          )
                        : Expanded(
                            child: ListView(
                              children: cartProvider.tenantCarts.entries
                                  .expand((entry) {
                                final tenantId = entry.key;
                                final cartPerTenant = entry.value;
                                final tenant = tenants.firstWhereOrNull(
                                    (t) => t.id == int.parse(tenantId));
                                if (tenant == null) return [Container()];
                                int totalHarga = 0;

                                if (cartPerTenant.cartMenuList!.isEmpty) {
                                  return [
                                    Container(),
                                  ];
                                }

                                return [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.75,
                                              ),
                                              child: Row(
                                                spacing: 8,
                                                children: [
                                                  InkWell(
                                                    onTap: () => {
                                                      cartProvider
                                                          .setSelectedCartTenant(
                                                              cartPerTenant)
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Container(
                                                      width: 24,
                                                      height: 24,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: cartProvider
                                                                      .selectedCartTenant
                                                                      ?.tenantId ==
                                                                  cartPerTenant
                                                              ? AppColors
                                                                  .primaryColor
                                                              : Colors.grey,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Container(
                                                          width: 24 / 2,
                                                          height: 24 / 2,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: cartProvider
                                                                        .selectedCartTenant
                                                                        ?.tenantId ==
                                                                    cartPerTenant
                                                                        .tenantId
                                                                ? AppColors
                                                                    .primaryColor
                                                                : Colors
                                                                    .transparent,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                        '${cartPerTenant.tenantName}',
                                                        softWrap: true,
                                                        overflow: TextOverflow
                                                            .visible,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                print('cek seh');

                                                if (tenant.isOnline == false) {
                                                  Fluttertoast.showToast(
                                                      msg: 'Tenant tutup',
                                                      backgroundColor:
                                                          AppColors.errorColor,
                                                      textColor: AppColors
                                                          .backgroundColor);
                                                  return;
                                                }
                                                final internetConnection =
                                                    await hasInternetAccess();
                                                if (!internetConnection) {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "Tidak ada koneksi internet");
                                                  return;
                                                }
                                                Navigator.push(
                                                    context,
                                                    CustomPageBuilder(
                                                        page: MenuTenant(
                                                            url:
                                                                "${MasbroConstants.url}/tenants/${cartPerTenant.tenantId}")));
                                              },
                                              child: Row(
                                                children: [
                                                  Text('Menu lain',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: AppColors
                                                            .primaryColor,
                                                        fontWeight: semibold,
                                                        fontSize: 14,
                                                      )),
                                                  HugeIcon(
                                                      icon: HugeIcons
                                                          .strokeRoundedArrowRight01,
                                                      color: AppColors
                                                          .primaryColor)
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                              top: 16, left: 16, bottom: 16),
                                          child: Column(spacing: 18, children: [
                                            ...cartPerTenant.cartMenuList!
                                                .map((item) {
                                              print(
                                                  'link gambar ${item.menuGambar}');
                                              totalHarga +=
                                                  item.menuPrice * item.count;
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2,
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          child: ImageByUrl(
                                                            key: Key(
                                                                '${item.menuId}-${item.menuGambar}'),
                                                            url:
                                                                item.menuGambar,
                                                            width: 64,
                                                            height: 64,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                '${item.menuNama}',
                                                                style: GoogleFonts
                                                                    .poppins(
                                                                        fontWeight:
                                                                            semibold),
                                                                softWrap: true,
                                                                overflow:
                                                                    TextOverflow
                                                                        .visible,
                                                              ),
                                                              item.catatan != ''
                                                                  ? Text(
                                                                      '${item.catatan}',
                                                                      style: TextStyle(
                                                                          color: AppColors
                                                                              .blackColor200,
                                                                          fontSize:
                                                                              12),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      maxLines:
                                                                          2,
                                                                    )
                                                                  : Text(
                                                                      'Catatan Kosong',
                                                                      style: TextStyle(
                                                                          color: AppColors
                                                                              .blackColor200,
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                              GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  final internetConnection =
                                                                      await hasInternetAccess();
                                                                  if (!internetConnection) {
                                                                    Fluttertoast
                                                                        .showToast(
                                                                            msg:
                                                                                "Tidak ada koneksi internet");
                                                                    return;
                                                                  }
                                                                  Navigator.push(
                                                                      context,
                                                                      CustomPageBuilder(
                                                                          page: DetailFoodPage(
                                                                              cartItem: item,
                                                                              addNewItem: false,
                                                                              catatan: item.catatan,
                                                                              tenant: tenant)));
                                                                },
                                                                child: Text(
                                                                  'Edit',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          color:
                                                                              AppColors.primaryColor),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Column(
                                                    spacing: 8,
                                                    children: [
                                                      Text(
                                                        '${FormatCurrency.intToStringCurrency(item.menuPrice * item.count)}',
                                                        style: GoogleFonts
                                                            .poppins(),
                                                      ),
                                                      Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                              color: AppColors
                                                                  .primaryColor,
                                                              width: 2,
                                                            ),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              // Tombol -
                                                              GestureDetector(
                                                                onTap: () => cartProvider.removeItemFromTenantCart(
                                                                    catatan: item
                                                                        .catatan,
                                                                    tenantId,
                                                                    item.menuId,
                                                                    context),
                                                                child:
                                                                    Container(
                                                                  width: 36,
                                                                  height: 36,
                                                                  child: Center(
                                                                    child: Text(
                                                                      '-',
                                                                      style: GoogleFonts
                                                                          .poppins(
                                                                        fontSize:
                                                                            18,
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
                                                              SizedBox(
                                                                width:
                                                                    24, // Samakan dengan tombol - dan +
                                                                height: 24,
                                                                child: Center(
                                                                  child:
                                                                      TextFormField(
                                                                    key: ValueKey(
                                                                        item.count),
                                                                    initialValue: item
                                                                        .count
                                                                        .toString(),
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    textAlignVertical:
                                                                        TextAlignVertical
                                                                            .center,
                                                                    style: GoogleFonts
                                                                        .poppins(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: AppColors
                                                                          .primaryColor,
                                                                    ),
                                                                    decoration:
                                                                        const InputDecoration(
                                                                      isDense:
                                                                          true,
                                                                      contentPadding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                      border: InputBorder
                                                                          .none,
                                                                    ),
                                                                    onChanged:
                                                                        (value) {
                                                                      final intCount =
                                                                          int.tryParse(
                                                                              value);
                                                                      if (intCount !=
                                                                              null &&
                                                                          intCount >=
                                                                              0) {
                                                                        cartProvider
                                                                            .updateItemCount(
                                                                          tenantId:
                                                                              tenantId,
                                                                          menuId:
                                                                              item.menuId,
                                                                          count:
                                                                              intCount,
                                                                        );
                                                                      }
                                                                    },
                                                                  ),
                                                                ),
                                                              ),

                                                              // Tombol +
                                                              GestureDetector(
                                                                onTap: () =>
                                                                    cartProvider
                                                                        .addItemToCart(
                                                                  catatan: item
                                                                      .catatan,
                                                                  tenantId:
                                                                      tenantId,
                                                                  cart: item,
                                                                ),
                                                                child:
                                                                    Container(
                                                                  width: 36,
                                                                  height: 36,
                                                                  child: Center(
                                                                    child: Text(
                                                                      '+',
                                                                      style: GoogleFonts
                                                                          .poppins(
                                                                        fontSize:
                                                                            18,
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
                                                          ))
                                                    ],
                                                  )
                                                ],
                                              );
                                            })
                                          ]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ];
                              }).toList(),
                            ),
                          ),
                    buildBottomSheetCartList(context, tenants),
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
    BuildContext context, List<TenantModel> tenants) {
  return Consumer<CartProvider>(builder: (innerContext, cartProvider, child) {
    final listCart = cartProvider.selectedCartTenant?.cartMenuList ?? [];
    print('cek listCart iki loh cak ${listCart}');
    if (listCart.isEmpty) return Container();
    final totalPrice =
        listCart.map((e) => e.menuPrice * e.count).reduce((a, b) => a + b);
    final tenant = tenants.firstWhereOrNull(
      (e) => e.id.toString() == cartProvider.selectedCartTenant?.tenantId,
    );

    if (tenant == null) return Container(); // atau tampilkan error friendly

    return Column(
      children: [
        Divider(
          color: Colors.grey,
          thickness: 1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
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
              GestureDetector(
                onTap: () async {
                  final internetConnection = await hasInternetAccess();
                  if (!internetConnection) {
                    Fluttertoast.showToast(msg: "Tidak ada koneksi internet");
                    return;
                  }
                  if (tenant.isOnline == false) {
                    Fluttertoast.showToast(
                        msg: 'Tenant Tutup',
                        backgroundColor: AppColors.errorColor,
                        textColor: AppColors.whiteColor);
                    return;
                  }
                  ;
                  await cartProvider.setCurrentTenant(tenant, null);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    Navigator.push(
                      context,
                      CustomPageBuilder(
                        page: CartPage(
                          tenantId: cartProvider.selectedCartTenant!.tenantId,
                        ),
                      ),
                    );
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: tenant.isOnline == false
                        ? AppColors.blackColor200
                        : AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tenant.isOnline == false
                        ? "Tenant Tutup"
                        : "Pesan Sekarang",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  });
}
