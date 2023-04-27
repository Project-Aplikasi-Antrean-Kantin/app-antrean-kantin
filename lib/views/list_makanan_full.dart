// import 'package:flutter/material.dart';
// import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
// import 'package:testgetdata/component/judul_tenant.dart';
// import 'package:testgetdata/component/list_food_by_category.dart';
// import 'package:testgetdata/controller/get_by_category.dart';
// import 'package:testgetdata/http/fetch_data_tenant.dart';
// import 'package:testgetdata/model/tenant_foods.dart';
// import 'package:testgetdata/theme/judul_font.dart';
// import 'package:testgetdata/theme/sub_judul_theme.dart';

// class ListMakananFull extends StatefulWidget {
//   final String url;
//   ListMakananFull({Key? key, required this.url}) : super(key: key);

//   @override
//   _ListMakananFullState createState() => _ListMakananFullState();
// }

// class _ListMakananFullState extends State<ListMakananFull> {
//   late Future<TenantFoods> futureTenant;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     futureTenant = fetchTenantFoods(widget.url);
//   }

//   final itemController = ItemScrollController();
//   final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();


//   Future scrollToItem() async {
//     itemController.jumpTo(index: 1);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<TenantFoods>(
//         future: futureTenant,
//         builder: (context, snapshots) {
//           final namaTenant = snapshots.data!.subname;
//           final gambarTenant = snapshots.data!.gambar;
//           final listMakananTenant = snapshots.data!.foods;
//           final category = snapshots.data!.category;
//           final listMenu =
//               GetByCategoryController(dataListMakananTenant: listMakananTenant)
//                   .getMenu();

//           if (snapshots.hasData) {
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
//                         child: SingleChildScrollView(
//                           physics: BouncingScrollPhysics(),
//                           child: Padding(
//                             padding: const EdgeInsets.all(20.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         namaTenant,
//                                         style: Judul(),
//                                       ),
//                                       Row(
//                                         children: [
//                                           for (int i = 0;
//                                               i < category.length;
//                                               i++)
//                                             TextButton(
//                                               style: TextButton.styleFrom(
//                                                 textStyle: Judul(),
//                                               ),
//                                               onPressed: () {
//                                                 scrollToItem();
//                                               },
//                                               child: Text(category[i]),
//                                             ),
//                                           const SizedBox(
//                                             width: 10,
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 ScrollablePositionedList.builder(
//                                   itemScrollController: itemController,
//                                   itemPositionsListener: itemPositionsListener,
//                                   shrinkWrap: true,
//                                   itemCount: listMenu.keys.length,
//                                   itemBuilder:
//                                       (BuildContext context, int index) {
//                                     final makanan = listMenu[index + 1]!;
//                                     return Container(
//                                         width:
//                                             MediaQuery.of(context).size.width,
//                                         child: Column(
//                                           children: [
//                                             Text(listMenu.keys
//                                                 .elementAt(index)
//                                                 .toString()),
//                                             for (int i = 0;
//                                                 i < listMenu[index + 1]!.length;
//                                                 i++)
//                                               Card(
//                                                   margin: EdgeInsets.only(
//                                                       bottom: 15),
//                                                   shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             20.0),
//                                                   ),
//                                                   child: Padding(
//                                                     padding:
//                                                         const EdgeInsets.all(
//                                                             15.0),
//                                                     child: Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .spaceBetween,
//                                                         children: [
//                                                           Row(
//                                                             children: [
//                                                               Container(
//                                                                 decoration: BoxDecoration(
//                                                                     borderRadius:
//                                                                         BorderRadius.circular(
//                                                                             20),
//                                                                     image: DecorationImage(
//                                                                         image: NetworkImage(makanan[i]
//                                                                             [
//                                                                             'gambar']),
//                                                                         fit: BoxFit
//                                                                             .cover)),
//                                                                 height: 89,
//                                                                 width: 83,
//                                                               ),
//                                                               Container(
//                                                                 margin: EdgeInsets
//                                                                     .only(
//                                                                         left:
//                                                                             20),
//                                                                 child: Column(
//                                                                   mainAxisAlignment:
//                                                                       MainAxisAlignment
//                                                                           .start,
//                                                                   crossAxisAlignment:
//                                                                       CrossAxisAlignment
//                                                                           .start,
//                                                                   children: [
//                                                                     Text(
//                                                                       '${makanan[i]['name']}',
//                                                                       style:
//                                                                           SubJudul(),
//                                                                     ),
//                                                                     Text(
//                                                                       '${makanan[i]['price']}',
//                                                                       style: SubJudul(
//                                                                           warna:
//                                                                               Colors.red[400]),
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ]),
//                                                   ))
//                                           ],
//                                         ));
//                                   },
//                                 )
//                               ],
//                             ),
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
//     );
//   }
// }
