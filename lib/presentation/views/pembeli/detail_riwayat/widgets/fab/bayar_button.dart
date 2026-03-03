import 'package:flutter/material.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/views/pembeli/checkout_qris.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat/widgets/fab/button_text.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';

class BayarButton extends StatelessWidget {
  final Pesanan pesanan;
  const BayarButton({super.key, required this.pesanan});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 48,
      child: FloatingActionButton.extended(
        key: const Key('bayarButton'),
        onPressed: () {
          Navigator.push(
            context,
            CustomPageBuilder(
              page: CheckoutQris(pesanan: pesanan),
            ),
          );
        },
        backgroundColor: AppColors.primaryColor,
        label: ButtonText(text: 'Bayar'),
      ),
    );
  }
}
