import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/components/custom_snackbar.dart';
import 'package:testgetdata/exceptions/api_exception.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/views/home/home_page.dart';
import 'package:testgetdata/views/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  var showPassword = true;
  TextEditingController nama = TextEditingController();
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
                'Daftar Akun',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 32),
              ),
              Text(
                'Masukan data kamu dibawah',
                style: GoogleFonts.poppins(
                    color: Colors.black45,
                    fontWeight: FontWeight.normal,
                    fontSize: 15),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Nama',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.normal, fontSize: 16),
              ),
              const SizedBox(height: 3),
              TextFormField(
                cursorColor: Colors.redAccent,
                controller: nama,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  hintText: 'Masukan nama',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap isi naam terlebih dahulu';
                  }
                  return null;
                },
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
                  hintText: 'Masukan email',
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
                  hintText: 'Masukan password',
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
                    // if (await authProvider.login(
                    //     email.text, password.text, token!)) {
                    //   print('hahaha');
                    //   // Navigator.pushReplacement(
                    //   //     context,
                    //   //     MaterialPageRoute(
                    //   //       builder: (context) => HomePage(),
                    //   //     ));
                    // }
                    try {
                      final success = await authProvider.register(
                          nama.text, email.text, password.text);
                      if (success) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      }
                    } catch (e) {
                      if (e is ApiException) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          CustomSnackBar(
                            status: e.status,
                            message: e.message,
                          ),
                        );
                      } else {
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
                          SizedBox(width: 10),
                          Text("Tunggu sebentar"),
                        ]
                      : [
                          Text(
                            "Daftar sekarang",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                            ),
                          ),
                        ],
                ),
              ),
              // ElevatedButton(
              //   onPressed: () {},
              //   style: ElevatedButton.styleFrom(
              //     elevation: 0,
              //     shadowColor: Colors.transparent,
              //     fixedSize: const Size(
              //       double.infinity,
              //       40,
              //     ),
              //     backgroundColor: Colors.transparent,
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Text(
              //         "Daftar",
              //         style: GoogleFonts.poppins(
              //           color: Colors.redAccent,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // Center(
              //   child: TextButton(
              //     onPressed: () async {
              //       // var url = 'whatsapp://send?phone=6285706015892';
              //       // const text =
              //       //     "Halo Masbro, saya izin meminta akses untuk login ke aplikasi Masbro Canteen";
              //       // url = '$url&text=$text';

              //       // try {
              //       //   await launchUrlString(url);
              //       // } catch (e) {
              //       //   debugPrint(e.toString());
              //       // }
              //     },
              //     style: TextButton.styleFrom(
              //         foregroundColor: Colors.pink,
              //         alignment: Alignment.center),
              //     child: Text(
              //       'Daftar',
              //       // style: GoogleFonts.poppins(
              //       //     color: Colors.redAccent,
              //       //     fontWeight: FontWeight.normal,
              //       //     fontSize: 15),
              //     ),
              //   ),
              // ),
            ]),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text("Tahan tombol")),
      //     );
      //   },
      //   backgroundColor: Colors.white,
      //   child: Icon(Icons.info_outline, color: Colors.redAccent),
      //   tooltip:
      //       'Aplikasi Masbro hanya bisa digunakan oleh beberapa orang yang sudah terdaftar, jika anda ingin mencobanya, klik "Minta Akses"',
      // ),
    );
  }
}
