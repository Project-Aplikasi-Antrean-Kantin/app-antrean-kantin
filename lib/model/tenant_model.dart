class TenantModel {
  final int id;
  final String name;
  final String subname;
  final String gambar;
  final range;
  final List<dynamic> foods;

  TenantModel(
      {required this.id,
      required this.name,
      required this.gambar,
      required this.subname,
      required this.range,
      required this.foods});

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
        id: json['id'],
        name: json['name'],
        gambar: json['gambar'],
        subname: json['subname'],
        range: json['range'],
        foods: json['foods']);
  }
}
