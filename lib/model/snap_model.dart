import 'package:flutter/material.dart';

class Snap {
  final String token;
  final String redirectUrl;

  Snap({
    required this.token,
    required this.redirectUrl,
  });

  factory Snap.fromJson(Map<String, dynamic> json) => Snap(
        token: json["token"],
        redirectUrl: json["redirect_url"],
      );
}
