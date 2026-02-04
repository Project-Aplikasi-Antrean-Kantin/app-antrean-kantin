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
  String namaPembeli;
  String? urlQris;
  DateTime? expiredQris;

  CashierTransaction({
    required this.namaPembeli,
    required this.status,
    required this.kodePemesanan,
    required this.orderTenant,
    required this.id,
    required this.userId,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    required this.listTransaksiDetail,
    this.urlQris,
    this.expiredQris,
  });

  @override
  String toString() {
    return 'PesananModel(kodePemesanan: $status), listTransaksiDetail: $listTransaksiDetail';
  }

  //copy with
  CashierTransaction copyWith({
    int? id,
    int? orderTenant,
    int? userId,
    int? total,
    String? kodePemesanan,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ListTransaksiDetail>? listTransaksiDetail,
    String? status,
    String? urlQris,
    DateTime? expiredQris,
  }) =>
      CashierTransaction(
        namaPembeli: this.namaPembeli,
        status: status ?? this.status,
        kodePemesanan: kodePemesanan ?? this.kodePemesanan,
        orderTenant: orderTenant ?? this.orderTenant,
        id: id ?? this.id,
        userId: userId ?? this.userId,
        total: total ?? this.total,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        listTransaksiDetail: listTransaksiDetail ?? this.listTransaksiDetail,
        urlQris: urlQris ?? this.urlQris,
        expiredQris: expiredQris ?? this.expiredQris,
      );

  factory CashierTransaction.fromJson(Map<String, dynamic> json) {
    return CashierTransaction(
      namaPembeli: json["nama_pembeli"] ?? "Tanpa Nama",
      status: json["status"],
      kodePemesanan: json["kode_pemesanan"],
      orderTenant: json["order_tenant"],
      id: json["id"],
      userId: json["user_id"],
      total: json["total"],
      createdAt: DateTime.parse(json["created_at"]).toLocal(),
      updatedAt: DateTime.parse(json["updated_at"]).toLocal(),

      // aman walaupun null
      urlQris: json["qr_url"] as String?,

      // parse date hanya kalau tidak null
      expiredQris: json["expiry"] != null && json["expiry"] != ""
          ? DateTime.parse(json["expiry"]).toLocal()
          : null,

      listTransaksiDetail: List<ListTransaksiDetail>.from(
        json["details"].map((x) => ListTransaksiDetail.fromJson(x)),
      ),
    );
  }
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
          tenantId: detail.menus!.tenants!.id.toString(),
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
