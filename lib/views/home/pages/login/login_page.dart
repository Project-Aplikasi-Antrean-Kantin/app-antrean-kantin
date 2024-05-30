import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/exceptions/api_exception.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/views/components/custom_snackbar.dart';
import 'package:testgetdata/views/home/pages/navbar_home.dart';
import 'package:testgetdata/views/theme.dart';

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

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: backgroundColor,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: 32,
          right: 32,
        ),
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(top: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Hallo Bro!',
                        style: GoogleFonts.poppins(
                          color: secondaryTextColor,
                          fontSize: 32,
                          fontWeight: semibold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          textAlign: TextAlign.center,
                          'Paastikan kamu sudah memiliki akun ya bro...',
                          style: GoogleFonts.poppins(
                            color: primaryextColor,
                            fontSize: 15,
                            fontWeight: regular,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  cursorColor: primaryColor,
                  controller: email,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Email address',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
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
                  height: 20,
                ),
                TextFormField(
                  obscureText: showPassword,
                  controller: password,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Password',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword
                            ? Icons.remove_red_eye
                            : Icons.remove_red_eye_outlined,
                      ),
                      onPressed: () => setState(() {
                        showPassword = !showPassword;
                      }),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
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
                GestureDetector(
                  onTap: () async {
                    String? token = await FirebaseMessaging.instance.getToken();
                    print("ini token $token");
                    if (email.text.isEmpty || password.text.isEmpty) {
                      setState(() {
                        isLoading = true;
                      });
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Harap isi data terlebih dahulu"),
                        ),
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
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NavbarHome(
                              pageIndex: 0,
                            ),
                          ),
                          (route) => false,
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
                              status: 'failed',
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
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: isLoading
                            ? [
                                const SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Tunggu sebentar",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ]
                            : [
                                Text(
                                  "Masuk",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: medium,
                                  ),
                                ),
                              ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: GoogleFonts.poppins(
                        color: primaryextColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        debugPrint('Daftar tapped');
                        Navigator.of(context).pushNamed('/daftar');
                      },
                      child: Text(
                        'Daftar',
                        style: GoogleFonts.poppins(
                          color: primaryColor,
                          fontWeight: semibold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
