import 'package:flutter/material.dart';
import 'package:testgetdata/views/home/navbar_home.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  static const int HomeIndex = 0;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> orderedFoods = [
    'Nasi Goreng',
    'Ayam Goreng',
    'Soto Ayam',
    'Mie Goreng',
  ];

  Future<void> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesanan"),
        actions: <Widget>[
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 2,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Pesanan Makanan',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          ...orderedFoods.map(
                            (food) {
                              return Column(
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: ListTile(
                                          leading: Container(
                                            width: 50, // Lebar gambar
                                            height: 50, // Tinggi gambar
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    "https://assets-a1.kompasiana.com/items/album/2021/08/14/images-6117992706310e0d285e54d2.jpeg"),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          title: Text(food),
                                          subtitle:
                                              const Text('Deskripsi makanan'),
                                          // trailing: IconButton(
                                          //   icon: Icon(Icons.close),
                                          //   onPressed: () {
                                          //     // removeFood(index);
                                          //   },
                                          // ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ).toList(),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.only(
                              left: 5,
                              right: 5,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Total harga',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Rp. 20.000',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          backgroundColor: Colors.red,
                                          minimumSize: const Size(20, 30),
                                        ),
                                        child: const Text(
                                          'Tolak',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          backgroundColor: Colors.green,
                                          minimumSize: const Size(20, 30),
                                        ),
                                        child: const Text(
                                          'Terima',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
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
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      // bottomNavigationBar: const NavbarHome(
      //   pageIndex: Home.HomeIndex,
      // ),
    );
  }
}
