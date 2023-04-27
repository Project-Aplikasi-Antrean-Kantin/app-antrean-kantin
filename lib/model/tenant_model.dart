class TenantModel{
  final int id;
  final String name;
  final String subname;
  final String gambar;

  TenantModel({
    required this.id,
    required this.name,
    required this.gambar,
    required this.subname
  });

  factory TenantModel.fromJson(Map<String, dynamic> json){
    return TenantModel(id: json['id'], name: json['name'], gambar: json['gambar'], subname: json['subname']);
  }
}