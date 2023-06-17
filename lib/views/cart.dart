import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:open_whatsapp/open_whatsapp.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testgetdata/component/list_cart.dart';
import 'package:testgetdata/http/post_transaction.dart';
import 'package:testgetdata/provider/cart_provider.dart';
import 'package:testgetdata/model/cart_model.dart';
import 'package:testgetdata/provider/user_provider.dart';
import 'package:testgetdata/views/last.dart';
import 'package:testgetdata/views/tenant.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  TextEditingController namaPembeli = TextEditingController();
  TextEditingController ruanganPembeli = TextEditingController();
  TextEditingController catatan = TextEditingController();

  setPreferences() async {
    final jembatan = await SharedPreferences.getInstance();

    final data =
        jsonEncode({"nama": namaPembeli.text, "ruangan": ruanganPembeli.text});
    jembatan.setString('data', data);
  }

  getPreferences() async {
    final jembatan = await SharedPreferences.getInstance();

    if (jembatan.containsKey('data')) {
      final data = jsonDecode(jembatan.getString('data').toString())
          as Map<String, dynamic>;

      namaPembeli.text = data['nama'];
      ruanganPembeli.text = data['ruangan'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<CartModel> cart = Provider.of<CartProvider>(context).cart;
    getPreferences();
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          title: Text(
            'Notes',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
              size: 30,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 85),
          child: Column(
            children: [
              Consumer<CartProvider>(
                builder: (context, data, _) {
                  return ListView.separated(
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      itemCount: data.cart.length,
                      itemBuilder: (context, i) {
                        return ListCart(cart: data.cart[i]);
                      });
                },
              ),
              const SizedBox(
                height: 40,
              ),
              Column(
                children: [
                  TextFormField(
                    controller: namaPembeli,
                    decoration: InputDecoration(
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Nama'),
                          Text('*', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      hintText: 'Masukkan nama Anda',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap isi nama terlebih dahulu';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: ruanganPembeli,
                    decoration: InputDecoration(
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Ruangan'),
                          Text('*', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      hintText: 'Masukkan tujuan pengiriman',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap isi ruangan terlebih dahulu';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: catatan,
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Catatan',
                      hintText: 'Masukkan catatan jika ada',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    )),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Ringkasan pembayaran",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Harga",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Column(
                            children: cart.map((e) {
                              return Text(
                                  NumberFormat.currency(
                                    symbol: 'Rp',
                                    decimalDigits: 0,
                                    locale: 'id-ID',
                                  ).format(e.menuPrice * e.count),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ));
                            }).toList(),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Biaya penanganan",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text('Rp2.000',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ))
                        ],
                      ),
                      const Divider(
                        color: Colors.black,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                              symbol: 'Rp',
                              decimalDigits: 0,
                              locale: 'id-ID',
                            ).format(Provider.of<CartProvider>(context).cost +
                                Provider.of<CartProvider>(context).service),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: context.watch<CartProvider>().isCartShow
          ? Consumer<CartProvider>(
        builder: (context, data, _) {
          // var userId = Provider.of<UserProvider>(context).getUserId();
          // var token = Provider.of<UserProvider>(context).getToken();
          // print(token);
          // print(userId);
          return Container(
            // margin: const EdgeInsets.all(20),
            height: 63,
            width: 355,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              onTap: () {
                if (namaPembeli.text.isEmpty ||
                    ruanganPembeli.text.isEmpty) {
                  // Menampilkan pesan error jika input kosong
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Harap isi data terlebih dahulu")),
                  );
                } else {
                  setPreferences();
                  createTransaction(
                      data.cart.map((e) => e.menuId).toList())
                      .then((value) {
                    print(value);
                    String strPesanan = '';
                    data.cart.forEach((element) {
                      strPesanan +=
                      '-  Nama Makanan : ${element.menuNama.toString()}\n'
                          '   ${element.tenantName} \n'
                          '   Banyaknya : ${element.count} \n'
                          '   Harga Satuan : ${element.menuPrice} \n'
                          '   Total : ${element.menuPrice * element.count} \n\n';
                    });

                    String pesanan = '*Halo MasBro* \n'
                        'Saya ingin memesan makanan sebagai berikut:\n\n'
                        '$strPesanan'
                        'Biaya Penanganan : 2000\n'
                        'Total Harga : *${data.cost + 2000}* \n\n'
                        '*) Catatan : ${catatan.text} \n'
                        'Mohon diantar ke *${ruanganPembeli.text}*. Terima kasih atas pelayanannya \n'
                        '\nSalam,\n'
                        '${namaPembeli.text}';

                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return Last(pesanan);
                        }));
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "Pesan sekarang",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      )
          : null,
      // bottomNavigationBar: context.watch<CartProvider>().isCartShow
      //     ? Consumer<CartProvider>(
      //         builder: (context, data, _) {
      //           // var userId = Provider.of<UserProvider>(context).getUserId();
      //           // var token = Provider.of<UserProvider>(context).getToken();
      //           // print(token);
      //           // print(userId);
      //           return Container(
      //             margin: const EdgeInsets.all(20),
      //             height: 63,
      //             decoration: BoxDecoration(
      //               color: Colors.redAccent,
      //               borderRadius: BorderRadius.circular(10),
      //             ),
      //             child: InkWell(
      //               onTap: () {
      //                 if (namaPembeli.text.isEmpty ||
      //                     ruanganPembeli.text.isEmpty) {
      //                   // Menampilkan pesan error jika input kosong
      //                   ScaffoldMessenger.of(context).showSnackBar(
      //                     const SnackBar(
      //                         content: Text("Harap isi data terlebih dahulu")),
      //                   );
      //                 } else {
      //                   setPreferences();
      //                   createTransaction(
      //                           data.cart.map((e) => e.menuId).toList())
      //                       .then((value) {
      //                     print(value);
      //                     String strPesanan = '';
      //                     data.cart.forEach((element) {
      //                       strPesanan +=
      //                           '-  Nama Makanan : ${element.menuNama.toString()}\n'
      //                           '   ${element.tenantName} \n'
      //                           '   Banyaknya : ${element.count} \n'
      //                           '   Harga Satuan : ${element.menuPrice} \n'
      //                           '   Total : ${element.menuPrice * element.count} \n\n';
      //                     });
      //
      //                     String pesanan = '*Halo MasBro* \n'
      //                         'Saya ingin memesan makanan sebagai berikut:\n\n'
      //                         '$strPesanan'
      //                         'Biaya Penanganan : 2000\n'
      //                         'Total Harga : *${data.cost + 2000}* \n\n'
      //                         '*) Catatan : ${catatan.text} \n'
      //                         'Mohon diantar ke *${ruanganPembeli.text}*. Terima kasih atas pelayanannya \n'
      //                         '\nSalam,\n'
      //                         '${namaPembeli.text}';
      //
      //                     Navigator.push(context,
      //                         MaterialPageRoute(builder: (context) {
      //                       return Last(pesanan);
      //                     }));
      //                   });
      //                 }
      //               },
      //               child: Padding(
      //                 padding: const EdgeInsets.all(15.0),
      //                 child: Text(
      //                   "Pesan sekarang",
      //                   textAlign: TextAlign.center,
      //                   style: GoogleFonts.poppins(
      //                     fontSize: 20,
      //                     color: Colors.white,
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           );
      //         },
      //       )
      //     : null,
    );
  }
}
