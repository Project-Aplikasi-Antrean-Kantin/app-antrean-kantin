import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/local/cart_local_data_source.dart';
import 'package:testgetdata/data/model/cart_per_tenant.dart';
import 'package:testgetdata/data/model/cashback.dart';
import 'package:testgetdata/data/model/cashier_transaction.dart';
import 'package:testgetdata/data/model/order_model.dart';
import 'package:testgetdata/data/model/settings_model.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/data/model/voucher_model.dart';
import 'package:testgetdata/data/remote/public_remote_data_source.dart';
import 'package:testgetdata/data/remote/transaction_remote_data_source.dart';
import 'package:testgetdata/data/model/ruangan_model.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';

/// A provider class responsible for managing the cart functionality.
class CartProvider extends ChangeNotifier {
  // Order details
  int totalPrice = 0;
  int _totalActiveDriver = 0;

  int get totalActiveDriver => _totalActiveDriver;
  bool? _isThereActiveDriver;
  bool get isThereActiveDriver => _isThereActiveDriver ?? false;
  bool isFetchingActiveDriver = false;
  int get totalItemCount =>
      _cartMenu.fold<int>(0, (sum, item) => sum + item.count);

  // Delivery details
  int get deliveryCost =>
      _cartMenu.fold(0, (sum, item) => sum + (item.menuPrice * item.count));
  // int deliveryCostPerItem = 2000;
  // int isDelivery = 0; // 0: Pickup, 1: Delivery
  int? roomId;

  // Fees and payment
  // int serviceFee = 1000;
  String? paymentMethod = 'koin';

  // UI state
  bool isCartVisible = false;
  bool isLoading = false;
  bool isFetchingVoucher = false;
  bool isClaimingCashback = false;
  bool isFetchCashback = false;
  bool transactionCompleted = false;
  bool submittingCashierTransaction = false;
  bool orderSuccessful = false;
  Map<String, CartPerTenant> _tenantCarts = {};
  Map<String, CartPerTenant> get tenantCarts => _tenantCarts;

  TenantModel? _currentTenant;
  TenantModel? get currentTenant => _currentTenant;
  CartPerTenant? selectedCartTenant;
  CartPerTenant get cartTenant => selectedCartTenant!;

  // A private list to store the items in the cart.
  List<CartMenuModel> _cartMenu = <CartMenuModel>[];

  // A public getter to access the list of cart items.
  List<CartMenuModel> get cart => _cartMenu;

  // A public list to store available rooms.
  List<Ruangan> listRuangan = [];

  int _selectedDeliveryOption = 1;
  int _priority = 0;

  int get selectedDeliveryOption => _selectedDeliveryOption;
  int get priority => _priority;

  List<SettingsModel> settings = [];
  List<Voucher> listVoucher = [];
  List<Cashback> listCashback = [];
  Voucher? selectedVoucher;
  Voucher? recommendedVoucher;
  Cashback? recommendedCashback;
  int biayaExtra = 0;
  int ongkir = 0;
  int biayaLayanan = 0;
  String catatanLokasi = '';
  String jumlahItem = '0';

  void setSelectedCartTenant(CartPerTenant cart) {
    selectedCartTenant = cart;
    notifyListeners();
  }

  Future<void> getOngkir(String token, int ongkosKirim) async {
    print("ongkirKirim $ongkosKirim");

    try {
      // Ambil data dari PublicRemoteDataSource
      settings = await PublicRemoteDataSource().getSettings();
      biayaExtra = int.parse(settings
          .firstWhere((setting) => setting.nama == 'biaya_extra')
          .nilai);
      print('settings ${settings.map((e) => e.toJson())}');
      for (var setting in settings) {
        if (setting.nama == 'biaya_layanan') {
          biayaLayanan = int.parse(setting.nilai);
        }
      }
      if (totalItemCount > 10) {
        ongkir = ongkosKirim + (totalItemCount - 10) * biayaExtra;
      } else {
        ongkir = ongkosKirim;
      }
      if (priority == 1) ongkir += 3000;
      // Beritahu UI bahwa data telah berubah
      notifyListeners();
    } catch (e) {
      // Tangani error, misalnya set nilai default
      ongkir = 0;
      biayaLayanan = 0;
      notifyListeners();
      debugPrint('Error fetching settings: $e');
    }
  }

