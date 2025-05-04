import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Future<int> _getImageSize(String imagePath) async {
    final file = File(imagePath);
    final sizeInBytes = await file.length();
    return sizeInBytes ~/ 1024; // KB
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final sizeInKB = await _getImageSize(pickedImage.path);
      if (sizeInKB > 2048) {
        showDialog(
          context: context,
          builder: (context) => CustomAlertDialog(
            title: 'Peringatan!',
            message: 'Gambar lebih dari 2MB.',
            showCancelButton: false,
          ),
        );
      } else {
        setState(() {
          selectedImagePath = pickedImage.path;
        });
      }
    }
  }

  Future<void> _saveForm(UserModel user) async {
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

    final data = {
      'kategori_id': selectedCategory,
      'nama_menu': namaMenuController.text,
      'deskripsi_menu': deskripsiMenuController.text,
      'harga': hargaMenuController.text,
      'gambar': selectedImagePath,
    };

    try {
      final source = TenantRemoteDataSource();
      final success = widget.initialData == null
          ? await source.createMenuTenant(user.token, data)
          : await source.updateMenuTenant(
              user.token, data, widget.initialData!.id);

      if (success) {
        // Kembalikan true untuk memicu refresh
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
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
        title: Text(
          isEditMode ? 'Edit Menu' : 'Tambah Menu',
          style: GoogleFonts.poppins(
            color: AppColors.textColorBlack,
            fontSize: 18,
            fontWeight: semibold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_backspace,
              color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        actions: isEditMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                  onPressed: () => _deleteMenu(user),
                ),
              ]
            : null,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            margin: const EdgeInsets.all(15),
            child: Column(
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
                                    image:
                                        AssetImage('assets/images/dummy.jpeg'),
                                    fit: BoxFit.cover,
                                  ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.edit_square),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  label: 'Nama Menu',
                  hintText: 'Tuliskan nama menu',
                  isRequired: true,
                  controller: namaMenuController,
                ),
                CustomTextFormField(
                  label: 'Deskripsi Menu',
                  hintText: 'Masukan deskripsi',
                  controller: deskripsiMenuController,
                  maxLine: 3,
                ),
                CustomTextFormField(
                  label: 'Harga Menu',
                  hintText: 'Rp',
                  isRequired: true,
                  inputType: TextInputType.number,
                  controller: hargaMenuController,
                ),
                Row(
                  children: [
                    Text(
                      'Kategori Menu',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
                      style:
                          GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                    ),
                    isExpanded: true,
                    dropdownColor: const Color.fromARGB(255, 236, 236, 236),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 5),
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF444444)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(color: Color(0xFF444444)),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _saveForm(user),
                        style: ElevatedButton.styleFrom(
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isEditMode ? 'Edit' : 'Simpan',
                                style: const TextStyle(color: Colors.white),
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
