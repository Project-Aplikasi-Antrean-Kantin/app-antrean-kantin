import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/model/cart_model.dart';
import 'package:testgetdata/provider/cart_provider.dart';
import 'package:testgetdata/theme/deskripsi_theme.dart';
import 'package:testgetdata/theme/judul_font.dart';
import 'package:testgetdata/theme/sub_judul_theme.dart';

class katalog extends StatefulWidget {
  final makanan;
  final namaTenant;

  const katalog({required this.makanan, required this.namaTenant});

  @override
  State<katalog> createState() => _katalogState();
}

class _katalogState extends State<katalog> {
  var isadd = false;
  @override
  Widget build(BuildContext context) {
    bool isKatalogInCart = Provider.of<CartProvider>(context).isKatalogInCart;

    return Card(
        margin: EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                          image: NetworkImage(widget.makanan['gambar']),
                          fit: BoxFit.cover)),
                  height: 89,
                  width: 83,
                ),
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.makanan['name']}',
                        style: SubJudul(),
                      ),
                      Text(
                        '${widget.makanan['price']}',
                        style: SubJudul(warna: Colors.red[400]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Jika Katalog sudah ada di cart, ubah tombol plusnya
            Consumer<CartProvider>(builder: (context, data, _) {
              var id = data.cart.indexWhere(
                  (element) => element.menuId == widget.makanan['id']);
              return (id >= 0)
                  ? Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26.withOpacity(0.3),
                                offset: Offset.fromDirection(100),
                                blurRadius: 5)
                          ]),
                      height: 40,
                      child: Row(children: [
                        IconButton(
                            onPressed: () {
                              data.addRemove(
                                  widget.makanan['id'],
                                  widget.makanan['name'],
                                  widget.makanan['price'],
                                  widget.makanan['gambar'].toString(),
                                  widget.namaTenant,
                                  false);
                            },
                            icon: Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            )),
                        Text(
                          (id == -1) ? "0" : data.cart[id].count.toString(),
                        ),
                        IconButton(
                            onPressed: () {
                              data.addRemove(
                                  widget.makanan['id'],
                                  widget.makanan['name'],
                                  widget.makanan['price'],
                                  widget.makanan['gambar'],
                                  widget.namaTenant,
                                  true);
                            },
                            icon: Icon(
                              Icons.add_circle,
                              color: Colors.green,
                            )),
                      ]),
                    )
                  : IconButton(
                      onPressed: () {
                        data.addRemove(
                            widget.makanan['id'],
                            widget.makanan['name'],
                            widget.makanan['price'],
                            widget.makanan['gambar'],
                            widget.namaTenant,
                            true);
                      },
                      icon: Icon(Icons.add),
                    );
            }),
          ]),
        ));
  }
}