  void setDeliveryOption(int option) {
    print('deliveryOptions ${option}');
    if (option == 0) {
      _priority = 0;
      notifyListeners();
    }
    if (_selectedDeliveryOption != option) {
      // Hanya update jika ada perubahan
      setIsDelivery(option);
      _selectedDeliveryOption = option;
      log(_selectedDeliveryOption.toString());
      notifyListeners();
    }
  }

  Future<void> setCurrentTenant(
      TenantModel tenant, List<CartMenuModel>? cart) async {
    _currentTenant = tenant;

    // Load cart dari local hanya jika cart == null
    List<CartMenuModel> cartList;
    if (cart != null) {
      cartList = cart;
      print('pesen lagi');
    } else {
      final cartPerTenant = await CartLocalDataSource()
          .loadTenantCartFromLocal(tenant.id.toString());
      cartList = cartPerTenant?.cartMenuList ?? [];
    }

    _tenantCarts[tenant.id.toString()] = CartPerTenant(
      tenantId: tenant.id.toString(),
      tenantName: tenant.namaTenant,
      tenantGambar: tenant.namaGambar ?? '',
      cartMenuList: cartList,
    );

    print('setCurrentTenant ${tenant.toString()}');

    _cartMenu = cartList;
    if (cart != null) {
      await CartLocalDataSource().saveTenantCartToLocal(CartPerTenant(
        tenantId: _currentTenant!.id.toString(),
        tenantGambar: currentTenant!.namaGambar ?? '',
        tenantName: currentTenant!.namaTenant,
        cartMenuList: cartList,
      ));
    }
    notifyListeners();
  }

  Future<void> setCartMenu(List<CartMenuModel> cartMenu) async {
    _cartMenu = cartMenu;
    notifyListeners();
  }

  Future<bool> syncCartWithServer(String token) async {
    final List<CartMenuModel> updatedCart = [];
    bool isRemoved = false;
    bool hasChanged = false;

    for (var item in _cartMenu) {
      final latestMenu = await PublicRemoteDataSource()
          .getTenantFoodsById(item.menuId.toString(), token);

      if (latestMenu == null) continue;

      if (latestMenu.isReady == 0) {
        isRemoved = true;
        hasChanged = true;
        continue;
      }

      if (latestMenu.harga != item.menuPrice) {
        item.menuPrice = latestMenu.harga;
        hasChanged = true;
      }

      updatedCart.add(item);
    }

    if (isRemoved) {
      Fluttertoast.showToast(
          msg: "Menghapus item di cart karena menu sudah tidak tersedia",
          backgroundColor: AppColors.errorColor,
          textColor: Colors.white);
    }

    final beforeSync = _cartMenu.length;
    _cartMenu = updatedCart;
    print('updatedCart ${updatedCart}');

    _tenantCarts[_currentTenant!.id.toString()] = CartPerTenant(
      tenantId: _currentTenant!.id.toString(),
      tenantName: _currentTenant!.namaTenant,
      tenantGambar: _currentTenant!.namaGambar ?? '',
      cartMenuList: _cartMenu,
    );
    selectedCartTenant = _tenantCarts[_currentTenant!.id.toString()];
    notifyListeners();

    await CartLocalDataSource().saveTenantCartToLocal(CartPerTenant(
      tenantId: _currentTenant!.id.toString(),
      tenantGambar: currentTenant!.namaGambar ?? '',
      tenantName: currentTenant!.namaTenant,
      cartMenuList: _cartMenu,
    ));

    return hasChanged;
  }

  // Adds a new item to the cart or increments an existing item's
  // void addItemToCartOrUpdateQuantity(int menuId, String name, int price,
  //     String image, String tenantName, String description, bool isAdd) {
  //   final existingItemIndex = _findExistingItemIndex(menuId);

  //   // Update the existing item or add a new one
  //   if (existingItemIndex != -1) {
  //     // _updateExistingItem(existingItemIndex, price, isAdd);
  //   } else if (isAdd) {
  //     // _addItemToCart(menuId, name, price, image, tenantName, description);
  //   }

  //   // Update the cart visibility
  //   _updateCartVisibility();
  //   notifyListeners();
  // }

  void getAllCarts() async {
    _tenantCarts = await CartLocalDataSource().loadAllCartsToTenantMap();
    notifyListeners();
  }

