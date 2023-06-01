import 'package:flutter/foundation.dart';

class TenantFoods {
  final int id;
  final String name;
  final String subname;
  final String gambar;
  final category;
  final List<dynamic> foods;

  TenantFoods({
    required this.id,
    required this.name,
    required this.subname,
    required this.gambar,
    required this.foods,
    required this.category,
  });

  factory TenantFoods.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final category = json['category'];
    return TenantFoods(
        id: data['id'],
        name: data['name'],
        subname: data['subname'],
        gambar: data['gambar'],
        foods: data['foods'],
        category: category);
  }
}
