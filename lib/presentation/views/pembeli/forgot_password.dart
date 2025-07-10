import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/login_page.dart';
import 'package:testgetdata/presentation/views/pembeli/open_email.dart';
import 'package:testgetdata/presentation/widgets/custom_form_field.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  String? emailError;
  bool validateInputs() {
    setState(() {
      emailError = _emailController.text.isEmpty
          ? "Email wajib diisi."
          : (!_emailController.text.contains('@')
              ? "Format email tidak valid."
              : null);
    });
    return [emailError].every((e) => e == null);
  }

  bool _isLoading = false;

  void _handleSendEmail(AuthProvider authProvider, BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    print('email iki cak ${_emailController.text}');
    if (!validateInputs()) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    ;
    final success =
        await authProvider.sendEmailForgetPassword(_emailController.text);
    if (success) {
      Fluttertoast.showToast(
        msg: "Email berhasil dikirim",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.pushReplacement(
          context,
          CustomPageBuilder(
              page: const OpenEmail(
            isResetPassword: true,
          )));
    } else {
      Fluttertoast.showToast(
        msg: "Email tidak ditemukan",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SingleChildScrollView(
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    height: 150,
                    width: 150,
                    image: const AssetImage("assets/images/logo-with-text.png"),
                  ),
                  Image(
                    height: 150,
                    width: 150,
                    image:
                        const AssetImage("assets/images/lupa-password-2.png"),
                  ),
                  Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lupa Kata Sandi',
                        style: TextStyle(
                          color: const Color(0xFF06144C),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.33,
                        ),
                      ),
                      Text(
                          style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primaryColor.withOpacity(0.5),
                              fontWeight: FontWeight.w300),
                          ('Gunakan email akun kamu untuk mengatur ulang kata sandi. Pastikan email sesuai, kami akan mengirim tautan ke email kamu.')),
                    ],
                  ),
                  CustomTextFormField(
                    label: 'Email',
                    boldLabel: true,
                    controller: _emailController,
                    hintText: 'Alamat email kamu',
                    inputType: TextInputType.emailAddress,
                    isRequired: true,
                    errorText: emailError,
                  ),
                  GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () => _handleSendEmail(authProvider, context),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
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
                        child: _isLoading
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
                                "Kirim",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: medium,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
