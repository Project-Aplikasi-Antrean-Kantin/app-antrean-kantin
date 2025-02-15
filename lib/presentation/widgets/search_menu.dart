// // import 'package:flutter/material.dart';
// // import 'package:testgetdata/components/search_widget.dart';
// // import 'package:testgetdata/model/tenant_foods.dart';

// // class SearchPageMenu extends StatefulWidget {
// //   final List<TenantFoods> data;

// //   const SearchPageMenu({
// //     Key? key,
// //     required this.data,
// //   }) : super(key: key);

// //   @override
// //   State<SearchPageMenu> createState() => _SearchPageMenuState();
// // }

// // class _SearchPageMenuState extends State<SearchPageMenu> {
// //   late List<TenantFoods> searchResult;
// //   late TextEditingController _searchController;
// //   late FocusNode _searchFocusNode;

// //   @override
// //   void initState() {
// //     super.initState();
// //     searchResult = widget.data;
// //     _searchController = TextEditingController();
// //     _searchFocusNode = FocusNode();
// //     _searchController.addListener(_onSearchChanged);
// //     _searchFocusNode.requestFocus();
// //   }

// //   @override
// //   void dispose() {
// //     _searchController.dispose();
// //     _searchFocusNode.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         automaticallyImplyLeading: false,
// //         leading: IconButton(
// //           icon: const Icon(
// //             Icons.keyboard_backspace,
// //             size: 24.0,
// //           ),
// //           onPressed: () {
// //             Navigator.of(context).pop();
// //           },
// //         ),
// //         titleSpacing: 0,
// //         title: Padding(
// //           padding: const EdgeInsets.only(right: 15),
// //           child: SearchWidget(
// //             paddingHorizontal: 0,
// //             onChanged: (value) {
// //               List<TenantFoods> result = widget.data;
// //               if (value.isEmpty) {
// //                 result = result;
// //               } else {
// //                 result = result
// //                     .where(
// //                       (tenanfoods) =>
// //                           (tenanfoods.detailMenu?.nama != null &&
// //                               tenanfoods.detailMenu!.nama!
// //                                   .toLowerCase()
// //                                   .contains(value.toLowerCase())) ||
// //                           (tenanfoods.nama != null &&
// //                               tenanfoods.nama!
// //                                   .toLowerCase()
// //                                   .contains(value.toLowerCase())),
// //                     )
// //                     .toList();
// //               }
// //               setState(() {
// //                 searchResult = result;
// //               });
// //             },
// //             tittle: "Cari menu . . . ",
// //             focusNode: _searchFocusNode,
// //             controller: _searchController,
// //           ),
// //         ),
// //       ),
// //       body: const Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Text('Search Box'),
// //             // Widget untuk kotak pencarian dan daftar menu bisa ditambahkan di sini
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   void _onSearchChanged() {
// //     final value = _searchController.text;
// //     List<TenantFoods> result = widget.data;
// //     if (value.isEmpty) {
// //       result = result;
// //     } else {
// //       result = result
// //           .where(
// //             (tenanfoods) =>
// //                 (tenanfoods.detailMenu?.nama != null &&
// //                     tenanfoods.detailMenu!.nama!
// //                         .toLowerCase()
// //                         .contains(value.toLowerCase())) ||
// //                 (tenanfoods.nama != null &&
// //                     tenanfoods.nama!
// //                         .toLowerCase()
// //                         .contains(value.toLowerCase())),
// //           )
// //           .toList();
// //     }
// //     setState(() {
// //       searchResult = result;
// //     });
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:testgetdata/constants.dart';
// import 'package:testgetdata/http/fetch_data_tenant.dart';
// import 'package:testgetdata/model/tenant_foods.dart';
// import 'package:testgetdata/model/tenant_model.dart';
// import 'package:testgetdata/model/user_model.dart';
// import 'package:testgetdata/provider/auth_provider.dart';
// import 'package:testgetdata/provider/cart_provider.dart';
// import 'package:testgetdata/views/common/format_currency.dart';
// import 'package:testgetdata/views/home/widgets/bottom_sheet_catatan.dart';
// import 'package:testgetdata/views/home/widgets/bottom_sheet_detail_menu.dart';
// import 'package:testgetdata/views/components/search_widget.dart';
// import 'package:testgetdata/views/theme.dart';

// class SearchPageMenu extends StatefulWidget {
//   final String url;
//   late List<TenantFoods> data;

//   SearchPageMenu({
//     Key? key,
//     required this.data,
//     required this.url,
//   }) : super(key: key);

//   @override
//   State<SearchPageMenu> createState() => _SearchPageMenuState();
// }

// class _SearchPageMenuState extends State<SearchPageMenu> {
//   late List<TenantFoods> searchResult;
//   late TextEditingController _searchController;
//   late FocusNode _searchFocusNode;
//   late Future<TenantModel> futureTenantFoods;

//   @override
//   void initState() {
//     super.initState();
//     AuthProvider authProvider =
//         Provider.of<AuthProvider>(context, listen: false);
//     UserModel user = authProvider.user;
//     searchResult = widget.data;
//     _searchController = TextEditingController();
//     _searchFocusNode = FocusNode();
//     _searchController.addListener(_onSearchChanged);
//     futureTenantFoods = fetchTenantFoods(widget.url, user.token);
//     _searchFocusNode.requestFocus();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _searchFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.keyboard_backspace,
//             size: 24.0,
//           ),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         titleSpacing: 0,
//         title: Padding(
//           padding: const EdgeInsets.only(right: 15),
//           child: SearchWidget(
//             paddingHorizontal: 0,
//             onChanged: (value) {
//               List<TenantFoods> result = widget.data;
//               if (value.isEmpty) {
//                 result = result;
//               } else {
//                 result = result
//                     .where(
//                       (tenantfoods) =>
//                           (tenantfoods.nama != null &&
//                               tenantfoods.nama!
//                                   .toLowerCase()
//                                   .contains(value.toLowerCase())) ||
//                           (tenantfoods.nama != null &&
//                               tenantfoods.nama!
//                                   .toLowerCase()
//                                   .contains(value.toLowerCase())),
//                     )
//                     .toList();
//               }
//               setState(() {
//                 searchResult = result;
//               });
//             },
//             tittle: "Cari menu . . . ",
//             focusNode: _searchFocusNode,
//             controller: _searchController,
//           ),
//         ),
//       ),
//       body: FutureBuilder<TenantModel>(
//         future: futureTenantFoods,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             final dataTenant = snapshot.data!.namaTenant;
//             final List<TenantFoods>? listMenu = snapshot.data!.tenantFoods;

//             return CustomScrollView(
//               slivers: <Widget>[
//                 SliverAppBar(
//                   scrolledUnderElevation: 0,
//                   automaticallyImplyLeading: false,
//                   pinned: true,
//                   expandedHeight: 200,
//                   flexibleSpace: FlexibleSpaceBar(
//                     background: Image.network(
//                       snapshot.data!.gambar.toString(),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 SliverList(
//                   delegate: SliverChildListDelegate(
//                     [
//                       Container(
//                         padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               dataTenant,
//                               style: GoogleFonts.poppins(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 20,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                     (BuildContext context, int index) {
//                       final dataTenant = snapshot.data!.namaKavling;
//                       final TenantFoods dataFoods =
//                           snapshot.data!.tenantFoods![index];
//                       return Card(
//                         elevation: 0,
//                         color: Colors.white,
//                         margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
//                         shape: const RoundedRectangleBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(20),
//                           ),
//                         ),
//                         child: Container(
//                           decoration: const BoxDecoration(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(20),
//                             ),
//                             border: Border(
//                               bottom: BorderSide(
//                                 color: Colors.grey, // Warna border
//                                 width: 1.0, // Lebar border
//                               ),
//                               top: BorderSide(
//                                 color: Colors.grey, // Warna border
//                                 width: 0.2, // Lebar border
//                               ),
//                               left: BorderSide(
//                                 color: Colors.grey, // Warna border
//                                 width: 0.2, // Lebar border
//                               ),
//                               right: BorderSide(
//                                 color: Colors.grey, // Warna border
//                                 width: 0.2, // Lebar border
//                               ),
//                             ),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(10),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(15),
//                                     color: const Color.fromARGB(
//                                         255, 200, 200, 200),
//                                   ),
//                                   height: 100,
//                                   width: 100,
//                                   margin: const EdgeInsets.only(right: 15),
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       // todo: tampilin bootomsheet detail menu
//                                       showDetailMenuBottomSheet(
//                                         context,
//                                         DetailMenu(
//                                           namaTenant: dataTenant,
//                                           idMenu: dataFoods.id,
//                                           title:
//                                               dataFoods.nama ?? dataFoods.nama,
//                                           gambar: dataFoods.gambar,
//                                           description:
//                                               dataFoods.deskripsi ?? '-',
//                                           price: dataFoods.harga,
//                                           isReady: dataFoods.isReady,
//                                         ),
//                                       );
//                                     },
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(15),
//                                       child: dataFoods.gambar != null
//                                           ? Image.network(
//                                               "${MasbroConstants.baseUrl}${dataFoods.gambar}",
//                                               fit: BoxFit.cover,
//                                               errorBuilder:
//                                                   (context, error, stackTrace) {
//                                                 return const Center(
//                                                   child: Icon(
//                                                     Icons.photo,
//                                                     color: Color.fromARGB(
//                                                         255, 120, 120, 120),
//                                                     size: 30,
//                                                   ),
//                                                 );
//                                               },
//                                             )
//                                           : const Center(
//                                               child: Icon(
//                                                 Icons.photo,
//                                                 color: Color.fromARGB(
//                                                     255, 120, 120, 120),
//                                                 size: 30,
//                                               ),
//                                             ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Container(
//                                     height: 100,
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       // mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         Text(
//                                           dataFoods.nama ?? dataFoods.nama,
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                           style: GoogleFonts.poppins(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 16,
//                                             color: primaryColor,
//                                           ),
//                                         ),
//                                         Text(
//                                           FormatCurrency.intToStringCurrency(
//                                             dataFoods.harga,
//                                           ),
//                                           style: GoogleFonts.poppins(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 14,
//                                           ),
//                                         ),
//                                         const SizedBox(
//                                           height: 10,
//                                         ),
//                                         Text(
//                                           dataFoods.deskripsi ?? '-',
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis,
//                                           style: GoogleFonts.poppins(
//                                             fontSize: 12,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 Align(
//                                   alignment: Alignment.centerRight,
//                                   child: Consumer<CartProvider>(
//                                     builder: (context, data, widget) {
//                                       var id = data.cart.indexWhere((element) =>
//                                           element.menuId == dataFoods.id);
//                                       if (id == -1) {
//                                         return GestureDetector(
//                                           onTap: () {
//                                             if (dataFoods.isReady == 1) {
//                                               Provider.of<CartProvider>(context,
//                                                       listen: false)
//                                                   .addRemove(
//                                                 dataFoods.id,
//                                                 dataFoods.nama ??
//                                                     dataFoods.nama,
//                                                 dataFoods.harga,
//                                                 dataFoods.gambar,
//                                                 dataFoods.deskripsi,
//                                                 dataTenant,
//                                                 true,
//                                               );
//                                             }
//                                           },
//                                           child: Container(
//                                             width: 75,
//                                             height: 25,
//                                             decoration: BoxDecoration(
//                                               color: dataFoods.isReady == 1
//                                                   ? Colors.transparent
//                                                   : Colors.transparent,
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                               border: Border.all(
//                                                 color: dataFoods.isReady == 1
//                                                     ? primaryColor
//                                                     : const Color.fromARGB(
//                                                         255, 180, 180, 180),
//                                                 width: 1.5,
//                                               ),
//                                             ),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 Text(
//                                                   dataFoods.isReady == 1
//                                                       ? 'Tambah'
//                                                       : 'Habis',
//                                                   style: TextStyle(
//                                                     color:
//                                                         dataFoods.isReady == 1
//                                                             ? primaryColor
//                                                             : Colors.grey,
//                                                     fontSize: 12,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         );
//                                       } else {
//                                         // item sudah ditambahkan ke dalam keranjang belanja
//                                         return Container(
//                                           child: Column(
//                                             children: [
//                                               Row(
//                                                 children: [
//                                                   IconButton(
//                                                       onPressed: () {
//                                                         Provider.of<CartProvider>(
//                                                                 context,
//                                                                 listen: false)
//                                                             .addRemove(
//                                                                 dataFoods.id,
//                                                                 dataFoods.nama,
//                                                                 dataFoods.harga,
//                                                                 dataFoods.nama,
//                                                                 dataFoods
//                                                                     .deskripsi,
//                                                                 dataTenant,
//                                                                 false);
//                                                       },
//                                                       icon: Icon(
//                                                         Icons
//                                                             .do_not_disturb_on_outlined,
//                                                         color: primaryColor,
//                                                         size: 26,
//                                                       )),
//                                                   Consumer<CartProvider>(
//                                                       builder: (context, data,
//                                                           widget) {
//                                                     var id = data.cart
//                                                         .indexWhere((element) =>
//                                                             element.menuId ==
//                                                             dataFoods.id);
//                                                     return Text(
//                                                       (id == -1)
//                                                           ? "0"
//                                                           : data.cart[id].count
//                                                               .toString(),
//                                                       style: const TextStyle(
//                                                         fontSize: 16,
//                                                         // fontWeight: FontWeight.bold,
//                                                       ),
//                                                     );
//                                                   }),
//                                                   IconButton(
//                                                     onPressed: () {
//                                                       Provider.of<CartProvider>(
//                                                               context,
//                                                               listen: false)
//                                                           .addRemove(
//                                                               dataFoods.id,
//                                                               dataFoods.nama,
//                                                               dataFoods.harga,
//                                                               dataFoods.nama,
//                                                               dataFoods
//                                                                   .deskripsi,
//                                                               dataTenant,
//                                                               true);
//                                                     },
//                                                     icon: Icon(
//                                                       Icons.add_circle_outline,
//                                                       color: primaryColor,
//                                                       size: 26,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               GestureDetector(
//                                                 onTap: () {
//                                                   final catatanCart = data.cart
//                                                       .where(
//                                                         (element) =>
//                                                             element.menuId ==
//                                                             dataFoods.id,
//                                                       )
//                                                       .first
//                                                       .catatan;
//                                                   bottomSheetCatatan(context,
//                                                           catatanCart ?? '')
//                                                       .then(
//                                                     (value) {
//                                                       if (value != null) {
//                                                         data.tambahCatatan(
//                                                             dataFoods.id,
//                                                             value);
//                                                       }
//                                                     },
//                                                   );
//                                                 },
//                                                 child: Container(
//                                                   width: 75,
//                                                   height: 25,
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.white,
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             12),
//                                                     border: Border.all(
//                                                       color: Colors.grey,
//                                                       width: 1.5,
//                                                     ),
//                                                   ),
//                                                   child: const Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .center,
//                                                     children: [
//                                                       Icon(
//                                                         Icons
//                                                             .description_outlined,
//                                                         size: 12,
//                                                       ),
//                                                       Text(
//                                                         'Catatan',
//                                                         style: TextStyle(
//                                                           color: Colors.black,
//                                                           fontSize: 11,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                       }
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                     childCount: snapshot.data!.tenantFoods!.length,
//                   ),
//                 ),
//               ],
//             );
//           } else if (snapshot.hasError) {
//             return Text('${snapshot.error}');
//           }
//           // loader saat get data makanan
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         },
//       ),
//     );
//   }

//   void _onSearchChanged() {
//     final value = _searchController.text;
//     List<TenantFoods> result = widget.data;
//     if (value.isEmpty) {
//       result = result;
//     } else {
//       result = result
//           .where(
//             (tenantfoods) =>
//                 (tenantfoods.nama != null &&
//                     tenantfoods.nama!
//                         .toLowerCase()
//                         .contains(value.toLowerCase())) ||
//                 (tenantfoods.nama != null &&
//                     tenantfoods.nama!
//                         .toLowerCase()
//                         .contains(value.toLowerCase())),
//           )
//           .toList();
//     }
//     setState(() {
//       searchResult = result;
//     });
//   }
// }
