import 'package:testgetdata/data/model/tenant_foods.dart';

class TransaksiDetail {
  final int id;
  final int transaksiId;
  final int jumlah;
  final int harga;
  final String status;
  String? catatan;
  int? menusKelolaId;
  final String namaMenu;
  final DateTime createdAt;
  final String kategoriMenu;
  TenantFoods? menus;

  TransaksiDetail({
    required this.id,
    required this.transaksiId,
    required this.jumlah,
    required this.harga,
    required this.status,
    this.catatan,
    required this.menusKelolaId,
    required this.namaMenu,
    required this.createdAt,
    required this.kategoriMenu,
    this.menus,
  });

  //copy with
  TransaksiDetail copyWith({
    int? id,
    int? transaksiId,
    int? jumlah,
    int? harga,
    String? status,
    String? catatan,
    int? menusKelolaId,
    String? namaMenu,
    DateTime? createdAt,
    String? kategoriMenu,
    TenantFoods? menus,
  }) {
    return TransaksiDetail(
      id: id ?? this.id,
      transaksiId: transaksiId ?? this.transaksiId,
      jumlah: jumlah ?? this.jumlah,
      harga: harga ?? this.harga,
      status: status ?? this.status,
      catatan: catatan ?? this.catatan,
      menusKelolaId: menusKelolaId ?? this.menusKelolaId,
      namaMenu: namaMenu ?? this.namaMenu,
      createdAt: createdAt ?? this.createdAt,
      kategoriMenu: kategoriMenu ?? this.kategoriMenu,
      menus: menus ?? this.menus,
    );
  }

  @override
  String toString() {
    return 'tenantfoods: $menus';
  }

  factory TransaksiDetail.fromJson(Map<String, dynamic> json) =>
      TransaksiDetail(
        id: json["id"],
        transaksiId: json["transaksi_id"] ?? json["cashier_id"] ?? 0,
        jumlah: json["jumlah"],
        harga: json["harga"],
        status: json["status"] ?? "cashier",
        catatan: json["catatan"],
        createdAt: DateTime.parse(json["created_at"]),
        menusKelolaId: json["menus_kelola_id"] ?? json["menu_id"],
        namaMenu: json["nama_menu"] ??
            json["menu"]["nama"] ??
            json["menu"]["nama_menu"],
        kategoriMenu: json["kategori_menu"] ?? "-",
        //menus: TenantFoods.fromJson(json["menus"]),
        menus: json["menus"] != null
            ? TenantFoods.fromJson(json["menus"])
            : json["menu"] != null
                ? TenantFoods.fromJson(json["menu"])
                : null,
      );
}
