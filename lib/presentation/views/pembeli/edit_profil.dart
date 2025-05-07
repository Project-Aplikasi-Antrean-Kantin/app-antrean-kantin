import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/remote/auth_remote_data_source.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/kategori_menu_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/navbar_home.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/custom_form_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';

class EditProfil extends StatefulWidget {
  const EditProfil({
    Key? key,
  }) : super(key: key);

  @override
  State<EditProfil> createState() => _EditProfilState();
}

Future<int> _getImageSize(String imagePath) async {
  File imageFile = File(imagePath);
  int sizeInBytes = await imageFile.length();
  int sizeInKB = sizeInBytes ~/ 1024; // Convert bytes to KB
  return sizeInKB;
}

class _EditProfilState extends State<EditProfil> {
  late ImagePicker _imagePicker;
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

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
    namaUserController = TextEditingController();
    emailUserController = TextEditingController();
    phoneUserController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;
    namaUserController.text = user.nama;
    emailUserController.text = user.email;
    phoneUserController.text = user.phone.toString();
  }

  Future<void> _getImageFromGallery() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      debugPrint('Original image path: ${pickedImage.path}');
      final tempDir = await getTemporaryDirectory();
      final tempFileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempPath = '${tempDir.path}/$tempFileName';
      debugPrint('Target path for compressed image: $tempPath');

      try {
        final compressedImage = await FlutterImageCompress.compressAndGetFile(
          pickedImage.path,
          tempPath,
          quality: 70,
          minWidth: 1024,
          minHeight: 1024,
        );
        if (compressedImage != null) {
          debugPrint('Compressed image path: ${compressedImage.path}');
          selectedImagePath = compressedImage.path;
          int imageSizeKB = await _getImageSize(selectedImagePath!);
          debugPrint('Compressed image size: $imageSizeKB KB');
          if (imageSizeKB > 2048) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomAlertDialog(
                  title: "Peringatan!",
                  message:
                      "Gambar yang kamu pilih lebih dari 2MB bahkan setelah kompresi.",
                  showCancelButton: false,
                );
              },
            );
            selectedImagePath = null;
          }
          setState(() {});
        } else {
          debugPrint('Compression returned null');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                title: "Gagal!",
                message: "Gagal mengompresi gambar. Silakan coba lagi.",
                showCancelButton: false,
              );
            },
          );
        }
      } catch (e) {
        debugPrint('Compression error: $e');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              title: "Error!",
              message: "Terjadi kesalahan saat mengompresi gambar: $e",
              showCancelButton: false,
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
        title: Text(
          'Edit Profil',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: AppColors.textColorBlack,
            fontWeight: semibold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_backspace,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            margin: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 250,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: selectedImagePath != null
                            ? DecorationImage(
                                image: FileImage(File(selectedImagePath!)),
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
                                    image:
                                        AssetImage('assets/images/dummy.jpeg'),
                                    fit: BoxFit.cover,
                                  ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: _getImageFromGallery,
                      icon: const Icon(Icons.edit_square),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  label: 'Nama Kamu',
                  hintText: 'Tuliskan nama kamu',
                  isRequired: true,
                  controller: namaUserController,
                ),
                CustomTextFormField(
                  label: 'Email Kamu',
                  hintText: 'Tuliskan email kamu',
                  controller: emailUserController,
                  isEnabled: false,
                ),
                CustomTextFormField(
                  label: 'Nomor Telp',
                  hintText: '089XX',
                  isRequired: true,
                  inputType: TextInputType.number,
                  controller: phoneUserController,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color.fromARGB(255, 68, 68, 68),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (namaUserController.text.isEmpty ||
                        phoneUserController.text.isEmpty) {
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
                      'image': selectedImagePath,
                    };

                    AuthRemoteDataSource()
                        .updateProfileUser(authProvider.user.token, data)
                        .then((value) {
                      debugPrint('value setelah edit $value');
                      if (value) {
                        Navigator.of(context).pushAndRemoveUntil(
                          CustomPageBuilder(
                            page: Builder(
                              builder: (context) {
                                final roles = authProvider.user.role;

                                // Cek kombinasi tenant dan driver
                                if (roles.contains('tenant') &&
                                    roles.contains('driver')) {
                                  return const NavbarHome(pageIndex: 5);
                                }
                                // Cek peran individu
                                else if (roles.contains('tenant')) {
                                  return const NavbarHome(pageIndex: 4);
                                } else if (roles.contains('driver')) {
                                  return const NavbarHome(pageIndex: 3);
                                } else {
                                  return const NavbarHome(pageIndex: 2);
                                }
                              },
                            ),
                          ),
                          (route) => route.isFirst,
                        );
                        authProvider.fetchUserData(authProvider.user.token);
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomAlertDialog(
                              title: 'Gagal!',
                              message:
                                  'Gagal memperbarui profil. Silakan coba lagi.',
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
                  },
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.primaryColor,
                    ),
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
    );
  }

  @override
  void dispose() {
    namaUserController.dispose();
    emailUserController.dispose();
    phoneUserController.dispose();
    super.dispose();
  }
}
