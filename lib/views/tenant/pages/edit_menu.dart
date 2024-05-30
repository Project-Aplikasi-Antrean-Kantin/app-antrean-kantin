import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/constants.dart';
import 'package:testgetdata/http/update_menu_kelola.dart';
import 'package:testgetdata/model/kategori_menu_model.dart';
import 'package:testgetdata/model/tenant_foods.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/provider/katalog_menu_provider.dart';
import 'package:testgetdata/views/theme.dart';

class EditMenuPage extends StatefulWidget {
  final TenantFoods tenantFoods;

  const EditMenuPage({
    Key? key,
    required this.tenantFoods,
  }) : super(key: key);

  static const int EditMenuPageIndex = 0;

  @override
  State<EditMenuPage> createState() => _EditMenuPageState();
}

Future<int> _getImageSize(String imagePath) async {
  File imageFile = File(imagePath);
  int sizeInBytes = await imageFile.length();
  int sizeInKB = sizeInBytes ~/ 1024; // Convert bytes to KB
  return sizeInKB;
}

class MenuItem {
  final String value;
  MenuItem(this.value);
}

class _EditMenuPageState extends State<EditMenuPage> {
  late ImagePicker _imagePicker;
  int selectedCategory = 0;
  bool isLoading = false;

  List<KategoriMenu> kategoriMenu = [
    KategoriMenu(id: 1, nama: 'Makanan', kategoriId: 1),
    KategoriMenu(id: 2, nama: 'Minuman', kategoriId: 1),
    KategoriMenu(id: 3, nama: 'Snack', kategoriId: 2),
  ];
  String? selectedImagePath;

  late TextEditingController namaMenuController;
  late TextEditingController deskripsiMenuController;
  late TextEditingController hargaMenuController;

  @override
  void initState() {
    namaMenuController =
        TextEditingController(text: widget.tenantFoods.nama ?? '');
    deskripsiMenuController =
        TextEditingController(text: widget.tenantFoods.deskripsi);
    hargaMenuController =
        TextEditingController(text: widget.tenantFoods.harga.toString());

    super.initState();
    selectedCategory = widget.tenantFoods.kategoriId;
    _imagePicker = ImagePicker();
  }

