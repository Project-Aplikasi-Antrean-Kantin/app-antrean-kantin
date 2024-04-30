// import 'package:flutter/material.dart';
// import 'package:testgetdata/views/home/navbar_home.dart';
// import 'package:testgetdata/views/tenant/tambah_menu.dart';

// class MenuPage extends StatefulWidget {
//   const MenuPage({Key? key}) : super(key: key);
//   // static const int MenuPageIndex = 0;

//   @override
//   State<MenuPage> createState() => _MenuPageState();
// }

// class _MenuPageState extends State<MenuPage> {
//   int itemCount = 1;
//   List<bool> switchValues = [false];

//   void incrementItemCount() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => TambahMenuPage()),
//     );

//     if (result != null && result is bool && result) {
//       setState(() {
//         itemCount++;
//         switchValues.add(false);
//       });
//     }
//   }

//   void _resetState() {
//     setState(() {
//       switchValues = List.generate(itemCount, (index) => false);
//     });
//   }

//   void _showDeleteConfirmationDialog(int index) async {
//     int? deleteIndex;
//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Konfirmasi'),
//           content: Text('Apakah Anda yakin ingin menghapus menu ini?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 _resetState();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Batal'),
//             ),
//             TextButton(
//               onPressed: () {
//                 deleteIndex = index;
//                 Navigator.of(context).pop(); // Tutup dialog
//               },
//               child: Text('Hapus'),
//             ),
//           ],
//         );
//       },
//     );
//     if (deleteIndex != null) {
//       setState(() {
//         itemCount--;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Ketersediaan menu"),
//         actions: <Widget>[
//           IconButton(onPressed: () {}, icon: Icon(Icons.notifications))
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           padding: EdgeInsets.all(10),
//           child: Column(
//             children: [
//               SizedBox(height: 10),
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 itemCount: itemCount,
//                 itemBuilder: (BuildContext context, int index) {
//                   return Dismissible(
//                     key: UniqueKey(),
//                     direction: DismissDirection.endToStart,
//                     onDismissed: (direction) {
//                       _showDeleteConfirmationDialog(index);
//                     },
//                     background: Container(
//                       color: Colors.red,
//                       child: Icon(Icons.delete),
//                       alignment: Alignment.centerRight,
//                       padding: EdgeInsets.only(right: 20.0),
//                     ),
//                     child: Container(
//                       padding: EdgeInsets.all(5),
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: Colors.grey,
//                           width: 1.0,
//                         ),
//                         borderRadius: BorderRadius.circular(5.0),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Container(
//                                 width: 60, // Lebar gambar
//                                 height: 60, // Tinggi gambar
//                                 decoration: const BoxDecoration(
//                                   image: DecorationImage(
//                                     image:
//                                         AssetImage('assets/images/dummy.jpeg'),
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: 10),
//                               // Detail dan nama produk
//                               const Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Nama Produk',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Text(
//                                     'Detail Produk',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           Switch(
//                             value: switchValues[index],
//                             onChanged: (bool value) {
//                               setState(() {
//                                 switchValues[index] = value;
//                               });
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: incrementItemCount,
//         child: const Icon(Icons.add),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//       // bottomNavigationBar: const NavbarHome(
//       //   pageIndex: MenuPage.MenuPageIndex,
//       // ),
//     );
//   }
// }
