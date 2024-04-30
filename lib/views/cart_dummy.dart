// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:testgetdata/components/list_cart.dart';
// import 'package:testgetdata/http/post_transaction.dart';
// import 'package:testgetdata/model/cart_menu_modelllll.dart';
// import 'package:testgetdata/provider/cart_provider.dart';
// import 'package:testgetdata/views/last.dart';
// import 'package:testgetdata/components/bottom_sheet_keranjang.dart';

// class CartModel {
//   final int menuId;
//   final String menuNama;
//   final int menuPrice;
//   final int count;
//   final String tenantName;

//   CartModel({
//     required this.menuId,
//     required this.menuNama,
//     required this.menuPrice,
//     required this.count,
//     required this.tenantName,
//   });
// }

// class DummyData {
//   static List<CartModel> getDummyCart() {
//     return [
//       CartModel(
//         menuId: 1,
//         menuNama: 'Nasi Goreng',
//         menuPrice: 10000,
//         count: 1,
//         tenantName: 'Tenant A',
//       ),
//       CartModel(
//         menuId: 2,
//         menuNama: 'Es Teh',
//         menuPrice: 3000,
//         count: 2,
//         tenantName: 'Tenant B',
//       ),
//       CartModel(
//         menuId: 3,
//         menuNama: 'Es Doger',
//         menuPrice: 5000,
//         count: 1,
//         tenantName: 'Tenant C',
//       ),
//     ];
//   }
// }

// class CartDummy extends StatefulWidget {
//   const CartDummy({Key? key}) : super(key: key);

//   @override
//   State<CartDummy> createState() => _CartDummyState();
// }

// class _CartDummyState extends State<CartDummy> {
//   TextEditingController namaPembeli = TextEditingController();
//   TextEditingController ruanganPembeli = TextEditingController();
//   TextEditingController catatan = TextEditingController();

//   setPreferences() async {
//     final jembatan = await SharedPreferences.getInstance();

//     final data =
//         jsonEncode({"nama": namaPembeli.text, "ruangan": ruanganPembeli.text});
//     jembatan.setString('data', data);
//   }

//   getPreferences() async {
//     final jembatan = await SharedPreferences.getInstance();

//     if (jembatan.containsKey('data')) {
//       final data = jsonDecode(jembatan.getString('data').toString())
//           as Map<String, dynamic>;

//       namaPembeli.text = data['nama'];
//       ruanganPembeli.text = data['ruangan'];
//     }
//   }

//   String? pilihPemesanan;
//   String? pilihRuangan;

//   // void _showBottomSheet(BuildContext context) {
//   //   bool isOptionSelected = false;

