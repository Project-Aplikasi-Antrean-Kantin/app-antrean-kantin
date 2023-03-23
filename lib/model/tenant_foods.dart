class TenantFoods{
  final int id;
  final String name;
  final String gambar;
  final List<dynamic> foods;

  TenantFoods({
    required this.id,
    required this.name,
    required this.gambar,
    required this.foods,
  });

  factory TenantFoods.fromJson(Map<String, dynamic> json){
    return TenantFoods(id: json['id'], name: json['name'], gambar: json['gambar'], foods: json['foods']);
  }
}