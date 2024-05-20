import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/exceptions/api_exception.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/views/components/custom_snackbar.dart';
import 'package:testgetdata/views/home/pages/navbar_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var showPassword = true;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xF8F8F8F8),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 32),
              ),
              Text(
                'Sign in to your account',
                style: GoogleFonts.poppins(
                    color: Colors.black45,
                    fontWeight: FontWeight.normal,
                    fontSize: 15),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Email',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.normal, fontSize: 16),
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
              Text(
                'Password',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.normal, fontSize: 16),
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
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  String? token = await FirebaseMessaging.instance.getToken();
                  print("ini token $token");
                  if (email.text.isEmpty || password.text.isEmpty) {
                    setState(() {
                      isLoading = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Harap isi data terlebih dahulu")),
                    );
                    setState(() {
                      isLoading = false;
                    });
                  } else {
                    setState(() {
                      isLoading = true;
                    });
                    try {
                      await authProvider.login(
                          email.text, password.text, token!);
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NavbarHome(
                            pageIndex: 0,
                          ),
                        ),
                      );
                    } catch (e) {
                      if (e is ApiException) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          CustomSnackBar(
                            status: e.status,
                            message: e.message,
                          ),
                        );
                      } else {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          CustomSnackBar(
                            status: 'failedP',
                            message: e.toString(),
                          ),
                        );
                      }
                    }
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                    fixedSize: const Size(double.infinity, 40)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: isLoading
                      ? [
                          Container(
                            width: 20,
                            height: 20,
                            child: const CircularProgressIndicator(
                              strokeWidth: 3, // Mengatur ketebalan garis
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text("Tunggu sebentar"),
                        ]
                      : [
                          Text(
                            "Masuk",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                            ),
                          ),
                        ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  print('object');
                  Navigator.of(context).pushNamed('/daftar');
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  fixedSize: const Size(
                    double.infinity,
                    40,
                  ),
                  backgroundColor: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Daftar",
                      style: GoogleFonts.poppins(
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}
