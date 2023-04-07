import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/http/fetch_data_tenant.dart';
import 'package:testgetdata/model/tenant_foods.dart';
import 'package:testgetdata/views/cart.dart';

import '../provider/cart_provider.dart';

class ListTenant extends StatefulWidget{
  final String url;
  ListTenant({Key? key, required this.url}) : super(key: key);

  @override
  _ListTenantState createState() => _ListTenantState();
}

class _ListTenantState extends State<ListTenant>{
  late Future<TenantFoods> futureTenant;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureTenant = fetchTenantFoods(widget.url);
  }

  Widget build(BuildContext context){
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded),
              color: Colors.red,
              onPressed: (){
                Navigator.pop(context);
              },
            ),
          ),
          body: FutureBuilder<TenantFoods>(
            future: futureTenant,
            builder: (context, snapshot){
              if(snapshot.hasData){
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Stack(
                    children: [
                      Positioned(
                          left: 0,
                          right: 0,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(snapshot.data!.gambar.toString()),
                                    fit: BoxFit.cover
                                )
                            ),
                          )
                      ), // image background
                      // Positioned(
                      //   top: 230,
                      //   child:
                        Positioned(
                            top: 180,
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 620,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(40),
                                      topRight: Radius.circular(40)
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 20, top: 20, right: 20),
                                    child: ListView.builder(
                                      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                      padding: EdgeInsets.only(bottom: 50),
                                      shrinkWrap: true,
                                      itemCount: snapshot.data!.foods.length,
                                      itemBuilder: (context, index){
                                        final dataTenant = snapshot.data!.name;
                                        final dataFoods = snapshot.data!.foods[index];
                                        print(dataFoods['id'].runtimeType);
                                        return Padding(
                                          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(20),
                                                  image: DecorationImage(
                                                    image: NetworkImage(dataFoods['gambar']),
                                                    fit: BoxFit.cover
                                                  ),
                                                ),
                                                height: 80,
                                                width: 80,
                                              ),
                                              const SizedBox(width: 20),
                                              Expanded(
                                                // flex: 1,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      dataFoods['name'],
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5,),
                                                    Text(dataFoods['price'].toString())
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(10),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Colors.black26.withOpacity(0.3),
                                                            offset: Offset.fromDirection(100),
                                                            blurRadius: 5
                                                        )
                                                      ]
                                                  ),
                                                  height: 40,
                                                  child: Row(
                                                      children: [
                                                        IconButton(onPressed: (){
                                                          Provider.of<CartProvider>(context, listen: false).addRemove(dataFoods['id'], dataFoods['name'], dataFoods['price'], dataFoods['gambar'].toString(), dataTenant, false);
                                                        }, icon: Icon(Icons.remove_circle, color: Colors.red,)),
                                                        Consumer<CartProvider>(builder: (context, data, widget){
                                                          var id = data.cart.indexWhere((element) => element.menuId == dataFoods['id']);
                                                          return Text(
                                                            (id == -1) ? "0" : data.cart[id].count.toString(),
                                                          );
                                                        }),
                                                        IconButton(onPressed: (){
                                                          Provider.of<CartProvider>(context, listen: false).addRemove(dataFoods['id'], dataFoods['name'], dataFoods['price'], dataFoods['gambar'], dataTenant, true);
                                                        }, icon: Icon(Icons.add_circle,color: Colors.green,)),
                                                      ]
                                                  )
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                      // ), // menu
                    ],
                  ),
                );
                // return Column(
                //   children: [
                //     Padding(
                //       padding: const EdgeInsets.all(20.0),
                //       child: Container(
                //         margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                //         height: 0.4 * 0.9 * MediaQuery.of(context).size.width,
                //         width: 0.9 * MediaQuery.of(context).size.width,
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(12),
                //           image: DecorationImage(
                //             image: NetworkImage('https://picsum.photos/1024/768'),
                //             fit: BoxFit.cover
                //           )
                //         ),
                //       ),
                //     ),
                //     Expanded(
                //       child: ListView.separated(
                //         scrollDirection: Axis.vertical,
                //         separatorBuilder: (context, index){
                //           return Divider();
                //         },
                //         shrinkWrap: true,
                //         itemBuilder: (context, index){
                //           final dataFoods = snapshot.data!.foods[index];
                //           return Padding(
                //               padding: const EdgeInsets.only(left: 20, right: 20),
                //               child: Row(
                //                 crossAxisAlignment: CrossAxisAlignment.center,
                //                 children: [
                //                   Container(
                //                     decoration: BoxDecoration(
                //                       borderRadius: BorderRadius.circular(20),
                //                       image: const DecorationImage(
                //                         image: NetworkImage('https://picsum.photos/1024/768'),
                //                       ),
                //                     ),
                //                     height: 80,
                //                     width: 80,
                //                   ),
                //                   const SizedBox(width: 20,),
                //                   Expanded(
                //                     flex: 1,
                //                     child: Column(
                //                       crossAxisAlignment: CrossAxisAlignment.start,
                //                       mainAxisAlignment: MainAxisAlignment.center,
                //                       children: [
                //                         Text(
                //                           dataFoods['name'],
                //                           style: const TextStyle(
                //                             fontSize: 16,
                //                             fontWeight: FontWeight.bold
                //                           ),
                //                         ),
                //                         const SizedBox(height: 5,),
                //                         Text(dataFoods['price'].toString())
                //                       ],
                //                     ),
                //                   ),
                //                   Container(
                //                     decoration: BoxDecoration(
                //                         color: Colors.white,
                //                         borderRadius: BorderRadius.circular(10),
                //                       boxShadow: [
                //                         BoxShadow(
                //                           color: Colors.black26.withOpacity(0.3),
                //                           offset: Offset.fromDirection(100),
                //                           blurRadius: 5
                //                         )
                //                       ]
                //                     ),
                //                       height: 40,
                //                       child: Row(
                //                         children: [
                //                           IconButton(onPressed: (){
                //                             Provider.of<CartProvider>(context, listen: false).addRemove(dataFoods['id'], dataFoods['name'], dataFoods['price'], dataFoods['gambar'], false);
                //                           }, icon: Icon(Icons.remove_circle, color: Colors.red,)),
                //                           Consumer<CartProvider>(builder: (context, data, widget){
                //                             var id = data.cart.indexWhere((element) => element.menuId == dataFoods['id']);
                //                             return Text(
                //                                 (id == -1) ? "0" : data.cart[id].count.toString(),
                //                             );
                //                           }),
                //                           IconButton(onPressed: (){
                //                             Provider.of<CartProvider>(context, listen: false).addRemove(dataFoods['id'], dataFoods['name'], dataFoods['price'], dataFoods['gambar'], true);
                //                           }, icon: Icon(Icons.add_circle,color: Colors.green,)),
                //                         ]
                //                       )
                //                   )
                //                 ],
                //               ),
                //             );
                //         },
                //       itemCount: snapshot.data!.foods.length,
                //       ),
                //     ),
                //   ],
                // );
              }else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return Center(child: const CircularProgressIndicator());
            },
          ),
          bottomNavigationBar: context.watch<CartProvider>().isCartShow
              ?
          Consumer<CartProvider>(
            builder: (context, data, _){
              return Container(
                margin: EdgeInsets.only(bottom: 20, right: 20, left: 20),
                height: 63,
                        decoration: BoxDecoration(

                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset.zero,
                                blurRadius: 2,
                                color: Colors.black26.withOpacity(0.3),
                              )
                            ]
                        ),
                child: InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return Cart();
                    }));
                  },

                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(data.cost.toString(), style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                              ),),
                              Text(data.total.toString() + " Items", style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                              ),)
                            ],
                          ),
                        ),
                      ),
                    );

            },
          ) : null,
        ),
      );
  }
}

