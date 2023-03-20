import 'package:flutter/material.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            color: Colors.red,
            onPressed: (){
            },
          ),
        ),
        body: Container(
          height: 500,
          width: 100,
          color: Colors.red,
        ),
        bottomNavigationBar: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
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
                height: 63,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Lanjutkan", style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),)
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}


