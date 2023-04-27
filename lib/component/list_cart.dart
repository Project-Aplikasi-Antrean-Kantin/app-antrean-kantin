import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/model/cart_model.dart';

import '../provider/cart_provider.dart';

class ListCart extends StatelessWidget{

  final CartModel cart;

  const ListCart({super.key, required this.cart});

  @override
  Widget build(BuildContext context){
    if(cart.count == 0){
      Navigator.of(context).pop();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                image: DecorationImage(
                    image: NetworkImage(cart.menuGambar),
                    fit: BoxFit.cover),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26.withOpacity(0.3),
                      offset: const Offset(0,3),
                      spreadRadius: 2,
                      blurRadius: 5
                  )
                ],
              ),
              height: 83,
              width: 89,
              margin: const EdgeInsets.only(right: 15),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26.withOpacity(0.3),
                        offset: const Offset(0,3),
                        blurRadius: 5
                    )
                  ],
                ),
                height: 35,
                child: Row(
                    children: [
                      IconButton(onPressed: (){
                        Provider.of<CartProvider>(context, listen: false).addRemove(cart.menuId, cart.menuNama, cart.menuPrice, cart.menuGambar.toString(), cart.tenantName, false);
                      },
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.grey,
                          )
                      ),
                      Consumer<CartProvider>(builder: (context, data, widget){
                        var id = data.cart.indexWhere((element) => element.menuId == cart.menuId);
                        return Text(
                            (id == -1) ? "0" : data.cart[id].count.toString(),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            )
                        );
                      }),
                      IconButton(onPressed: (){
                        Provider.of<CartProvider>(context, listen: false).addRemove(cart.menuId, cart.menuNama, cart.menuPrice, cart.menuGambar.toString(), cart.tenantName, true);
                      },
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.redAccent,
                          )
                      ),
                    ]
                )
            )
          ],
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                cart.menuNama,
                style:
                GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${NumberFormat.currency(
                  symbol: 'Rp',
                  decimalDigits: 0,
                  locale: 'id-ID',
                ).format(cart.menuPrice)} x ${cart.count}',
                style:
                GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}