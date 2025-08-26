import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/chat.dart';

class ChatRemoteDataSource {
  Future<Chat> sendMessage(
      String token, String message, String chatType, String id) async {
    print("token: $token, message: $message, chatType: $chatType, id: $id");
    print("${MasbroConstants.url}/transaksi/$id/chat");
    try {
      final result = await http.post(
          Uri.parse("${MasbroConstants.url}/transaksi/$id/chat"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json"
          },
          body: jsonEncode({"message": message, "chat_type": chatType}));

      final json = jsonDecode(result.body);
      print(json);

      if (result.statusCode == 200) {
        print("berhasil ini loh $json");
        final chat = Chat.fromJson(json["data"]);
        return chat;
      } else if (result.statusCode == 400) {
        throw jsonDecode(result.body)["message"];
      } else {
        throw Exception(json['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Chat>> getChat(
      String token, String id, String destination) async {
    try {
      final result = await http.get(
        Uri.parse("${MasbroConstants.url}/transaksi/$id/chat/$destination"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      );

      print("Status code: ${result.statusCode}");
      print("Body: ${result.body}");

      if (result.statusCode == 200) {
        final List<dynamic> data = jsonDecode(result.body);

        // Convert tiap index ke Chat
        return data.map((item) => Chat.fromJson(item)).toList();
      } else {
        throw Exception("HTTP ${result.statusCode}: ${result.body}");
      }
    } catch (e) {
      rethrow;
    }
  }
}