  void addItemToCart({
    TenantFoods? newItem,
    String? tenantName,
    CartMenuModel? cart,
    String? catatan,
    required String tenantId,
  }) async {
    final cartItem = cart ??
        (newItem != null && tenantName != null
            ? CartMenuModel.fromTenantFoods(
                tenantFoods: newItem,
                tenantName: tenantName,
              )
            : throw ArgumentError(
                'newItem dan tenantName wajib diisi jika cart null'));

    // Ambil cart menu list untuk tenant ini
    print('tenantId iki loh cak ${tenantId}');
    final currentTenantId = _currentTenant?.id.toString() ?? tenantId;
    final existingCartPerTenant = _tenantCarts[currentTenantId];
    final listMenu =
        List<CartMenuModel>.from(existingCartPerTenant?.cartMenuList ?? []);
    print(
        'existingCartPerTenant iki loh cak ${existingCartPerTenant?.cartMenuList}');

    final index = catatan != null
        ? listMenu.indexWhere(
            (item) => item.catatan == catatan && item.menuId == cartItem.menuId)
        : listMenu.indexWhere((item) => item.menuId == cartItem.menuId);

    if (index == -1) {
      listMenu.add(cartItem);
    } else {
      listMenu[index] =
          listMenu[index].copyWith(count: listMenu[index].count + 1);
    }

    // Update _tenantCarts[currentTenantId] dengan cartMenuList yang baru
    // Update atau buat baru jika null
    _tenantCarts[currentTenantId] =
        _tenantCarts[currentTenantId]?.copyWith(cartMenuList: listMenu) ??
            CartPerTenant(
              tenantId: currentTenantId,
              tenantName: existingCartPerTenant?.tenantName ?? '',
              tenantGambar: existingCartPerTenant?.tenantGambar ?? '',
              cartMenuList: listMenu,
            );
    if (ongkir != 0 && totalItemCount > 10) {
      ongkir =
          ongkir - (totalItemCount - 10) * (biayaExtra == 0 ? 500 : biayaExtra);
    }

    _cartMenu = listMenu;

    final totalItem =
        _cartMenu.fold<int>(0, (total, item) => total + item.count);
    if (totalItem > 10 && ongkir != 0) {
      ongkir = (totalItem - 10) * (biayaExtra == 0 ? 500 : biayaExtra) + ongkir;
    }

    if (selectedCartTenant?.tenantId == currentTenantId) {
      selectedCartTenant = _tenantCarts[currentTenantId];
    }
    await CartLocalDataSource()
        .saveTenantCartToLocal(_tenantCarts[currentTenantId]!);
    notifyListeners();
  }

  void editCartModelToCart({
    required CartMenuModel cartItem,
    required BuildContext context,
    required String tenantId,
    required int index,
  }) async {
    final currentTenantId = _currentTenant?.id.toString() ?? tenantId;
    final existingCartPerTenant = _tenantCarts[currentTenantId];
    final listMenu =
        List<CartMenuModel>.from(existingCartPerTenant?.cartMenuList ?? []);
    final duplicateIndex = listMenu.indexWhere((item) =>
        item.menuId == cartItem.menuId &&
        item.catatan == cartItem.catatan &&
        item != listMenu[index]); // pastikan bukan yang diedit
    print('cek cartMenuModel iki loh cak ${cartItem}');
    print('duplicateIndex iki loh cak ${duplicateIndex}');
    if (duplicateIndex != -1) {
      listMenu[index] = cartItem.copyWith(
          count: cartItem.count + listMenu[duplicateIndex].count);
      listMenu.removeAt(duplicateIndex);
    } else {
      listMenu[index] = cartItem;
    }

    _tenantCarts[currentTenantId] =
        _tenantCarts[currentTenantId]?.copyWith(cartMenuList: listMenu) ??
            CartPerTenant(
              tenantId: currentTenantId,
              cartMenuList: listMenu,
              tenantName: existingCartPerTenant?.tenantName ?? '',
              tenantGambar: existingCartPerTenant?.tenantGambar ?? '',
            );
    if (ongkir != 0 && totalItemCount > 10) {
      ongkir =
          ongkir - (totalItemCount - 10) * (biayaExtra == 0 ? 500 : biayaExtra);
    }

    if (selectedVoucher != null &&
        listMenu.fold<int>(0, (sum, item) => sum + item.menuPrice) <
            selectedVoucher!.cashback!.minimalOrder) {
      selectedVoucher = null;
      Fluttertoast.showToast(
          msg: 'Minimal order belum terpenuhi, voucher dihapus',
          backgroundColor: AppColors.errorColor,
          textColor: Colors.white);
    }

    _cartMenu = listMenu;
    if (selectedCartTenant?.tenantId == currentTenantId) {
      selectedCartTenant = _tenantCarts[currentTenantId];
    }
    final totalItem =
        _cartMenu.fold<int>(0, (total, item) => total + item.count);
    if (totalItem > 10 && ongkir != 0) {
      ongkir = (totalItem - 10) * (biayaExtra == 0 ? 500 : biayaExtra) + ongkir;
    }

    await CartLocalDataSource()
        .saveTenantCartToLocal(_tenantCarts[currentTenantId]!);
    notifyListeners();
  }

