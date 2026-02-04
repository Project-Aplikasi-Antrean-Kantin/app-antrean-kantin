import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/exceptions/api_exception.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/widgets/custom_form_field.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;
  final String email;
  const ResetPasswordPage({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool showPassword = true;
  bool isPasswordEqual = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword(AuthProvider authProvider) async {
    if (isPasswordEqual == false) {
      Fluttertoast.showToast(msg: 'Password tidak sama');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      try {
        final success = await authProvider.resetPassword(
          widget.email,
          _passwordController.text,
          _passwordConfirmController.text,
          widget.token,
        );
        if (success) {
          setState(() {
            _isLoading = false;
          });
          Fluttertoast.showToast(
              msg: 'Reset password berhasil',
              backgroundColor: Colors.green,
              textColor: Colors.white);
          Navigator.pop(context);
        }
      } on ApiException catch (e) {
        Fluttertoast.showToast(msg: e.message);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
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
                    Text('Atur Ulang Password',
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.50,
                        )),
                    Text(
                      'Pastikan kamu tidak melupkan kata sandimu lagi yaa...',
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    CustomTextFormField(
                      labelColor: AppColors.primaryColor,
                      label: 'Email',
                      boldLabel: true,
                      controller: _emailController,
                      isEnabled: false,
                      hintText: 'Alamat email kamu',
                      inputType: TextInputType.emailAddress,
                      isRequired: true,
                    ),
                    CustomTextFormField(
                      onChanged: (value) => {
                        setState(() {
                          isPasswordEqual = _passwordController.text ==
                              _passwordConfirmController.text;
                        })
                      },
                      labelColor: AppColors.primaryColor,
                      label: 'Password',
                      boldLabel: true,
                      controller: _passwordController,
                      hintText: 'Password Baru',
                      inputType: TextInputType.emailAddress,
                      isRequired: true,
                      obscureText: showPassword,
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
                      onChanged: (value) => {
                        setState(() {
                          isPasswordEqual = _passwordController.text ==
                              _passwordConfirmController.text;
                        })
                      },
                      labelColor: AppColors.primaryColor,
                      label: 'Konfirmasi Password',
                      boldLabel: true,
                      errorText: isPasswordEqual ? null : 'Password tidak sama',
                      controller: _passwordConfirmController,
                      hintText: 'Konfirmasi Password Baru',
                      inputType: TextInputType.emailAddress,
                      isRequired: true,
                      obscureText: showPassword,
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
                    _passwordController.text.isNotEmpty &&
                            _passwordConfirmController.text.isNotEmpty &&
                            !isPasswordEqual
                        ? Text(
                            'Konfirmasi password kamu tidak sesuai',
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          )
                        : SizedBox.shrink(),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () => _handleResetPassword(authProvider),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(16),
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
          ),
        ),
      ),
    );
  }
}
