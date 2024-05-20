class CartMenuModel {
  final String tenantName;
  int menuId;
  final String menuNama;
  final int menuPrice;
  final String menuGambar;
  String? catatan;
  var count;
  bool isLoading;
  String? deskripsi;

  CartMenuModel({
    required this.tenantName,
    required this.menuId,
    required this.menuGambar,
    required this.menuNama,
    required this.menuPrice,
    this.deskripsi,
    required this.count,
    this.catatan,
    this.isLoading = false,
  });

  Map<String, dynamic> toJson() => {
        "id": menuId,
        "jumlah": count,
        "harga": menuPrice,
        "catatan": catatan,
      };
}
