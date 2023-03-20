class tenant{
  final int id;
  final String name;
  final String gambar;
  final List<dynamic> foods;

  tenant({
    required this.id,
    required this.name,
    required this.gambar,
    required this.foods,
  });

  factory tenant.fromJson(Map<String, dynamic> json){
    return tenant(id: json['id'], name: json['name'], gambar: json['gambar'], foods: json['foods']);
  }
}