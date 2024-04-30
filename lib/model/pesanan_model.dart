import 'package:testgetdata/model/ruangan_model.dart';
import 'package:testgetdata/model/transaksi_detail_model.dart';

class Pesanan {
  final int id;
  final int userId;
  final String status;
  int? ruanganId;
  final int total;
  final int ongkosKirim;
  final int biayaLayanan;
  final int isAntar;
  final String metodePembayaran;
  final String subTotal;
  String? gedung;
  String? namaRuangan;
  final List<ListTransaksiDetail> listTransaksiDetail;
  Ruangan? ruangan;

  Pesanan({
    required this.id,
    required this.userId,
    required this.status,
    this.ruanganId,
    required this.total,
    required this.ongkosKirim,
    required this.biayaLayanan,
    required this.isAntar,
    required this.metodePembayaran,
    required this.subTotal,
    this.gedung,
    this.namaRuangan,
    required this.listTransaksiDetail,
    this.ruangan,
  });

  factory Pesanan.fromJson(Map<String, dynamic> json) => Pesanan(
        id: json["id"],
        userId: json["user_id"],
        status: json["status"],
        ruanganId: json["ruangan_id"],
        total: json["total"],
        ongkosKirim: json["ongkos_kirim"],
        biayaLayanan: json["biaya_layanan"],
        isAntar: json["isAntar"],
        metodePembayaran: json["metode_pembayaran"],
        subTotal: json["sub_total"],
        gedung: json["gedung"],
        namaRuangan: json["nama_ruangan"],
        listTransaksiDetail: List<ListTransaksiDetail>.from(
            json["list_transaksi_detail"]
                .map((x) => ListTransaksiDetail.fromJson(x))),
        // ruangan: Ruangan.fromJson(json["ruangan"]),
      );
}