//   //   showModalBottomSheet(
//   //     context: context,
//   //     isScrollControlled: true,
//   //     shape: RoundedRectangleBorder(
//   //       borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
//   //     ),
//   //     builder: (BuildContext context) {
//   //       return StatefulBuilder(
//   //         builder: (context, setState) {
//   //           return Padding(
//   //             padding: const EdgeInsets.all(20),
//   //             child: Column(
//   //               mainAxisSize: MainAxisSize.min,
//   //               children: <Widget>[
//   //                 SizedBox(
//   //                   height: 40,
//   //                   child: Row(
//   //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                     children: [
//   //                       Expanded(
//   //                         child: ElevatedButton(
//   //                           onPressed: () {
//   //                             setState(
//   //                               () {
//   //                                 pilihPengantaran = 'Pesan Antar';
//   //                                 isOptionSelected = true;
//   //                               },
//   //                             );
//   //                           },
//   //                           style: ElevatedButton.styleFrom(
//   //                             shape: RoundedRectangleBorder(
//   //                               borderRadius: BorderRadius.circular(8),
//   //                               side: BorderSide(
//   //                                 color: Colors.grey,
//   //                               ),
//   //                             ),
//   //                           ),
//   //                           child: Text(
//   //                             'Pesan Antar',
//   //                             style: GoogleFonts.poppins(),
//   //                           ),
//   //                         ),
//   //                       ),
//   //                       SizedBox(width: 10),
//   //                       Expanded(
//   //                         child: ElevatedButton(
//   //                           onPressed: () {
//   //                             setState(
//   //                               () {
//   //                                 pilihPengantaran = 'Ambil Sendiri';
//   //                                 isOptionSelected = true;
//   //                               },
//   //                             );
//   //                           },
//   //                           style: ElevatedButton.styleFrom(
//   //                             shape: RoundedRectangleBorder(
//   //                               borderRadius: BorderRadius.circular(8),
//   //                               side: BorderSide(
//   //                                 color: Colors.grey,
//   //                               ),
//   //                             ),
//   //                           ),
//   //                           child: Text(
//   //                             'Ambil Sendiri',
//   //                             style: GoogleFonts.poppins(),
//   //                           ),
//   //                         ),
//   //                       ),
//   //                     ],
//   //                   ),
//   //                 ),
//   //                 SizedBox(height: 20),
//   //                 Row(
//   //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//   //                   children: [
//   //                     ElevatedButton(
//   //                       onPressed: () {
//   //                         Navigator.of(context).pop();
//   //                       },
//   //                       child: Text('Batal'),
//   //                     ),
//   //                     ElevatedButton(
//   //                       onPressed:
//   //                           isOptionSelected ? _onConfirmButtonPressed : null,
//   //                       child: Text('Konfirmasi'),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ],
//   //             ),
//   //           );
//   //         },
//   //       );
//   //     },
//   //   );
//   // }

//   // void _onConfirmButtonPressed() {
//   //   if (pilihPengantaran != null) {
//   //     setState(() {
//   //       pilihPengantaran = pilihPengantaran;
//   //       Navigator.of(context).pop();
//   //     });
//   //   }
//   // }

//   // void bottomSheetPengantaran(BuildContext context) {
//   //   bool isOptionSelected = false;
//   //   showModalBottomSheet(
//   //     context: context,
//   //     isScrollControlled: true,
//   //     shape: RoundedRectangleBorder(
//   //       borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
//   //     ),
//   //     builder: (BuildContext context) {
//   //       return StatefulBuilder(
//   //         builder: (context, setState) {
//   //           return Padding(
//   //             padding: const EdgeInsets.all(20),
//   //             child: Container(
//   //               // height: MediaQuery.of(context).size.height * 0.8,
//   //               child: Column(
//   //                 mainAxisSize: MainAxisSize.min,
//   //                 children: <Widget>[
//   //                   ListTile(
//   //                     leading: Icon(Icons.location_pin),
//   //                     title: Text(
//   //                       'Ruang C305',
//   //                       style: GoogleFonts.poppins(),
//   //                     ),
//   //                     onTap: () {
//   //                       setState(() {
//   //                         pilihRuangan = 'Ruang C305';
//   //                         isOptionSelected = true;
//   //                       });
//   //                     },
//   //                   ),
//   //                   ListTile(
//   //                     leading: Icon(Icons.location_pin),
//   //                     title: Text(
//   //                       'Ruang Perpusatakaan',
//   //                       style: GoogleFonts.poppins(),
//   //                     ),
//   //                     onTap: () {
//   //                       setState(() {
//   //                         pilihRuangan = 'Ruang Perpusatakaan';
//   //                         isOptionSelected = true;
//   //                       });
//   //                     },
//   //                   ),
//   //                   // Add more items as needed
//   //                   SizedBox(height: 20),
//   //                   Row(
//   //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//   //                     children: [
//   //                       ElevatedButton(
//   //                         onPressed: () {
//   //                           Navigator.of(context).pop();
//   //                         },
//   //                         child: Text('Batal'),
//   //                       ),
//   //                       ElevatedButton(
//   //                         onPressed:
//   //                             isOptionSelected ? konfirmasiRuangan : null,
//   //                         child: Text('Konfirmasi'),
//   //                       ),
//   //                     ],
//   //                   ),
//   //                 ],
//   //               ),
//   //             ),
//   //           );
//   //         },
//   //       );
//   //     },
//   //   );
//   // }

