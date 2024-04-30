class CartMenuModel {
  final int id;
  final int jumlah;
  final int harga;

  CartMenuModel({
    required this.id,
    required this.jumlah,
    required this.harga,
  });

  factory CartMenuModel.fromJson(Map<String, dynamic> json) => CartMenuModel(
        id: json["id"],
        jumlah: json["jumlah"],
        harga: json["harga"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "jumlah": jumlah,
        "harga": harga,
      };
}
