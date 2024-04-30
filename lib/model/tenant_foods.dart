import 'dart:convert';

import 'package:testgetdata/model/detail_menu_model.dart';

class TenantFoods {
  final int id;
  final String nama;
  final int kategoriId;
  DetailMenu? detailMenu;

  TenantFoods({
    required this.id,
    required this.nama,
    required this.kategoriId,
    this.detailMenu,
  });

  factory TenantFoods.fromJson(Map<String, dynamic> json) => TenantFoods(
        id: json["id"],
        nama: json["nama"],
        kategoriId: json["kategori_id"],
        detailMenu: json["detail_menu"] != null
            ? DetailMenu.fromJson(json["detail_menu"])
            : null,
      );
}