  Future<void> _getImageFromGallery() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      selectedImagePath = pickedImage.path;
      setState(() {});
    }
  }

  Future<void> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UserModel user = authProvider.user;
    print(selectedCategory);

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 220, 220, 220),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
        title: Text(
          'Edit Menu',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
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

        // Button Hapus Menu
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
              size: 24,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Hapus Menu",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Apakah Anda yakin ingin untuk menghapus menu ini?",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      side: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  minimumSize:
                                      MaterialStateProperty.all(Size(100, 30)),
                                ),
                                child: const Text(
                                  "Batal",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 99, 99, 99),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              TextButton(
                                onPressed: () {
                                  context
                                      .read<KatalogMenuProvider>()
                                      .deleteFood(
                                          user.token, widget.tenantFoods.id);
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Color.fromARGB(227, 244, 67, 54),
                                  ),
                                  minimumSize:
                                      MaterialStateProperty.all(Size(100, 30)),
                                ),
                                child: const Text(
                                  "Hapus",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Colors.grey,
            height: 0.5,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                // border: Border.all(
                //   color: Colors.grey,
                //   width: 1.0,
                // ),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Container(
                          //   width: 250,
                          //   height: 150,
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(8),
                          //     image: selectedImagePath != null
                          //         ? DecorationImage(
                          //             image:
                          //                 FileImage(File(selectedImagePath!)),
                          //             fit: BoxFit.cover,
                          //           )
                          //         : const DecorationImage(
                          //             image: AssetImage(
                          //                 'assets/images/dummy.jpeg'),
                          //             fit: BoxFit.cover,
                          //           ),
                          //   ),
                          // ),
                          Container(
                            width: 250,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: selectedImagePath != null
                                  ? DecorationImage(
                                      image:
                                          FileImage(File(selectedImagePath!)),
                                      fit: BoxFit.cover,
                                    )
                                  : widget.tenantFoods.gambar != null &&
                                          widget.tenantFoods.gambar.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            "${MasbroConstants.baseUrl}${widget.tenantFoods.gambar}",
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

                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () async {
                              await _getImageFromGallery();
                              if (selectedImagePath != null) {
                                int imageSizeKB =
                                    await _getImageSize(selectedImagePath!);
                                if (imageSizeKB > 2048) {
                                  // ignore: use_build_context_synchronously
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(25),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "Peringatan!",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 15),
                                              const Text(
                                                "Gambar yang kamu pilih lebih dari 2MB.",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 16),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                style: ButtonStyle(
                                                  shape:
                                                      MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        5.0,
                                                      ),
                                                      side: const BorderSide(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                  minimumSize:
                                                      MaterialStateProperty.all(
                                                          Size(100, 30)),
                                                ),
                                                child: const Text(
                                                  "Batal",
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 99, 99, 99),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                  selectedImagePath = null;
                                } else {
                                  setState(() {});
                                }
                              }
                            },
                            icon: const Icon(Icons.edit_square),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            'Nama Menu',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            ' *',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: namaMenuController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          hintText: 'Tuliskan nama menu',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Deskripsi Menu',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      TextField(
                        controller: deskripsiMenuController,
                        maxLines: 3, // Atau jumlah baris yang diinginkan
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          // labelText: 'Deskripsi',
                          hintText: 'Masukkan deskripsi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            'Harga Menu',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            ' *',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: hargaMenuController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Rp ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 62,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: DropdownButton<int>(
                        value: selectedCategory,
                        items: kategoriMenu.map((value) {
                          return DropdownMenuItem<int>(
                            value: value.id,
                            child: Text(value.nama),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedCategory = newValue!;
                          });
                        },
                        hint: const Text(
                          'Pilih kategori menu',
                        ),
                        isExpanded: true,
                        // elevation: 0,
                        dropdownColor: Color.fromARGB(255, 236, 236, 236),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                  Row(
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
                              // setState(() {
                              //   isLoading = true;
                              // });
                              // final menu_id = selectedCategory;
                              // final nama_menu = namaMenuController.text;
                              // final harga_menu = hargaMenuController.text;
                              // final deskripsi_menu =
                              //     deskripsiMenuController.text;
                              // final data = {
                              //   "menu_id": menu_id,
                              //   "nama_menu": nama_menu,
                              //   "deskripsi_menu": deskripsi_menu,
                              //   "harga": harga_menu,
                              //   "gambar": selectedImagePath
                              // };
                              // updateMenuKelolaFile(user.token, (data),
                              //         widget.tenantFoods.detailMenu!.id)
                              //     .then((value) {
                              //   debugPrint('value setelah edit $value');
                              //   if (value) {
                              //     // Navigator.pushReplacementNamed(
                              //     //     context, '/profile');
                              //     Navigator.pop(context, true);
                              //   } else {
                              //     // Navigator.pop(context);
                              //     debugPrint('gagall');
                              //   }
                              // }).whenComplete(() {
                              //   // Hide CircularProgressIndicator when operation is completed
                              //   setState(() {
                              //     isLoading = false;
                              //   });
                              // });
                              String message = '';
                              if (hargaMenuController.text.isEmpty &&
                                  selectedCategory == null) {
                                message =
                                    "Kategori dan harga menu belum diisi.";
                              } else if (hargaMenuController.text.isEmpty) {
                                message = "Harga menu belum diisi.";
                              } else if (selectedCategory == null) {
                                message = "Kategori menu belum dipilih.";
                              } else if (double.tryParse(
                                      hargaMenuController.text)! <=
                                  0) {
                                message =
                                    "Koreksi harga! Harga menu harus lebih besar dari 0";
                              }

                              if (message.isNotEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(25),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Koreksi field!",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            Text(
                                              message,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 16),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              style: ButtonStyle(
                                                shape:
                                                    MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                    side: const BorderSide(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                                minimumSize:
                                                    MaterialStateProperty.all(
                                                        Size(100, 30)),
                                              ),
                                              child: const Text(
                                                "Ok",
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 99, 99, 99),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                setState(() {
                                  isLoading = true;
                                });

                                final kategori_id = selectedCategory;
                                final nama_menu = namaMenuController.text;
                                final harga_menu = hargaMenuController.text;
                                final deskripsi_menu =
                                    deskripsiMenuController.text;

                                final data = {
                                  "kategori_id": kategori_id,
                                  "nama_menu": nama_menu,
                                  "deskripsi_menu": deskripsi_menu,
                                  "harga": harga_menu,
                                  "gambar": selectedImagePath,
                                };

                                updateMenuKelolaFile(user.token, (data),
                                        widget.tenantFoods.id)
                                    .then((value) {
                                  debugPrint('value setelah edit $value');
                                  if (value) {
                                    Navigator.pop(context, true);
                                  } else {
                                    debugPrint('gagall');
                                  }
                                }).whenComplete(() {
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              side: BorderSide(
                                color: primaryColor,
                              ),
                              backgroundColor: primaryColor,
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
                                : const Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
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
      ),
    );
  }
}