  Future<void> fetchVoucher(String token, List<Cashback> listCashback) async {
    isFetchingVoucher = true;
    try {
      listVoucher = await TransactionRemoteDataSource().getVoucherData(token);

      // Filter cashback yang belum ada di voucher
      final filteredCashbacks = listCashback.where((cashback) {
        final isAlreadyInVoucher = listVoucher.any(
          (voucher) => voucher.cashback.id == cashback.id,
        );
        return !isAlreadyInVoucher;
      }).toList();

      // Reset default
      recommendedVoucher = null;
      recommendedCashback = null;

      // Panggil fungsi khusus buat tentuin rekomendasi
      _determineRecommendation(listVoucher, filteredCashbacks);

      notifyListeners();
    } catch (e) {
      throw Exception('Error in provider: $e');
    } finally {
      isFetchingVoucher = false;
      notifyListeners();
    }
  }

  bool showBottomSheetVoucher() {
    if (selectedVoucher != null) return false;
    final isThereRecommended = listVoucher
            .where((element) =>
                element.qty > 0 &&
                element.cashback.minimalOrder <= deliveryCost)
            .isNotEmpty &&
        listCashback
            .where((element) =>
                element.value > 0 && element.minimalOrder <= deliveryCost)
            .isNotEmpty;
    print('isThereRecommended $isThereRecommended');
    if (isThereRecommended) {
      return true;
    }
    return false;
  }

  /// Fungsi khusus buat tentuin rekomendasi voucher/cashback
  void _determineRecommendation(
    List<Voucher> vouchers,
    List<Cashback> filteredCashbacks,
  ) {
    if (vouchers.isEmpty) {
      // Kalau gak ada voucher → ambil cashback terbaik
      recommendedCashback = _getBestCashback(filteredCashbacks);
      return;
    }

    final currentVoucher = _getBestVoucher(vouchers);
    recommendedVoucher = currentVoucher;

    final bestCashback = _getBestCashback(filteredCashbacks);

    // Bandingkan cashback dengan voucher
    if (bestCashback != null &&
        currentVoucher != null &&
        bestCashback.value > currentVoucher.cashback.value &&
        bestCashback.maxCashback >= currentVoucher.cashback.maxCashback) {
      // Kalau cashback lebih baik
      recommendedVoucher = null;
      recommendedCashback = bestCashback;
    }
  }

  Cashback? _getBestCashback(List<Cashback> listCashback) {
    if (listCashback.isEmpty) return null;

    print('halo ini');
    listCashback.sort((a, b) {
      final scoreA = a.value + a.maxCashback;
      final scoreB = b.value + b.maxCashback;
      return scoreB.compareTo(scoreA); // terbesar duluan
    });

    return listCashback.first;
  }

  void removeVoucher() {
    selectedVoucher = null;
    notifyListeners();
  }

  Voucher? _getBestVoucher(List<Voucher> listVoucher) {
    if (listVoucher.isEmpty) return null;

    // ambil hanya voucher dengan qty > 0
    final availableVouchers = listVoucher.where((v) => v.qty > 0).toList();

    if (availableVouchers.isEmpty) return null;

    availableVouchers.sort((a, b) {
      final scoreA = a.cashback.value + a.cashback.maxCashback;
      final scoreB = b.cashback.value + b.cashback.maxCashback;
      return scoreB.compareTo(scoreA); // terbesar duluan
    });

    return availableVouchers.first;
  }

  Future<List<Cashback>> fetchCashback(
      String token, bool clearSelectedVoucher) async {
    isFetchCashback = true;
    try {
      if (clearSelectedVoucher) {
        selectedVoucher = null;
      }
      listCashback = await TransactionRemoteDataSource().getCashbackData(token);
      notifyListeners();
      return listCashback;
    } catch (e) {
      throw Exception('Error in provider: $e');
    } finally {
      isFetchCashback = false;
      notifyListeners();
    }
  }

