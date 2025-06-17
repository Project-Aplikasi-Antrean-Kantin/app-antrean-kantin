class CoinTransactionModel {
  final int id;
  final int userId;
  final int jumlah;
  final String tipe;
  final String deskripsi;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic deletedAt;

  CoinTransactionModel({
    required this.id,
    required this.userId,
    required this.jumlah,
    required this.tipe,
    required this.deskripsi,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory CoinTransactionModel.fromJson(Map<String, dynamic> json) =>
      CoinTransactionModel(
        id: json["id"],
        userId: json["user_id"],
        jumlah: json["jumlah"],
        tipe: json["tipe"],
        deskripsi: json["deskripsi"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "jumlah": jumlah,
        "tipe": tipe,
        "deskripsi": deskripsi,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
      };
}
