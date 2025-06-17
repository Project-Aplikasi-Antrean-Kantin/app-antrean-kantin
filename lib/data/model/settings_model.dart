class SettingsModel {
  final int id;
  final String nama;
  final String nilai;
  final DateTime createdAt;
  final DateTime updatedAt;

  SettingsModel({
    required this.id,
    required this.nama,
    required this.nilai,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
        id: json["id"],
        nama: json["nama"],
        nilai: json["nilai"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "nilai": nilai,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
