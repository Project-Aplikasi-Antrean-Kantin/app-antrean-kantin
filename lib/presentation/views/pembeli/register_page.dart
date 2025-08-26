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
import 'package:testgetdata/presentation/widgets/primary_button.dart';

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

  Future<void> _handleRegister(AuthProvider authProvider) async {
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
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
              context,
              CustomPageBuilder(
                  page: OpenEmail(
                email: email.text,
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
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: SingleChildScrollView(
              child: Container(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Image(
                            width: 150,
                            image: const AssetImage(
                                "assets/images/Logo Header.png"),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 48,
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daftar',
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryColor,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Yuk daftar dan menjelajah kuliner bersama FoodLAB 🥘',
                            style: GoogleFonts.poppins(
                              color: AppColors.blackColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      CustomTextFormField(
                        labelColor: AppColors.primaryColor,
                        label: 'Nama',
                        controller: nama,
                        hintText: 'Masukkan nama kamu',
                        isRequired: true,
                        errorText: namaError,
                      ),
                      CustomTextFormField(
                        labelColor: AppColors.primaryColor,
                        label: 'Email',
                        controller: email,
                        hintText: 'Masukkan email kamu',
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
                        labelColor: AppColors.primaryColor,
                        label: 'Password',
                        controller: password,
                        hintText: 'Masukkan password',
                        obscureText: showPassword,
                        isRequired: true,
                        errorText: passwordError,
                        onChanged: (value) {
                          setState(() {
                            confirmPasswordError =
                                confirmPassword.text.isNotEmpty &&
                                        confirmPassword.text != value
                                    ? "Konfirmasi password tidak cocok."
                                    : null;
                          });
                        },
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
                        labelColor: AppColors.primaryColor,
                        label: 'Konfirmasi Password',
                        controller: confirmPassword,
                        onChanged: (value) {
                          setState(() {
                            confirmPasswordError = value != password.text
                                ? "Konfirmasi password tidak cocok."
                                : null;
                          });
                        },
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
                      PrimaryButton(
                        onPressed: () =>
                            isLoading ? null : _handleRegister(authProvider),
                        width: double.infinity,
                        borderRadius: 20,
                        isLoading: isLoading,
                        child: Center(
                          child: Text(
                            "Daftar Sekarang",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: medium,
                              fontSize: 16,
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
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
