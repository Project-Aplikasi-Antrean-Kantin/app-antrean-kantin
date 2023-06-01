import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/provider/user_provider.dart';
import 'package:testgetdata/views/home/navbar_home.dart';
import 'package:testgetdata/views/login.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  static const int profileIndex = 2;

  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    return Scaffold(
        body: Center(
            child: OutlinedButton(
                onPressed: () async {
                  final response = await http.post(
                      Uri.parse("http://masbrocanteen.me/api/logout"),
                      headers: {"content-type": "application/json"},
                      body: jsonEncode({"id": await provider.id}));
                  print(response.body);
                  if (response.statusCode == 200) {
                    provider.putToken("");
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => Login()));
                  }
                },
                child: Text("Logout"))),
        bottomNavigationBar: NavbarHome(
          pageIndex: ProfilePage.profileIndex,
        ));
  }
}
