import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/transaksi_detail_model.dart';

class CashierTransaction {
  int id;
  int orderTenant;
  int userId;
  int total;
  String kodePemesanan;
  DateTime createdAt;
  DateTime updatedAt;
  List<ListTransaksiDetail> listTransaksiDetail;
  String status;

  CashierTransaction({
    required this.status,
    required this.kodePemesanan,
    required this.orderTenant,
    required this.id,
    required this.userId,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    required this.listTransaksiDetail,
  });

  factory CashierTransaction.fromJson(Map<String, dynamic> json) =>
      CashierTransaction(
        status: json["status"],
        kodePemesanan: json["kode_pemesanan"],
        orderTenant: json["order_tenant"],
        id: json["id"],
        userId: json["user_id"],
        total: json["total"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        listTransaksiDetail: List<ListTransaksiDetail>.from(
            json["details"].map((x) => ListTransaksiDetail.fromJson(x))),
      );
}

extension CashierTransactionToCartExtension on CashierTransaction {
  List<CartMenuModel> toCartMenuList() {
    return listTransaksiDetail.map((detail) {
      if (detail.menus != null) {
        return CartMenuModel.fromTenantFoods(tenantFoods: detail.menus!)
            .copyWith(
          count: detail.jumlah,
          catatan: detail.catatan,
        );
      } else {
        return CartMenuModel(
          menuId: detail.menusKelolaId ?? 0,
          menuNama: detail.namaMenu,
          menuPrice: detail.harga,
          count: detail.jumlah,
          isReady: 1,
          kategoriId: 0,
          menuGambar: '',
          catatan: detail.catatan,
        );
      }
    }).toList();
  }
}
