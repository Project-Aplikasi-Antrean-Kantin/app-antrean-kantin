import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/remote/tenant_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/tenant_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/navbar_home.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/custom_form_field.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/shimmer_widget.dart';

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

  @override
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
      });
    });
  }

  Future<int> _getImageSize(String imagePath) async {
    final imageFile = File(imagePath);
    final sizeInBytes = await imageFile.length();
    return sizeInBytes ~/ 1024; // Convert bytes to KB
  }

  Future<void> _getImageFromGallery() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return;

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

      if (compressedImage == null) {
        debugPrint('Compression returned null');
        _showErrorDialog(
            'Gagal!', 'Gagal mengompresi gambar. Silakan coba lagi.');
        return;
      }

      debugPrint('Compressed image path: ${compressedImage.path}');
      selectedImagePath = compressedImage.path;
      final imageSizeKB = await _getImageSize(selectedImagePath!);
      debugPrint('Compressed image size: $imageSizeKB KB');

      if (imageSizeKB > 2048) {
        _showErrorDialog(
          'Peringatan!',
          'Gambar yang kamu pilih lebih dari 2MB bahkan setelah kompresi.',
        );
        selectedImagePath = null;
      }

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
      'no_rekening_toko': nomorRekeningTokoController.text,
      'no_rekening_pribadi': nomorRekeningPribadiController.text,
      'gambar': selectedImagePath,
    };

    TenantRemoteDataSource()
        .updateProfileTenant(authProvider.user.token, data)
        .then((success) {
      log('value setelah edit tenant: $success');
      if (success) {
        // Navigator.of(context).pushAndRemoveUntil(
        //   CustomPageBuilder(
        //     page: Builder(
        //       builder: (context) {
        //         final roles = authProvider.user.role;
        //         if (roles.contains('tenant') && roles.contains('driver')) {
        //           return const NavbarHome(pageIndex: 5);
        //         } else if (roles.contains('tenant')) {
        //           return const NavbarHome(pageIndex: 4);
        //         } else if (roles.contains('driver')) {
        //           return const NavbarHome(pageIndex: 3);
        //         }
        //         return const NavbarHome(pageIndex: 2);
        //       },
        //     ),
        //   ),
        //   (route) => false,
        // );
        Navigator.of(context).pop();
        tenantProvider.fetchTenantData(authProvider.user.token);
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
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        scrolledUnderElevation: 0,
        toolbarHeight: 50,
        title: Text(
          'Edit Profil Tenant',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: AppColors.textColorBlack,
            fontWeight: semibold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_backspace,
              color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            margin: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Priview User',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: semibold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                _buildUserPreview(tenantProvider, authProvider),
                Text(
                  'Form Edit Tenant',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: semibold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                _buildEditForm(tenantProvider),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          _buildBottomNavigationBar(tenantProvider, authProvider),
    );
  }

  Widget _buildUserPreview(
      TenantProvider tenantProvider, AuthProvider authProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        color: authProvider.user.isOnline == true
            ? AppColors.containerColorWhite
            : Colors.grey.shade300,
      ),
      child: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
              child: ColorFiltered(
                colorFilter: authProvider.user.isOnline == true
                    ? const ColorFilter.mode(
                        Colors.transparent, BlendMode.multiply)
                    : const ColorFilter.matrix(<double>[
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                child: Stack(
                  children: [
                    const ShimmerLoadingWidget(
                      shimmerContainerImage: true,
                      padding: EdgeInsets.zero,
                      heightContainerImage: 200,
                      widhtContainerImage: double.infinity,
                    ),
                    if (tenantProvider.tenant?.gambar != null)
                      Image.network(
                        tenantProvider.tenant!.gambar!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const ShimmerLoadingWidget(
                            shimmerContainerImage: true,
                            padding: EdgeInsets.zero,
                            heightContainerImage: 200,
                            widhtContainerImage: double.infinity,
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDummyImage(),
                      )
                    else
                      _buildDummyImage(),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tenantProvider.tenant?.namaTenant ?? '',
                            style: GoogleFonts.poppins(
                              color: AppColors.textColorBlack,
                              fontSize: 16,
                              fontWeight: semibold,
                            ),
                          ),
                          const SizedBox(width: 5),
                          if (authProvider.user.isOnline == false)
                            Text(
                              'Tutup',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: medium,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        'Aneka makanan mulai dari ${FormatCurrency.intToStringCurrency(tenantProvider.tenant?.range ?? 0)}',
                        style: GoogleFonts.poppins(
                          color: AppColors.textColorBlack,
                          fontSize: 12,
                          fontWeight: regular,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 0.3, color: AppColors.containerColorGrey),
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                  ),
                  height: 50,
                  width: 50,
                  child: Center(
                    child: Text(
                      tenantProvider.tenant?.namaKavling ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textColorBlack,
                        fontWeight: bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDummyImage() {
    return Image.asset(
      'assets/images/dummy.jpeg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: 200,
    );
  }

  Widget _buildEditForm(TenantProvider tenantProvider) {
    return Column(
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
                    : tenantProvider.tenant?.gambar != null
                        ? DecorationImage(
                            image: NetworkImage(tenantProvider.tenant!.gambar!),
                            fit: BoxFit.cover,
                          )
                        : const DecorationImage(
                            image: AssetImage('assets/images/dummy.jpeg'),
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
          label: 'Nama Tenant',
          hintText: 'Tuliskan nama tenant',
          isRequired: true,
          controller: namaTenantController,
        ),
        CustomTextFormField(
          label: 'Nomor Kavling Tenant',
          hintText: 'Tuliskan nomor kavling tenant (e.g. M12)',
          isRequired: true,
          controller: nomorKavlingController,
        ),
        CustomTextFormField(
          label: 'No Rekening Toko',
          hintText: '8xxx-9xxx-4xxx',
          inputType: TextInputType.number,
          controller: nomorRekeningTokoController,
        ),
        CustomTextFormField(
          label: 'No Rekening Pribadi',
          hintText: '8xxx-9xxx-4xxx',
          inputType: TextInputType.number,
          controller: nomorRekeningPribadiController,
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
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color.fromARGB(255, 68, 68, 68)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(color: Color.fromARGB(255, 68, 68, 68)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _saveProfile(tenantProvider, authProvider),
              style: ElevatedButton.styleFrom(
                side: BorderSide(color: AppColors.primaryColor),
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Simpan',
                      style: TextStyle(color: Colors.white),
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
