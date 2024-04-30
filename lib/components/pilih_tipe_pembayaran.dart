import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:testgetdata/components/bottom_sheet_keranjang.dart';

class PilihTipePembayaran extends StatelessWidget {
  final List<String> tipePembayaran;
  final String? pilihTipePembayaran;
  final Function(String?) selectedPembayaran;

  const PilihTipePembayaran({
    required this.tipePembayaran,
    required this.pilihTipePembayaran,
    required this.selectedPembayaran,
  });

  @override
  Widget build(BuildContext context) {
    log(pilihPembayaran.toString());
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: const Text(
            'Tipe Pembayaran',
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
            bottomSheetTipePembayaran(context, (option2) {
              if (option2 == 'Bayar tunai') {
                selectedPembayaran('cod');
              } else {
                selectedPembayaran('tranfer');
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
                if (pilihTipePembayaran == 0) Icon(Icons.back_hand),
                if (pilihTipePembayaran == 1) Icon(Icons.motorcycle),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: pilihTipePembayaran != null ? 25 : 0),
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          pilihTipePembayaran == null
                              ? 'Pilih Tipe Pembayaran'
                              : pilihTipePembayaran!,
                          style: TextStyle(fontSize: 16),
                        ),
                        if (pilihTipePembayaran != null)
                          const Text(
                            'Tunggu pesananmu sampai...',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
