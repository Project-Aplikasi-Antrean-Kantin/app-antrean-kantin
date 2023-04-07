import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Last extends StatelessWidget {
  String pesanan;
  Last(
    String this.pesanan
  );
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 5), ()async{
      var url = 'whatsapp://send?phone=6285706015892';
      url = '${url}&text=$pesanan';
      if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
      } else {
      throw 'Could not launch $url';
      }
    });
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Tunggu Sebentar ya!!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Colors.black,

              ),
            ),
            Text(
              'MasBro sedang mengambil pesananmu',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Colors.black,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('SELESAI',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600
                ),),
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
    );
  }
}