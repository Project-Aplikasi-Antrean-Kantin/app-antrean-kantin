import 'package:testgetdata/data/model/cart_menu_modelllll.dart';

class CartPerTenant {
  String tenantName;
  String tenantGambar;
  String tenantId;
  List<CartMenuModel>? cartMenuList;

  CartPerTenant({
    required this.tenantName,
    required this.tenantGambar,
    required this.tenantId,
    this.cartMenuList,
  });

  Map<String, dynamic> toJson() => {
        'tenantName': tenantName,
        'tenantGambar': tenantGambar,
        'tenantId': tenantId,
        'cartMenuList':
            cartMenuList?.map((item) => item.toJson()).toList() ?? [],
      };
  CartPerTenant copyWith({
    String? tenantName,
    String? tenantGambar,
    String? tenantId,
    List<CartMenuModel>? cartMenuList,
  }) {
    return CartPerTenant(
      tenantName: tenantName ?? this.tenantName,
      tenantGambar: tenantGambar ?? this.tenantGambar,
      tenantId: tenantId ?? this.tenantId,
      cartMenuList: cartMenuList ?? this.cartMenuList,
    );
  }

  @override
  String toString() {
    return 'CartPerTenant(tenantId: $tenantId, tenantName: $tenantName, tenantGambar: $tenantGambar, cartMenuList: $cartMenuList)';
  }
}
