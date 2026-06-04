import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant/menu_tenant.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/molecules/custom_snackbar.dart';
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class FooterReorderButton extends StatelessWidget {
  final Pesanan pesanan;
  final List<CartMenuModel> cartMenu;
  final CartProvider cartProvider;

  const FooterReorderButton({
    super.key,
    required this.pesanan,
    required this.cartMenu,
    required this.cartProvider,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('pesanLagi${pesanan.id}'),
      onTap: () async {
        final connectivityResult = await hasInternetAccess();

        if (!connectivityResult) {
          CustomSnackbar.warning('Tidak ada koneksi internet');
          showNoConnectionBottomSheet(
            context: context,
            onRetry: () {},
          );

          return;
        }

        if (pesanan.listTransaksiDetail[0].menus?.tenants == null) return;

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
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primaryColor,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Pesan Lagi',
          style: GoogleFonts.poppins(
            color: AppColors.primaryColor,
            fontSize: 14,
            fontWeight: semibold,
          ),
        ),
      ),
    );
  }
}
