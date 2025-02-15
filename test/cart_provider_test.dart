import 'package:flutter_test/flutter_test.dart';
import 'package:testgetdata/data/provider/cart_provider.dart';

void main() {
  group('CartProvider', () {
    late CartProvider cartProvider;

    setUp(() {
      cartProvider = CartProvider();
    });

    test('addItemToCartOrUpdateQuantity adds a new item', () {
      cartProvider.addItemToCartOrUpdateQuantity(
          1, 'Test Item', 100, 'image.png', 'Tenant', 'Description', true);

      expect(cartProvider.cart.length, 1);
      expect(cartProvider.cart[0].menuId, 1);
      expect(cartProvider.cart[0].count, 1);
      expect(cartProvider.totalItemCount, 1);
      expect(cartProvider.deliveryCost, 100);
    });

    test('addItemToCartOrUpdateQuantity increments an existing item', () {
      cartProvider.addItemToCartOrUpdateQuantity(
          1, 'Test Item', 100, 'image.png', 'Tenant', 'Description', true);
      cartProvider.addItemToCartOrUpdateQuantity(
          1, 'Test Item', 100, 'image.png', 'Tenant', 'Description', true);

      expect(cartProvider.cart.length, 1);
      expect(cartProvider.cart[0].count, 2);
      expect(cartProvider.totalItemCount, 2);
      expect(cartProvider.deliveryCost, 200);
    });

    test('addItemToCartOrUpdateQuantity decrements an existing item', () {
      cartProvider.addItemToCartOrUpdateQuantity(
          1, 'Test Item', 100, 'image.png', 'Tenant', 'Description', true);
      cartProvider.addItemToCartOrUpdateQuantity(
          1, 'Test Item', 100, 'image.png', 'Tenant', 'Description', false);

      expect(cartProvider.cart.length, 0);
      expect(cartProvider.totalItemCount, 0);
      expect(cartProvider.deliveryCost, 0);
    });

    test('clearCart clears the cart', () {
      cartProvider.addItemToCartOrUpdateQuantity(
          1, 'Test Item', 100, 'image.png', 'Tenant', 'Description', true);
      cartProvider.clearCart();

      expect(cartProvider.cart.length, 0);
      expect(cartProvider.isCartVisible, false);
      expect(cartProvider.deliveryCost, 0);
      expect(cartProvider.totalItemCount, 0);
    });

    test('getTotal calculates total price including service', () {
      cartProvider.addItemToCartOrUpdateQuantity(
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
      cartProvider.addItemToCartOrUpdateQuantity(
          1, 'Test Item', 100, 'image.png', 'Tenant', 'Description', true);
      cartProvider.addNote(1, 'Note');

      expect(cartProvider.cart[0].catatan, 'Note');
    });
  });
}
