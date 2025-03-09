import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/provider/cart_provider.dart';
import 'package:testgetdata/data/provider/coin_provider.dart';
import 'package:testgetdata/data/provider/kasir_provider.dart';

String? pilihPembayaran = '';
bool isOptionSelected = false;
bool isButtonEnabled = false;
typedef OptionSelectedCallback = void Function(int? option);
typedef OptionSelectedCallback2 = void Function(String? option2);

void bottomSheetTipePembayaran(
    BuildContext contextPemesanan, OptionSelectedCallback2 onSelect) {
  final kasirProvider =
      Provider.of<KasirProvider>(contextPemesanan, listen: false);
  final cartProvider =
      Provider.of<CartProvider>(contextPemesanan, listen: false);
  final coinProvider =
      Provider.of<CoinProvider>(contextPemesanan, listen: false);

  final isKasirActive = kasirProvider.cart.isNotEmpty;
  final isSaldoCukup = coinProvider.saldoKoin >= cartProvider.getTotal();

  showModalBottomSheet(
    backgroundColor: AppColors.backgroundColor,
    context: contextPemesanan,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(10),
      ),
    ),
    builder: (BuildContext contextPemesanan) {
      return StatefulBuilder(
        builder: (contextPemesanan, setState) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "Metode Pembayaran",
                    style: GoogleFonts.poppins(
                      fontWeight: bold,
                      fontSize: 20,
                      color: AppColors.textColorBlack,
                    ),
                  ),
                ),
                if (!isKasirActive)
                  ElevatedButton(
                    onPressed: isSaldoCukup
                        ? () {
                            setState(() {
                              pilihPembayaran = 'koin';
                              isOptionSelected = true;
                            });
                            konfirmasiTipePembayaran(
                              contextPemesanan,
                              setState,
                              onSelect,
                            );
                          }
                        : null, // Disable jika saldo kurang
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      backgroundColor: isSaldoCukup
                          ? AppColors.backgroundColor
                          : Colors.grey, // Warna tombol jika saldo kurang
                      shadowColor: Colors.transparent,
                      overlayColor: AppColors.textColorBlack.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      width: double.infinity,
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: const Icon(
                              Icons.toll,
                              size: 24,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "FoodLab Coin",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: semibold,
                                  color: AppColors.textColorBlack,
                                ),
                              ),
                              Text(
                                isSaldoCukup
                                    ? "Saldo: ${coinProvider.saldoKoin.toString()}"
                                    : "Saldo: ${coinProvider.saldoKoin.toString()}\nSaldo tidak mencukupi!", // Ubah teks jika saldo kurang
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: regular,
                                  color: isSaldoCukup
                                      ? AppColors.textColorBlack
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: isButtonEnabled
                      ? () {
                          setState(() {
                            pilihPembayaran = 'Transfer';
                            isOptionSelected = true;
                          });
                          konfirmasiTipePembayaran(
                            contextPemesanan,
                            setState,
                            onSelect,
                          );
                        }
                      : null, // Disabled jika false
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    backgroundColor: isButtonEnabled
                        ? AppColors.backgroundColor
                        : Colors.grey, // Warna tombol saat nonaktif
                    shadowColor: Colors.transparent,
                    overlayColor: AppColors.textColorBlack.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    width: double.infinity,
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: const Icon(
                            Icons.currency_exchange_outlined,
                            size: 24.0,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Transfer",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: semibold,
                                color: AppColors.textColorBlack,
                              ),
                            ),
                            Text(
                              isButtonEnabled
                                  ? "by Mandiri"
                                  : "Maintenance", // Ubah teks berdasarkan status
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: regular,
                                color: AppColors.textColorBlack.withOpacity(
                                  isButtonEnabled ? 1.0 : 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      pilihPembayaran = 'Bayar Tunai';
                      isOptionSelected = true;
                    });
                    konfirmasiTipePembayaran(
                      contextPemesanan,
                      setState,
                      onSelect,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    backgroundColor: AppColors.backgroundColor,
                    shadowColor: Colors.transparent,
                    overlayColor: AppColors.textColorBlack.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    width: double.infinity,
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: const Icon(
                            Icons.payments_outlined,
                            size: 24,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bayar Tunai",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: semibold,
                                color: AppColors.textColorBlack,
                              ),
                            ),
                            Text(
                              "Persiapkan uang tunaimu",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: regular,
                                color: AppColors.textColorBlack,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void konfirmasiTipePembayaran(
    BuildContext contextPemesanan, Function setState, Function onSelect) {
  if (pilihPembayaran != null) {
    setState(() {
      pilihPembayaran = pilihPembayaran;
      Navigator.of(contextPemesanan).pop();
    });
    onSelect(pilihPembayaran);
    log(pilihPembayaran.toString());
  }
}
