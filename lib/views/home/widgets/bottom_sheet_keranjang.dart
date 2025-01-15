import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/model/ruangan_model.dart';
import 'package:testgetdata/provider/cart_provider.dart';
import 'package:testgetdata/views/theme.dart';

int? pilihPemesanan;
int? pilihRuangan;
// String? pilihPembayaran = '';
bool isOptionSelected = false;
bool isButtonEnabled = false;
// String pilihPembayaran = '';
typedef OptionSelectedCallback = void Function(int? option);
typedef OptionSelectedCallback2 = void Function(String? option2);

void bottomSheetTipePemesanan(
    BuildContext contextPemesanan, OptionSelectedCallback onSelect) {
  pilihPemesanan = null;
  pilihRuangan = null;
  bool isOptionSelected = false;
  showModalBottomSheet(
    context: contextPemesanan,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
    ),
    builder: (BuildContext contextPemesanan) {
      return StatefulBuilder(
        builder: (contextPemesanan, setState) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              pilihPemesanan = 1;
                              isOptionSelected = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: pilihPemesanan == 1
                                    ? primaryColor
                                    : Colors
                                        .grey, // Warna border akan berbeda jika tombol dipilih
                              ),
                            ),
                            backgroundColor: pilihPemesanan == 1
                                ? primaryColor
                                : Colors
                                    .white, // Warna latar belakang akan berbeda jika tombol dipilih
                          ),
                          child: Text(
                            'Pesan Antar',
                            style: TextStyle(
                              color: pilihPemesanan == 1
                                  ? Colors.white
                                  : Colors
                                      .black, // Warna teks akan berbeda jika tombol dipilih
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              pilihPemesanan = 0;
                              isOptionSelected = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: pilihPemesanan == 0
                                    ? primaryColor
                                    : Colors
                                        .grey, // Warna border akan berbeda jika tombol dipilih
                              ),
                            ),
                            backgroundColor: pilihPemesanan == 0
                                ? primaryColor
                                : Colors
                                    .white, // Warna latar belakang akan berbeda jika tombol dipilih
                          ),
                          child: Text(
                            'Ambil Sendiri',
                            style: TextStyle(
                              color: pilihPemesanan == 0
                                  ? Colors.white
                                  : Colors
                                      .black, // Warna teks akan berbeda jika tombol dipilih
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: [
                //     ElevatedButton(
                //       onPressed: () {
                //         Navigator.of(contextPemesanan).pop();
                //       },
                //       child: Text('Batal'),
                //     ),
                //     ElevatedButton(
                //       onPressed: isOptionSelected
                //           ? () => konfirmasiTipePemesanan(
                //               contextPemesanan, setState, onSelect)
                //           : null,
                //       child: Text('Konfirmasi'),
                //     ),
                //   ],
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(contextPemesanan).pop();
                      },
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: const BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        minimumSize: MaterialStateProperty.all(Size(150, 30)),
                      ),
                      child: const Text(
                        "Batal",
                        style: TextStyle(
                          color: Color.fromARGB(255, 99, 99, 99),
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    TextButton(
                      onPressed: isOptionSelected
                          ? () => konfirmasiTipePemesanan(
                              contextPemesanan, setState, onSelect)
                          : null,
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.blue,
                        ),
                        minimumSize: MaterialStateProperty.all(
                          Size(150, 30),
                        ),
                      ),
                      child: const Text(
                        "Pilih",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void konfirmasiTipePemesanan(
    BuildContext contextPemesanan, Function setState, Function onSelect) {
  if (pilihPemesanan != null) {
    setState(() {
      pilihPemesanan = pilihPemesanan;
      Navigator.of(contextPemesanan).pop();
    });
    onSelect(pilihPemesanan);
  }
}

void bottomSheetLokasiRuangan(BuildContext context, List<Ruangan> listRuangan,
    OptionSelectedCallback onSelect) {
  bool isOptionSelected = false;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // todo : Map en iki
                ...listRuangan.map(
                  (e) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: pilihRuangan == e.id
                            ? primaryColor
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      // tileColor: pilihRuangan == e.id ? primaryColor : null,
                      leading: Icon(
                        Icons.location_pin,
                        color: pilihRuangan == e.id ? primaryColor : null,
                      ),
                      title: Text(
                        e.namaRuangan,
                        style: GoogleFonts.poppins(
                            color: pilihRuangan == e.id ? primaryColor : null),
                      ),
                      onTap: () {
                        setState(() {
                          pilihRuangan = e.id;
                          isOptionSelected = true;
                        });
                      },
                    ),
                  ),
                ),
                // Add more items as needed
                SizedBox(height: 20),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: [
                //     ElevatedButton(
                //       onPressed: () {
                //         Navigator.of(context).pop();
                //       },
                //       child: Text('Batal'),
                //     ),
                //     ElevatedButton(
                //       onPressed: isOptionSelected
                //           ? () => konfirmasiLokasiRuangan(
                //               context, setState, onSelect)
                //           : null,
                //       child: Text('Konfirmasi'),
                //     ),
                //   ],
                // ),\
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: const BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        minimumSize: MaterialStateProperty.all(Size(150, 30)),
                      ),
                      child: const Text(
                        "Batal",
                        style: TextStyle(
                          color: Color.fromARGB(255, 99, 99, 99),
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    TextButton(
                      onPressed: isOptionSelected
                          ? () => konfirmasiLokasiRuangan(
                              context, setState, onSelect)
                          : null,
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.blue,
                        ),
                        minimumSize: MaterialStateProperty.all(
                          Size(150, 30),
                        ),
                      ),
                      child: const Text(
                        "Pilih",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void konfirmasiLokasiRuangan(
    BuildContext context, Function setState, Function onSelect) {
  if (pilihRuangan != null) {
    setState(() {
      pilihRuangan = pilihRuangan;
      Navigator.of(context).pop();
    });
    onSelect(pilihRuangan);
  }
}

// void bottomSheetTipePembayaran(
//     BuildContext contextPemesanan, OptionSelectedCallback2 onSelect) {
//   bool isOptionSelected = false;
//   showModalBottomSheet(
//     context: contextPemesanan,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(
//         top: Radius.circular(10),
//       ),
//     ),
//     builder: (BuildContext contextPemesanan) {
//       return StatefulBuilder(
//         builder: (contextPemesanan, setState) {
//           return Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 SizedBox(
//                   height: 40,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             setState(() {
//                               pilihPembayaran = 'Transfer';
//                               isOptionSelected = true;
//                             });
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: pilihPembayaran == 'Transfer'
//                                 ? primaryColor
//                                 : Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               side: const BorderSide(
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ),
//                           child: Text(
//                             'Transfer',
//                             style: GoogleFonts.poppins(
//                               color: pilihPembayaran == 'Transfer'
//                                   ? Colors.white
//                                   : Colors.black,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       ),

//                       // disable button transfer
//                       // Expanded(
//                       //   child: ElevatedButton(
//                       //     onPressed: isButtonEnabled
//                       //         ? () {
//                       //             setState(() {
//                       //               pilihPembayaran = 'Transfer';
//                       //               isOptionSelected = true;
//                       //               isButtonEnabled = false;
//                       //             });
//                       //           }
//                       //         : null,
//                       //     style: ElevatedButton.styleFrom(
//                       //       backgroundColor: isButtonEnabled
//                       //           ? (pilihPembayaran == 'Transfer'
//                       //               ? primaryColor
//                       //               : Colors.white)
//                       //           : Colors.grey,
//                       //       shape: RoundedRectangleBorder(
//                       //         borderRadius: BorderRadius.circular(8),
//                       //         side: const BorderSide(
//                       //           color: Colors.grey,
//                       //         ),
//                       //       ),
//                       //     ),
//                       //     child: Text(
//                       //       'Transfer',
//                       //       style: GoogleFonts.poppins(
//                       //         color: isButtonEnabled
//                       //             ? (pilihPembayaran == 'Transfer'
//                       //                 ? Colors.white
//                       //                 : Colors.black)
//                       //             : Colors.grey,
//                       //         fontSize: 16,
//                       //       ),
//                       //     ),
//                       //   ),
//                       // ),
//                       SizedBox(width: 10),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             setState(() {
//                               pilihPembayaran = 'Bayar Tunai';
//                               isOptionSelected = true;
//                             });
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: pilihPembayaran == 'Bayar Tunai'
//                                 ? primaryColor
//                                 : Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               side: pilihPembayaran == 'Bayar Tunai'
//                                   ? BorderSide(
//                                       color: primaryColor,
//                                     )
//                                   : const BorderSide(
//                                       color: Colors.grey,
//                                     ),
//                               // side: BorderSide(
//                               //   color: Colors.grey,
//                               // ),
//                             ),
//                           ),
//                           child: Text(
//                             'Bayar Tunai',
//                             style: GoogleFonts.poppins(
//                               color: pilihPembayaran == 'Bayar Tunai'
//                                   ? Colors.white
//                                   : Colors.black,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 SizedBox(height: 20),
//                 // Row(
//                 //   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 //   children: [
//                 //     ElevatedButton(
//                 //       onPressed: () {
//                 //         Navigator.of(contextPemesanan).pop();
//                 //       },
//                 //       child: Text('Batal'),
//                 //     ),
//                 //     ElevatedButton(
//                 //       onPressed: isOptionSelected
//                 //           ? () => konfirmasiTipePembayaran(
//                 //               contextPemesanan, setState, onSelect)
//                 //           : null,
//                 //       child: Text('Konfirmasi'),
//                 //     ),
//                 //   ],
//                 // ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(contextPemesanan).pop();
//                       },
//                       style: ButtonStyle(
//                         shape:
//                             MaterialStateProperty.all<RoundedRectangleBorder>(
//                           RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(5.0),
//                             side: const BorderSide(
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ),
//                         minimumSize: MaterialStateProperty.all(Size(150, 30)),
//                       ),
//                       child: const Text(
//                         "Batal",
//                         style: TextStyle(
//                           color: Color.fromARGB(255, 99, 99, 99),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 30),
//                     TextButton(
//                       onPressed: isOptionSelected
//                           ? () => konfirmasiTipePembayaran(
//                               contextPemesanan, setState, onSelect)
//                           : null,
//                       style: ButtonStyle(
//                         shape:
//                             MaterialStateProperty.all<RoundedRectangleBorder>(
//                           RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(5.0),
//                           ),
//                         ),
//                         backgroundColor: MaterialStateProperty.all<Color>(
//                           Colors.blue,
//                         ),
//                         minimumSize: MaterialStateProperty.all(
//                           Size(150, 30),
//                         ),
//                       ),
//                       child: const Text(
//                         "Pilih",
//                         style: TextStyle(
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }

// void konfirmasiTipePembayaran(
//     BuildContext contextPemesanan, Function setState, Function onSelect) {
//   if (pilihPembayaran != null) {
//     setState(() {
//       pilihPembayaran = pilihPembayaran;
//       Navigator.of(contextPemesanan).pop();
//     });
//     onSelect(pilihPembayaran);
//     log(pilihPembayaran.toString());
//   }
// }
