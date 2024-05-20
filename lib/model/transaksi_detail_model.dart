import 'package:testgetdata/model/menu_kelola_model.dart';
import 'package:testgetdata/model/tenant_foods.dart';

class ListTransaksiDetail {
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

  ListTransaksiDetail({
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

  factory ListTransaksiDetail.fromJson(Map<String, dynamic> json) =>
      ListTransaksiDetail(
        id: json["id"],
        transaksiId: json["transaksi_id"],
        jumlah: json["jumlah"],
        harga: json["harga"],
        status: json["status"],
        catatan: json["catatan"],
        createdAt: DateTime.parse(json["created_at"]),
        menusKelolaId: json["menus_kelola_id"],
        namaMenu: json["nama_menu"] ?? '-',
        kategoriMenu: json["kategori_menu"] ?? '-',
        //menus: TenantFoods.fromJson(json["menus"]),
        menus:
            json["menus"] != null ? TenantFoods.fromJson(json["menus"]) : null,
      );
}
