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
    final data = json['data'];
    return TenantFoods(id: data['id'], name: data['name'], gambar: data['gambar'], foods: data['foods']);
  }
}