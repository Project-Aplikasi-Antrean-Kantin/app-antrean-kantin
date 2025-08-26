import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page.dart';

class PilihTipePembayaran extends StatelessWidget {
  final PaymentMethod? selectedPaymentMethod;
  final Function(PaymentMethod?) onPaymentMethodSelected;
  final bool isKasirActive;
  final bool isCartActive;

  const PilihTipePembayaran({
    Key? key,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodSelected,
    required this.isKasirActive,
    required this.isCartActive,
  }) : super(key: key);

  static const _iconSize = 30.0;
  static const _padding = EdgeInsets.symmetric(horizontal: 10);
  static const _fontSizeTitle = 12.0;
  static const _fontSizeAmount = 13.0;

  static final _paymentOptions = {
    PaymentMethod.koin: {
      'label': 'FoodLab Koin',
      'icon': SvgPicture.asset('assets/icons/koin.svg'),
    },
    PaymentMethod.cod: {
      'label': 'Bayar Tunai',
      'icon': Icons.payments_outlined,
    },
  };

  void _showPaymentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _PaymentOptionBottomSheet(
        selectedMethod: selectedPaymentMethod,
        isKasirActive: isKasirActive,
        onSelect: (method) {
          onPaymentMethodSelected(method);
          Navigator.pop(context);
        },
      ),
    );
  }

  String _formatTotal(int total, PaymentMethod? method) {
    return method == PaymentMethod.koin
        ? FormatCurrency.stringCoin(total.toString())
        : FormatCurrency.intToStringCurrency(total);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final kasirProvider = Provider.of<KasirProvider>(context, listen: false);
    final total =
        isKasirActive ? kasirProvider.getTotal() : cartProvider.getTotal();

    return Semantics(
      label: selectedPaymentMethod == null
          ? 'Pilih metode pembayaran'
          : 'Metode pembayaran: ${_paymentOptions[selectedPaymentMethod]!['label']}',
      child: GestureDetector(
        // onTap: () => _showPaymentOptions(context),
        child: Container(
          color: AppColors.backgroundColor,
          padding: _padding,
          child: Row(
            children: [
              if (selectedPaymentMethod != null)
                SvgPicture.asset('assets/images/koin-logo.svg', height: 30),
              Expanded(
                child: Container(
                  padding: _padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        selectedPaymentMethod == null
                            ? 'Pilih Tipe Pembayaran'
                            : _paymentOptions[selectedPaymentMethod]!['label']
                                as String,
                        style: GoogleFonts.poppins(
                          fontSize: selectedPaymentMethod == null
                              ? 14
                              : _fontSizeTitle,
                          color: AppColors.textColorBlack,
                          height: 1.5,
                        ),
                      ),
                      if (selectedPaymentMethod != null)
                        Text(
                          _formatTotal(total, selectedPaymentMethod),
                          style: GoogleFonts.poppins(
                            fontWeight: semibold,
                            fontSize: _fontSizeAmount,
                            color: AppColors.textColorBlack,
                            height: 1.5,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentOptionBottomSheet extends StatelessWidget {
  final PaymentMethod? selectedMethod;
  final bool isKasirActive;
  final Function(PaymentMethod?) onSelect;

  const _PaymentOptionBottomSheet({
    required this.selectedMethod,
    required this.isKasirActive,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final availableMethods = isKasirActive
        ? [PaymentMethod.cod]
        : [PaymentMethod.koin, PaymentMethod.cod];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Metode Pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorBlack,
            ),
          ),
          const SizedBox(height: 16),
          ...availableMethods.map((method) => ListTile(
                leading: Icon(
                  PilihTipePembayaran._paymentOptions[method]!['icon']
                      as IconData,
                  color: AppColors.primaryColor,
                ),
                title: Text(
                  PilihTipePembayaran._paymentOptions[method]!['label']
                      as String,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textColorBlack,
                  ),
                ),
                onTap: () => onSelect(method),
                selected: selectedMethod == method,
                selectedTileColor: AppColors.primaryColor.withOpacity(0.1),
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
