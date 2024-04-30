// import 'package:flutter/material.dart';

// // Enum untuk peran pengguna
// enum UserRole { buyer, seller, delivery }

// // Enum untuk izin
// enum UserPermission { addMenu, manageOrders, deliver, allMenu }

// // user.permission.find()

// class User {
//   UserRole role;

//   User({required this.role});
// }

// // Kelas untuk mengelola izin
// class PermissionManager {
//   static Map<UserRole, List<UserPermission>> permissions = {
//     UserRole.buyer: [UserPermission.allMenu],
//     UserRole.seller: [UserPermission.addMenu, UserPermission.manageOrders],
//     UserRole.delivery: [UserPermission.deliver],
//   };

//   static bool hasPermission(UserRole role, UserPermission permission) {
//     return permissions[role]?.contains(permission) ?? false;
//   }
// }

// // Contoh Widget Flutter
// class RBACExample extends StatelessWidget {
//   final User user;

//   RBACExample({required this.user});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("RBAC Example"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             if (PermissionManager.hasPermission(
//               user.role,
//               UserPermission.addMenu,
//             ))
//               ElevatedButton(
//                 onPressed: () {
//                   // Logika untuk menambahkan menu
//                   print('User memiliki izin untuk melihat dashboard');
//                 },
//                 child: Text("Tambah Menu"),
//               ),
//             if (PermissionManager.hasPermission(
//               user.role,
//               UserPermission.manageOrders,
//             ))
//               ElevatedButton(
//                 onPressed: () {
//                   // Logika untuk mengelola pesanan
//                   print('User memiliki izin untuk melihat dashboard');
//                 },
//                 child: Text("Kelola Pesanan"),
//               ),
//             if (PermissionManager.hasPermission(
//               user.role,
//               UserPermission.deliver,
//             ))
//               ElevatedButton(
//                 onPressed: () {
//                   // Logika untuk mengantar pesanan
//                   print('User memiliki izin untuk melihat dashboard');
//                 },
//                 child: Text("Antar Pesanan"),
//               ),
//             if (PermissionManager.hasPermission(
//               user.role,
//               UserPermission.allMenu,
//             ))
//               ElevatedButton(
//                 onPressed: () {
//                   // Logika untuk mengelola pesanan
//                   print('User memiliki izin untuk melihat dashboard');
//                 },
//                 child: Text("List Menu"),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   User user =
//       User(role: UserRole.buyer); // Ganti peran pengguna sesuai kebutuhan

//   runApp(MaterialApp(
//     home: RBACExample(user: user),
//   ));
// }
