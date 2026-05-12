import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/remote/tenant_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/tenant_provider.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/custom_form_field.dart';
import 'package:testgetdata/presentation/widgets/organisms/image_picker_bottom_sheet/image_picker_bottom_sheet.dart';

class EditProfileTenant extends StatefulWidget {
  const EditProfileTenant({Key? key}) : super(key: key);

  @override
  State<EditProfileTenant> createState() => _EditProfileTenantState();
}

class _EditProfileTenantState extends State<EditProfileTenant> {
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

  Future<void> _openImagePicker() {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return ImagePickerBottomSheet(
          titleBottomSheet: 'Foto Tenant',
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
                  _openImagePicker();
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
        CustomTextFormField(
          labelColor: AppColors.primaryColor,
          label: 'Nomor Kavling Tenant',
          hintText: 'Tuliskan nomor kavling tenant (e.g. M12)',
          isRequired: true,
          controller: nomorKavlingController,
        ),
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
