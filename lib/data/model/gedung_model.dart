class Gedung {
  final int id;
  final String nama;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic deletedAt;

  Gedung({
    required this.id,
    required this.nama,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory Gedung.fromJson(Map<String, dynamic> json) => Gedung(
        id: json["id"],
        nama: json["nama"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
      };
}
