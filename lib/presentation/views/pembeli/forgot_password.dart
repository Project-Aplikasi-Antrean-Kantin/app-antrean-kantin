import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/login_page.dart';
import 'package:testgetdata/presentation/views/pembeli/open_email.dart';
import 'package:testgetdata/presentation/widgets/custom_form_field.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  String? emailError;
  String difference = '';
  int _secondsRemaining = 0;
  Timer? _timer;

  String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$secs";
  }

  void startCountdown() {
    _timer?.cancel(); // stop timer sebelumnya kalau ada
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkTimeDifference();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> checkTimeDifference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTimeStr = prefs.getString('last_send_reset_password');

    if (savedTimeStr == null) {
    } else {
      final savedTime = DateTime.tryParse(savedTimeStr);
      if (savedTime != null) {
        final now = DateTime.now();
        final minutesDiff = now.difference(savedTime).inMinutes;
        final secondsDiff = now.difference(savedTime).inSeconds;
        if (minutesDiff >= 3) {
        } else {
          setState(() {
            _secondsRemaining = 180 - secondsDiff;
          });
          startCountdown();
        }
      }
    }
  }

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
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    SvgPicture.asset('assets/images/lupa-password.svg'),
                    Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lupa Password',
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.blackColor,
                            ),
                            ('Gunakan email akun kamu untuk mengatur ulang kata sandi. Pastikan email sesuai, kami akan mengirim tautan ke email kamu.')),
                      ],
                    ),
                    CustomTextFormField(
                      labelColor: AppColors.primaryColor,
                      label: 'Email',
                      boldLabel: true,
                      controller: _emailController,
                      hintText: 'Alamat email kamu',
                      inputType: TextInputType.emailAddress,
                      isRequired: true,
                      errorText: emailError,
                    ),
                    PrimaryButton(
                      key: const Key('sendEmail'),
                      borderRadius: 20,
                      waitingText:
                          'Coba dalam ${formatDuration(_secondsRemaining)}',
                      isEnabled: _secondsRemaining <= 0,
                      isLoading: _isLoading,
                      onPressed: () {
                        if (_secondsRemaining <= 0) {
                          _handleSendEmail(authProvider, context);
                        } else {
                          Fluttertoast.showToast(
                              msg:
                                  "Coba lagi dalam ${formatDuration(_secondsRemaining)}",
                              backgroundColor: AppColors.errorColor,
                              textColor: AppColors.whiteColor);
                        }
                      },
                      width: double.infinity,
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
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                _secondsRemaining <= 0
                                    ? "Kirim"
                                    : "Kirim lagi dalam ${formatDuration(_secondsRemaining)} ",
                                style: GoogleFonts.poppins(
                                  color: _isLoading
                                      ? AppColors.blackColor300
                                      : AppColors.whiteColor,
                                  fontWeight: medium,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
