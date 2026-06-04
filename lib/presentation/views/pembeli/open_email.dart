import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/widgets/molecules/custom_snackbar.dart';

class OpenEmail extends StatefulWidget {
  final bool isResetPassword;
  final String? email;

  const OpenEmail({super.key, required this.isResetPassword, this.email});

  @override
  State<OpenEmail> createState() => _OpenEmailState();
}

class _OpenEmailState extends State<OpenEmail> {
  bool showButton = true;
  String difference = '';
  int _secondsRemaining = 0;
  Timer? _timer;
  bool isEmailSent = false;

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
        setState(() {
          showButton = true;
        });
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
    if (!widget.isResetPassword) {
      checkTimeDifference();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> checkTimeDifference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTimeStr = prefs.getString('last_send_verify_email');

    if (savedTimeStr == null) {
      setState(() {
        showButton = true;
      });
    } else {
      final savedTime = DateTime.tryParse(savedTimeStr);
      if (savedTime != null) {
        final now = DateTime.now();
        final minutesDiff = now.difference(savedTime).inMinutes;
        final secondsDiff = now.difference(savedTime).inSeconds;
        if (minutesDiff >= 10) {
          setState(() => showButton = true);
        } else {
          setState(() {
            showButton = false;
            _secondsRemaining = 600 - secondsDiff;
          });
          startCountdown();
        }
      } else {
        setState(() => showButton = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: Image(
                      width: 150,
                      image: const AssetImage("assets/images/Logo Header.png"),
                    ),
                  ),
                ),
                SvgPicture.asset('assets/images/verifikasi-email.svg'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isResetPassword ? 'Atur Password' : 'Buka Email',
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.33,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kami telah mengirim email verifikasi. Silakan cek kotak masuk kamu untuk melanjutkan proses pendaftaran akun FoodLAB.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    const intent = AndroidIntent(
                      action: 'android.intent.action.MAIN',
                      package: 'com.google.android.gm',
                      componentName:
                          'com.google.android.gm.ConversationListActivityGmail',
                      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
                    );

                    try {
                      await intent.launch();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Gagal membuka aplikasi Gmail")),
                      );
                    }
                  },
                  child: Container(
                    height: 50,
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
                      child: Text(
                        "Buka Email",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: medium,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                if (!widget.isResetPassword)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum menerima email verifikasi?',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryColor.withOpacity(0.5),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (isEmailSent) return;
                          if (!showButton) {
                            CustomSnackbar.error('Cek Emailmu dulu');
                            return;
                          }

                          try {
                            setState(() {
                              isEmailSent = true;
                            });
                            final success =
                                await authProvider.resendVerify(widget.email!);
                            if (success) {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString(
                                'last_send_verify_email',
                                DateTime.now().toString(),
                              );
                              CustomSnackbar.success('Email berhasil dikirim');
                              checkTimeDifference();
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Gagal membuka aplikasi Gmail")),
                            );
                          } finally {
                            setState(() {
                              isEmailSent = false;
                            });
                          }
                        },
                        child: Text(
                          showButton
                              ? isEmailSent
                                  ? 'Tunggu...'
                                  : 'Kirim Ulang'
                              : 'Tunggu ${formatDuration(_secondsRemaining)}',
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryColor,
                            fontWeight: semibold,
                            fontSize: 14,
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
