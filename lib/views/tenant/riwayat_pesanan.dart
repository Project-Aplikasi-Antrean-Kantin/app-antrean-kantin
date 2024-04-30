// import 'package:flutter/material.dart';
// import 'package:testgetdata/views/home/navbar_home.dart';

// class RiwayatPage extends StatefulWidget {
//   const RiwayatPage({Key? key}) : super(key: key);
//   static const int RiwayatPageIndex = 0;

//   @override
//   State<RiwayatPage> createState() => _RiwayatPageState();
// }

// class _RiwayatPageState extends State<RiwayatPage> {
//   List<String> orderedFoods = [
//     'Nasi Goreng',
//     'Ayam Goreng',
//     'Soto Ayam',
//     'Mie Goreng',
//   ];
//   List<String> orderedFoods2 = [
//     'Nasi Goreng',
//     'Ayam Goreng',
//     'Soto Ayam',
//     'Mie Goreng',
//   ];

//   Future<void> _refresh() async {
//     await Future.delayed(Duration(seconds: 1));
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;

//     Widget pesananCard(
//         String harga, Text status, List<String> menu, int noPesanan) {
//       return Container(
//         margin: EdgeInsets.only(bottom: 10.0),
//         padding: EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: Colors.grey,
//             width: 1.0,
//           ),
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               "Pesananan no $noPesanan",
//               style: TextStyle(
//                 fontSize: 16.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 10),
//             ...menu.map(
//               (food) {
//                 return Column(
//                   children: [
//                     Column(
//                       children: [
//                         Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                               color: Colors.grey,
//                               width: 1.0,
//                             ),
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                           child: ListTile(
//                             leading: Container(
//                               width: 50, // Lebar gambar
//                               height: 50, // Tinggi gambar
//                               decoration: const BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 image: DecorationImage(
//                                   image: NetworkImage(
//                                       "https://assets-a1.kompasiana.com/items/album/2021/08/14/images-6117992706310e0d285e54d2.jpeg"),
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                             title: Text(food),
//                             subtitle: const Text('Deskripsi makanan'),
//                             // trailing: IconButton(
//                             //   icon: Icon(Icons.close),
//                             //   onPressed: () {
//                             //     // removeFood(index);
//                             //   },
//                             // ),
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                       ],
//                     ),
//                   ],
//                 );
//               },
//             ).toList(),
//             const SizedBox(height: 10),
//             Column(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.only(
//                     left: 10,
//                     right: 30,
//                   ),
//                   child: Row(
//                     // crossAxisAlignment:
//                     //     CrossAxisAlignment.stretch,
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         children: [
//                           Text(
//                             'Total harga',
//                             style: TextStyle(
//                               fontSize: 16.0,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             harga,
//                             style: TextStyle(
//                               fontSize: 14.0,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 10),
//                       status,
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Riwayat Pesanan"),
//         actions: <Widget>[
//           IconButton(onPressed: () {}, icon: Icon(Icons.notifications))
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: SingleChildScrollView(
//           physics: AlwaysScrollableScrollPhysics(),
//           child: Container(
//             padding: const EdgeInsets.all(10.0),
//             child: Column(
//               children: [
//                 SizedBox(height: 10),
//                 ListView(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   children: [
//                     pesananCard(
//                       'Rp. 20,000',
//                       Text(
//                         "Pesanan diproses",
//                         style: TextStyle(
//                           color: Colors.orange,
//                         ),
//                       ),
//                       orderedFoods,
//                       0001,
//                     ),
//                     pesananCard(
//                       'Rp. 300,000',
//                       Text(
//                         "Diterima",
//                         style: TextStyle(
//                           color: Colors.green,
//                         ),
//                       ),
//                       orderedFoods2,
//                       002,
//                     )
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: const NavbarHome(
//         pageIndex: RiwayatPage.RiwayatPageIndex,
//       ),
//     );
//   }
// }
