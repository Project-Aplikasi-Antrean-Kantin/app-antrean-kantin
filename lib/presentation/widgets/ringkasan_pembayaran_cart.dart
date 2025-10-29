import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/ruangan_model.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';

class RingkasanPembayaranCart extends StatelessWidget {
  const RingkasanPembayaranCart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    log("ongkir RP dari server: " + cartProvider.ongkir.toString());
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            'Ringkasan pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: semibold,
              color: AppColors.blackColor400,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total pesanan (${cartProvider.totalItemCount} menu)",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textColorBlack,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        FormatCurrency.intToStringCurrency(
                          cartProvider.deliveryCost,
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: medium,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 7,
              ),
              if (cartProvider.selectedDeliveryOption != 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Biaya pengantaran ${cartProvider.ongkir == 0 ? "" : cartProvider.totalItemCount > 10 ? "(${(cartProvider.totalItemCount - 10) * cartProvider.biayaExtra} + ${cartProvider.ongkir - ((cartProvider.totalItemCount - 10) * cartProvider.biayaExtra)})" : ""}",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textColorBlack,
                      ),
                    ),
                    cartProvider.roomId == null
                        ? Flexible(
                            child: Text('Pilih Ruangan Terlebih dahulu',
                                textAlign: TextAlign.end,
                                softWrap: true,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.red,
                                )),
                          )
                        : Row(
                            children: [
                              Text(
                                FormatCurrency.stringCurrency(
                                    "${cartProvider.ongkir}"),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textColorBlack,
                                  fontWeight: FontWeight.w500, // medium
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              const SizedBox(
                height: 7,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Biaya layanan",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                    ),
                  ),
                  cartProvider.biayaLayanan == 0
                      ? Row(
                          children: [
                            Text(
                              FormatCurrency.intToStringCurrency(3000),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.red,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.red,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Gratis",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textColorBlack,
                                fontWeight: FontWeight.w600, // semibold
                              ),
                            ),
                          ],
                        )
                      : cartProvider.biayaLayanan < 3000 &&
                              cartProvider.biayaLayanan > 0
                          ? Row(
                              children: [
                                Text(
                                  FormatCurrency.intToStringCurrency(3000),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.red,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Colors.red,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  FormatCurrency.intToStringCurrency(
                                      cartProvider.biayaLayanan),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.textColorBlack,
                                    fontWeight: medium,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              FormatCurrency.intToStringCurrency(
                                  cartProvider.biayaLayanan),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: semibold,
                              ),
                            ),
                ],
              ),
              const SizedBox(
                height: 7,
              ),
              const Divider(
                color: Colors.grey,
                thickness: 1,
                indent: 0,
                endIndent: 0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Pembayaran",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  Text(
                    FormatCurrency.intToStringCurrency(
                      cartProvider.getTotal(),
                    ),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              if (cartProvider.selectedVoucher != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cashback",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.successColor,
                      ),
                    ),
                    Text(
                      FormatCurrency.intToStringCurrency(
                        (cartProvider.selectedVoucher!.cashback.value *
                                        cartProvider.deliveryCost)
                                    .floor() <
                                cartProvider
                                    .selectedVoucher!.cashback.maxCashback
                            ? (cartProvider.selectedVoucher!.cashback.value *
                                    cartProvider.deliveryCost)
                                .floor()
                            : cartProvider
                                .selectedVoucher!.cashback.maxCashback,
                      ),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.successColor,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
