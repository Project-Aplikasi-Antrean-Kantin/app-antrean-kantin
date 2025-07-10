import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/exceptions/api_exception.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/login_page.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/views/pembeli/open_email.dart';
import 'package:testgetdata/presentation/widgets/custom_form_field.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool showPassword = true;
  final TextEditingController nama = TextEditingController();
  final TextEditingController email = TextEditingController();
  // final TextEditingController telp = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  String? namaError;
  String? emailError;
  // String? telpError;
  String? passwordError;
  String? confirmPasswordError;

  bool isLoading = false;

  Route routeToLoginPage() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const LoginPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset(0.0, 0.0);
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  void showCustomSnackbar(String message, {bool success = false}) {
    final snackBar = SnackBar(
      content: GestureDetector(
        behavior: HitTestBehavior.opaque, // supaya seluruh area bisa ditekan
        onTap: () {
          // Hilangkan snackbar saat ditekan
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        child: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error_outline,
              color: success ? Colors.green : Colors.redAccent,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: success ? Colors.green : Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool validateInputs() {
    setState(() {
      namaError = nama.text.isEmpty ? "Nama wajib diisi." : null;
      emailError = email.text.isEmpty
          ? "Email wajib diisi."
          : (!email.text.contains('@') ? "Format email tidak valid." : null);
      // telpError = telp.text.isEmpty
      //     ? "Nomor telepon wajib diisi."
      //     : (telp.text.length < 10 ? "Nomor telepon minimal 10 digit." : null);
      passwordError = password.text.isEmpty
          ? "Password wajib diisi."
          : (password.text.length < 8 ? "Password minimal 8 karakter." : null);
      confirmPasswordError = confirmPassword.text.isEmpty
          ? "Konfirmasi password wajib diisi."
          : (confirmPassword.text != password.text
              ? "Konfirmasi password tidak cocok."
              : null);
    });
    return [
      namaError,
      emailError,
      // telpError,
      passwordError,
      confirmPasswordError
    ].every((e) => e == null);
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 32,
            right: 32,
          ),
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(top: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Daftar',
                            style: GoogleFonts.poppins(
                              color: AppColors.textColorBlack,
                              fontSize: 32,
                              fontWeight: semibold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Text(
                              textAlign: TextAlign.center,
                              'Bergabunglah dan mulai jelajahi kuliner favoritmu!',
                              style: GoogleFonts.poppins(
                                color: AppColors.textColorBlack,
                                fontSize: 15,
                                fontWeight: regular,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    CustomTextFormField(
                      label: 'Nama',
                      controller: nama,
                      hintText: 'Nama lengkap kamu',
                      isRequired: true,
                      errorText: namaError,
                    ),
                    CustomTextFormField(
                      label: 'Email',
                      controller: email,
                      hintText: 'Alamat email kamu',
                      inputType: TextInputType.emailAddress,
                      isRequired: true,
                      errorText: emailError,
                    ),
                    // CustomTextFormField(
                    //   label: 'Nomor Telepon',
                    //   controller: telp,
                    //   hintText: 'Nomor telepon aktif',
                    //   inputType: TextInputType.phone,
                    //   isRequired: true,
                    //   errorText: telpError,
                    // ),
                    CustomTextFormField(
                      label: 'Password',
                      controller: password,
                      hintText: 'Buat password',
                      obscureText: showPassword,
                      isRequired: true,
                      errorText: passwordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: Colors.grey[500],
                        ),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                    CustomTextFormField(
                      label: 'Konfirmasi Password',
                      controller: confirmPassword,
                      hintText: 'Ulangi password',
                      obscureText: showPassword,
                      isRequired: true,
                      errorText: confirmPasswordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: Colors.grey[500],
                        ),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: isLoading
                          ? null
                          : () async {
                              if (!validateInputs()) return;

                              setState(() => isLoading = true);
                              try {
                                final success = await authProvider.register(
                                  nama.text,
                                  email.text,
                                  password.text,
                                );
                                if (success) {
                                  showCustomSnackbar(
                                    "Registrasi berhasil! Silakan login menggunakan akun kamu.",
                                    success: true,
                                  );
                                  Future.delayed(
                                      const Duration(milliseconds: 1200), () {
                                    Navigator.pushReplacement(
                                        context,
                                        CustomPageBuilder(
                                            page: const OpenEmail(
                                          isResetPassword: false,
                                        )));
                                  });
                                }
                              } catch (e) {
                                if (e is ApiException) {
                                  showCustomSnackbar(
                                    e.message.isNotEmpty
                                        ? e.message
                                        : "Terjadi kesalahan, silakan coba lagi.",
                                  );
                                } else {
                                  showCustomSnackbar(
                                    "Gagal mendaftar. Pastikan data sudah benar dan jaringan stabil.",
                                  );
                                }
                              }
                              setState(() => isLoading = false);
                            },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: double.infinity,
                        height: 45,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Memproses...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  "Daftar Sekarang",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: medium,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: GoogleFonts.poppins(
                            color: AppColors.textColorBlack,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              routeToLoginPage(),
                              (route) => false,
                            );
                          },
                          child: Text(
                            'Masuk',
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryColor,
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
        ),
      ),
    );
  }
}
