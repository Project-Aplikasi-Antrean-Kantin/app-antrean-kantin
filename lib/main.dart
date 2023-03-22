import 'dart:js';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/provider/cart_provider.dart';
import 'views/list_tenant.dart';
import 'package:testgetdata/views/cart.dart';
import '';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => CartProvider(),
      child: ListTenant(),
    )
  );
}

//ini main.dartku dan
// import 'package:flutter/material.dart';
// import 'views/tenant.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'MasBro',
//       theme: ThemeData(),
//       home: const Tenant(),
//     );
//   }
// }