import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();
    return Scaffold(
        body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(400, 40),
                        backgroundColor: Colors.redAccent
                      ),
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
                        child: Text("Logout", style: TextStyle(
                          color: Colors.white
                        ),)),
                  )
                ],
              ),
            )
    ),
        bottomNavigationBar: NavbarHome(
          pageIndex: ProfilePage.profileIndex,
        ));
  }
}
