import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/http/add_menu_kelola.dart';
import 'package:testgetdata/model/kategori_menu_model.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';

class TambahMenuPage extends StatefulWidget {
  const TambahMenuPage({Key? key}) : super(key: key);
  // static const int TambahMenuPageIndex = 0;

  @override
  State<TambahMenuPage> createState() => _TambahMenuPageState();
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

class _TambahMenuPageState extends State<TambahMenuPage> {
  int? selectedCategory;
  late ImagePicker _imagePicker;
  String? selectedImagePath;
  bool isLoading = false;
  TextEditingController namaMenuController = TextEditingController();
  TextEditingController deskripsiMenuController = TextEditingController();
  TextEditingController hargaMenuController = TextEditingController();

  List<KategoriMenu> kategoriMenu = [
    KategoriMenu(id: 1, nama: 'Martabak', kategoriId: 1),
    KategoriMenu(id: 2, nama: 'Telur gulung', kategoriId: 1),
    KategoriMenu(id: 3, nama: 'Es Teh', kategoriId: 2),
    KategoriMenu(id: 4, nama: 'Bakso', kategoriId: 1),
    KategoriMenu(id: 5, nama: 'Mie Ayam', kategoriId: 1),
  ];

  @override
  void initState() {
    super.initState();
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

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 220, 220, 220),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
        title: Text(
          'Tambah Menu',
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () {
              // Navigator.pop(context);
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
              margin: EdgeInsets.all(10),
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
                                if (imageSizeKB > 1024) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Warning'),
                                        content: Text(
                                            'Gambar yang kamu pilih lebih dari 1MB'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('OK'),
                                          ),
                                        ],
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
                                selectedCategory = newValue;
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
                      Row(
                        children: [
                          Text(
                            'Deskripsi Menu',
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
                          hintText: 'Rp. ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ],
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
                      // Expanded(
                      //   child: Container(
                      //     margin: const EdgeInsets.only(left: 5),
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     child: ElevatedButton(
                      //       onPressed: () {
                      //         // Navigator.pop(context, true);
                      //         final menu_id = selectedCategory;
                      //         final nama_menu = namaMenuController.text;
                      //         final harga_menu = hargaMenuController.text;
                      //         final deskripsi_menu =
                      //             deskripsiMenuController.text;

                      //         final data = {
                      //           "menu_id": menu_id,
                      //           "nama_menu": nama_menu,
                      //           "deskripsi_menu": deskripsi_menu,
                      //           "harga": harga_menu,
                      //           "gambar": selectedImagePath,
                      //         };
                      //         addMenuKelolaFile(user.token, (data))
                      //             .then((value) {
                      //           if (value) {
                      //             Navigator.pushReplacementNamed(
                      //                 context, '/katalog_menu');
                      //           } else {
                      //             // Navigator.pop(context);
                      //           }
                      //         });
                      //       },
                      //       style: ElevatedButton.styleFrom(
                      //         side: const BorderSide(
                      //           color: Colors.redAccent,
                      //         ),
                      //         backgroundColor: Colors.redAccent,
                      //         shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(10),
                      //         ),
                      //       ),
                      //       child: const Text(
                      //         'Simpan',
                      //         style: TextStyle(
                      //           color: Colors.white,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Show CircularProgressIndicator when button is pressed
                            setState(() {
                              isLoading = true;
                            });

                            final menu_id = selectedCategory;
                            final nama_menu = namaMenuController.text;
                            final harga_menu = hargaMenuController.text;
                            final deskripsi_menu = deskripsiMenuController.text;

                            final data = {
                              "menu_id": menu_id,
                              "nama_menu": nama_menu,
                              "deskripsi_menu": deskripsi_menu,
                              "harga": harga_menu,
                              "gambar": selectedImagePath,
                            };

                            addMenuKelolaFile(user.token, (data)).then((value) {
                              if (value) {
                                Navigator.pushReplacementNamed(
                                    context, '/katalog_menu');
                              } else {
                                // Handle failure
                              }
                            }).whenComplete(() {
                              // Hide CircularProgressIndicator when operation is completed
                              setState(() {
                                isLoading = false;
                              });
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(color: Colors.redAccent),
                            backgroundColor: Colors.redAccent,
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
                                  'Simpan',
                                  style: TextStyle(
                                    color: Colors.white,
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