//   // void konfirmasiRuangan() {
//   //   if (pilihRuangan != null) {
//   //     setState(() {
//   //       pilihRuangan = pilihRuangan;
//   //       Navigator.of(context).pop();
//   //     });
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     // final List<CartModel> cart = Provider.of<CartProvider>(context).cart;
//     final List<CartModel> cart = DummyData.getDummyCart();
//     getPreferences();
//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: 50,
//         // backgroundColor: Color.fromARGB(255, 136, 24, 24),
//         // shadowColor: Color.fromARGB(255, 228, 26, 26),
//         title: Text(
//           'Keranjang',
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
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(4.0),
//           child: Container(
//             color: Colors.grey,
//             height: 0.5,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           // decoration: BoxDecoration(
//           //   border: Border.all(
//           //     color: Colors.grey,
//           //     width: 1.0,
//           //   ),
//           //   borderRadius: BorderRadius.circular(5.0),
//           // ),
//           margin: const EdgeInsets.all(15),
//           child: Column(
//             children: [
//               // Consumer<CartProvider>(
//               //   builder: (context, data, _) {
//               //     return ListView.separated(
//               //       separatorBuilder: (context, index) {
//               //         return const Divider();
//               //       },
//               //       shrinkWrap: true,
//               //       physics: const ScrollPhysics(),
//               //       itemCount: cart.length,
//               //       itemBuilder: (context, index) {
//               //         return ListCart(cart: cart[index]);
//               //       },
//               //     );
//               //   },
//               // ),
//               Card(
//                 margin: const EdgeInsets.fromLTRB(1, 10, 1, 1),
//                 shape: const RoundedRectangleBorder(
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(10),
//                     topRight: Radius.circular(10),
//                   ),
//                 ),
//                 // shadowColor: Colors.transparent,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(11),
//                           image: const DecorationImage(
//                             // image:
//                             //     NetworkImage(dataFoods['gambar']),
//                             // fit: BoxFit.cover),
//                             // image: NetworkImage(''),
//                             // fit: BoxFit.cover),
//                             image: AssetImage('assets/images/dummy.jpeg'),
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         height: 100,
//                         width: 100,
//                         margin: const EdgeInsets.only(right: 15),
//                       ),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           // mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               // dataFoods.nama,
//                               'infoooooooooooooooooooo',
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: GoogleFonts.poppins(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                                 color: Colors.redAccent,
//                               ),
//                             ),
//                             Text(
//                               // NumberFormat.currency(
//                               //   symbol: 'Rp',
//                               //   decimalDigits: 0,
//                               //   locale: 'id-ID',
//                               // ).format(dataFoods.detailMenu.harga),
//                               'info',
//                               style: GoogleFonts.poppins(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 10,
//                             ),
//                             Text(
//                               'Deskripis produk diisi nanti diambilkan dari api...',
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: GoogleFonts.poppins(
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Consumer<CartProvider>(
//                         builder: (context, data, widget) {
//                           // var id = data.cart.indexWhere((element) =>
//                           //     element.menuId ==
//                           //     dataFoods.detailMenu.id);
//                           if (true) {
//                             return Container(
//                               width: 30,
//                               height: 30,
//                               decoration: BoxDecoration(
//                                 color: Colors.yellow,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Center(
//                                 child: IconButton(
//                                   onPressed: () {
//                                     // Provider.of<CartProvider>(context,
//                                     //         listen: false)
//                                     //     .addRemove(
//                                     //         dataFoods.detailMenu.id,
//                                     //         dataFoods.nama,
//                                     //         dataFoods
//                                     //             .detailMenu.harga,
//                                     //         dataFoods.nama,
//                                     //         dataTenant,
//                                     //         true);
//                                   },
//                                   icon: const Icon(
//                                     Icons.add,
//                                     size: 15,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             );
//                             // } else {
//                             //   // item sudah ditambahkan ke dalam keranjang belanja
//                             //   return Container(
//                             //     decoration: const BoxDecoration(
//                             //       color: Colors.yellow,
//                             //       // borderRadius:
//                             //       //     BorderRadius.circular(10),
//                             //       // boxShadow: [
//                             //       //   BoxShadow(
//                             //       //       color: Colors.black26
//                             //       //           .withOpacity(0.3),
//                             //       //       offset: const Offset(0, 3),
//                             //       //       blurRadius: 5)
//                             //       // ],
//                             //     ),
//                             //     // height: 35,
//                             //     child: Column(
//                             //       children: [
//                             //         Row(
//                             //           // crossAxisAlignment:
//                             //           //     CrossAxisAlignment.center,
//                             //           // mainAxisAlignment:
//                             //           //     MainAxisAlignment.center,
//                             //           children: [
//                             //             IconButton(
//                             //                 onPressed: () {
//                             //                   // Provider.of<CartProvider>(
//                             //                   //         context,
//                             //                   //         listen: false)
//                             //                   //     .addRemove(
//                             //                   //         dataFoods
//                             //                   //             .detailMenu
//                             //                   //             .id,
//                             //                   //         dataFoods.nama,
//                             //                   //         dataFoods
//                             //                   //             .detailMenu
//                             //                   //             .harga,
//                             //                   //         dataFoods.nama,
//                             //                   //         dataTenant,
//                             //                   //         false);
//                             //                 },
//                             //                 icon: const Icon(
//                             //                   Icons
//                             //                       .do_not_disturb_on_outlined,
//                             //                   color: Colors.redAccent,
//                             //                   size: 24,
//                             //                 )),
//                             //             // Consumer<CartProvider>(builder:
//                             //             //     (context, data, widget) {
//                             //             //   var id = data.cart.indexWhere(
//                             //             //       (element) =>
//                             //             //           element.menuId ==
//                             //             //           dataFoods
//                             //             //               .detailMenu.id);
//                             //             //   return Text(
//                             //             //     (id == -1)
//                             //             //         ? "0"
//                             //             //         : data.cart[id].count
//                             //             //             .toString(),
//                             //             //     style: const TextStyle(
//                             //             //       fontSize: 14,
//                             //             //       // fontWeight: FontWeight.bold,
//                             //             //     ),
//                             //             //   );
//                             //             // },),
//                             //             IconButton(
//                             //               onPressed: () {
//                             //               //   Provider.of<CartProvider>(
//                             //               //           context,
//                             //               //           listen: false)
//                             //               //       .addRemove(
//                             //               //           dataFoods
//                             //               //               .detailMenu.id,
//                             //               //           dataFoods.nama,
//                             //               //           dataFoods.detailMenu
//                             //               //               .harga,
//                             //               //           dataFoods.nama,
//                             //               //           dataTenant,
//                             //               //           true);
//                             //               },
//                             //               icon: const Icon(
//                             //                 Icons.add_circle_outline,
//                             //                 color: Colors.redAccent,
//                             //                 size: 24,
//                             //               ),
//                             //             ),
//                             //           ],
//                             //         ),
//                             //         GestureDetector(
//                             //           onTap: () {},
//                             //           child: Container(
//                             //             width: 85,
//                             //             height: 30,
//                             //             decoration: BoxDecoration(
//                             //               color: Colors.white,
//                             //               borderRadius:
//                             //                   BorderRadius.circular(12),
//                             //               border: Border.all(
//                             //                 color: Colors.grey,
//                             //                 width: 1.5,
//                             //               ),
//                             //             ),
//                             //             child: const Row(
//                             //               mainAxisAlignment:
//                             //                   MainAxisAlignment.center,
//                             //               children: [
//                             //                 Icon(
//                             //                   Icons
//                             //                       .description_outlined,
//                             //                   size: 15,
//                             //                 ),
//                             //                 Text(
//                             //                   'Catatan',
//                             //                   style: TextStyle(
//                             //                     color: Colors.black,
//                             //                     fontSize: 12,
//                             //                   ),
//                             //                 ),
//                             //               ],
//                             //             ),
//                             //           ),
//                             //         ),
//                             //       ],
//                             //     ),
//                             //   );
//                             // }
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(
//                 height: 40,
//               ),
//               Column(
//                 children: [
//                   Column(
//                     children: [
//                       Container(
//                         alignment: Alignment.centerLeft,
//                         child: const Text(
//                           'Pilih Tipe Pemesanan',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 7,
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           bottomSheetTipePemesanan(context, (option) {
//                             setState(() {
//                               print(123);
//                               pilihPemesanan = option;
//                               // isOptionSelected = option != null;
//                             });
//                           });
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             vertical: 10,
//                             horizontal: 25,
//                           ),
//                           height: 65,
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Row(
//                             children: [
//                               if (pilihPemesanan != null)
//                                 Icon(Icons.motorcycle),
//                               Expanded(
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal:
//                                           pilihPemesanan != null ? 25 : 0),
//                                   alignment: Alignment.centerLeft,
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Text(
//                                         pilihPemesanan ??
//                                             'Silahkan memilih Ruangan',
//                                         style: TextStyle(fontSize: 16),
//                                       ),
//                                       if (pilihPemesanan != null)
//                                         const Text(
//                                           'Tunggu pesananmu sampai...',
//                                           style: TextStyle(fontSize: 12),
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               Icon(Icons.arrow_drop_down),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   Column(
//                     children: [
//                       Container(
//                         alignment: Alignment.centerLeft,
//                         child: const Text(
//                           'Lokasi Pengantaran',
//                           style: TextStyle(
//                             fontSize: 12, // Ukuran font yang diinginkan
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 7,
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           bottomSheetPengantaran(context, (option) {
//                             setState(() {
//                               print(123);
//                               pilihRuangan = option;
//                             });
//                           });
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             vertical: 10,
//                             horizontal: 25,
//                           ),
//                           height: 65,
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Row(
//                             children: [
//                               if (pilihRuangan != null) Icon(Icons.location_on),
//                               Expanded(
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal:
//                                           pilihRuangan != null ? 25 : 0),
//                                   alignment: Alignment.centerLeft,
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Text(
//                                         pilihRuangan ??
//                                             'Silahkan memilih Ruangan',
//                                         style: TextStyle(fontSize: 16),
//                                       ),
//                                       if (pilihRuangan != null)
//                                         const Text(
//                                           'Gedung D4',
//                                           style: TextStyle(fontSize: 12),
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               Icon(Icons.arrow_drop_down),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   // const SizedBox(height: 20),
//                   // TextFormField(
//                   //   controller: catatan,
//                   //   keyboardType: TextInputType.multiline,
//                   //   maxLines: 4,
//                   //   decoration: InputDecoration(
//                   //     labelText: 'Catatan',
//                   //     hintText: 'Masukkan catatan jika ada',
//                   //     border: OutlineInputBorder(
//                   //       borderRadius: BorderRadius.circular(10),
//                   //     ),
//                   //   ),
//                   // ),
//                 ],
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(
//                       color: Colors.grey,
//                       width: 1,
//                     )),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Text(
//                         "Ringkasan pembayaran",
//                         style: GoogleFonts.poppins(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 13,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Harga",
//                             style: GoogleFonts.poppins(
//                               fontSize: 14,
//                               // fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           // Column(
//                           //   children: cart.map((e) {
//                           //     return Text(
//                           //         NumberFormat.currency(
//                           //           symbol: 'Rp',
//                           //           decimalDigits: 0,
//                           //           locale: 'id-ID',
//                           //         ).format(e.menuPrice * e.count),
//                           //         style: GoogleFonts.poppins(
//                           //           fontSize: 14,
//                           //           fontWeight: FontWeight.w500,
//                           //         ));
//                           //   }).toList(),
//                           // )
//                           Text(
//                             NumberFormat.currency(
//                               symbol: 'Rp. ',
//                               decimalDigits: 0,
//                               locale: 'id-ID',
//                             ).format(
//                               cart.fold<int>(
//                                 0,
//                                 (previousValue, element) =>
//                                     previousValue +
//                                     (element.menuPrice * element.count),
//                               ),
//                             ),
//                             style: GoogleFonts.poppins(
//                               // fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                               // color: Colors.redAccent,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 7,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Biaya layanan",
//                             style: GoogleFonts.poppins(
//                               fontSize: 14,
//                               // fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           Text('Rp. 2.000',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 14,
//                                 // fontWeight: FontWeight.w500,
//                               ))
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 7,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Ongkir",
//                             style: GoogleFonts.poppins(
//                               fontSize: 14,
//                               // fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           // Menampilkan jumlah menu dikalikan dengan 10000
//                           Text.rich(
//                             TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: "${cart.length}x ",
//                                   style: GoogleFonts.poppins(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 TextSpan(
//                                   text: "Rp.1.000",
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 7,
//                       ),
//                       const Divider(
//                         color: Colors.black,
//                         thickness: 1,
//                         indent: 0,
//                         endIndent: 0,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Total",
//                             style: GoogleFonts.poppins(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           Text(
//                             NumberFormat.currency(
//                               symbol: 'Rp',
//                               decimalDigits: 0,
//                               locale: 'id-ID',
//                             ).format(cart.fold<int>(
//                                 0,
//                                 (previousValue, element) =>
//                                     previousValue +
//                                     (element.menuPrice * element.count +
//                                         (element.count * 1000)))),
//                             style: GoogleFonts.poppins(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                               color: Colors.redAccent,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(
//                 height: 30,
//               ),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: Consumer<CartProvider>(
//         builder: (context, data, _) {
//           return Container(
//             height: 55,
//             width: 363,
//             decoration: BoxDecoration(
//               color: Color(0xFFFF5E5E),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: InkWell(
//               onTap: () {
//                 if (namaPembeli.text.isEmpty || ruanganPembeli.text.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                         content: Text("Harap isi data terlebih dahulu")),
//                   );
//                 } else {
//                   setPreferences();
//                   createTransaction(cart.map((e) => e.menuId).toList())
//                       .then((value) {
//                     String strPesanan = '';
//                     cart.forEach((element) {
//                       strPesanan +=
//                           '-  Nama Makanan : ${element.menuNama.toString()}\n'
//                           '   ${element.tenantName} \n'
//                           '   Banyaknya : ${element.count} \n'
//                           '   Harga Satuan : ${element.menuPrice} \n'
//                           '   Total : ${element.menuPrice * element.count} \n\n';
//                     });

//                     String pesanan = '*Halo MasBro* \n'
//                         'Saya ingin memesan makanan sebagai berikut:\n\n'
//                         '$strPesanan'
//                         'Biaya Penanganan : 2000\n'
//                         'Total Harga : *${cart.fold<int>(0, (previousValue, element) => previousValue + (element.menuPrice * element.count)) + 2000}* \n\n'
//                         '*) Catatan : ${catatan.text} \n'
//                         'Mohon diantar ke *${ruanganPembeli.text}*. Terima kasih atas pelayanannya \n'
//                         '\nSalam,\n'
//                         '${namaPembeli.text}';

//                     Navigator.push(context,
//                         MaterialPageRoute(builder: (context) {
//                       return Last(pesanan);
//                     }));
//                   });
//                 }
//               },
//               child: Align(
//                 alignment: Alignment.center,
//                 child: Text(
//                   "Pesan sekarang",
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.poppins(
//                     fontSize: 18,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