  void setSelectedVoucher(Voucher voucher) {
    selectedVoucher = voucher;
    notifyListeners();
  }

  Future<Voucher> getCashback(String token, String referralCode) async {
    if (isClaimingCashback) return Future.error('Claiming cashback...');
    isClaimingCashback = true;
    try {
      final newVoucher = await TransactionRemoteDataSource()
          .claimCashback(token, referralCode);
      listVoucher.add(newVoucher);
      // Filter cashback yang belum ada di voucher
      final filteredCashbacks = listCashback.where((cashback) {
        final isAlreadyInVoucher = listVoucher.any(
          (voucher) => voucher.cashback.id == cashback.id,
        );
        return !isAlreadyInVoucher;
      }).toList();

      // Reset default
      recommendedVoucher = null;
      recommendedCashback = null;

      // Panggil fungsi khusus buat tentuin rekomendasi
      _determineRecommendation(listVoucher, filteredCashbacks);
      notifyListeners();
      return newVoucher;
    } catch (e) {
      throw ('$e');
    } finally {
      isClaimingCashback = false;
      notifyListeners();
    }
  }

  void addCartModelToCart({
    required CartMenuModel cartItem,
    required String tenantId,
  }) async {
    final currentTenantId = _currentTenant?.id.toString() ?? tenantId;
    final existingCartPerTenant = _tenantCarts[currentTenantId];
    final listMenu =
        List<CartMenuModel>.from(existingCartPerTenant?.cartMenuList ?? []);

    // Cek berdasarkan menuId dan catatan
    final index = listMenu.indexWhere((item) =>
        item.menuId == cartItem.menuId && (item.catatan == cartItem.catatan));

    if (index == -1) {
      listMenu.add(cartItem);
    } else {
      listMenu[index] =
          cartItem.copyWith(count: cartItem.count + listMenu[index].count);
    }

    _tenantCarts[currentTenantId] =
        _tenantCarts[currentTenantId]?.copyWith(cartMenuList: listMenu) ??
            CartPerTenant(
              tenantId: currentTenantId,
              cartMenuList: listMenu,
              tenantName: existingCartPerTenant?.tenantName ?? '',
              tenantGambar: existingCartPerTenant?.tenantGambar ?? '',
            );

    _cartMenu = listMenu;

    if (selectedCartTenant?.tenantId == currentTenantId) {
      selectedCartTenant = _tenantCarts[currentTenantId];
    }

    await CartLocalDataSource()
        .saveTenantCartToLocal(_tenantCarts[currentTenantId]!);
    notifyListeners();
  }

  Future<void> removeItemFromTenantCart(
      String tenantId, int menuId, BuildContext context,
      {String? catatan, int? indexCart}) async {
    final currentTenantId = _currentTenant?.id.toString() ?? tenantId;

    final tenantCart = _tenantCarts[currentTenantId];
    if (tenantCart == null) return;

    final menuList = tenantCart.cartMenuList ?? [];

    // Cek berdasarkan menuId dan catatan
    final index = indexCart ??
        menuList.indexWhere((item) =>
            item.menuId == menuId &&
            (catatan == null || item.catatan == catatan));
    if (index == -1) return;

    final currentItem = menuList[index];
    if (currentItem.count > 1) {
      menuList[index] = currentItem.copyWith(count: currentItem.count - 1);
    } else {
      menuList.removeAt(index);
    }

    if (selectedVoucher != null &&
        menuList.fold<int>(0, (sum, item) => sum + item.menuPrice) <
            selectedVoucher!.cashback!.minimalOrder) {
      selectedVoucher = null;
      Fluttertoast.showToast(
          msg: 'Minimal order belum terpenuhi, voucher dihapus',
          backgroundColor: AppColors.errorColor,
          textColor: Colors.white);
    }

    if (menuList.isEmpty) {
      _tenantCarts.remove(currentTenantId);
      selectedCartTenant = null;
      await CartLocalDataSource().clearCart(currentTenantId);
    } else {
      _tenantCarts[currentTenantId] =
          tenantCart.copyWith(cartMenuList: menuList);
      if (selectedCartTenant?.tenantId == currentTenantId) {
        selectedCartTenant = _tenantCarts[currentTenantId];
      }
      await CartLocalDataSource()
          .saveTenantCartToLocal(_tenantCarts[currentTenantId]!);
    }
    print('tenantId iki loh caksadas ${currentTenantId}');

    if (ongkir != 0 && totalItemCount >= 10) {
      ongkir = ongkir - (biayaExtra == 0 ? 500 : biayaExtra);
    }

    if (_currentTenant?.id.toString() == currentTenantId) {
      _cartMenu = _tenantCarts[currentTenantId]?.cartMenuList ?? [];
    }

    notifyListeners();
  }

