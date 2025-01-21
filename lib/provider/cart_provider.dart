import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:testgetdata/model/order_model.dart';
import 'package:testgetdata/http/add_transaksi.dart';
import 'package:testgetdata/model/ruangan_model.dart';
import 'package:testgetdata/http/fetch_data_ruangan.dart';
import 'package:testgetdata/model/cart_menu_modelllll.dart';

/// A provider class responsible for managing the cart functionality.
class CartProvider extends ChangeNotifier {
  // Order details
  int totalItemCount = 0;
  int totalPrice = 0;

  // Delivery details
  int deliveryCost = 0;
  int deliveryCostPerItem = 1000;
  int isDelivery = 0; // 0: Pickup, 1: Delivery
  int? roomId;

  // Fees and payment
  int serviceFee = 1000;
  String? paymentMethod;

  // UI state
  bool isCartVisible = false;
  bool isLoading = false;
  bool transactionCompleted = false;
  bool orderSuccessful = false;

  // A private list to store the items in the cart.
  final List<CartMenuModel> _cartMenu = <CartMenuModel>[];

  // A public getter to access the list of cart items.
  List<CartMenuModel> get cart => _cartMenu;

  // A public list to store available rooms.
  List<Ruangan> listRuangan = [];

  // Adds a new item to the cart or increments an existing item's
  void addItemToCartOrUpdateQuantity(int menuId, String name, int price,
      String image, String tenantName, String description, bool isAdd) {
    final existingItemIndex = _findExistingItemIndex(menuId);

    // Update the existing item or add a new one
    if (existingItemIndex != -1) {
      _updateExistingItem(existingItemIndex, price, isAdd);
    } else if (isAdd) {
      _addItemToCart(menuId, name, price, image, tenantName, description);
    }

    // Update the cart visibility
    _updateCartVisibility();
    notifyListeners();
  }

  // Finds the index of an existing item in the cart with the given menu ID.
  int _findExistingItemIndex(int menuId) {
    return _cartMenu.indexWhere((element) => element.menuId == menuId);
  }

  // Updates the count and cost of an existing item in the cart.
  void _updateExistingItem(int index, int price, bool isAdd) {
    final existingItem = _cartMenu[index];

    // Update the count and cost
    if (isAdd) {
      existingItem.count += 1;
      totalItemCount += 1;
      deliveryCost += price;
    } else if (existingItem.count > 0) {
      existingItem.count -= 1;
      totalItemCount -= 1;
      deliveryCost -= price;
      if (existingItem.count == 0) {
        _cartMenu.removeAt(index);
      }
    }
  }

  // Adds a new item to the cart list. The item count is set to 1
  // and the deliveryCost is incremented by the price of the item.
  void _addItemToCart(int menuId, String name, int price, String image,
      String tenantName, String description) {
    _cartMenu.add(
      CartMenuModel(
        menuId: menuId,
        count: 1,
        menuGambar: image,
        menuNama: name,
        menuPrice: price,
        deskripsi: description,
        tenantName: tenantName,
        catatan: '',
      ),
    );
    totalItemCount += 1;
    deliveryCost += price;
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

  // Clears the cart
  void clearCart() {
    _cartMenu.clear();
    isCartVisible = false;
    deliveryCost = 0;
    totalItemCount = 0;
    notifyListeners();
  }

  // Calculates and returns the total price including additional costs
  int getTotal() {
    final additionalCost =
        isDelivery == 1 ? getTotalItemCount() * deliveryCostPerItem : 0;
    totalPrice = deliveryCost + serviceFee + additionalCost;
    return totalPrice;
  }

  // Returns the total number of items in the cart
  int getTotalItemCount() {
    return cart.fold(0, (sum, item) => sum + item.count as int);
  }

  // Adds a note to a specific item in the cart
  void addNote(int menuId, String note) {
    final cartSelected = _cartMenu.firstWhere((item) => item.menuId == menuId);
    // Update the note for the selected item
    cartSelected.catatan = note;
  }

  // Creates a transaction and sends it to the server
  Future<OrderModel> createTransaction(BuildContext context, String token) {
    print('isAntar : $isDelivery');
    print('sebelum add transaksi ' + toJson());
    orderSuccessful = true;
    notifyListeners();

    // Add transaction using server API
    return addTransaksi(token, toJson());
  }

  // Converts the current state to JSON format
  String toJson() => jsonEncode({
        "isAntar": isDelivery,
        "total": totalPrice,
        "ruangan_id": roomId,
        "metode_pembayaran": paymentMethod,
        "ongkos_kirim": isDelivery == 1 ? getTotalItemCount() * 1000 : 0,
        "menus": _cartMenu.map((x) => x.toJson()).toList(),
      });

  // Sets the payment method
  void setPaymentMethod(String metode) {
    paymentMethod = metode;
  }

  // Sets the delivery status
  void setIsDelivery(int delivery) {
    isDelivery = delivery;
  }

  // Sets the room ID
  void setIdRoom(int id) {
    roomId = id;
  }

  // Fetches room data from the server
  Future<void> getRoom(String token) async {
    listRuangan = await fetchDataRuangan(token);
  }

  // Validates the cart based on delivery and room selection
  bool isCartValid(int? selectDelivery, int? selectRoom) {
    return selectDelivery != null &&
        (selectDelivery != 1 || selectRoom != null);
  }
}
