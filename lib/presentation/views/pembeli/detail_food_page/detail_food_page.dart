import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_food_page/widgets/detail_food_fab.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_food_page/widgets/detail_food_header.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_food_page/widgets/detail_food_info.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_food_page/widgets/detail_food_note.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/molecules/counter/counter.dart';

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
  final _textEditingController = TextEditingController();
  int count = 0;
  bool isInitialized = false;
  int? indexCart;

  // ── Getter food ──────────────────────────────────────────
  TenantFoods get food =>
      widget.food ??
      TenantFoods(
        kategoriId: widget.cartItem?.kategoriId ?? 0,
        isReady: widget.cartItem?.isReady ?? 0,
        id: widget.cartItem?.menuId ?? 0,
        nama: widget.cartItem?.menuNama ?? '',
        harga: widget.cartItem?.menuPrice ?? 0,
        gambar: widget.cartItem?.menuGambar ?? '',
        deskripsi: null,
      );

  // ── Resolve item dari cart ───────────────────────────────
  CartMenuModel? _resolveItem(CartProvider cartProvider) {
    final tenantId = widget.tenant.id.toString();
    final tenantCart = cartProvider.tenantCarts[tenantId];
    final listMenu = tenantCart?.cartMenuList ?? [];

    if (widget.cartItem == null) {
      return widget.addNewItem
          ? (listMenu.isEmpty
              ? cartProvider.cart.firstWhereOrNull(
                  (i) => i.menuId == food.id && i.catatan == widget.catatan)
              : listMenu.firstWhereOrNull(
                  (i) => i.menuId == food.id && i.catatan == widget.catatan))
          : listMenu.firstWhereOrNull((i) => i.menuId == food.id);
    }

    // mode edit — cari index
    indexCart = listMenu.isNotEmpty
        ? listMenu.indexWhere(
            (i) => i.menuId == food.id && i.catatan == widget.catatan)
        : -1;

    return widget.cartItem;
  }

  // ── Init count & catatan sekali saja ────────────────────
  void _initIfNeeded(CartMenuModel? item) {
    if (!isInitialized && item != null) {
      count = item.count;
      _textEditingController.text = item.catatan ?? '';
      isInitialized = true;
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final item = _resolveItem(cartProvider);
    _initIfNeeded(item);

    return WillPopScope(
      onWillPop: () => _onWillPop(context, item),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: MediaQuery.of(context).viewInsets.bottom != 0
            ? null
            : DetailFoodFab(
                food: food,
                tenant: widget.tenant,
                cartItem: widget.cartItem,
                count: count,
                indexCart: indexCart,
                catatan: _textEditingController.text,
              ),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Column(
                spacing: 16,
                children: [
                  DetailFoodHeader(
                    imageUrl: food.gambar.toString(),
                    onClose: () => Navigator.pop(context),
                  ),
                  DetailFoodInfo(food: food),
                  const Divider(thickness: 1, color: Colors.grey),
                  DetailFoodNote(controller: _textEditingController),
                  Center(
                    child: Counter(
                      cartItem: item,
                      count: count,
                      onCountChanged: (v) => setState(() => count = v),
                      onIncrement: () => setState(() => count++),
                      onDecrement: () => setState(() => count--),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context, CartMenuModel? item) async {
    if (count == 0) return true;
    if (item != null &&
        item.count == count &&
        item.catatan == _textEditingController.text) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (_) => CustomAlertDialog(
        title: 'Perubahan Belum Disimpan',
        message: item != null
            ? 'Isi keranjangmu telah diubah. Yakin ingin keluar?'
            : 'Kamu belum menyimpan pesananmu. Keluar sekarang akan menghapus perubahan. Yakin ingin keluar?',
        onOkPressed: () => Navigator.of(context).pop(true),
        onCancelPressed: () => Navigator.of(context).pop(false),
      ),
    );

    return shouldPop ?? false;
  }
}
