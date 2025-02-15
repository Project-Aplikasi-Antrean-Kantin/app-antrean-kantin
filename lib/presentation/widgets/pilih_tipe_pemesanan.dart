import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_keranjang.dart';

class PilihTipePemesanan extends StatelessWidget {
  final List<String> tipePemesanan;
  final int? plihPengantaran;
  final Function(int?) onPemesananSelected;

  const PilihTipePemesanan({
    super.key,
    required this.tipePemesanan,
    required this.plihPengantaran,
    required this.onPemesananSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: const Text(
            'Tipe Pemesanan',
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
            bottomSheetTipePemesanan(context, (option) {
              onPemesananSelected(option);
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
                if (plihPengantaran == 0)
                  const Icon(
                    Icons.fastfood,
                  ),
                if (plihPengantaran == 1)
                  const Icon(
                    Icons.delivery_dining_rounded,
                  ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: plihPengantaran != null ? 25 : 0,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          plihPengantaran == null
                              ? 'Pilih Tipe Pemesanan'
                              : tipePemesanan[plihPengantaran!],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                          ),
                        ),
                        if (plihPengantaran != null)
                          Text(
                            plihPengantaran == 0
                                ? 'Jemput pesananmu di kantin'
                                : 'Pesananmu akan dikirim',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// void bottomSheetTipePemesanan(BuildContext context, Function(int?) onSelect) {
//   // Implement your bottom sheet here
// }
