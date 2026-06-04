import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat/widgets/fab/button_text.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant/menu_tenant.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/molecules/custom_snackbar.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class PesanLagiButton extends StatelessWidget {
  final Pesanan pesanan;
  final CartProvider cartProvider;
  const PesanLagiButton(
      {super.key, required this.pesanan, required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 48,
      child: FloatingActionButton.extended(
        key: const Key('pesanLagiButton'),
        onPressed: () async {
          if (!await hasInternetAccess()) {
            CustomSnackbar.warning('Tidak ada koneksi internet');
            return;
          }

          final cartMenu = pesanan.toCartMenuList();

          cartProvider.setCurrentTenant(
            pesanan.listTransaksiDetail[0].menus!.tenants!,
            cartMenu,
            null,
          );

          Future.delayed(const Duration(milliseconds: 300), () {
            Navigator.push(
              context,
              CustomPageBuilder(
                page: MenuTenant(
                  url:
                      '${MasbroConstants.url}/tenants/${pesanan.listTransaksiDetail[0].menus!.tenants!.id}',
                  cart: cartMenu,
                ),
              ),
            );
          });
        },
        backgroundColor: AppColors.primaryColor,
        label: ButtonText(text: 'Pesan Lagi'),
      ),
    );
  }
}
