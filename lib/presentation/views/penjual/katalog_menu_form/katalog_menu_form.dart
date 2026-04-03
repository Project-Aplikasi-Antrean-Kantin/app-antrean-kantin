import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/kategori_menu_model.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/katalog_menu_provider.dart';
import 'package:testgetdata/presentation/views/penjual/katalog_menu_form/widgets/app_bar_form.dart';
import 'package:testgetdata/presentation/views/penjual/katalog_menu_form/widgets/bottom_navigation_bar_form.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/custom_form_field.dart';
import 'package:testgetdata/presentation/widgets/organisms/image_picker_bottom_sheet/image_picker_bottom_sheet.dart';

class KatalogMenuForm extends StatefulWidget {
  final TenantFoods? initialData; // Null untuk tambah, non-null untuk edit

  const KatalogMenuForm({Key? key, this.initialData}) : super(key: key);

  @override
  State<KatalogMenuForm> createState() => _KatalogMenuFormState();
}

class _KatalogMenuFormState extends State<KatalogMenuForm> {
  String? selectedImagePath;
  int? selectedCategory;

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

    final provider = Provider.of<KatalogMenuProvider>(context, listen: false);

    final data = {
      'kategori_id': selectedCategory,
      'nama_menu': namaMenuController.text,
      'deskripsi': deskripsiMenuController.text,
      'harga': hargaMenuController.text,
      'gambar': selectedImagePath,
    };

    final result = await provider.saveMenu(
      token: user.token,
      data: data,
      id: widget.initialData?.id,
    );

    if (result != null) {
      Navigator.of(context).pop(true);
    } else {
      showDialog(
        context: context,
        builder: (context) => CustomAlertDialog(
          title: 'Gagal!',
          message: provider.errorMessage ?? 'Terjadi kesalahan',
          showCancelButton: false,
        ),
      );
    }
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
                    AppBarForm(title: isEditMode ? 'Edit Menu' : 'Tambah Menu'),
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
                          onTap: () => _openImagePicker(),
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: selectedImagePath != null
                                  ? DecorationImage(
                                      image:
                                          FileImage(File(selectedImagePath!)),
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
                                onTap: () => _openImagePicker(),
                                child: Text(
                                    isEditMode ? 'Ubah Foto' : 'Pilih Foto',
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
        bottomNavigationBar:
            Consumer<KatalogMenuProvider>(builder: (context, provider, _) {
          return BottomNavigationBarForm(
              confirmText: isEditMode ? 'Simpan' : 'Tambah',
              isLoading: provider.isLoading,
              onConfirm: () => _saveForm(user, context));
        }));
  }

  Future<void> _openImagePicker() {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return ImagePickerBottomSheet(
          titleBottomSheet: 'Foto Menu',
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
}