  Future<void> clearItemFromCart(String tenantId, int indexCart) async {
    final currentTenantId = _currentTenant?.id.toString() ?? tenantId;

    final tenantCart = _tenantCarts[currentTenantId];
    if (tenantCart == null) return;

    final menuList = tenantCart.cartMenuList ?? [];

    if (indexCart >= 0 && indexCart < menuList.length) {
      menuList.removeAt(indexCart);
    }

    if (menuList.isEmpty) {
      _tenantCarts.remove(currentTenantId);
      await CartLocalDataSource().clearCart(currentTenantId);
      if (selectedCartTenant?.tenantId == currentTenantId) {
        selectedCartTenant = null;
      }
    } else {
      _tenantCarts[currentTenantId] =
          tenantCart.copyWith(cartMenuList: menuList);

      if (selectedCartTenant?.tenantId == currentTenantId) {
        selectedCartTenant = _tenantCarts[currentTenantId];
      }

      await CartLocalDataSource()
          .saveTenantCartToLocal(_tenantCarts[currentTenantId]!);
    }

    if (_currentTenant?.id.toString() == currentTenantId) {
      _cartMenu = _tenantCarts[currentTenantId]?.cartMenuList ?? [];
    }

    notifyListeners();
  }

  Future<bool> removeUnavailableMenusFromCart(
      String tenantId, List<TenantFoods> foods) async {
    bool hasRemoved = false;

    for (final food in foods) {
      if (food.isReady == 0) {
        final removed = await clearItemByMenuIdFromCart(tenantId, food.id);
        if (removed) {
          hasRemoved = true;
        }
      }
    }

    return hasRemoved;
  }

  Future<bool> clearItemByMenuIdFromCart(String tenantId, int menuId) async {
    final currentTenantId = _currentTenant?.id.toString() ?? tenantId;

    final tenantCart = _tenantCarts[currentTenantId];
    if (tenantCart == null) return false;

    final menuList = tenantCart.cartMenuList ?? [];

    final updatedMenuList =
        menuList.where((item) => item.menuId != menuId).toList();

    // Kalau tidak ada yang berubah, artinya tidak ada yang dihapus
    if (updatedMenuList.length == menuList.length) {
      return false;
    }

    if (updatedMenuList.isEmpty) {
      _tenantCarts.remove(currentTenantId);
      await CartLocalDataSource().clearCart(currentTenantId);
    } else {
      _tenantCarts[currentTenantId] =
          tenantCart.copyWith(cartMenuList: updatedMenuList);

      if (selectedCartTenant?.tenantId == currentTenantId) {
        selectedCartTenant = _tenantCarts[currentTenantId];
      }

      await CartLocalDataSource()
          .saveTenantCartToLocal(_tenantCarts[currentTenantId]!);
    }

    if (_currentTenant?.id.toString() == currentTenantId) {
      _cartMenu = _tenantCarts[currentTenantId]?.cartMenuList ?? [];
    }

    notifyListeners();
    return true;
  }

  void clearCart(bool clearLocal) async {
    final tenantId = _currentTenant?.id.toString();
    _currentTenant = null;
    ongkir = 0;
    _priority = 0;

    print('clear cart $clearLocal');
    roomId = null;
    selectedCartTenant = null;

    if (clearLocal == true && _tenantCarts.isNotEmpty && tenantId != null) {
      _tenantCarts.remove(tenantId);
      _cartMenu = _tenantCarts[tenantId]?.cartMenuList ?? [];
      await CartLocalDataSource().clearCart(tenantId);
    }

    notifyListeners();
  }

  void clearCartOnly() async {
    final tenantId = _currentTenant?.id.toString();
    if (_tenantCarts.isNotEmpty && tenantId != null) {
      _tenantCarts.remove(tenantId);
      _cartMenu = _tenantCarts[tenantId]?.cartMenuList ?? [];
      await CartLocalDataSource().clearCart(tenantId);
    }

    notifyListeners();
  }
  // Finds the index of an existing item in the cart with the given menu ID.
  // int _findExistingItemIndex(int menuId) {
  //   return _cartMenu.indexWhere((element) => element.menuId == menuId);
  // }

