import 'package:flutter/material.dart';

class Tenant extends StatelessWidget {
  const Tenant({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget> [
              Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  top: 70.0
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: Image.asset('assets/images/ads.png'),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all (20.0),
                  child: GridView.count(
                    crossAxisCount: 2, // jumlah kolom
                    crossAxisSpacing: 20.0,
                      children: List.generate(6, (index) {
                        return Center(
                          child: Card(
                            child: Stack(
                              children: <Widget> [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(25.0),
                                  child: Image.asset('assets/images/tenant.png')
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 10,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black12, // warna background
                                      borderRadius: BorderRadius.circular(10), // radius border
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 4.0,
                                        left: 4.0
                                      ),
                                      child: Text(
                                        'M-$index',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Oxygen'
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
