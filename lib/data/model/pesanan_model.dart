import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/gedung_model.dart';
import 'package:testgetdata/data/model/ruangan_model.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/data/model/transaksi_detail_model.dart';

class Pesanan {
  final int id;
  final int userId;
  final String status;
  final String? namaDriver;
  final String? fotoDriver;
  final String? buktiPengantaran;
  final int? multitenantId;
  String? catatan;
  String? kodePemesanan;
  int? ruanganId;
  final int total;
  final int ongkosKirim;
  final int biayaLayanan;
  final int isAntar;
  final String metodePembayaran;
  int? driverId;
  final String orderId;
  final int subTotal;
  String? gedung;
  String? namaRuangan;
  int? biayaAdmin;
  final List<TransaksiDetail> listTransaksiDetail;
  Ruangan? ruangan;
  String? namaPembeli;
  String? phone;
  String? catatanPenolakan;
  String? kodePenolakan;
  String? catatanLokasi;
  String? urlQris;
  DateTime? expiredQris;
  final DateTime createdAt;
  int? cashbackAmount;
  int? isPriority;
  int? totalQris;

  Pesanan({
    this.cashbackAmount,
    this.totalQris,
    this.namaDriver,
    this.fotoDriver,
    this.multitenantId,
    required this.id,
    this.kodePenolakan,
    this.buktiPengantaran,
    required this.userId,
    required this.status,
    required this.catatan,
    required this.kodePemesanan,
    this.ruanganId,
    required this.total,
    this.isPriority,
    required this.ongkosKirim,
    required this.biayaLayanan,
    required this.isAntar,
    required this.metodePembayaran,
    this.driverId,
    required this.orderId,
    required this.subTotal,
    this.gedung,
    this.namaRuangan,
    required this.listTransaksiDetail,
    this.ruangan,
    this.namaPembeli,
    this.phone,
    this.catatanPenolakan,
    this.catatanLokasi,
    this.biayaAdmin,
    this.urlQris,
    this.expiredQris,
    required this.createdAt,
  });
  @override
  String toString() {
    return 'PesananModel(kodePemesanan: $kodePemesanan, Status: $status DriverId: $driverId)';
  }

