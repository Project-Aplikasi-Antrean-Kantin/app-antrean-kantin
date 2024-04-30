import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/components/bottom_sheet_keranjang.dart';
import 'package:testgetdata/provider/cart_provider.dart';

class PilihLokasiRuangan extends StatelessWidget {
  final int? selectedLocation;
  final Function(int?)? onLocationSelected;
  final listRuangan;
  final String token;

  PilihLokasiRuangan({
    required this.listRuangan,
    required this.token,
    this.selectedLocation,
    this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    print(listRuangan);
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: const Text(
            'Lokasi Pengantaran',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(
          height: 7,
        ),
        GestureDetector(
          onTap: () {
            bottomSheetLokasiRuangan(context, listRuangan, (option) {
              if (onLocationSelected != null) {
                onLocationSelected!(option);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 25,
            ),
            height: MediaQuery.of(context).size.width * 0.18,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey, // Warna border
                  width: 1.0, // Lebar border
                ),
                top: BorderSide(
                  color: Colors.grey, // Warna border
                  width: 0.2, // Lebar border
                ),
                left: BorderSide(
                  color: Colors.grey, // Warna border
                  width: 0.2, // Lebar border
                ),
                right: BorderSide(
                  color: Colors.grey, // Warna border
                  width: 0.2, // Lebar border
                ),
              ),
              // borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                if (selectedLocation != null) Icon(Icons.location_on),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: selectedLocation != null ? 25 : 0,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        selectedLocation == null
                            ? Text(
                                'Silahkan pilih ruangan',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                ),
                              )
                            // : Text('haha')
                            : Text(
                                listRuangan
                                    .where((element) =>
                                        element.id == selectedLocation)
                                    .first
                                    .namaRuangan
                                    .toString(),
                                style: TextStyle(fontSize: 14),
                              ),
                      ],
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