  // // Updates the visibility of the cart's bottom navigation bar based on whether
  // void _updateCartVisibility() {
  //   final newVisibility = totalItemCount > 0;
  //   if (isCartVisible != newVisibility) {
  //     isCartVisible = newVisibility;
  //     notifyListeners();
  //   }
  // }

  void setTransactionStatus({bool? isLoading, bool? isTransactionCompleted}) {
    isLoading = isLoading ?? false;
    transactionCompleted = isTransactionCompleted ?? false;
    notifyListeners();
  }

  // Calculates and returns the total price including additional costs
  int getTotal() {
    final additionalCost = _selectedDeliveryOption == 1
        // ? getTotalItemCount() * deliveryCostPerItem
        ? ongkir
        : 0;
    // totalPrice = deliveryCost + serviceFee + additionalCost;
    totalPrice = deliveryCost + biayaLayanan + additionalCost;
    log("hitung delivery cost: $additionalCost");
    log("ongkir CP: $ongkir");
    log("biaya layanan CP: $biayaLayanan");
    return totalPrice; // Kembalikan nilai totalPrice
  }

  // Returns the total number of items in the cart
  int getTotalItemCount() {
    return cart.fold(0, (sum, item) => sum + item.count);
  }

  // Adds a note to a specific item in the cart
  Future<void> addNote({
    required String tenantId,
    required int menuId,
    required String note,
  }) async {
    final tenantCart = _tenantCarts[tenantId];
    if (tenantCart == null) return;

    final updatedCartMenuList = tenantCart.cartMenuList!.map((item) {
      if (item.menuId == menuId) {
        return item.copyWith(catatan: note);
      }
      return item;
    }).toList();

    // Update di map dan _cartMenu jika tenant aktif
    final updatedTenantCart =
        tenantCart.copyWith(cartMenuList: updatedCartMenuList);
    _tenantCarts[tenantId] = updatedTenantCart;

    if (_currentTenant?.id.toString() == tenantId) {
      _cartMenu = updatedCartMenuList;
    }

    if (selectedCartTenant?.tenantId == tenantId) {
      selectedCartTenant = updatedTenantCart;
    }

    // Simpan ke local storage
    await CartLocalDataSource().saveTenantCartToLocal(updatedTenantCart);

    notifyListeners();
  }

  // Creates a transaction and sends it to the server
  Future<OrderModel?> createTransaction(
      BuildContext context, String token, String paymentMethod) async {
    int total = getTotalItemCount();
    print('total $total');
    print('paymentMethod $paymentMethod');

    final hasCartChanged = await syncCartWithServer(token);
    print('totalItemCount $totalItemCount');
    final result = TransactionRemoteDataSource()
        .createTransaction(token, toJson(_cartMenu, paymentMethod));

    if (hasCartChanged || total != totalItemCount) {
      if (cart.isEmpty) {
        Navigator.pop(context);
        isLoading = false;
      }
      isLoading = false;
      return null; // ⛔ Batal create transaksi
    }

    print('isAntar : $_selectedDeliveryOption');
    print('sebelum add transaksi ' + toJson(_cartMenu, paymentMethod));
    orderSuccessful = true;
    notifyListeners();
    return result;
  }

  // Converts the current state to JSON format
  String toJson(List<CartMenuModel> cart, String paymentMethod) {
    final data = {
      "isAntar": _selectedDeliveryOption,
      "total": totalPrice,
      "ruangan_id": roomId,
      "metode_pembayaran": paymentMethod,
      "isPriority": _priority,
      "ongkos_kirim":
          _selectedDeliveryOption == 1 ? getTotalItemCount() * 1000 : 0,
      "menus": cart.map((x) => x.toJson()).toList(),
    };

    // Hanya tambahkan 'catatan_lokasi' jika tidak kosong
    if (catatanLokasi.trim().isNotEmpty) {
      data["catatan_lokasi_pengantaran"] = catatanLokasi;
    }
    if (selectedVoucher != null) {
      data["voucher_id"] = selectedVoucher!.id;
    }

    return jsonEncode(data);
  }

  String toJsonCashier(List<CartMenuModel> cart) {
    final data = {
      "menus": cart.map((x) => x.toJson()).toList(),
    };

    return jsonEncode(data);
  }

