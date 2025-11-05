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
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final transaksiData = json["data"]["transaksi"];

    // Cek apakah transaksi berupa list atau object tunggal
    final pesanan = (transaksiData is List && transaksiData.isNotEmpty)
        ? Pesanan.fromJson(transaksiData[0])
        : Pesanan.fromJson(transaksiData);

    return OrderModel(
      status: json["status"],
      messages: json["messages"],
      pesanan: pesanan,
      snap: json["snap"] != null ? Snap.fromJson(json["snap"]) : null,
    );
  }
}
