// food_item.dart
// model update menu tenant
class FoodItem {
  final String name;
  final String price;
  bool isReadyStock;
  bool available;

  FoodItem({
    required this.isReadyStock,
    required this.name,
    required this.price,
    this.available = true,
  });
}
