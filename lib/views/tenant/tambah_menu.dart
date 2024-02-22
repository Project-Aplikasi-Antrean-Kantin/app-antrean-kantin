import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:testgetdata/views/home/navbar_home.dart';

class TambahMenu extends StatefulWidget {
  const TambahMenu({Key? key}) : super(key: key);
  static const int TambahMenuIndex = 0;

  @override
  State<TambahMenu> createState() => _TambahMenuState();
}

class MenuItem {
  final String value;
  final String label;

  MenuItem(this.value, this.label);
}

class _TambahMenuState extends State<TambahMenu> {
  String? selectedCategory;
  String? selectedMenu;
  bool customMenu = false;
  late ImagePicker _imagePicker;
  String? selectedImagePath;

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
    // Tambahkan logika pembaruan di sini
    // Misalnya, memperbarui daftar kategori atau menu
    await Future.delayed(Duration(seconds: 1)); // Contoh penundaan palsu
    setState(() {}); // Setelah selesai pembaruan, panggil setState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah menu"),
        actions: <Widget>[
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications))
        ],
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
              padding: const EdgeInsets.all(20),
              // decoration: BoxDecoration(
              //   border: Border.all(
              //     color: Colors.grey,
              //     width: 1.0,
              //   ),
              //   borderRadius: BorderRadius.circular(5.0),
              // ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
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
                              // Navigator.pop(context, true);
                            },
                            icon: const Icon(Icons.edit),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Nama Menu',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<String>(
                        value: selectedMenu,
                        items: <String>[
                          'Nasi goreng',
                          'Nasi Pecel',
                          'Nasi Padang',
                          'Nasi uduk',
                          'Nasi Campur'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          // Perbarui nilai yang dipilih saat dropdown berubah
                          setState(() {
                            selectedMenu = newValue;
                          });
                        },
                        hint: const Text('Pilih Nama Menu'),
                        isExpanded: true,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Harga Menu',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan Harga Menu',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Kategori Makanan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<String>(
                        value: selectedCategory,
                        items: <String>[
                          'Makanan Ringan',
                          'Makanan Berat',
                          'Minuman'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue;
                          });
                        },
                        hint: const Text('Pilih Kategori'),
                        isExpanded: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 180),
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
                              // Tombol Batal hanya perlu melakukan navigasi kembali ke Menu
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                color: Color.fromARGB(255, 74, 74, 74),
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
                              Navigator.pop(context, true);
                            },
                            style: ElevatedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color.fromARGB(255, 22, 68, 105)),
                              primary: Color.fromARGB(255, 22, 68, 105),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
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
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const NavbarHome(
        pageIndex: TambahMenu.TambahMenuIndex,
      ),
    );
  }
}
