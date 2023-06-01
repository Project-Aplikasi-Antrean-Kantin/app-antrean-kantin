import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/http/update_food_tenant.dart';

import '../http/fetch_data_tenant.dart';
import '../model/tenant_foods.dart';

class Masbro extends StatefulWidget {
  @override
  _Masbro createState() => _Masbro();
}

// enum FoodStatus {
//   Habis,
//   Siap,
// }

// class FoodItem {
//   final String name;
//   FoodStatus status;
//   final double price;
//   final String image;

//   FoodItem({
//     required this.name,
//     required this.status,
//     required this.price,
//     required this.image,
//   });
// }

class _Masbro extends State<Masbro> with SingleTickerProviderStateMixin {
  late Future<TenantFoods> futureTenant;
  final url = 'http://masbrocanteen.me/api/tenant/17';

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  int selectedFilter = 1;

  // List<FoodItem> itemList = [
  //   FoodItem(
  //       name: 'Nasi Goreng',
  //       status: FoodStatus.Habis,
  //       price: 15.0,
  //       image: 'assets/nasi_goreng.jpg'),
  //   FoodItem(
  //       name: 'Sate Ayam',
  //       status: FoodStatus.Siap,
  //       price: 10.0,
  //       image: 'assets/sate_ayam.jpg'),
  //   FoodItem(
  //       name: 'Mie Goreng',
  //       status: FoodStatus.Habis,
  //       price: 12.0,
  //       image: 'assets/mie_goreng.jpg'),
  //   FoodItem(
  //       name: 'Bakso',
  //       status: FoodStatus.Siap,
  //       price: 8.0,
  //       image: 'assets/bakso.jpg'),
  //   FoodItem(
  //       name: 'Gado-gado',
  //       status: FoodStatus.Habis,
  //       price: 7.0,
  //       image: 'assets/gado_gado.jpg'),
  // ];

  @override
  void initState() {
    super.initState();
    futureTenant = fetchTenantFoods(url);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0.0), // Ubah Offset.begin menjadi (-1.0, 0.0)
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<TenantFoods>(
      future: futureTenant,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print(snapshot.data!.foods[0]);
          var totalSiap =
              snapshot.data!.foods.where((element) => element['status'] == 1);
          var totalHabis =
              snapshot.data!.foods.where((element) => element['status'] != 1);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Stock Makanan',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedFilter = 1;
                      });
                      _animationController.forward(from: 0.0);
                    },
                    style: ElevatedButton.styleFrom(
                      primary:
                          selectedFilter == 1 ? Colors.redAccent : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9.0),
                      ),
                      minimumSize: Size(159, 31),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'SIAP',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: selectedFilter == 1
                                ? Colors.white
                                : Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          '(${totalSiap.length})',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: selectedFilter == 1
                                ? Colors.white
                                : Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedFilter = 0;
                      });
                      _animationController.forward(from: 0.0);
                    },
                    style: ElevatedButton.styleFrom(
                      primary:
                          selectedFilter == 0 ? Colors.redAccent : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9.0),
                      ),
                      minimumSize: Size(159, 31),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'HABIS',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: selectedFilter == 0
                                ? Colors.white
                                : Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          '(${totalHabis.length})',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: selectedFilter == 0
                                ? Colors.white
                                : Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (BuildContext context, Widget? child) {
                    return ListView.builder(
                      itemCount: totalSiap.length,
                      itemBuilder: (BuildContext context, int index) {
                        final foodItem = snapshot.data!.foods[index];
                        final bool isFilterMatched =
                            foodItem['status'] == selectedFilter;

                        return SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              if (isFilterMatched)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 16,
                                    bottom: 0,
                                    left: 16,
                                    right: 16,
                                  ),
                                  child: Card(
                                    elevation: 2.0,
                                    child: ListTile(
                                      leading: Container(
                                        width: 80.0,
                                        height: 80.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image:
                                                AssetImage(foodItem['gambar']),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        foodItem['name'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 3.0),
                                          Text(
                                            '\Rp.${foodItem['price'].toStringAsFixed(2)}',
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                color: Color(
                                                    0xFFFF5E5E)), // Mengubah warna teks menjadi Color(0xFFFF5E5E)
                                          ),
                                          SizedBox(height: 8.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (isFilterMatched)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 17.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              foodItem['status'] =
                                                  foodItem['status'] == 1
                                                      ? 0
                                                      : 1;
                                              updateFoodTenant(
                                                      '$url/food/${foodItem['id']}',
                                                      foodItem['status'])
                                                  .then((berhasil) {
                                                if (berhasil!) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            "Data Berhasil Diupdate")),
                                                  );
                                                }
                                              });
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.white,
                                            onPrimary: Color(
                                                0xFFFF5E5E), // Mengubah warna teks tombol menjadi Color(0xFFFF5E5E)
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                            ),
                                            minimumSize:
                                                Size(double.infinity, 40),
                                          ),
                                          child: Text(
                                            foodItem['status'] == 1
                                                ? 'Ubah ke stok kosong'
                                                : 'READY',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          throw Exception(snapshot.error);
        } else {
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.red,
          ));
        }
      },
    ));
  }
}
