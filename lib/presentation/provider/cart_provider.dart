import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:testgetdata/data/model/order_model.dart';
import 'package:testgetdata/data/model/settings_model.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
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
  bool transactionCompleted = false;
  bool orderSuccessful = false;

  // A private list to store the items in the cart.
  List<CartMenuModel> _cartMenu = <CartMenuModel>[];

  // A public getter to access the list of cart items.
  List<CartMenuModel> get cart => _cartMenu;

  // A public list to store available rooms.
  List<Ruangan> listRuangan = [];

  int _selectedDeliveryOption = 1;

  int get selectedDeliveryOption => _selectedDeliveryOption;

  List<SettingsModel> settings = [];
  int ongkir = 0;
  int biayaLayanan = 0;
  String jumlahItem = '0';

  Future<void> getOngkir(String token) async {
    try {
      // Ambil data dari PublicRemoteDataSource
      settings = await PublicRemoteDataSource().getOngkir(token);

      // Cari ongkos_kirim dan biaya_layanan dari settings
      for (var setting in settings) {
        if (setting.nama == 'ongkos_kirim') {
          // ongkir = setting.nilai;
          ongkir = int.parse(setting.nilai);
        } else if (setting.nama == 'biaya_layanan') {
          biayaLayanan = int.parse(setting.nilai);
        }
        // Jika jumlahItem juga ada di settings, tambahkan logika serupa
        // else if (setting.nama == 'jumlah_item') {
        //   jumlahItem = setting.nilai;
        // }
      }

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
    if (_selectedDeliveryOption != option) {
      // Hanya update jika ada perubahan
      setIsDelivery(option);
      _selectedDeliveryOption = option;
      log(_selectedDeliveryOption.toString());
      notifyListeners();
    }
  }

  // Adds a new item to the cart or increments an existing item's
  void addItemToCartOrUpdateQuantity(int menuId, String name, int price,
      String image, String tenantName, String description, bool isAdd) {
    final existingItemIndex = _findExistingItemIndex(menuId);

    // Update the existing item or add a new one
    if (existingItemIndex != -1) {
      // _updateExistingItem(existingItemIndex, price, isAdd);
    } else if (isAdd) {
      // _addItemToCart(menuId, name, price, image, tenantName, description);
    }

    // Update the cart visibility
    _updateCartVisibility();
    notifyListeners();
  }

  void addItemToCart(
      {TenantFoods? newItem, String? tenantName, CartMenuModel? cart}) {
    final cartItem = cart ??
        (newItem != null && tenantName != null
            ? CartMenuModel.fromTenantFoods(
                tenantFoods: newItem,
                tenantName: tenantName,
              )
            : throw ArgumentError(
                'newItem dan tenantName wajib diisi jika cart null'));

    final index =
        _cartMenu.indexWhere((item) => item.menuId == cartItem.menuId);
    print('nambah menu cak $cartItem');

    if (index == -1) {
      _cartMenu = [..._cartMenu, cartItem];
    } else {
      _cartMenu[index] = _cartMenu[index].copyWith(
        count: _cartMenu[index].count + 1,
      );
      print('iki cak cart menu $_cartMenu');
    }

    notifyListeners();
    _updateCartVisibility();
  }

  void removeItemFromCart(int menuId) {
    final index = _cartMenu.indexWhere((item) => item.menuId == menuId);
    if (index != -1) {
      final currentItem = _cartMenu[index];
      if (currentItem.count > 1) {
        final updatedItem = currentItem.copyWith(count: currentItem.count - 1);
        final newList = [..._cartMenu];
        newList[index] = updatedItem;
        _cartMenu = newList;
      } else {
        _cartMenu = [..._cartMenu]..removeAt(index);
      }
      _updateCartVisibility();
      notifyListeners();
    }
  }

  void clearCart() {
    _cartMenu = [];
    notifyListeners();
  }

  // Finds the index of an existing item in the cart with the given menu ID.
  int _findExistingItemIndex(int menuId) {
    return _cartMenu.indexWhere((element) => element.menuId == menuId);
  }

  // Updates the visibility of the cart's bottom navigation bar based on whether
  void _updateCartVisibility() {
    final newVisibility = totalItemCount > 0;
    if (isCartVisible != newVisibility) {
      isCartVisible = newVisibility;
      notifyListeners();
    }
  }

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
  void addNote(int menuId, String note) {
    final cartSelected = _cartMenu.firstWhere((item) => item.menuId == menuId);
    // Update the note for the selected item
    cartSelected.catatan = note;
  }

  // Creates a transaction and sends it to the server
  Future<OrderModel> createTransaction(BuildContext context, String token) {
    print('isAntar : $_selectedDeliveryOption');
    print('sebelum add transaksi ' + toJson());
    orderSuccessful = true;
    notifyListeners();

    // Add transaction using server API
    return TransactionRemoteDataSource().createTransaction(token, toJson());
  }

  // Converts the current state to JSON format
  String toJson() => jsonEncode({
        "isAntar": _selectedDeliveryOption,
        "total": totalPrice,
        "ruangan_id": roomId,
        "metode_pembayaran": paymentMethod,
        "ongkos_kirim":
            _selectedDeliveryOption == 1 ? getTotalItemCount() * 1000 : 0,
        "menus": _cartMenu.map((x) => x.toJson()).toList(),
      });

  // Sets the payment method
  void setPaymentMethod(String metode) {
    paymentMethod = metode;
  }

  // Sets the delivery status
  void setIsDelivery(int delivery) {
    _selectedDeliveryOption = delivery;
  }

  // Sets the room ID
  void setIdRoom(int id) {
    roomId = id;
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
}
