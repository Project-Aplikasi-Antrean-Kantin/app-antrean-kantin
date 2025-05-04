// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:testgetdata/core/theme/text_theme.dart';
// import 'package:testgetdata/data/constants.dart';
// import 'package:testgetdata/data/remote/tenant_remote_data_source.dart';
// import 'package:testgetdata/core/theme/colors_theme.dart';
// import 'package:testgetdata/data/model/kategori_menu_model.dart';
// import 'package:testgetdata/data/model/tenant_foods.dart';
// import 'package:testgetdata/data/model/user_model.dart';
// import 'package:testgetdata/presentation/provider/auth_provider.dart';
// import 'package:testgetdata/presentation/provider/katalog_menu_provider.dart';
// import 'package:testgetdata/presentation/views/penjual/katalog_menu_page.dart';
// import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
// import 'package:testgetdata/presentation/widgets/custom_form_field.dart';

// class EditProfil extends StatefulWidget {
//   final UserModel userProfil;

//   const EditProfil({
//     Key? key,
//     required this.userProfil,
//   }) : super(key: key);

//   // static const int EditMenuPageIndex = 0;

//   @override
//   State<EditProfil> createState() => _EditProfilState();
// }

// Future<int> _getImageSize(String imagePath) async {
//   File imageFile = File(imagePath);
//   int sizeInBytes = await imageFile.length();
//   int sizeInKB = sizeInBytes ~/ 1024; // Convert bytes to KB
//   return sizeInKB;
// }

// class MenuItem {
//   final String value;
//   MenuItem(this.value);
// }

// class _EditProfilState extends State<EditProfil> {
//   late ImagePicker _imagePicker;
//   int selectedCategory = 0;
//   bool isLoading = false;

//   List<KategoriMenu> kategoriMenu = [
//     KategoriMenu(id: 1, nama: 'Makanan', kategoriId: 1),
//     KategoriMenu(id: 2, nama: 'Minuman', kategoriId: 1),
//     KategoriMenu(id: 3, nama: 'Snack', kategoriId: 2),
//   ];
//   String? selectedImagePath;

//   late TextEditingController namaMenuController;
//   late TextEditingController deskripsiMenuController;
//   late TextEditingController hargaMenuController;

//   @override
//   void initState() {
//     namaMenuController =
//         TextEditingController(text: widget.userProfil.nama ?? '');
//     // deskripsiMenuController =
//     //     TextEditingController(text: widget.userProfil.deskripsi);
//     // hargaMenuController =
//     //     TextEditingController(text: widget.userProfil.harga.toString());

//     super.initState();
//     // selectedCategory = widget.userProfil.kategoriId;
//     _imagePicker = ImagePicker();
//   }

//   Future<void> _getImageFromGallery() async {
//     final pickedImage =
//         await _imagePicker.pickImage(source: ImageSource.gallery);
//     if (pickedImage != null) {
//       selectedImagePath = pickedImage.path;
//       int imageSizeKB = await _getImageSize(selectedImagePath!);
//       if (imageSizeKB > 2048) {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return CustomAlertDialog(
//               title: "Peringatan!",
//               message: "Gambar yang kamu pilih lebih dari 2MB.",
//               showCancelButton: false,
//             );
//           },
//         );
//         selectedImagePath = null;
//       }
//       setState(() {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     AuthProvider authProvider = Provider.of<AuthProvider>(context);
//     UserModel user = authProvider.user;
//     print(selectedCategory);

