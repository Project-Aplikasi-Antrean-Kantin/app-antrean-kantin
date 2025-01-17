import 'package:flutter_test/flutter_test.dart';
import 'package:testgetdata/provider/cart_provider.dart';

void main() {
  group('CartProvider', () {
    late CartProvider cartProvider;

    setUp(() {
      cartProvider = CartProvider();
    });

    test('addItemToCartOrIncrementIfExists adds a new item', () {
      cartProvider.addItemToCartOrIncrementIfExists(
          1, 'Test Item', 100, 'image.png', 'Tenant', 'Description', true);

      expect(cartProvider.cart.length, 1);
      expect(cartProvider.cart[0].menuId, 1);
      expect(cartProvider.cart[0].count, 1);
      expect(cartProvider.total, 1);
      expect(cartProvider.cost, 100);
    });

    test('addItemToCartOrIncrementIfExists increments an existing item', () {
      cartProvider.addItemToCartOrIncrementIfExists(
          1, 'Test Item', 100, 'image.png', 'Tenant', 'Description', true);
      cartProvider.addItemToCartOrIncrementIfExists(
          1, 'Test Item', 100, 'image.png', 'Tenant', 'Description', true);

      expect(cartProvider.cart.length, 1);
      expect(cartProvider.cart[0].count, 2);
      expect(cartProvider.total, 2);
      expect(cartProvider.cost, 200);
    });

    test('addItemToCartOrIncrementIfExists decrements an existing item', () {
      cartProvider.addItemToCartOrIncrementIfExists(
          1, 'Test Item', 100, 'image.png', 'Tenant', 'Description', true);
      cartProvider.addItemToCartOrIncrementIfExists(
          1, 'Test Item', 100, 'image.png', 'Tenant', 'Description', false);

      expect(cartProvider.cart.length, 0);
      expect(cartProvider.total, 0);
      expect(cartProvider.cost, 0);
    });

    test('clearCart clears the cart', () {
      cartProvider.addItemToCartOrIncrementIfExists(
          1, 'Test Item', 100, 'image.png', 'Tenant', 'Description', true);
      cartProvider.clearCart();

      expect(cartProvider.cart.length, 0);
      expect(cartProvider.isCartShow, false);
      expect(cartProvider.cost, 0);
      expect(cartProvider.total, 0);
    });

    test('getTotal calculates total price including service', () {
      cartProvider.addItemToCartOrIncrementIfExists(
          1, 'Test Item', 100, 'image.png', 'Tenant', 'Description', true);
      final totalPrice = cartProvider.getTotal();

      expect(totalPrice, 1100);
    });

    test('isCartValid returns true for valid cart', () {
      expect(cartProvider.isCartValid(0, null), true);
      expect(cartProvider.isCartValid(1, 1), true);
      expect(cartProvider.isCartValid(1, null), false);
    });

    test('tambahCatatan adds note to cart item', () {
      cartProvider.addItemToCartOrIncrementIfExists(
          1, 'Test Item', 100, 'image.png', 'Tenant', 'Description', true);
      cartProvider.tambahCatatan(1, 'Note');

      expect(cartProvider.cart[0].catatan, 'Note');
    });
  });
}
