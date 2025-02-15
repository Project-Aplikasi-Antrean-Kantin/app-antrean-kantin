import 'package:testgetdata/data/model/fitur_model.dart';

class UserModel {
  final String nama;
  final String email;
  final String token;
  final List<String> permission;
  final List<FiturModel> menu;

  UserModel({
    required this.nama,
    required this.email,
    required this.token,
    required this.permission,
    required this.menu,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        nama: json["nama"],
        email: json["email"],
        // url: json["url"],
        token: json["token"],
        menu: json['menu']
            .map<FiturModel>((menu) => FiturModel.fromJson(menu))
            .toList(),
        permission: json["permission"].cast<String>(),
      );
}
