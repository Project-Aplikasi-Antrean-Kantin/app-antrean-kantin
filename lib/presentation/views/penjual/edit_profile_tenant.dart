import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/remote/tenant_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/tenant_provider.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/custom_form_field.dart';

class EditProfileTenant extends StatefulWidget {
  const EditProfileTenant({Key? key}) : super(key: key);

  @override
  State<EditProfileTenant> createState() => _EditProfileTenantState();
}

class _EditProfileTenantState extends State<EditProfileTenant> {
  late ImagePicker _imagePicker;
  late TextEditingController namaTenantController;
  late TextEditingController nomorKavlingController;
  late TextEditingController nomorRekeningTokoController;
  late TextEditingController nomorRekeningPribadiController;

  bool isLoading = false;
  String? selectedImagePath;
  String selectedOpenTime = "00:00:00";
  String selectedCloseTime = "00:00:00";

  void handleTimeChanged(String type, String newTime) {
    setState(() {
      if (type == "open") {
        selectedOpenTime = newTime;
      } else if (type == "close") {
        selectedCloseTime = newTime;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
    namaTenantController = TextEditingController();
    nomorKavlingController = TextEditingController();
    nomorRekeningTokoController = TextEditingController();
    nomorRekeningPribadiController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tenantProvider = context.read<TenantProvider>();
      tenantProvider
          .fetchTenantData(context.read<AuthProvider>().user.token)
          .then((_) {
        // Isi controller hanya sekali setelah data diambil
        final tenantData = tenantProvider.tenant;
        namaTenantController.text = tenantData?.namaTenant ?? '';
        nomorKavlingController.text = tenantData?.namaKavling ?? '';
        nomorRekeningTokoController.text = tenantData?.nomorRekeningToko ?? '';
        nomorRekeningPribadiController.text =
            tenantData?.nomorRekeningPribadi ?? '';
        setState(() {
          selectedOpenTime = tenantData?.jamBuka ?? '00:00:00';
          selectedCloseTime = tenantData?.jamTutup ?? '00:00:00';
        });
      });
    });
  }

  Future<int> _getImageSize(String imagePath) async {
    final imageFile = File(imagePath);
    final sizeInBytes = await imageFile.length();
    return sizeInBytes ~/ 1024; // Convert bytes to KB
  }

  Future<void> _getImageFromCamera(BuildContext context) async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      final tempDir = await getTemporaryDirectory();
      final tempFileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempPath = '${tempDir.path}/$tempFileName';

      try {
        final compressedImage = await FlutterImageCompress.compressAndGetFile(
          pickedImage.path,
          tempPath,
          quality: 70,
          minWidth: 1024,
          minHeight: 1024,
        );
        if (compressedImage != null) {
          selectedImagePath = compressedImage.path;
          int imageSizeKB = await _getImageSize(selectedImagePath!);
          if (imageSizeKB > 2048) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomAlertDialog(
                  title: "Peringatan!",
                  message:
                      "Gambar yang kamu ambil lebih dari 2MB bahkan setelah kompresi.",
                  showCancelButton: false,
                );
              },
            );
            selectedImagePath = null;
          }
          Navigator.pop(context);
          setState(() {});
        } else {
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

  Future<void> _getImageFromGallery(BuildContext context) async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return;

    final tempDir = await getTemporaryDirectory();
    final tempFileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final tempPath = '${tempDir.path}/$tempFileName';

    try {
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        pickedImage.path,
        tempPath,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
      );

      if (compressedImage == null) {
        _showErrorDialog(
            'Gagal!', 'Gagal mengompresi gambar. Silakan coba lagi.');
        return;
      }

      selectedImagePath = compressedImage.path;
      final imageSizeKB = await _getImageSize(selectedImagePath!);

      if (imageSizeKB > 2048) {
        _showErrorDialog(
          'Peringatan!',
          'Gambar yang kamu pilih lebih dari 2MB bahkan setelah kompresi.',
        );
        selectedImagePath = null;
      }
      Navigator.pop(context);
      setState(() {});
    } catch (e) {
      debugPrint('Compression error: $e');
      _showErrorDialog(
          'Error!', 'Terjadi kesalahan saat mengompresi gambar: $e');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: title,
        message: message,
        showCancelButton: false,
      ),
    );
  }

  void _saveProfile(TenantProvider tenantProvider, AuthProvider authProvider) {
    if (namaTenantController.text.isEmpty ||
        nomorKavlingController.text.isEmpty) {
      _showErrorDialog(
        'Koreksi field!',
        'Nama Tenant dan Nomor Kavling harus diisi.',
      );
      return;
    }

    setState(() => isLoading = true);

    final data = {
      'nama_tenant': namaTenantController.text,
      'nama_kavling': nomorKavlingController.text,
      'gambar': selectedImagePath,
    };

    TenantRemoteDataSource()
        .updateProfileTenant(authProvider.user.token, data)
        .then((success) {
      if (success) {
        Fluttertoast.showToast(
            msg: 'Profil berhasil diperbarui',
            backgroundColor: Colors.green,
            textColor: Colors.white);
        Navigator.of(context).pop();
      } else {
        _showErrorDialog(
          'Gagal!',
          'Gagal memperbarui profil. Silakan coba lagi.',
        );
      }
    }).whenComplete(() => setState(() => isLoading = false));
  }

  @override
  Widget build(BuildContext context) {
    final tenantProvider = context.watch<TenantProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          'Edit Profil Tenant',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Foto Profil Tenant',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: semibold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      Text(' *',
                          style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  _buildUserPreview(tenantProvider, authProvider),
                  _buildEditForm(tenantProvider),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
          child: _buildBottomNavigationBar(tenantProvider, authProvider)),
    );
  }

  Widget _buildUserPreview(
      TenantProvider tenantProvider, AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        spacing: 8,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: selectedImagePath != null
                  ? DecorationImage(
                      image: FileImage(File(selectedImagePath!)),
                      fit: BoxFit.cover,
                    )
                  : tenantProvider.tenant?.gambar != null
                      ? DecorationImage(
                          image: NetworkImage(tenantProvider.tenant!.gambar),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: AssetImage('assets/images/dummy.jpeg'),
                          fit: BoxFit.cover,
                        ),
            ),
          ),
          Expanded(
              child: Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  _buildBottomSheetProfile(context, authProvider);
                },
                child: Text('Edit Foto',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: semibold,
                      color: AppColors.primaryColor,
                    )),
              ),
              Text(
                'Ukuran foto 1:1, pastikan ukuran sesuai dan tidak lebih dari 1 MB',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: regular,
                    color: AppColors.blackColor),
              )
            ],
          ))
        ],
      ),
    );
  }

  Future<void> _buildBottomSheetProfile(
      BuildContext context, AuthProvider authProvider) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor400,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ]),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 5,
                  child: Column(
                    spacing: 16,
                    children: [
                      Text(
                        'Foto Profil',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _getImageFromCamera(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                border: BoxBorder.all(
                                    color: AppColors.blackColor100, width: 1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedCamera02,
                                    color: AppColors.primaryColor,
                                  ),
                                  Text(
                                    'Kamera',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _getImageFromGallery(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                border: BoxBorder.all(
                                    color: AppColors.blackColor100, width: 1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedImage02,
                                    color: AppColors.primaryColor,
                                  ),
                                  Text(
                                    'Galeri',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (selectedImagePath != null &&
                                  authProvider.user.gambar != null) {
                                selectedImagePath = null;
                                authProvider.user.gambar = null;
                                setState(() {});
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                border: BoxBorder.all(
                                    color: AppColors.blackColor100, width: 1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedDelete02,
                                    color: AppColors.primaryColor,
                                  ),
                                  Text(
                                    'Hapus',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )),
          );
        });
  }

  Widget _buildEditForm(TenantProvider tenantProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextFormField(
          label: 'Nama Tenant',
          labelColor: AppColors.primaryColor,
          hintText: 'Tuliskan nama tenant',
          isRequired: true,
          controller: namaTenantController,
        ),
        // TimePicker(
        //   label: "Jam Buka",
        //   selectedTime: selectedOpenTime,
        //   onTimeChanged: (newTime) => handleTimeChanged("open", newTime),
        // ),
        // TimePicker(
        //   label: "Jam Tutup",
        //   selectedTime: selectedCloseTime,
        //   onTimeChanged: (newTime) => handleTimeChanged("close", newTime),
        // ),
        CustomTextFormField(
          labelColor: AppColors.primaryColor,
          label: 'Nomor Kavling Tenant',
          hintText: 'Tuliskan nomor kavling tenant (e.g. M12)',
          isRequired: true,
          controller: nomorKavlingController,
        ),
        // CustomTextFormField(
        //   label: 'No Rekening Toko',
        //   hintText: '8xxx-9xxx-4xxx',
        //   inputType: TextInputType.number,
        //   controller: nomorRekeningTokoController,
        // ),
        // CustomTextFormField(
        //   label: 'No Rekening Pribadi',
        //   hintText: '8xxx-9xxx-4xxx',
        //   inputType: TextInputType.number,
        //   controller: nomorRekeningPribadiController,
        // ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(
      TenantProvider tenantProvider, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
      ),
      child: Row(
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
                  surfaceTintColor: Colors.transparent, // hilangkan efek tint
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
          const SizedBox(width: 10),
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
                onPressed: () => _saveProfile(tenantProvider, authProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent, // tidak ada shadow
                  surfaceTintColor: Colors.transparent, // hilangkan efek tint
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
    );
  }

  @override
  void dispose() {
    namaTenantController.dispose();
    nomorKavlingController.dispose();
    nomorRekeningTokoController.dispose();
    nomorRekeningPribadiController.dispose();
    super.dispose();
  }
}
