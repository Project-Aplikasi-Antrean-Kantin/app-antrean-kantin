import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
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
  static final Map<PaymentMethod, Map<String, String>> _paymentOptions = {
    PaymentMethod.koin: {
      'label': 'FoodLab Koin',
      'icon': 'assets/images/koin-logo.svg',
      'description': 'Pastikan koin FoodLAB mencukupi',
    },
    PaymentMethod.qris: {
      'label': 'QRIS',
      'icon': 'assets/images/koin-logo.svg',
      'description': 'Pembayaran instan dengan QRIS',
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
            spacing: 8,
            children: [
              if (selectedPaymentMethod != null)
                SvgPicture.asset('assets/images/koin-logo.svg', height: 30),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedPaymentMethod == null
                                    ? 'Pilih metode bayar'
                                    : _paymentOptions[selectedPaymentMethod]![
                                        'label'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: AppColors.textColorBlack,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                ),
                              ),
                              if (selectedPaymentMethod != null)
                                Text(
                                  _formatTotal(total, selectedPaymentMethod),
                                  style: GoogleFonts.poppins(
                                    fontWeight: semibold,
                                    color: AppColors.textColorBlack,
                                    height: 1.5,
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const HugeIcon(
                              icon:
                                  HugeIcons.strokeRoundedMoreHorizontalCircle02,
                              size: _iconSize,
                              color: AppColors.blackColor,
                            ),
                            onPressed: () => showModalBottomSheet(
                              context: context,
                              builder: (context) => _PaymentOptionBottomSheet(
                                  selectedMethod: selectedPaymentMethod,
                                  isKasirActive: isKasirActive,
                                  onSelect: onPaymentMethodSelected),
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
        ),
      ),
    );
  }
}

class _PaymentOptionBottomSheet extends StatefulWidget {
  final PaymentMethod? selectedMethod;
  final bool isKasirActive;
  final Function(PaymentMethod?) onSelect;

  const _PaymentOptionBottomSheet({
    required this.selectedMethod,
    required this.isKasirActive,
    required this.onSelect,
  });

  @override
  State<_PaymentOptionBottomSheet> createState() =>
      _PaymentOptionBottomSheetState();
}

class _PaymentOptionBottomSheetState extends State<_PaymentOptionBottomSheet> {
  PaymentMethod? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = widget.selectedMethod; // default dari parent
  }

  Widget build(BuildContext context) {
    final availableMethods = widget.isKasirActive
        ? [PaymentMethod.qris]
        : [PaymentMethod.koin, PaymentMethod.qris];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.backgroundColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Metode Bayar',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textColorBlack,
            ),
          ),
          const SizedBox(height: 16),
          ...availableMethods.map((method) {
            final iconPath =
                PilihTipePembayaran._paymentOptions[method]!['icon'] as String;

            print(iconPath);

            return Column(
              children: [
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    setState(() => _selectedPaymentMethod = method);
                    widget.onSelect(method);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: _selectedPaymentMethod == method
                            ? AppColors.primaryColor100
                            : AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedPaymentMethod == method
                              ? AppColors.primaryColor200
                              : AppColors.blackColor100,
                          width: 1.5,
                        )),
                    child: Row(
                      spacing: 8,
                      children: [
                        SvgPicture.asset(
                          PilihTipePembayaran._paymentOptions[method]!['icon']!,
                          height: 30,
                        ),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  PilihTipePembayaran
                                          ._paymentOptions[method]!['label']
                                      as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColorBlack,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  PilihTipePembayaran._paymentOptions[method]![
                                      'description'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textColorBlack,
                                  ),
                                ),
                              ]),
                        ),
                        InkWell(
                          onTap: () => {
                            widget.onSelect(method),
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedPaymentMethod == method
                                    ? AppColors.primaryColor
                                    : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 24 / 2,
                                height: 24 / 2,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _selectedPaymentMethod == method
                                      ? AppColors.primaryColor
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
