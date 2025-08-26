import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/snap_model.dart';

class OrderModel {
  final String status;
  final String messages;
  final Pesanan pesanan;
  Snap? snap;
  // final int orderId;

  OrderModel({
    required this.pesanan,
    required this.status,
    required this.messages,
    this.snap,
    // required this.orderId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        status: json["status"],
        messages: json["messages"],
        pesanan: Pesanan.fromJson(json["data"]["transaksi"]),
        snap: json["snap"] != null ? Snap.fromJson(json["snap"]) : null,
        // orderId: json["order_id"],
      );
}