  static Pesanan getDummyPesanan() {
    final gedung = Gedung(
      ongkirMultitenant: 2000,
      ongkir: 5000,
      id: 5 + 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      deletedAt: null,
      nama: 'Gedung ${5 + 1}',
    );

    final ruangan = Ruangan(
      id: 5 + 1,
      nama: 'Ruang ${5 + 1}',
      gedungId: gedung.id,
      namaRuangan: 'Ruangan ${5 + 1}',
      gedung: gedung,
    );

    final tenant = TenantModel(
      id: 5 + 1,
      namaTenant: 'Tenant ${5 + 1}',
      namaKavling: 'Kavling B${5 + 1}',
      transaksiBerhasil: 100 + 5,
      gambar: 'https://example.com/image.jpg',
      userId: 10 + 5,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final food = TenantFoods(
      tenants: tenant,
      kategoriId: 1,
      isReady: 1,
      id: 5 + 1,
      nama: 'Makanan ${5 + 1}',
      deskripsi: 'Deskripsi makanan ${5 + 1}',
      harga: 10000 + (5 * 1000),
      gambar: 'https://example.com/food.jpg',
      tenantId: tenant.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final detail = TransaksiDetail(
      id: 5 + 1,
      transaksiId: 5 + 1,
      jumlah: 2 + 5,
      harga: 15000 + (5 * 500),
      status: 'selesai',
      catatan: 'Catatan ${5 + 1}',
      menusKelolaId: food.id,
      namaMenu: food.nama,
      createdAt: DateTime.now(),
      kategoriMenu: 'Minuman',
      menus: food,
    );

    return Pesanan(
      userId: 10,
      kodePemesanan: 'abc',
      catatan: 'Catatan ${5 + 1}',
      total: 10,
      ongkosKirim: 10,
      biayaLayanan: 10,
      isAntar: 1,
      metodePembayaran: 'Cash',
      orderId: "1",
      subTotal: 1,
      createdAt: DateTime.now(),
      id: 5 + 1,
      ruanganId: ruangan.id,
      ruangan: ruangan,
      status: 'selesai',
      listTransaksiDetail: [detail],
    );
  }

  factory Pesanan.fromJson(Map<String, dynamic> json) => Pesanan(
        id: json["id"],
        catatanPenolakan: json["catatan_penolakan"],
        catatanLokasi: json['catatan_lokasi_pengantaran'],
        buktiPengantaran: json["bukti_pengantaran"],
        kodePenolakan: json["verification_code"],
        userId: json["user_id"],
        status: json["status"],
        catatan: json["catatan"],
        totalQris: json["grand_total"],
        kodePemesanan: json["kode_pemesanan"],
        ruanganId: json["ruangan_id"],
        total: json["total"],
        ongkosKirim: json["ongkos_kirim"],
        biayaLayanan: json["biaya_layanan"],
        isAntar: json["isAntar"],
        metodePembayaran: json["metode_pembayaran"],
        driverId: json["driver_id"],
        orderId: json["order_id"],
        subTotal: json["sub_total"],
        multitenantId: json["multitenant_id"],
        gedung: json["gedung"],
        urlQris: json["qr_url"],
        cashbackAmount: json["cashback_amount"],
        isPriority: json["isPriority"] ?? 0,
        expiredQris:
            json["expiry"] != null ? DateTime.parse(json["expiry"]) : null,
        biayaAdmin: json["biaya_admin"],
        namaRuangan: json["nama_ruangan"],
        namaDriver: json["nama_driver"],
        fotoDriver: json["foto_driver"],
        listTransaksiDetail: List<TransaksiDetail>.from(
          json["list_transaksi_detail"].map((x) => TransaksiDetail.fromJson(x)),
        ),
        namaPembeli: json["nama_pembeli"],
        phone: json["user"]?["phone"] ?? "-",
        createdAt: DateTime.parse(json["updated_at"]).toLocal(),
        // ruangan: Ruangan.fromJson(json["ruangan"]),
      );

  Pesanan copyWith({
    int? id,
    int? userId,
    String? status,
    String? namaDriver,
    String? fotoDriver,
    String? buktiPengantaran,
    int? multitenantId,
    String? catatan,
    String? kodePemesanan,
    int? ruanganId,
    int? total,
    int? ongkosKirim,
    int? biayaLayanan,
    int? isAntar,
    String? metodePembayaran,
    int? driverId,
    String? orderId,
    int? subTotal,
    String? gedung,
    String? namaRuangan,
    int? biayaAdmin,
    List<TransaksiDetail>? listTransaksiDetail,
    Ruangan? ruangan,
    String? namaPembeli,
    String? phone,
    String? catatanPenolakan,
    String? catatanLokasi,
    String? urlQris,
    DateTime? expiredQris,
    DateTime? createdAt,
    int? cashbackAmount,
    int? isPriority,
  }) {
    return Pesanan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      namaDriver: namaDriver ?? this.namaDriver,
      fotoDriver: fotoDriver ?? this.fotoDriver,
      buktiPengantaran: buktiPengantaran ?? this.buktiPengantaran,
      multitenantId: multitenantId ?? this.multitenantId,
      catatan: catatan ?? this.catatan,
      kodePemesanan: kodePemesanan ?? this.kodePemesanan,
      ruanganId: ruanganId ?? this.ruanganId,
      total: total ?? this.total,
      ongkosKirim: ongkosKirim ?? this.ongkosKirim,
      biayaLayanan: biayaLayanan ?? this.biayaLayanan,
      isAntar: isAntar ?? this.isAntar,
      metodePembayaran: metodePembayaran ?? this.metodePembayaran,
      driverId: driverId ?? this.driverId,
      orderId: orderId ?? this.orderId,
      subTotal: subTotal ?? this.subTotal,
      gedung: gedung ?? this.gedung,
      namaRuangan: namaRuangan ?? this.namaRuangan,
      biayaAdmin: biayaAdmin ?? this.biayaAdmin,
      listTransaksiDetail: listTransaksiDetail ?? this.listTransaksiDetail,
      ruangan: ruangan ?? this.ruangan,
      namaPembeli: namaPembeli ?? this.namaPembeli,
      phone: phone ?? this.phone,
      catatanPenolakan: catatanPenolakan ?? this.catatanPenolakan,
      catatanLokasi: catatanLokasi ?? this.catatanLokasi,
      urlQris: urlQris ?? this.urlQris,
      expiredQris: expiredQris ?? this.expiredQris,
      createdAt: createdAt ?? this.createdAt,
      cashbackAmount: cashbackAmount ?? this.cashbackAmount,
      isPriority: isPriority ?? this.isPriority,
    );
  }
}

extension PesananToCartExtension on Pesanan {
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
