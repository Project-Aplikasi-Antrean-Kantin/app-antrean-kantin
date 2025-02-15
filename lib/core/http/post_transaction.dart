// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// Future<bool?> createTransaction(List<int> data) async {
//   final response =
//       await http.post(Uri.parse('http://masbrocanteen.me/api/transaction'),
//           headers: {
//             "content-type": "application/json",
//             // "Authorization": "Bearer $tokenid"
//           },
//           body: jsonEncode({"data": data}));
//   if (response.hashCode == 201) {
//     return true;
//   } else {
//     return false;
//   }
// }
