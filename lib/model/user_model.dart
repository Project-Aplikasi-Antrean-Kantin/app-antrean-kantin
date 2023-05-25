class UserModel {
  final int id;
  final String name;
  final String email;
  final String token;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.token,
    required this.email,
    required this.role
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      token: json['token'],
      email: json['email'],
      role: json['role'],
    );
  }
}
