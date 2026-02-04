import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/exceptions/api_exception.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/forgot_password.dart';
import 'package:testgetdata/presentation/views/pembeli/open_email.dart';
import 'package:testgetdata/presentation/views/pembeli/register_page.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/views/pembeli/navbar_home.dart';
import 'package:testgetdata/presentation/widgets/custom_form_field.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = true;
  bool _isLoading = false;

  String? emailError;
  String? passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Route _createRouteToHomePage() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const NavbarHome(pageIndex: 0),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  Route _createRouteToRegisterPage() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const RegisterPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  void showCustomSnackbar(BuildContext ctx, String message,
      {bool success = false}) {
    final scaffoldMessenger = ScaffoldMessenger.of(ctx);

    final snackBar = SnackBar(
      content: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => scaffoldMessenger.hideCurrentSnackBar(),
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

    scaffoldMessenger.showSnackBar(snackBar);
  }

  bool validateInputs() {
    setState(() {
      emailError = _emailController.text.isEmpty
          ? "Email wajib diisi."
          : (!_emailController.text.contains('@')
              ? "Format email tidak valid."
              : null);
      passwordError = _passwordController.text.isEmpty
          ? "Password wajib diisi."
          : (_passwordController.text.length < 8
              ? "Password minimal 8 karakter."
              : null);
    });
    return [emailError, passwordError].every((e) => e == null);
  }

  Future<void> _handleLogin(AuthProvider authProvider, BuildContext ctx) async {
    if (!validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      final token = await FirebaseMessaging.instance.getToken();
      log("Token fcm: " + token.toString());
      if (token == null) {
        showCustomSnackbar(ctx, "Gagal mengakses perangkat. Silakan coba lagi.",
            success: false);
        setState(() => _isLoading = false);
        return;
      }

      await authProvider.login(
          _emailController.text, _passwordController.text, token);
      await authProvider.fetchUserData(authProvider.user.token);

      if (mounted) {
        showCustomSnackbar(ctx, "Login berhasil! Selamat datang.",
            success: true);

        // kasih jeda dikit biar snackbar muncul dulu sebelum pindah halaman
        await Future.delayed(const Duration(milliseconds: 800));

        if (!mounted) return;
        Future.delayed(const Duration(milliseconds: 1000), () {
          Navigator.pushAndRemoveUntil(
            context,
            _createRouteToHomePage(),
            (route) => false,
          );
        });
      }
    } on ApiException catch (e) {
      // --- Ini bagian penting: deteksi error email belum terdaftar
      if (e.message.toLowerCase().contains('tidak ditemukan') ||
          e.message.toLowerCase().contains('not found') ||
          e.message.toLowerCase().contains('belum terdaftar')) {
        showCustomSnackbar(
          ctx,
          "Email belum terdaftar. Silakan daftar akun terlebih dahulu.",
          success: false,
        );
      } else {
        if (e.message.isNotEmpty && e.message.contains('verifikasi')) {
          showCustomSnackbar(
            ctx,
            "Email belum diverifikasi. Silakan periksa email anda.",
            success: false,
          );
          Navigator.push(
              context,
              CustomPageBuilder(
                  page: OpenEmail(
                email: _emailController.text,
                isResetPassword: false,
              )));
          return;
        }
        showCustomSnackbar(
          ctx,
          e.message.isNotEmpty
              ? e.message
              : "Email atau password salah. Silakan periksa kembali.",
          success: false,
        );
      }
    } catch (e) {
      showCustomSnackbar(
        ctx,
        "Terjadi kesalahan pada sistem. Silakan coba beberapa saat lagi.",
        success: false,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Image(
                        width: 150,
                        image:
                            const AssetImage("assets/images/Logo Header.png"),
                      ),
                    ),
                  ),
                  Text(
                    'Masuk',
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryColor,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Pastikan kamu sudah mendaftar yaa ☺️',
                    textAlign: TextAlign.justify,
                    style: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontSize: 13,
                      fontWeight: regular,
                    ),
                  ),
                  CustomTextFormField(
                    labelColor: AppColors.primaryColor,
                    label: 'Email',
                    controller: _emailController,
                    hintText: 'Alamat email kamu',
                    inputType: TextInputType.emailAddress,
                    isRequired: true,
                    errorText: emailError,
                  ),
                  CustomTextFormField(
                    label: 'Password',
                    labelColor: AppColors.primaryColor,
                    controller: _passwordController,
                    hintText: 'Masukkan password kamu',
                    obscureText: _showPassword,
                    isRequired: true,
                    errorText: passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: Colors.grey[500],
                      ),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  GestureDetector(
                    key: const Key('forgotPassword'),
                    onTap: () => Navigator.push(
                        context, CustomPageBuilder(page: ForgotPassword())),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Lupa Password?',
                        style: GoogleFonts.poppins(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  PrimaryButton(
                    key: const Key('loginButton'),
                    isLoading: _isLoading,
                    borderRadius: 20,
                    onPressed: () =>
                        _isLoading ? null : _handleLogin(authProvider, context),
                    child: Center(
                      child: Text(
                        "Masuk",
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
                        'Belum punya akun? ',
                        style: GoogleFonts.poppins(
                          color: AppColors.textColorBlack,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context)
                            .push(_createRouteToRegisterPage()),
                        child: Text(
                          'Daftar',
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
    );
  }
}
