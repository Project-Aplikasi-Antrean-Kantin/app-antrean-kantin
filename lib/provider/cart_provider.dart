import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:testgetdata/http/add_transaksi.dart';
import 'package:testgetdata/http/fetch_data_ruangan.dart';
import 'package:testgetdata/model/cart_menu_modelllll.dart';
import 'package:testgetdata/model/order_model.dart';
import 'package:testgetdata/model/ruangan_model.dart';

/// A provider class responsible for managing the cart functionality.
class CartProvider extends ChangeNotifier {
  /// A private list to store the items in the cart.
  final List<CartMenuModel> _cartMenu = <CartMenuModel>[];

  /// A public getter to access the list of cart items.
  List<CartMenuModel> get cart => _cartMenu;

  /// A public list to store available rooms.
  List<Ruangan> listRuangan = [];

  int total = 0;
  int totalHarga = 0;
  int cost = 0;
  int service = 1000;
  int isAntar = 0;
  int? ruanganId;
  bool isCartShow = false;
  bool orderBerhasil = false;
  String? metodePembayaran;

  // Adds an item to the cart or increments its count if it already exists
  void addItemToCartOrIncrementIfExists(
    int menuId,
    String name,
    int price,
    String gambar,
    String tenantName,
    String deskripsi,
    bool isAdd,
  ) {
    // Find if the item already exists in the cart
    final existingItemIndex = _cartMenu.indexWhere(
      (element) => element.menuId == menuId,
    );

    if (existingItemIndex != -1) {
      // If item exists, update its count
      final existingItem = _cartMenu[existingItemIndex];
      if (isAdd) {
        existingItem.count += 1;
        total += 1;
        cost += price;
      } else if (existingItem.count > 0) {
        existingItem.count -= 1;
        total -= 1; // Update total item count
        cost -= price; // Update total cost
        if (existingItem.count == 0) {
          // Remove item if count is zero
          _cartMenu.removeAt(existingItemIndex);
        }
      }
    } else if (isAdd) {
      // If item doesn't exist, add it to the cart
      _cartMenu.add(
        CartMenuModel(
          menuId: menuId,
          count: 1,
          menuGambar: gambar,
          menuNama: name,
          menuPrice: price,
          deskripsi: deskripsi,
          tenantName: tenantName,
          catatan: '',
        ),
      );
      setBottomNavVisible(true);
      total += 1; // Update total item count
      cost += price; // Update total cost
    }

    // Set the visibility of the bottom navigation based on total
    if (total < 1) setBottomNavVisible(false);
    notifyListeners(); // Notify listeners about changes
  }

  // Sets the visibility of the cart UI component
  void setBottomNavVisible(bool value) {
    isCartShow = value;
    notifyListeners();
  }

  // Checks if the catalog is already present
  void cekKatalogSudahAda(menuId) {
    isCartShow = _cartMenu.isNotEmpty;
    notifyListeners();
  }

  // Clears the cart
  void clearCart() {
    _cartMenu.clear();
    isCartShow = false;
    cost = 0;
    total = 0;
    notifyListeners();
  }

  // Calculates and returns the total price including additional costs
  int getTotal() {
    final additionalCost = isAntar == 1 ? jumlahMenu() * 1000 : 0;
    totalHarga = cost + service + additionalCost;
    return totalHarga;
  }

  // Returns the total number of items in the cart
  int jumlahMenu() {
    return cart.fold(0, (sum, item) => sum + item.count as int);
  }

  // Adds a note to a specific item in the cart
  void tambahCatatan(int menuId, String catatan) {
    final cartSelected = _cartMenu.firstWhere((item) => item.menuId == menuId);
    // Update the note for the selected item
    cartSelected.catatan = catatan;
  }

  // Creates a transaction and sends it to the server
  Future<OrderModel> buatTransaksi(BuildContext context, String token) {
    print('isAntar : $isAntar');
    print('sebelum add transaksi ' + toJson());
    orderBerhasil = true;
    notifyListeners();

    // Add transaction using server API
    return addTransaksi(token, toJson());
  }

  // Converts the current state to JSON format
  String toJson() => jsonEncode({
        "isAntar": isAntar,
        "total": totalHarga,
        "ruangan_id": ruanganId,
        "metode_pembayaran": metodePembayaran,
        "ongkos_kirim": isAntar == 1 ? jumlahMenu() * 1000 : 0,
        "menus": _cartMenu.map((x) => x.toJson()).toList(),
      });

  // Sets the payment method
  void setMetodePembayaran(String metode) {
    metodePembayaran = metode;
  }

  // Sets the delivery status
  void setIsAntar(int antar) {
    isAntar = antar;
  }

  // Sets the room ID
  void setRuanganId(int id) {
    ruanganId = id;
  }

  // Fetches room data from the server
  Future<void> getRuangan(String token) async {
    listRuangan = await fetchDataRuangan(token);
  }

  // Validates the cart based on delivery and room selection
  bool isCartValid(int? pengantaran, int? ruangan) {
    return pengantaran != null && (pengantaran != 1 || ruangan != null);
  }
}
