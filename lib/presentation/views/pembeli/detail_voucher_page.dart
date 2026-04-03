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
import 'package:testgetdata/presentation/views/pembeli/navbar_home/navbar_home.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';

class DetailVoucherPage extends StatefulWidget {
  final Voucher? voucher;
  final Cashback? cashback;
  final bool fromProfile;

  const DetailVoucherPage({
    required this.fromProfile,
    super.key,
    this.voucher,
    this.cashback,
  }) : assert(voucher != null || cashback != null,
            "Harus salah satu Voucher atau Cashback yang tidak null");

  @override
  State<DetailVoucherPage> createState() => _DetailVoucherPageState();
}

class _DetailVoucherPageState extends State<DetailVoucherPage> {
  Cashback? cashback;
  Voucher? voucher;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    voucher = widget.voucher;
    cashback = widget.cashback;
  }

  @override
  Widget build(BuildContext context) {
    final cashbackData = voucher?.cashback ?? cashback!;
    final isThereVoucher = voucher != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
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
      floatingActionButton: Consumer2<CartProvider, AuthProvider>(
        builder: (context, cartProvider, authProvider, _) {
          return SizedBox(
            width: MediaQuery.of(context).size.width - 48, // ini dia kuncinya!
            child: FloatingActionButton.extended(
              onPressed: () async {
                if (widget.fromProfile) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    CustomPageBuilder(
                      page: NavbarHome(
                        pageIndex: authProvider.user.menu
                            .indexWhere((element) => element.url == '/beranda'),
                      ),
                    ),
                    (route) => false,
                  );
                  return;
                }
                if (isThereVoucher &&
                    cartProvider.selectedVoucher?.id == voucher?.id) {
                  cartProvider.removeVoucher();
                  Fluttertoast.showToast(
                      msg: 'Voucher dibatalkan',
                      backgroundColor: AppColors.errorColor,
                      textColor: Colors.white);
                } else if (isThereVoucher &&
                    cartProvider.selectedVoucher?.id != voucher?.id) {
                  if (cartProvider.selectedTenantDeliveryCost <
                      voucher!.cashback.minimalOrder) {
                    Fluttertoast.showToast(
                        msg:
                            "Minimal Pembelian ${voucher!.cashback.minimalOrder ~/ 1000}rb");
                    return;
                  }
                  cartProvider.setSelectedVoucher(voucher!);
                  Fluttertoast.showToast(
                      msg: 'Voucher terpakai',
                      backgroundColor: AppColors.successColor,
                      textColor: Colors.white);
                  Navigator.pop(context);
                }
                try {
                  if (!isThereVoucher) {
                    final newVoucher = await cartProvider.getCashback(
                        authProvider.user.token, cashbackData.referralCode);
                    setState(() {
                      voucher = newVoucher;
                    });
                    setState(() {
                      cashback = null;
                    });
                    Fluttertoast.showToast(
                        msg: 'Voucher terklaim',
                        backgroundColor: AppColors.successColor,
                        textColor: Colors.white);
                  }
                } catch (e) {
                  Fluttertoast.showToast(msg: e.toString());
                }
              },
              backgroundColor: cashback == null
                  ? isThereVoucher &&
                          cartProvider.selectedVoucher?.id == voucher?.id
                      ? AppColors.errorColor
                      : AppColors.successColor
                  : AppColors.primaryColor,
              label: Center(
                child: Text(
                  cashback == null
                      ? isThereVoucher &&
                              cartProvider.selectedVoucher?.id == voucher?.id
                          ? 'Batalkan'
                          : 'Pakai'
                      : 'Klaim',
                  style: GoogleFonts.poppins(
                    color: AppColors.whiteColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(clipBehavior: Clip.none, children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: Stack(
                    children: [
                      // background warna pertama
                      Container(color: AppColors.primaryColor),

                      // potongan warna kedua
                      ClipPath(
                        clipper: DiagonalClipper(),
                        child: Container(color: AppColors.infoColor100),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.0625,
                  left: 16, // kasih posisi
                  right: 16, // kasih batas kanan → otomatis kasih width
                  child: ClipPath(
                    clipper: CouponClipper(),
                    child: Container(
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cashback ${(cashbackData.value * 100).toInt()}% maks ${cashbackData.maxCashback ~/ 1000}rb',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.blackColor400,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        'Min. pembelian ${cashbackData.minimalOrder ~/ 1000}rb',
                                        style:
                                            GoogleFonts.poppins(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12), // kasih jarak kiri-kanan
                            child: DashedDivider(
                              color: Colors.black,
                              dashWidth: 2,
                              dashSpace: 2,
                            ),
                          ),
                          // atau langsung pakai SizedBox

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              spacing: 8,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.infoColor100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              '${voucher != null ? voucher?.qty : cashbackData.qty}x',
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.infoColor100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'Berlaku s.d ${FormatDate.dateToDay(cashbackData.endDate)}',
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
                    ),
                  ),
                ),
              ]),
              Container(
                margin: EdgeInsets.only(top: 96, left: 24, right: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Reward",
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            )),
                        Text(
                            "Cashback ${(cashbackData.value * 100).toInt()}% s/d ${cashbackData.maxCashback ~/ 1000}rb, Min. pembelian ${cashbackData.minimalOrder ~/ 1000}rb")
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Periode Voucher",
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            )),
                        Text(
                            "${FormatDate.dateTimeToStringDate(cashbackData.startDate)} - ${FormatDate.dateTimeToStringDate(cashbackData.endDate)}")
                      ],
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Syarat & Ketentuan",
                              style: GoogleFonts.poppins(
                                color: AppColors.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              )),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("• ", style: TextStyle(fontSize: 16)),
                              Expanded(
                                  child: Text(
                                      "Voucher berlaku untuk semua metode pembayaran yang tersedia di FoodLAB")),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("• ", style: TextStyle(fontSize: 16)),
                              Expanded(
                                  child: Text(
                                      "Voucher hanya dapat digunakan di Aplikasi FoodLAB")),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("• ", style: TextStyle(fontSize: 16)),
                              Expanded(
                                  child: Text(
                                      "Voucher hanya dapat digunakan jika tersedia di aplikasi")),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("• ", style: TextStyle(fontSize: 16)),
                              Expanded(
                                  child: Text(
                                      "Voucher dapat digunakan selama masih dalam jangka Waktu yang tertera di bagian Masa Berlaku")),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("• ", style: TextStyle(fontSize: 16)),
                              Expanded(
                                  child: Text(
                                      "Voucher akan hangus otomatis jika sudah melewati masa berlaku penukaran")),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("• ", style: TextStyle(fontSize: 16)),
                              Expanded(
                                  child: Text("Voucher tidak bisa ditukar")),
                            ],
                          ),
                        ])
                  ],
                ),
              ),
              SizedBox(
                height: 128,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CouponClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const radius = 12.0; // ukuran lingkaran potongan
    Path path = Path();

    // mulai dari pojok kiri atas
    path.moveTo(0, 0);

    // garis ke kanan atas
    path.lineTo(size.width, 0);

    // garis ke kanan bawah
    path.lineTo(size.width, size.height);

    // garis ke kiri bawah
    path.lineTo(0, size.height);

    // tutup ke atas, tapi sambil bikin "gigitan"
    path.close();

    // bikin 2 lubang lingkaran di kiri & kanan
    Path circleLeft = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(0, size.height / 1.65), radius: radius));

    Path circleRight = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(size.width, size.height / 1.65), radius: radius));

    // combine path utama dengan "difference" lingkaran
    Path temp = Path.combine(PathOperation.difference, path, circleLeft);
    return Path.combine(PathOperation.difference, temp, circleRight);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // mulai dari tengah atas
    path.moveTo(size.width / 2 + 25, 0);

    // ke kanan atas
    path.lineTo(size.width, 0);

    // ke kanan bawah
    path.lineTo(size.width, size.height);

    // ke tengah bawah
    path.lineTo(size.width / 2 - 25, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