  Future<CashierTransaction> createCashierTransaction(
      BuildContext context, String token) async {
    submittingCashierTransaction = true;
    notifyListeners();
    int total = getTotalItemCount();
    print('total $total');
    print('paymentMethod $paymentMethod');

    print('totalItemCount $totalItemCount');
    try {
      final result = await TransactionRemoteDataSource()
          .createCashierTransaction(token, toJsonCashier(_cartMenu));
      return result;
    } catch (e) {
      print(e);
      throw Exception(e.toString());
    } finally {
      print('isAntar : $_selectedDeliveryOption');
      submittingCashierTransaction = false;
      notifyListeners();
    }
  }

  // Sets the payment method
  void setPaymentMethod(String metode) {
    paymentMethod = metode;
  }

  // Sets the delivery status
  void setIsDelivery(int delivery) {
    _selectedDeliveryOption = delivery;
  }

  void setIsPriority(int selectedPriority) {
    if (roomId == null) {
      Fluttertoast.showToast(msg: "Pilih ruangan terlebih dahulu");
      return;
    }
    ;
    _priority = selectedPriority;
    if (selectedPriority == 1) {
      ongkir += 3000;
    } else {
      ongkir -= 3000;
    }
    notifyListeners();
  }

  // Sets the room ID
  void setIdRoom(int id) {
    roomId = id;
  }

  void clearRoomIdAndOngkir() {
    roomId = null;
    _priority = 0;
    ongkir = 0;
    notifyListeners();
  }

  void setCatatanLokasi(String catatan) {
    catatanLokasi = catatan;
    notifyListeners();
  }

  void setTotalActiveDriver(int total) {
    _totalActiveDriver = total;
    notifyListeners();
  }

  // Fetches room data from the server
  Future<void> getRoom(String token) async {
    listRuangan = await TransactionRemoteDataSource().getRoomData(token);
  }

  // Validates the cart based on delivery and room selection
  bool isCartValid(int? selectRoom) {
    if (_selectedDeliveryOption == 1) {
      return selectRoom != null;
    }
    return true;
  }

  void setIsThereActiveDriver(bool value) {
    final oldIsThereActiveDriver = _isThereActiveDriver;

    _isThereActiveDriver = value;
    isFetchingActiveDriver = false;

    if (oldIsThereActiveDriver != _isThereActiveDriver) {
      notifyListeners();
    } else {
      notifyListeners(); // Atau tetep dipanggil, tergantung logika kamu
    }
  }

  Future<void> getActiveDriver(String token) async {
    isFetchingActiveDriver = true;
    print('getActiveDriver');
    notifyListeners(); // Tambahkan ini biar shimmer muncul
    int driverAvailability =
        await PublicRemoteDataSource().isThereActiveDriver(token);
    setTotalActiveDriver(driverAvailability);
    setIsThereActiveDriver(driverAvailability > 0);
    if (driverAvailability > 0) {
      setDeliveryOption(1);
    } else {
      setDeliveryOption(0);
    }
    notifyListeners();
  }

  void updateItemCount({
    required String tenantId,
    required int menuId,
    required int count,
  }) async {
    final currentTenantId = _currentTenant?.id.toString() ?? tenantId;

    final tenantCart = _tenantCarts[currentTenantId];
    if (tenantCart == null) return;

    final updatedMenuList = tenantCart.cartMenuList!
        .map((item) {
          if (item.menuId == menuId) {
            return item.copyWith(count: count);
          }
          return item;
        })
        .where((item) => item.count > 0)
        .toList();

    // Update map dan _cartMenu jika perlu
    final updatedTenantCart =
        tenantCart.copyWith(cartMenuList: updatedMenuList);
    _tenantCarts[currentTenantId] = updatedTenantCart;
    if (ongkir != 0 && totalItemCount > 10) {
      ongkir =
          ongkir - (totalItemCount - 10) * (biayaExtra == 0 ? 500 : biayaExtra);
    }

    if (_currentTenant?.id.toString() == currentTenantId) {
      _cartMenu = updatedMenuList;
    }
    final totalItem =
        _cartMenu.fold<int>(0, (total, item) => total + item.count);
    if (totalItem > 10 && ongkir != 0) {
      ongkir = (totalItem - 10) * (biayaExtra == 0 ? 500 : biayaExtra) + ongkir;
    }

    if (selectedCartTenant?.tenantId == currentTenantId) {
      selectedCartTenant = updatedTenantCart;
    }

    await CartLocalDataSource().saveTenantCartToLocal(updatedTenantCart);

    notifyListeners();
  }
}
