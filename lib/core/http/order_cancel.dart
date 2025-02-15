import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:testgetdata/core/constants.dart';

Future<bool?> orderCanceled(int id) async {
  final response = await http.post(
    Uri.parse(
      '${MasbroConstants.baseUrl}/order/cancel/$id',
    ),
    headers: {
      "content-type": "application/json",
      // "Authorization": "Bearer $tokenid"
    },
  );
  if (response.hashCode == 201) {
    return true;
  } else {
    return false;
  }
}
