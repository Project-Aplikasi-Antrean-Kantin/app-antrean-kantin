import 'package:testgetdata/data/model/cashback.dart';

class Voucher {
  int id;
  int qty;
  DateTime createdAt;
  DateTime updatedAt;
  Cashback cashback;

  Voucher(
      {required this.id,
      required this.qty,
      required this.createdAt,
      required this.updatedAt,
      required this.cashback});

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'],
      qty: json['quantity'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      cashback: Cashback.fromJson(json['cashback']),
    );
  }

  String toString() =>
      'Voucher(id: $id, qty: $qty, createdAt: $createdAt, updatedAt: $updatedAt, cashback: $cashback)';
}
