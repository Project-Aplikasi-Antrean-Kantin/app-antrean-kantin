import 'package:testgetdata/data/model/transaksi_detail_model.dart';

class CashierTransaction {
  int id;
  int userId;
  int total;
  DateTime createdAt;
  DateTime updatedAt;
  List<ListTransaksiDetail> listTransaksiDetail;

  CashierTransaction({
    required this.id,
    required this.userId,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    required this.listTransaksiDetail,
  });

  factory CashierTransaction.fromJson(Map<String, dynamic> json) =>
      CashierTransaction(
        id: json["id"],
        userId: json["user_id"],
        total: json["total"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        listTransaksiDetail: List<ListTransaksiDetail>.from(
            json["details"].map((x) => ListTransaksiDetail.fromJson(x))),
      );
}
