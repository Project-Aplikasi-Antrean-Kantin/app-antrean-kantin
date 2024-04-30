import 'package:testgetdata/model/menu_kelola_model.dart';

class ListTransaksiDetail {
  final int id;
  final int transaksiId;
  final int jumlah;
  final int harga;
  final String status;
  String? catatan;
  final int menusKelolaId;
  final String namaMenu;
  String? createdAt;
  final String kategoriMenu;
  final MenusKelola menusKelola;

  ListTransaksiDetail({
    required this.id,
    required this.transaksiId,
    required this.jumlah,
    required this.harga,
    required this.status,
    this.catatan,
    required this.menusKelolaId,
    required this.namaMenu,
    this.createdAt,
    required this.kategoriMenu,
    required this.menusKelola,
  });

  factory ListTransaksiDetail.fromJson(Map<String, dynamic> json) =>
      ListTransaksiDetail(
        id: json["id"],
        transaksiId: json["transaksi_id"],
        jumlah: json["jumlah"],
        harga: json["harga"],
        status: json["status"],
        catatan: json["catatan"],
        menusKelolaId: json["menus_kelola_id"],
        namaMenu: json["nama_menu"],
        kategoriMenu: json["kategori_menu"],
        menusKelola: MenusKelola.fromJson(json["menus_kelola"]),
      );
}
