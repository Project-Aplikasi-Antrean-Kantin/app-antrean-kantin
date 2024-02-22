import 'package:flutter/material.dart';
import 'package:testgetdata/views/home/home_page.dart';
import 'package:testgetdata/views/home/navbar_home.dart';

class Home extends StatefulWidget {
  const Home({super.key});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesanan menunggu"),
        actions: <Widget>[
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 10,
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
                        ...orderedFoods.map((food) {
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
                                      borderRadius: BorderRadius.circular(10.0),
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
                                      subtitle: const Text('Deskripsi makanan'),
                                      trailing: Icon(Icons.close),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                ],
                              ),
                            ],
                          );
                        }).toList(),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.only(
                            left: 5,
                            right: 5,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                children: [
                                  Text(
                                    'Total harga',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Rp. 20.000',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text('Terima'),
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
      bottomNavigationBar: const NavbarHome(
        pageIndex: Home.HomeIndex,
      ),
    );
  }
}
