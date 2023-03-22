// return Card(
//   color: Colors.white60,
//   child: Row(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Expanded(
//         flex: 1,
//         child: Image.asset(
//           dataFoods['gambar'],
//           fit: BoxFit.fill,
//         ),
//       ),
//       Expanded(
//         flex: 2,
//         child: Text(
//           dataFoods['name'],
//           style: const TextStyle(
//             fontSize: 16.0,
//           ),
//         ),
//       ),
//     ],
//   ),
// );

import 'package:flutter/material.dart';
import 'package:testgetdata/model/cart_model.dart';

class ListCart extends StatelessWidget{

  final CartModel cart;

  const ListCart({
    required this.cart
  });

  @override
  Widget build(BuildContext context){
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                image: NetworkImage('https://picsum.photos/1024/768'),
                ),
              ),
              height: 80,
              width: 80,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  cart.menuNama,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5,),
                Text(cart.menuPrice.toString() + "x"+cart.count.toString()),
              ],
            ),
          ),
          SizedBox(width: 20,)
        ]
    );
  }
}