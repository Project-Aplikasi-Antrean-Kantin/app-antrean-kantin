import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';

class HeaderBottomSheetCart extends StatelessWidget {
  final CartProvider cartProvider;
  const HeaderBottomSheetCart({super.key, required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: cartProvider.tenantCarts.length >= 1
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              textAlign: cartProvider.tenantCarts.length >= 1
                  ? TextAlign.start
                  : TextAlign.center,
              'Keranjang',
              style: GoogleFonts.poppins(
                color: AppColors.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.50,
              ),
            ),
          ),
          if (cartProvider.tenantCarts.length >= 1)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ' ${cartProvider.selectedCartTenant.length > 0 ? cartProvider.selectedCartTenant.length : cartProvider.tenantCarts.length} Tenant ${cartProvider.selectedCartTenant.length > 0 ? 'terpilih' : ''}',
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.50,
                    ),
                  ),
                  if (cartProvider.tenantCarts.length == 5 &&
                      cartProvider.selectedCartTenant.length == 0)
                    Text(
                      textAlign: TextAlign.end,
                      ' Keranjang mencapai batas maksimal',
                      softWrap: true,
                      style: GoogleFonts.poppins(
                        color: AppColors.warningColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.50,
                      ),
                    ),
                  if (cartProvider.selectedCartTenant.length == 2)
                    Text(
                      textAlign: TextAlign.end,
                      'Multi tenant mencapai batas maksimal',
                      softWrap: true,
                      style: GoogleFonts.poppins(
                        color: AppColors.warningColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.50,
                      ),
                    )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
