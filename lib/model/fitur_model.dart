import 'package:meta/meta.dart';
import 'dart:convert';

class FiturModel {
  final int id;
  final String nama;
  String? url;
  final String kategori;
  String? ikon;
  final int urutan;
  final int aktif;

  FiturModel({
    required this.id,
    required this.nama,
    this.url,
    required this.kategori,
    this.ikon,
    required this.urutan,
    required this.aktif,
  });

  factory FiturModel.fromJson(Map<String, dynamic> json) => FiturModel(
        id: json["id"],
        nama: json["nama"],
        url: json["url"],
        kategori: json["kategori"],
        ikon: json["ikon"],
        urutan: json["urutan"],
        aktif: json["aktif"],
      );
}
