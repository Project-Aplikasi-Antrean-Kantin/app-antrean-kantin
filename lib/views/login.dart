import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testgetdata/http/login.dart';
import 'package:testgetdata/provider/user_provider.dart';
import 'package:testgetdata/views/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/http/login.dart';
import 'package:testgetdata/views/home/navbar_home.dart';
import 'package:testgetdata/views/tenant.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var showPassword = true;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  halamanDirect(isDosen) {
    isDosen
        ? Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
            return Tenant();
          }))
        : Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
            return const SplashScreen();
          }));
  }

  @override
  Widget build(BuildContext context) {
    print(showPassword);
    return Scaffold(
      backgroundColor: const Color(0xF8F8F8F8),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Welcome Back',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 32),
          ),
          Text('Sign in to your account',
          style: GoogleFonts.poppins(
              color: Colors.black45,
              fontWeight: FontWeight.normal,
              fontSize: 15),
          ),
          const SizedBox(
            height: 10,
          ),
          Text('Email',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.normal,
                fontSize: 16),
          ),
          const SizedBox(height: 3),
          TextFormField(
            cursorColor: Colors.redAccent,
            controller: email,
            decoration: InputDecoration(
              fillColor: Colors.white,
              hintText: 'Your email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Harap isi email terlebih dahulu';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Text('Password',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.normal,
                fontSize: 16),
          ),
          const SizedBox(height: 3),
          TextFormField(
            obscureText: showPassword,
            controller: password,
            decoration: InputDecoration(
              fillColor: Colors.white,
              suffixIcon: showPassword
                  ? IconButton(
                      icon: const Icon(Icons.remove_red_eye),
                      onPressed: () => setState(() {
                        showPassword = !showPassword;
                      }),
                    )
                  : IconButton(
                      icon: const Icon(Icons.remove_red_eye_outlined),
                      onPressed: () => setState(() {
                        showPassword = !showPassword;
                      }),
                    ),
              hintText: 'Your password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Harap isi password terlebih dahulu';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          Text('Forgot Password?',
            style: GoogleFonts.poppins(
                color: Colors.redAccent,
                fontWeight: FontWeight.normal,
                fontSize: 15),
          ),
          const SizedBox(height: 20),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (email.text.isEmpty || password.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Harap isi data terlebih dahulu")),
                );
              } else {
// <<<<<<< HEAD
                LoginFuture(email.text, password.text).then((user) {
                  Provider.of<UserProvider>(context, listen: false)
                      .setUserModel(user);
                  print(user.role);
                  final isDosen = user.role == "Dosen" ? true : false;
                  if (user.token.isNotEmpty)
                    halamanDirect(isDosen);
                  else
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              "Email or password cannot find in own records")),
                    );
// =======
//                 LoginFuture(email.text, password.text).then((value) {
//                   print(value);
//                   if (value != 'gagal') {
//                     Navigator.pushReplacement(context,
//                         MaterialPageRoute(builder: (context) {
//                       return NavbarHome(token: value);
//                     }));
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                         content: Text("Email or password cannot find in own records")),
//                   );
//                   }
// >>>>>>> 8bc57d4e98bddb6121351cf79e84c72a983a3db6
                });
              }
            },
            child: Center(
              child: Container(
                height: 47,
                width: 213,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.redAccent),
                child: Center(
                    child: Text("LOGIN",
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16))),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
