import 'package:intl/intl.dart';
import 'package:testgetdata/data/model/income_transaksi.dart';

class Income {
  List<String> labels;
  List<int> totalPesananSelesai;
  List<int> totalPesananRefund;
  Map<String, List<IncomeTransaksi>> listIncomeTransaksi;
  int totalPendapatan;

  Income({
    required this.totalPendapatan,
    required this.labels,
    required this.listIncomeTransaksi,
    required this.totalPesananSelesai,
    required this.totalPesananRefund,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    final transaksiList = List<IncomeTransaksi>.from(
      json['transaksi'].map((x) => IncomeTransaksi.fromJson(x)),
    );

    final Map<String, List<IncomeTransaksi>> grouped = {};
    for (var t in transaksiList) {
      grouped.putIfAbsent(t.label, () => []);
      grouped[t.label]!.add(t);
    }

    return Income(
      labels: List<String>.from(json['labels'].map((x) => x.toString())),
      totalPesananSelesai:
          List<int>.from(json['selesaiData'].map((x) => x as int)),
      totalPendapatan: json['totalPendapatan'],
      totalPesananRefund:
          List<int>.from(json['refundData'].map((x) => x as int)),
      listIncomeTransaksi: grouped,
    );
  }

  // langsung taruh di model
  String getLabelBySortInPendapatanSort(String selectedSort, String labelKey) {
    final transaksiList = listIncomeTransaksi[labelKey];
    if (transaksiList == null || transaksiList.isEmpty) return "";

    transaksiList.sort((a, b) => a.tanggal.compareTo(b.tanggal));

    if (selectedSort == "Minggu") {
      DateTime tanggal;

      // Parse tanggal dari label (format: dd-MM-yyyy)
      tanggal = DateFormat("dd-MM-yyyy").parse(transaksiList.first.label);

      return DateFormat("dd MMM yyyy", "id_ID").format(tanggal);
    }

    if (selectedSort == "Bulan") {
      final start = transaksiList.first.tanggal.subtract(
          Duration(days: transaksiList.first.tanggal.weekday - 1)); // Senin
      final end = start.add(const Duration(days: 6)); // Minggu
      final formatter = DateFormat("dd MMM yyyy", "id_ID");
      return "${formatter.format(start)} - ${formatter.format(end)}";
    }

    if (selectedSort == "Tahun") {
      final bulan = transaksiList.first.tanggal;
      return DateFormat("MMMM yyyy", "id_ID").format(bulan);
    }

    return "";
  }

  String getLabelBySort(String selectedSort, DateTime date) {
    final allTransaksi = listIncomeTransaksi.values.expand((e) => e).toList();

    // kalau ada data transaksi → pake data transaksi
    if (allTransaksi.isNotEmpty) {
      allTransaksi.sort((a, b) => a.tanggal.compareTo(b.tanggal));

      if (selectedSort == "Minggu") {
        final start = date.subtract(Duration(days: date.weekday - 1)); // Senin
        final end = start.add(const Duration(days: 6)); // Minggu
        final formatter = DateFormat("dd MMM yyyy", "id_ID");
        return "${formatter.format(start)} - ${formatter.format(end)}";
      }

      if (selectedSort == "Bulan") {
        final mid = allTransaksi[allTransaksi.length ~/ 2];
        return DateFormat("MMMM yyyy", "id_ID").format(mid.tanggal);
      }

      if (selectedSort == "Tahun") {
        return DateFormat("yyyy", "id_ID").format(allTransaksi.first.tanggal);
      }
    }

    // fallback kalau ga ada transaksi → pake date
    if (selectedSort == "Minggu") {
      // cari senin dan minggu dari tanggal tersebut
      final start = date.subtract(Duration(days: date.weekday - 1)); // Senin
      final end = start.add(const Duration(days: 6)); // Minggu
      final formatter = DateFormat("dd MMM yyyy", "id_ID");
      return "${formatter.format(start)} - ${formatter.format(end)}";
    }

    if (selectedSort == "Bulan") {
      return DateFormat("MMMM yyyy", "id_ID").format(date);
    }

    if (selectedSort == "Tahun") {
      return DateFormat("yyyy", "id_ID").format(date);
    }

    return "";
  }
}
