class CartModel{
  final int menuId;
  final String menuNama;
  final int menuPrice;
  final String menuGambar;
  var count;

  CartModel({
    required this.menuId,
    required this.menuGambar,
    required this.menuNama,
    required this.menuPrice,
    required this.count,
  });


}