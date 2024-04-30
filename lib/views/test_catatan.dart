// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class TestBsCatatan extends StatefulWidget {
//   const TestBsCatatan({Key? key}) : super(key: key);

//   @override
//   State<TestBsCatatan> createState() => _TestBsCatatanState();
// }

// class _TestBsCatatanState extends State<TestBsCatatan> {
//   TextEditingController _textEditingController = TextEditingController();

//   @override
//   void dispose() {
//     _textEditingController.dispose();
//     super.dispose();
//   }

//   void _showBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(15),
//         ),
//       ),
//       builder: (BuildContext context) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(18),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: <Widget>[
//                 Text(
//                   'Tambah catatan untuk pesanan',
//                   style: GoogleFonts.poppins(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   decoration: const BoxDecoration(
//                     border: Border(
//                       top: BorderSide(
//                         color: Color.fromARGB(133, 158, 158, 158),
//                         width: 1,
//                       ),
//                     ),
//                   ),
//                   height: 200,
//                   child: TextField(
//                     controller: _textEditingController,
//                     decoration: const InputDecoration(
//                       hintText: 'Masukkan catatan...',
//                       contentPadding:
//                           EdgeInsets.symmetric(horizontal: 3, vertical: 8),
//                       border: InputBorder.none,
//                     ),
//                     maxLines: 3,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Lakukan sesuatu dengan catatan yang dimasukkan
//                     String catatan = _textEditingController.text;
//                     print('Catatan: $catatan');
//                     // Tutup BottomSheet
//                     Navigator.pop(context);
//                   },
//                   child: const Text('Konfirmasi'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Test Bottom Sheet Catatan'),
//       ),
//       resizeToAvoidBottomInset: true,
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () => _showBottomSheet(context),
//           child: Text('Tampilkan Bottom Sheet'),
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: TestBsCatatan(),
//   ));
// }
