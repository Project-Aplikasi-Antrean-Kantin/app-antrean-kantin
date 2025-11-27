import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/kategori_menu_model.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/remote/tenant_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/katalog_menu_provider.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/custom_form_field.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class KatalogMenuForm extends StatefulWidget {
  final TenantFoods? initialData; // Null untuk tambah, non-null untuk edit

  const KatalogMenuForm({Key? key, this.initialData}) : super(key: key);

  @override
  State<KatalogMenuForm> createState() => _KatalogMenuFormState();
}

class _KatalogMenuFormState extends State<KatalogMenuForm> {
  late ImagePicker _imagePicker;
  String? selectedImagePath;
  int? selectedCategory;
  bool isLoading = false;

  late TextEditingController namaMenuController;
  late TextEditingController deskripsiMenuController;
  late TextEditingController hargaMenuController;

  // Kategori statis (nanti bisa diganti dengan API)
  final List<KategoriMenu> kategoriMenu = [
    KategoriMenu(id: 1, nama: 'Makanan', kategoriId: 1),
    KategoriMenu(id: 2, nama: 'Minuman', kategoriId: 1),
    KategoriMenu(id: 3, nama: 'Snack', kategoriId: 2),
  ];

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
    namaMenuController =
        TextEditingController(text: widget.initialData?.nama ?? '');
    deskripsiMenuController =
        TextEditingController(text: widget.initialData?.deskripsi ?? '');
    hargaMenuController =
        TextEditingController(text: widget.initialData?.harga.toString() ?? '');
    selectedCategory = widget.initialData?.kategoriId;
  }

  TextInputFormatter noDotFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      // Hapus semua titik dari input baru
      String newText = newValue.text.replaceAll('.', '');
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    });
  }

  Future<int> _getImageSize(String imagePath) async {
    final imageFile = File(imagePath);
    final sizeInBytes = await imageFile.length();
    return sizeInBytes ~/ 1024; // Convert bytes to KB
  }

  Future<void> _getImageFromGallery(BuildContext context) async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
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
          setState(() {
            selectedImagePath = compressedImage.path;
          });
          Navigator.pop(context);
        } else {
          showDialog(
            context: context,
            builder: (context) => CustomAlertDialog(
              title: 'Gagal!',
              message: 'Gagal mengompresi gambar. Silakan coba lagi.',
              showCancelButton: false,
            ),
          );
        }
      } catch (e) {
        debugPrint('Compression error: $e');
        showDialog(
          context: context,
          builder: (context) => CustomAlertDialog(
            title: 'Error!',
            message: 'Terjadi kesalahan saat mengompresi gambar.',
            showCancelButton: false,
          ),
        );
      }
    }
  }

  Future<void> _saveForm(UserModel user, BuildContext context) async {
    String message = '';
    if (namaMenuController.text.isEmpty) {
      message = 'Nama menu belum diisi.';
    } else if (hargaMenuController.text.isEmpty) {
      message = 'Harga menu belum diisi.';
    } else if (selectedCategory == null) {
      message = 'Kategori menu belum dipilih.';
    } else if (double.tryParse(hargaMenuController.text) == null ||
        double.parse(hargaMenuController.text) <= 0) {
      message = 'Harga menu harus lebih besar dari 0.';
    }

    if (message.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => CustomAlertDialog(
          title: 'Koreksi field!',
          message: message,
          showCancelButton: false,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final dataCreate = {
      'kategori_id': selectedCategory,
      'nama_menu': namaMenuController.text,
      'deskripsi_menu': deskripsiMenuController.text,
      'harga': hargaMenuController.text,
      'gambar': selectedImagePath,
    };

    final dataEdit = {
      'kategori_id': selectedCategory,
      'nama_menu': namaMenuController.text,
      'deskripsi': deskripsiMenuController.text,
      'harga': hargaMenuController.text,
      'gambar': selectedImagePath,
    };

    try {
      final source = TenantRemoteDataSource();
      final provider = Provider.of<KatalogMenuProvider>(context, listen: false);
      final success = widget.initialData == null
          ? await source.createMenuTenant(user.token, dataCreate)
          : await source.updateMenuTenant(
              user.token, dataEdit, widget.initialData!.id);

      if (success != null) {
        if (widget.initialData != null) {
          provider.updateDataById(success);
        }
        Navigator.of(context).pop(true);
      } else {
        showDialog(
          context: context,
          builder: (context) => CustomAlertDialog(
            title: 'Gagal!',
            message: 'Gagal menyimpan menu. Coba lagi.',
            showCancelButton: false,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving menu: $e');
      showDialog(
        context: context,
        builder: (context) => CustomAlertDialog(
          title: 'Error!',
          message: 'Terjadi kesalahan. Coba lagi nanti.',
          showCancelButton: false,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
          setState(() {});
          Navigator.pop(context);
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

  Future<void> _deleteMenu(UserModel user) async {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Hapus Menu',
        message: 'Apakah Anda yakin ingin menghapus menu ini?',
        showCancelButton: true,
        onOkPressed: () async {
          try {
            final success = await context
                .read<KatalogMenuProvider>()
                .deleteFood(user.token, widget.initialData!.id);
            Navigator.of(context).pop(); // Tutup dialog
            if (success) {
              Navigator.of(context).pop(true); // Kembalikan true untuk refresh
            } else {
              showDialog(
                context: context,
                builder: (context) => CustomAlertDialog(
                  title: 'Gagal!',
                  message: 'Gagal menghapus menu. Coba lagi.',
                  showCancelButton: false,
                ),
              );
            }
          } catch (e) {
            debugPrint('Error deleting menu: $e');
            showDialog(
              context: context,
              builder: (context) => CustomAlertDialog(
                title: 'Gagal!',
                message: 'Gagal menghapus menu. Coba lagi.',
                showCancelButton: false,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isEditMode = widget.initialData != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              margin: const EdgeInsets.all(15),
              child: Column(
                spacing: 8,
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
                          isEditMode
                              ? 'Edit Menu Tenant'
                              : 'Tambah Menu Tenant',
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
                        'Foto Menu',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const Text(
                        ' *',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 10,
                    children: [
                      GestureDetector(
                        onTap: () =>
                            _buildBottomSheetProfile(context, authProvider),
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: selectedImagePath != null
                                ? DecorationImage(
                                    image: FileImage(File(selectedImagePath!)),
                                    fit: BoxFit.cover,
                                  )
                                : isEditMode &&
                                        widget.initialData!.gambar != null &&
                                        widget.initialData!.gambar.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          '${MasbroConstants.baseUrl}${widget.initialData!.gambar}',
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
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => _buildBottomSheetProfile(
                                  context, authProvider),
                              child:
                                  Text(isEditMode ? 'Ubah Foto' : 'Pilih Foto',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryColor,
                                      )),
                            ),
                            Text(
                                'Ukuran foto 1:1, pastikan ukuran sesuai dan tidak lebih dari 1 MB',
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.blackColor200)),
                          ],
                        ),
                      ),
                      // IconButton(
                      //   onPressed: _getImageFromGallery,
                      //   icon: const Icon(Icons.edit_square),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    label: 'Nama Menu',
                    labelColor: AppColors.primaryColor,
                    hintText: 'Tuliskan nama menu',
                    isRequired: true,
                    controller: namaMenuController,
                  ),
                  CustomTextFormField(
                    label: 'Deskripsi Menu',
                    labelColor: AppColors.primaryColor,
                    hintText: 'Masukan deskripsi',
                    controller: deskripsiMenuController,
                    maxLine: 3,
                  ),
                  CustomTextFormField(
                    label: 'Harga Menu',
                    labelColor: AppColors.primaryColor,
                    hintText: 'Tuliskan harga menu',
                    isRequired: true,
                    inputType: TextInputType.number,
                    controller: hargaMenuController,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      noDotFormatter(),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Kategori Menu',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const Text(
                        ' *',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: DropdownButton<int>(
                      value: selectedCategory,
                      items: kategoriMenu.map((value) {
                        return DropdownMenuItem<int>(
                          value: value.id,
                          child: Text(
                            value.nama,
                            style: GoogleFonts.poppins(
                              fontWeight: regular,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                      hint: Text(
                        'Pilih kategori menu',
                        style: GoogleFonts.poppins(
                            color: Colors.grey, fontSize: 14),
                      ),
                      isExpanded: true,
                      dropdownColor: const Color.fromARGB(255, 236, 236, 236),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
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
                    onPressed:
                        isLoading ? null : () => _saveForm(user, context),
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
                        : Text(
                            isEditMode ? 'Edit' : 'Simpan',
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
                        'Foto Menu',
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
}