//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: AppBar(
//         scrolledUnderElevation: 0,
//         automaticallyImplyLeading: false,
//         toolbarHeight: 50,
//         title: Text(
//           'Edit Profil',
//           style: GoogleFonts.poppins(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.keyboard_backspace,
//             color: Colors.black,
//             size: 24,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         // actions: [
//         //   IconButton(
//         //     icon: const Icon(
//         //       Icons.delete,
//         //       color: Colors.red,
//         //       size: 24,
//         //     ),
//         //     onPressed: () {
//         //       showDialog(
//         //         context: context,
//         //         builder: (BuildContext context) {
//         //           return CustomAlertDialog(
//         //             title: "Hapus Menu",
//         //             message:
//         //                 "Apakah Anda yakin ingin untuk menghapus menu ini?",
//         //             showCancelButton: true,
//         //             onOkPressed: () {
//         //               context
//         //                   .read<KatalogMenuProvider>()
//         //                   .deleteFood(user.token, widget.tenantFoods.id);
//         //               Navigator.of(context).pop();
//         //               Navigator.of(context).pop();
//         //             },
//         //           );
//         //         },
//         //       );
//         //     },
//         //   ),
//         // ],
//       ),
//       body: GestureDetector(
//         onTap: () {
//           FocusScope.of(context).requestFocus(FocusNode());
//         },
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: Container(
//             margin: const EdgeInsets.all(15),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           width: 250,
//                           height: 150,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8),
//                             image: selectedImagePath != null
//                                 ? DecorationImage(
//                                     image: FileImage(File(selectedImagePath!)),
//                                     fit: BoxFit.cover,
//                                   )
//                                 : widget.userProfil. != null &&
//                                         widget.tenantFoods.gambar.isNotEmpty
//                                     ? DecorationImage(
//                                         image: NetworkImage(
//                                           "${MasbroConstants.baseUrl}${widget.tenantFoods.gambar}",
//                                         ),
//                                         fit: BoxFit.cover,
//                                       )
//                                     : const DecorationImage(
//                                         image: AssetImage(
//                                             'assets/images/dummy.jpeg'),
//                                         fit: BoxFit.cover,
//                                       ),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         IconButton(
//                           onPressed: _getImageFromGallery,
//                           icon: const Icon(Icons.edit_square),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     CustomTextFormField(
//                       label: 'Nama Tenant',
//                       hintText: 'Tuliskan nama menu',
//                       isRequired: true,
//                       controller: namaMenuController,
//                     ),
//                     CustomTextFormField(
//                       label: 'Deskripsi menu',
//                       hintText: 'Masukan deskripsi',
//                       controller: deskripsiMenuController,
//                       maxLine: 3,
//                     ),
//                     CustomTextFormField(
//                       label: 'Harga Menu',
//                       hintText: 'Rp',
//                       isRequired: true,
//                       inputType: TextInputType.number,
//                       controller: hargaMenuController,
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     Text(
//                       'Kategori Menu',
//                       style: GoogleFonts.poppins(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const Text(
//                       ' *',
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 8),
//                 Container(
//                   height: 50,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: Colors.grey,
//                       width: 1.0,
//                     ),
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   padding: EdgeInsets.symmetric(horizontal: 12.0),
//                   child: Align(
//                     alignment: Alignment.center,
//                     child: DropdownButton<int>(
//                       value: selectedCategory,
//                       items: kategoriMenu.map((value) {
//                         return DropdownMenuItem<int>(
//                           value: value.id,
//                           child: Text(
//                             value.nama,
//                             style: GoogleFonts.poppins(
//                               fontWeight: regular,
//                               fontSize: 14,
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                       onChanged: (int? newValue) {
//                         setState(() {
//                           selectedCategory = newValue!;
//                         });
//                       },
//                       hint: const Text(
//                         'Pilih kategori menu',
//                       ),
//                       isExpanded: true,
//                       dropdownColor: Color.fromARGB(255, 236, 236, 236),
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 50),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Container(
//                         margin: const EdgeInsets.only(right: 5),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: OutlinedButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           style: OutlinedButton.styleFrom(
//                             side: const BorderSide(
//                               color: Color.fromARGB(255, 68, 68, 68),
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           child: const Text(
//                             'Batal',
//                             style: TextStyle(
//                               color: Color.fromARGB(255, 68, 68, 68),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Container(
//                         margin: const EdgeInsets.only(left: 5),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: ElevatedButton(
//                           onPressed: () {
//                             String message = '';
//                             if (hargaMenuController.text.isEmpty &&
//                                 selectedCategory == null) {
//                               message = "Kategori dan harga menu belum diisi.";
//                             } else if (hargaMenuController.text.isEmpty) {
//                               message = "Harga menu belum diisi.";
//                             } else if (selectedCategory == null) {
//                               message = "Kategori menu belum dipilih.";
//                             } else if (double.tryParse(
//                                     hargaMenuController.text)! <=
//                                 0) {
//                               message =
//                                   "Koreksi harga! Harga menu harus lebih besar dari 0";
//                             }

//                             if (message.isNotEmpty) {
//                               showDialog(
//                                 context: context,
//                                 builder: (BuildContext context) {
//                                   return CustomAlertDialog(
//                                     title: "Koreksi field!",
//                                     message: message,
//                                     showCancelButton: false,
//                                   );
//                                 },
//                               );
//                             } else {
//                               setState(() {
//                                 isLoading = true;
//                               });

//                               final kategori_id = selectedCategory;
//                               final nama_menu = namaMenuController.text;
//                               final harga_menu = hargaMenuController.text;
//                               final deskripsi_menu =
//                                   deskripsiMenuController.text;

//                               final data = {
//                                 "kategori_id": kategori_id,
//                                 "nama_menu": nama_menu,
//                                 "deskripsi_menu": deskripsi_menu,
//                                 "harga": harga_menu,
//                                 "gambar": selectedImagePath,
//                               };

//                               TenantRemoteDataSource()
//                                   .updateMenuTenant(
//                                       user.token, (data), widget.tenantFoods.id)
//                                   .then((value) {
//                                 debugPrint('value setelah edit $value');
//                                 if (value) {
//                                   Navigator.of(context).pushAndRemoveUntil(
//                                     MaterialPageRoute(
//                                       builder: (context) => const KatalogMenu(),
//                                     ),
//                                     (route) => route.isFirst,
//                                   );
//                                 } else {
//                                   debugPrint('gagall');
//                                 }
//                               }).whenComplete(() {
//                                 setState(() {
//                                   isLoading = false;
//                                 });
//                               });
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             side: BorderSide(
//                               color: AppColors.primaryColor,
//                             ),
//                             backgroundColor: AppColors.primaryColor,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           child: isLoading
//                               ? const SizedBox(
//                                   width: 20,
//                                   height: 20,
//                                   child: CircularProgressIndicator(
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                         Colors.white),
//                                     strokeWidth: 2,
//                                   ),
//                                 )
//                               : const Text(
//                                   'Edit',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
