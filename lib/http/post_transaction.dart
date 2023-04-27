import 'dart:convert';

import 'package:http/http.dart' as http;

Future<bool?> createTransaction(List<int> data) async{
  final response = await http.post(
    Uri.parse('https://www.masbrocanteen.my.id/public/api/transaction'),
    headers: {"content-type": "application/json"},
    body: jsonEncode({
      "data": data
    })
  );
  if(response.hashCode == 201){
    return true;
  }else{
    return false;
  }
}