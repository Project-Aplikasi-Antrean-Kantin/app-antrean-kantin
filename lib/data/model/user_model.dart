import 'package:testgetdata/data/model/fitur_model.dart';

class UserModel {
  final String nama;
  final String email;
  final String token;
  final List<String> role;
  final List<String> permission;
  final List<FiturModel> menu;
  bool? isOnline;

  UserModel({
    required this.nama,
    required this.email,
    required this.token,
    required this.role,
    required this.permission,
    required this.menu,
    this.isOnline,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        nama: json["nama"],
        email: json["email"],
        // url: json["url"],
        token: json["token"],
        menu: json['menu']
            .map<FiturModel>((menu) => FiturModel.fromJson(menu))
            .toList(),
        role: List<String>.from(json["role"].map((x) => x)),
        permission: json["permission"].cast<String>(),
        // isOnline: json["isOnline"] == 1 ? true : false,
        isOnline: json["isOnline"] == 1 ? true : false,
        // isOnline:
        //     json["isOnline"] is bool ? json["isOnline"] : json["isOnline"] == 1,
      );
}
