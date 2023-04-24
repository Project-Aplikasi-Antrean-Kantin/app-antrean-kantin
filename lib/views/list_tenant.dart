import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../http/fetch_data_tenant.dart';
import '../model/tenant_foods.dart';
import '../provider/cart_provider.dart';
import 'cart.dart';

class ListTenant extends StatefulWidget {
  final String url;
  const ListTenant({Key? key, required this.url}) : super(key: key);

  @override
  _ListTenantState createState() => _ListTenantState();
}

class _ListTenantState extends State<ListTenant> {
  // Scroll controller untuk mengontrol scroll dan menentukan kapan warna appbar muncul
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarTransparent = true;
  late Future<TenantFoods> futureTenant;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    futureTenant = fetchTenantFoods(widget.url);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.offset >= 200) {
      setState(() {
        _isAppBarTransparent = false;
      });
    } else {
      setState(() {
        _isAppBarTransparent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<TenantFoods>(
        future: futureTenant,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final dataTenant = snapshot.data!.name;
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  toolbarHeight: _isAppBarTransparent ? 80 : 70,
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: Colors.white,
                  shadowColor: Colors.white70,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Image.network(
                      snapshot.data!.gambar.toString(),
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: _isAppBarTransparent
                      ? null
                      : Row(
                          children: [
                            InkWell(
                              onTap: () {}, // buat auto scroll
                              child: Text(
                                'Kategori 1',
                                style:
                                GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Colors.black
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            InkWell(
                              onTap: () {}, // buat auto scroll
                              child: Text(
                                'Kategori 2',
                                style:
                                GoogleFonts.poppins(fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Colors.black
                                ),
                              ),
                            ),
                          ],
                      ),
                  leading: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 8.0,
                      ),
                      Container(
                        height: 90,
                        decoration: _isAppBarTransparent
                            ? BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.3),
                        )
                            : null,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 25,
                            color: _isAppBarTransparent ? Colors.white : Colors.black,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                        padding: const EdgeInsets.fromLTRB(20,20,20,0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dataTenant,
                              style:
                              GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {}, // buat auto scroll
                                  child: Text(
                                    'Kategori 1',
                                    style:
                                    GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: Colors.black
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                  onTap: () {}, // buat auto scroll
                                  child: Text(
                                    'Kategori 2',
                                    style:
                                    GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: Colors.black54
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final dataTenant = snapshot.data!.name;
                      final dataFoods = snapshot.data!.foods[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20,20,20,0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(11),
                              image: DecorationImage(
                                  image: NetworkImage(dataFoods['gambar']),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dataFoods['name'],
                                  style:
                                  GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Rp${dataFoods['price']}',
                                  style:
                                    GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.redAccent,
                                    ),
                                )
                              ],
                            ),
                          ),
                          Consumer<CartProvider>(
                              builder: (context, data, widget){
                                var id = data.cart.indexWhere((element) => element.menuId == dataFoods['id']);
                                if (id == -1) {
                                  // item belum ditambahkan ke dalam keranjang belanja
                                  return Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: IconButton(
                                        onPressed: () {
                                          Provider.of<CartProvider>(context, listen: false).addRemove(dataFoods['id'], dataFoods['name'], dataFoods['price'], dataFoods['gambar'], dataTenant, true);
                                        },
                                        icon: const Icon(
                                          Icons.add,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  // item sudah ditambahkan ke dalam keranjang belanja
                                  return Container(
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
                                          Provider.of<CartProvider>(context, listen: false).addRemove(
                                              dataFoods['id'],
                                              dataFoods['name'],
                                              dataFoods['price'],
                                              dataFoods['gambar'].toString(),
                                              dataTenant,
                                              false
                                          );
                                        },
                                            icon: const Icon(
                                              Icons.remove_circle,
                                              color: Colors.grey,
                                              size: 20,
                                            )
                                        ),
                                        Consumer<CartProvider>
                                          (builder: (context, data, widget){
                                          var id = data.cart.indexWhere((element) => element.menuId == dataFoods['id']);
                                          return Text(
                                              (id == -1) ? "0" : data.cart[id].count.toString(),
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold
                                              )
                                          );
                                        }),
                                        IconButton(onPressed: (){
                                          Provider.of<CartProvider>(context, listen: false).addRemove(dataFoods['id'], dataFoods['name'], dataFoods['price'], dataFoods['gambar'], dataTenant, true);
                                        },
                                            icon: const Icon(
                                              Icons.add_circle,
                                              color: Colors.redAccent,
                                              size: 20,
                                            )
                                        ),
                                      ]
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                      ),
                    );
                    },
                    childCount: snapshot.data!.foods.length,
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const Center(
              child: CircularProgressIndicator()
          );
        }
      ),
      bottomNavigationBar: context.watch<CartProvider>().isCartShow
          ?
      Consumer<CartProvider>(
        builder: (context, data, _){
          return Container(
            margin: const EdgeInsets.fromLTRB(20,0,20,20),
            height: 63,
            decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return const Cart();
                }));
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rp${data.cost}',
                      style:
                      GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      data.total>=2
                      ?
                        "${data.total} items"
                      :
                        "${data.total} item",
                      style:
                      GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ) : null,
    );
  }
}
