import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/tenant_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';

class DetailFoodPage extends StatefulWidget {
  final TenantFoods? food;
  final TenantModel tenant;
  final String? tenantId;
  final String? catatan;
  final bool addNewItem;
  final CartMenuModel? cartItem;
  const DetailFoodPage(
      {super.key,
      this.food,
      this.tenantId,
      required this.tenant,
      this.catatan,
      required this.addNewItem,
      this.cartItem});

  @override
  State<DetailFoodPage> createState() => _DetailFoodPageState();
}

class _DetailFoodPageState extends State<DetailFoodPage> {
  TenantFoods get food {
    return widget.food ??
        TenantFoods(
          kategoriId: widget.cartItem?.kategoriId ?? 0,
          isReady: widget.cartItem?.isReady ?? 0,
          id: widget.cartItem?.menuId ?? 0,
          nama: widget.cartItem?.menuNama ?? '',
          harga: widget.cartItem?.menuPrice ?? 0,
          gambar: widget.cartItem?.menuGambar ?? '',
          deskripsi: null,
        );
  }

  final _textEditingController = TextEditingController();
  bool isThereItem = false;
  int count = 0;
  Timer? _debounceTimer;
  bool isInitialized = false;
  int? indexCart;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    CartMenuModel? item;
    if (widget.cartItem == null) {
      if (widget.addNewItem) {
        item = cartProvider.cart.firstWhereOrNull(
            (item) => item.menuId == food.id && item.catatan == widget.catatan);
      } else {
        item = cartProvider.cart
            .firstWhereOrNull((item) => item.menuId == food.id);
      }
    } else {
      print('cek doang');
      indexCart = cartProvider.cart.indexWhere(
          (item) => item.menuId == food.id && item.catatan == widget.catatan);
      print('indexCart ${indexCart}');
      item = widget.cartItem;
    }
    if (!isInitialized && item != null) {
      count = item.count;
      _textEditingController.text = item.catatan ?? '';
      isInitialized = true;
    }
    return WillPopScope(
      onWillPop: () async {
        // Jika count masih 0, maka langsung boleh pop
        if (count == 0) return true;

        // Jika tidak ada perubahan dari item yang diedit, juga langsung boleh pop
        if (item != null &&
            item.count == count &&
            item.catatan == _textEditingController.text) return true;

        // Selain itu, munculkan dialog konfirmasi
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => CustomAlertDialog(
            title: 'Perubahan Belum Disimpan',
            message: item != null
                ? "Isi keranjangmu telah diubah. Yakin ingin keluar?"
                : "Kamu belum menyimpan pesananmu. Keluar sekarang akan menghapus perubahan. Yakin ingin keluar?",
            onOkPressed: () => Navigator.of(context).pop(true),
            onCancelPressed: () => Navigator.of(context).pop(false),
          ),
        );

        return shouldPop ?? false; // default ke false kalau user batal
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: MediaQuery.of(context).viewInsets.bottom != 0
            ? Container()
            : _buildFloatingActionButton(context),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Consumer<CartProvider>(builder: (context, cartProvider, _) {
              final item = cartProvider.cart
                  .firstWhereOrNull((item) => item.menuId == food.id);
              isThereItem = item != null;
              return Column(
                spacing: 16,
                children: [
                  Stack(children: [
                    ImageByUrl(
                      url: food.gambar.toString(),
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 3.5,
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          top: 24, left: 16, right: 16, bottom: 16),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.all(16),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCancel01,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    )
                  ]),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 1.75,
                              child: Text('${food.nama}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600)),
                            ),
                            Expanded(
                                child: Text(
                              textAlign: TextAlign.end,
                              FormatCurrency.intToStringCurrency(food.harga),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: AppColors.textColorBlack,
                              ),
                            ))
                          ],
                        ),
                        if (food.deskripsi != null &&
                            food.deskripsi.toString().toLowerCase() != 'null')
                          Text(
                            food.deskripsi.toString(),
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Catatan Untuk Tenant',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                              color: Color(0xFFCDCDCD),
                              borderRadius: BorderRadius.circular(16)),
                          child: Text('Opsional',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      spacing: 4,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primaryColor,
                              width: 1.5,
                            ),
                          ),
                          height: 124,
                          child: TextField(
                            controller: _textEditingController,
                            decoration: const InputDecoration(
                                hintStyle: TextStyle(fontSize: 14),
                                hintText: 'Tambahkan catatan untuk tenant',
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                border: InputBorder.none,
                                counter: SizedBox.shrink()),
                            maxLines: null,
                            maxLength: 200,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              textAlign: TextAlign.end,
                              '${_textEditingController.text.length} / 200 '),
                        ),
                      ],
                    ),
                  ),
                  IntrinsicWidth(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min, // penting agar Row tidak stretch
                        children: [
                          // Tombol -
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (count >= 1) count--;
                                });
                              },
                              child: Ink(
                                width: 48,
                                height: 36,
                                decoration: BoxDecoration(
                                    color: AppColors.backgroundColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    )),
                                child: Center(
                                  child: Text(
                                    '-',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Count
                          Container(
                            decoration: BoxDecoration(
                              border: Border.symmetric(
                                vertical: BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            width: 48,
                            height: 36,
                            alignment: Alignment.center,
                            child: TextFormField(
                              key: ValueKey(count),
                              initialValue: count.toString(),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  count = int.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ),

                          // Tombol +
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  count++;
                                });
                              },
                              child: Ink(
                                width: 48,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundColor,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '+',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 6,
                  )
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Consumer<CartProvider>(builder: (context, cartProvider, _) {
      int totalPrice = 0;
      if (count > 0) {
        totalPrice = food.harga * count;
      }

      // Jika count 0 dan sedang edit item → tampilkan tombol hapus
      if (count == 0 && widget.cartItem != null) {
        return SizedBox(
          width: MediaQuery.of(context).size.width - 32,
          child: FloatingActionButton.extended(
            onPressed: () async {
              await cartProvider.clearItemFromCart(
                widget.tenant.id.toString(),
                indexCart!,
              );
              Navigator.pop(context); // Tutup halaman detail
            },
            backgroundColor: AppColors.errorColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            label: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Text(
                'Hapus Pesanan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      }

      // Jika count 0 dan bukan edit → tidak tampilkan tombol
      if (count == 0) {
        return Container();
      }

      // Jika count > 0 → tampilkan tombol tambah/edit pesanan
      return SizedBox(
        width: MediaQuery.of(context).size.width - 32,
        child: FloatingActionButton.extended(
          onPressed: () {
            final menuGambar = food.gambar;
            final menuNama = food.nama;
            final menuPrice = food.harga;

            if (widget.cartItem != null && indexCart != null) {
              cartProvider.editCartModelToCart(
                cartItem: CartMenuModel(
                  kategoriId: food.kategoriId,
                  isReady: food.isReady,
                  menuId: food.id,
                  menuGambar: menuGambar,
                  menuNama: menuNama,
                  menuPrice: menuPrice,
                  count: count,
                  catatan: _textEditingController.text,
                ),
                tenantId: widget.tenant.id.toString(),
                index: indexCart ?? 0,
              );
            } else {
              cartProvider.addCartModelToCart(
                cartItem: CartMenuModel(
                  kategoriId: food.kategoriId,
                  isReady: food.isReady,
                  menuId: food.id,
                  menuGambar: menuGambar,
                  menuNama: menuNama,
                  menuPrice: menuPrice,
                  count: count,
                  catatan: _textEditingController.text,
                ),
                tenantId: widget.tenant.id.toString(),
              );
            }

            Navigator.pop(context);
          },
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          label: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              spacing: 2,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width / 2,
                  ),
                  child: Text(
                    widget.cartItem != null ? 'Edit Pesanan' : 'Tambah pesanan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(' - ',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
                Text(
                  FormatCurrency.intToStringCoin(totalPrice),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
