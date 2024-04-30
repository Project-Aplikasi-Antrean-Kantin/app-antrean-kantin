import 'package:testgetdata/model/gedung_model.dart';

class Ruangan {
  final int id;
  final String nama;
  final int gedungId;
  final String namaRuangan;
  final Gedung gedung;

  Ruangan({
    required this.id,
    required this.nama,
    required this.gedungId,
    required this.namaRuangan,
    required this.gedung,
  });

  factory Ruangan.fromJson(Map<String, dynamic> json) => Ruangan(
        id: json["id"],
        nama: json["nama"],
        gedungId: json["gedung_id"],
        namaRuangan: json["nama_ruangan"],
        gedung: Gedung.fromJson(json["gedung"]),
      );
}
