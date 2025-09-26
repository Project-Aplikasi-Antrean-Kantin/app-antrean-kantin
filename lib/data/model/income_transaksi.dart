import 'package:intl/intl.dart';

class IncomeTransaksi {
  int id;
  String status;
  int harga;
  int pendapatanBersih;
  DateTime tanggal;
  String label;

  IncomeTransaksi({
    required this.id,
    required this.status,
    required this.harga,
    required this.pendapatanBersih,
    required this.tanggal,
    required this.label,
  });

  factory IncomeTransaksi.fromJson(Map<String, dynamic> json) {
    final formatter = DateFormat("dd-MM-yyyy HH:mm:ss"); // sesuai format API

    return IncomeTransaksi(
      id: json['id'],
      status: json['status'],
      harga: json['harga'],
      pendapatanBersih: json['pendapatan_bersih'],
      tanggal: formatter.parse(json['tanggal']), // parsing custom format
      label: json['label'],
    );
  }
}
