// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:testgetdata/component/judul_tenant.dart';
// import 'package:testgetdata/component/list_food_by_category.dart';
// import 'package:testgetdata/controller/get_by_category.dart';
// import 'package:testgetdata/http/fetch_data_tenant.dart';
// import 'package:testgetdata/model/tenant_foods.dart';
// import 'package:testgetdata/model/tenant_model.dart';
// import 'package:testgetdata/provider/cart_provider.dart';
// import 'package:testgetdata/theme/judul_font.dart';
// import 'package:testgetdata/views/cart.dart';

// class ListMakanan extends StatefulWidget {
//   final String url;
//   ListMakanan({Key? key, required this.url}) : super(key: key);

//   @override
//   _ListMakananState createState() => _ListMakananState();
// }

// class _ListMakananState extends State<ListMakanan> {
//   late Future<TenantModel> futureTenant;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     futureTenant = fetchTenantFoods(widget.url);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<TenantModel>(
//         future: futureTenant,
//         builder: (context, snapshots) {
//           if (snapshots.hasData) {
//             print(snapshots.data);
//             final namaTenant = snapshots.data!.namaTenant;
//             final gambarTenant = snapshots.data!.gambar;
//             final listMakananTenant = snapshots.data!.tenantFoods;
//             // .where((element) => element['status'] == 1)
//             // .toList();
//             print(listMakananTenant);
//             // final category = snapshots.data!.category;
//             final listMenu = listMakananTenant;
//             // final listMenu = GetByCategoryController(
//             //         dataListMakananTenant: listMakananTenant)
//             //     .getMenu();
//             return Container(
//               height: 900,
//               width: MediaQuery.of(context).size.width,
//               child: Stack(
//                 children: [
//                   Container(
//                     width: MediaQuery.of(context).size.width,
//                     height: 300,
//                     decoration: BoxDecoration(
//                       image: DecorationImage(
//                           image:
//                               NetworkImage(snapshots.data!.gambar.toString()),
//                           fit: BoxFit.cover),
//                     ),
//                   ),

//                   /* Untuk Nampilin data makanan tenant */

//                   Positioned(
//                       top: 200,
//                       child: Container(
//                         height: 700,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20),
//                           color: Colors.white,
//                         ),
//                         width: MediaQuery.of(context).size.width,
//                         child: Padding(
//                           padding: const EdgeInsets.all(20.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               JudulTenant(
//                                   judul: namaTenant, category: 'makanan'),
//                               ListFoodsByCategory(
//                                   listMenu: listMenu, namaTenant: namaTenant)
//                             ],
//                           ),
//                         ),
//                       ))
//                 ],
//               ),
//             );
//           } else if (snapshots.hasError) {
//             throw Exception(snapshots.error);
//           } else {
//             return const Center(
//                 child: CircularProgressIndicator(
//               color: Colors.red,
//             ));
//           }
//         },
//       ),
//       bottomNavigationBar: context.watch<CartProvider>().isCartShow
//           ? Consumer<CartProvider>(
//               builder: (context, data, _) {
//                 return Container(
//                   margin: EdgeInsets.only(bottom: 20, right: 20, left: 20),
//                   height: 63,
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: InkWell(
//                     onTap: () {
//                       Navigator.push(context,
//                           MaterialPageRoute(builder: (context) {
//                         return Cart();
//                       }));
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             data.cost.toString(),
//                             style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white),
//                           ),
//                           Text(
//                             data.total.toString() + " Items",
//                             style: const TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             )
//           : null,
//     );
//   }
// }
