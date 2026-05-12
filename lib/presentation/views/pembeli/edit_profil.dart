import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/data/remote/auth_remote_data_source.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/kategori_menu_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/custom_form_field.dart';
import 'package:testgetdata/presentation/widgets/organisms/image_picker_bottom_sheet/image_picker_bottom_sheet.dart';

class EditProfil extends StatefulWidget {
  const EditProfil({Key? key}) : super(key: key);

  @override
  State<EditProfil> createState() => _EditProfilState();
}

class _EditProfilState extends State<EditProfil> {
  bool isLoading = false;

  List<KategoriMenu> kategoriMenu = [
    KategoriMenu(id: 1, nama: 'Makanan', kategoriId: 1),
    KategoriMenu(id: 2, nama: 'Minuman', kategoriId: 1),
    KategoriMenu(id: 3, nama: 'Snack', kategoriId: 2),
  ];
  String? selectedImagePath;

  late TextEditingController namaUserController;
  late TextEditingController emailUserController;
  late TextEditingController phoneUserController;

  // Focus nodes untuk pindah field
  final _namaFocus = FocusNode();
  final _phoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    namaUserController = TextEditingController();
    emailUserController = TextEditingController();
    phoneUserController = TextEditingController();

    // Ambil data user dari provider setelah frame build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      namaUserController.text = user.nama;
      emailUserController.text = user.email;
      phoneUserController.text = user.phone?.toString() ?? '';
    });
  }

  @override
  void dispose() {
    namaUserController.dispose();
    emailUserController.dispose();
    phoneUserController.dispose();
    _namaFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _submit(AuthProvider authProvider) {
    if (namaUserController.text.isEmpty || phoneUserController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: 'Koreksi!',
            message: 'Nama dan nomor telepon harus diisi.',
            showCancelButton: false,
          );
        },
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final data = {
      'name': namaUserController.text,
      'phone': phoneUserController.text,
    };

    if (selectedImagePath != null || authProvider.user.gambar != null) {
      if (selectedImagePath != null) data['image'] = selectedImagePath!;
    } else {
      data['delete_image'] = 'true'; // ubah boolean jadi string
    }

    AuthRemoteDataSource()
        .updateProfileUser(authProvider.user.token, data)
        .then((value) {
      if (value) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: 'Profil berhasil diperbarui',
            backgroundColor: Colors.green,
            textColor: Colors.white);
        authProvider.fetchUserData(authProvider.user.token);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              title: 'Gagal!',
              message: 'Gagal memperbarui profil. Silakan coba lagi.',
              showCancelButton: false,
            );
          },
        );
      }
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _openImagePicker() {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return ImagePickerBottomSheet(
          titleBottomSheet: 'Foto Profil',
          onImageSelected: (path) async {
            if (path == null) {
              setState(() {
                selectedImagePath = null;
              });
              return;
            }

            // optional validasi size
            final file = File(path);
            final sizeKB = await file.length() ~/ 1024;

            if (sizeKB > 2048) {
              showDialog(
                context: context,
                builder: (_) => CustomAlertDialog(
                  title: "Peringatan!",
                  message: "Gambar lebih dari 2MB",
                  showCancelButton: false,
                ),
              );
              return;
            }

            setState(() {
              selectedImagePath = path;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 56,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedArrowLeft02,
                                  color: AppColors.blackColor,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            'Edit Akun',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await _openImagePicker();
                      },
                      child: Column(
                        spacing: 12,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(88),
                              image: selectedImagePath != null
                                  ? DecorationImage(
                                      image:
                                          FileImage(File(selectedImagePath!)),
                                      fit: BoxFit.cover,
                                    )
                                  : authProvider.user.gambar != null
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            "${authProvider.user.gambar}",
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : const DecorationImage(
                                          image: AssetImage(
                                              'assets/images/dummy.jpeg'),
                                          fit: BoxFit.cover,
                                        ),
                            ),
                          ),
                          Text('Edit foto profil',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      label: 'Nama',
                      labelColor: AppColors.primaryColor,
                      hintText: 'Tuliskan nama kamu',
                      isRequired: true,
                      controller: namaUserController,
                      focusNode: _namaFocus,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_phoneFocus);
                      },
                    ),
                    CustomTextFormField(
                      label: 'Email',
                      hintText: 'Tuliskan email kamu',
                      labelColor: AppColors.primaryColor,
                      controller: emailUserController,
                      isEnabled: false,
                    ),
                    CustomTextFormField(
                      label: 'Nomor Telepon',
                      labelColor: AppColors.primaryColor,
                      hintText: '089XX',
                      isRequired: true,
                      inputType: TextInputType.number,
                      controller: phoneUserController,
                      focusNode: _phoneFocus,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 48,
              right: 24,
              left: 24,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // harus ada agar shadow muncul
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent, // tidak ada shadow
                        surfaceTintColor:
                            Colors.transparent, // hilangkan efek tint
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Color.fromARGB(255, 68, 68, 68),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _submit(authProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent, // tidak ada shadow
                        surfaceTintColor:
                            Colors.transparent, // hilangkan efek tint
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Simpan',
                              style: TextStyle(
                                color: Colors.white,
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
    );
  }
}
