import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/provider/cart_provider.dart';
import 'package:testgetdata/views/home/home_page.dart';
import 'package:testgetdata/views/home/navbar_home.dart';
import 'package:testgetdata/views/tenant.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Last extends StatefulWidget {
  String pesanan;
  Last(String this.pesanan);

  @override
  State<Last> createState() => _LastState();
}

class _LastState extends State<Last> {
  @override
  void initState(){
    super.initState();
    Future.delayed(Duration(seconds: 1), () async {
      var url = 'whatsapp://send?phone=6285706015892';
      url = '${url}&text=${widget.pesanan}';

      try {
        await launchUrlString(url);
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CartProvider>(context);


    return Scaffold(
      body: WillPopScope(
        onWillPop: () async{
          provider.clearCart();
          Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context){
            return HomePage();
          }), (route) => false);
          return false;
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Image.asset(
                    'assets/images/pic1.jpg',
                    width: MediaQuery.of(context).size.width,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(15),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.clearCart();
                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    //    perlu diganti
                    return HomePage();
                  }), (route) => false);
                },
                child: Text(
                  'SELESAI',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
