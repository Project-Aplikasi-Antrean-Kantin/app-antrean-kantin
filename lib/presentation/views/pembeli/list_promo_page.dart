import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/cashback.dart';
import 'package:testgetdata/data/model/voucher_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_voucher_page.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';

class ListPromoPage extends StatefulWidget {
  const ListPromoPage({super.key});

  @override
  State<ListPromoPage> createState() => _ListPromoPageState();
}

class _ListPromoPageState extends State<ListPromoPage> {
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInit) {
        _isInit = true;
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        cartProvider
            .fetchCashback(authProvider.user.token, false)
            .then((listCashback) {
          cartProvider.fetchVoucher(authProvider.user.token, listCashback);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.whiteColor100,
        surfaceTintColor: AppColors.backgroundColor,
        title: const Text("Voucher",
            style: TextStyle(
                color: AppColors.textColorBlack,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Consumer<CartProvider>(
                builder: (context, cartProvider, _) {
                  if (cartProvider.selectedVoucher != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        Text(
                          'Voucher yang kamu pilih',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        _buildVoucherOrCashback(cartProvider.selectedVoucher!,
                            cartProvider, authProvider.user.token),
                      ],
                    );
                  } else {
                    return const SizedBox(); // jangan tampilkan apapun
                  }
                },
              ),
              Consumer<CartProvider>(
                builder: (context, cartProvider, _) {
                  final filteredVouchers = cartProvider.listVoucher
                      .where((voucher) =>
                          voucher.qty > 0 &&
                          cartProvider.selectedVoucher?.id !=
                              voucher.id) // hanya tampil kalau qty > 0
                      .toList();
                  if (filteredVouchers.isEmpty) {
                    return const SizedBox(); // jangan tampilkan apapun
                  }

                  return Column(
                      spacing: 16,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Voucher yang bisa kamu pakai',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        ...filteredVouchers
                            .map((voucher) => _buildVoucherOrCashback(
                                voucher, cartProvider, authProvider.user.token))
                            .toList(),
                      ]);
                },
              ),
              Consumer<CartProvider>(
                builder: (context, cartProvider, _) {
                  final filteredCashbacks =
                      cartProvider.listCashback.where((cashback) {
                    final isAlreadyInVoucher = cartProvider.listVoucher.any(
                      (voucher) => voucher.cashback.id == cashback.id,
                    );
                    return !isAlreadyInVoucher;
                  }).toList();

                  if (filteredCashbacks.isEmpty) {
                    return const SizedBox(); // jangan tampilkan apapun
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: [
                      Text(
                        'Claim Voucher',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      ...filteredCashbacks
                          .map((cashback) => _buildVoucherOrCashback(
                                cashback,
                                cartProvider,
                                authProvider.user.token,
                              )),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildVoucherOrCashback(
      dynamic data, CartProvider cartProvider, String token) {
    // cek apakah data itu Voucher atau Cashback
    Cashback cashback;
    int? qty;
    bool isVoucher = false;

    if (data is Voucher) {
      cashback = data.cashback;
      qty = data.qty;
      isVoucher = true;
    } else if (data is Cashback) {
      cashback = data;
      qty = data.maxUsed;
    } else {
      throw Exception("Unsupported type: ${data.runtimeType}");
    }

    return Container(
      decoration: BoxDecoration(
        color: cartProvider.selectedVoucher?.id == data.id && isVoucher
            ? AppColors.successColor100
            : Colors.white,
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
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              spacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.successColor100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedDiscount,
                    color: AppColors.successColor,
                    size: 24,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (isVoucher) {
                        Navigator.push(
                          context,
                          CustomPageBuilder(
                            page: DetailVoucherPage(
                              voucher: data as Voucher,
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          CustomPageBuilder(
                            page: DetailVoucherPage(
                              cashback: data as Cashback,
                            ),
                          ),
                        );
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cashback ${(cashback.value * 100).toInt()}% maks ${cashback.maxCashback ~/ 1000}rb',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackColor400,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Min. pembelian ${cashback.minimalOrder ~/ 1000}rb',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                if (data is Cashback ||
                    (isVoucher && cartProvider.selectedVoucher?.id != data.id))
                  GestureDetector(
                    onTap: () async {
                      try {
                        if (isVoucher) {
                          if (cartProvider.totalPrice <
                              data.cashback.minimalOrder) {
                            Fluttertoast.showToast(
                                msg:
                                    'Minimal pembelian ${data.cashback.minimalOrder ~/ 1000}rb');
                            return;
                          }
                          cartProvider.setSelectedVoucher(data);
                          Fluttertoast.showToast(
                              msg: 'Voucher berhasil dipilih',
                              backgroundColor: AppColors.successColor,
                              textColor: Colors.white);
                        } else {
                          await cartProvider.getCashback(
                              token, cashback.referralCode);
                          Fluttertoast.showToast(
                              msg: 'Voucher berhasil diklaim',
                              backgroundColor: AppColors.successColor,
                              textColor: Colors.white);
                        }
                      } catch (e) {
                        Fluttertoast.showToast(msg: e.toString());
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isVoucher ? null : AppColors.successColor,
                        border: Border.all(color: AppColors.successColor),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        isVoucher ? 'Pakai' : 'Klaim',
                        style: GoogleFonts.poppins(
                          color: isVoucher
                              ? AppColors.successColor400
                              : AppColors.whiteColor100,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (isVoucher && cartProvider.selectedVoucher?.id == data.id)
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                    color: AppColors.successColor,
                  ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              DashedDivider(
                color: isVoucher && cartProvider.selectedVoucher?.id == data.id
                    ? AppColors.blackColor
                    : AppColors.blackColor200,
                dashWidth: 2,
                dashSpace: 2,
              ),
              Positioned(
                left: -8,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: -8,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isVoucher && cartProvider.selectedVoucher?.id == data.id
                            ? Colors.white
                            : AppColors.successColor100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${qty}x',
                          style: GoogleFonts.poppins(
                            color: AppColors.blackColor400,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: ' pemakaian',
                          style: GoogleFonts.poppins(
                            color: AppColors.blackColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isVoucher && cartProvider.selectedVoucher?.id == data.id
                            ? Colors.white
                            : AppColors.successColor100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Berlaku s.d ${FormatDate.dateToDay(cashback.endDate)}',
                    style: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontSize: 12,
                    ),
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
