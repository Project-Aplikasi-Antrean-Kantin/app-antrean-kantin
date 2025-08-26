import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/coin_provider.dart';
import 'package:testgetdata/presentation/provider/topup_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/views/pembeli/kode_va_page.dart';
import 'package:testgetdata/presentation/views/pembeli/pembayaran_top_up.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/payment_topup_dialog.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';
import 'package:testgetdata/presentation/widgets/shimmer_card.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class TopupPage extends StatefulWidget {
  final String email;

  const TopupPage({super.key, required this.email});

  @override
  _TopupPageState createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  final List<int> nominalList = [10000, 15000, 20000, 30000, 50000, 100000];
  int? _selectedNominal;
  DateTime? _lastFetch;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  String? selectedValue;
  bool isLoading = false;

  List<String> _paymentMethods =  [
  ];
  @override
  void initState() {
    super.initState();
    _initializeProviders();
    _setupFirebaseListener();
  }

  void _initializeProviders() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final topUpProvider = Provider.of<TopupProvider>(context, listen: false);
    final user = authProvider.user;

    topUpProvider.getDataTopUp(user.token);
  }

  void _setupFirebaseListener() {
    _onMessageSubscription = FirebaseMessaging.onMessage.listen((message) {
      final title = message.data['title']?.toString().toLowerCase();
      if (title == 'top-up berhasil') {
        final coinProvider = Provider.of<CoinProvider>(context, listen: false);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        _handleCoinTopUpByNotification(coinProvider, authProvider.user);
      }
    });
  }

  void _handleCoinTopUpByNotification(
      CoinProvider coinProvider, UserModel user) {
    coinProvider.getCoinAmount(user.token);
    coinProvider.getHistoryCoin(user.token);
    _lastFetch = DateTime.now();
  }

  @override
  void dispose() {
    _onMessageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final topUpProvider = Provider.of<TopupProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: _buildAppBar(),
        body: _buildBody(authProvider, topUpProvider),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.backgroundColor,
      toolbarHeight: 50,
      title: Text(
        'Isi Saldo',
        style: GoogleFonts.poppins(
          color: AppColors.textColorBlack,
          fontSize: 18,
          fontWeight: semibold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(AuthProvider authProvider, TopupProvider topUpProvider) {
    final manualTopUp = topUpProvider.manualTransfer == "1" ||
        selectedValue == 'VA Mandiri' ||
        selectedValue == 'QRIS';
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        child: Column(
          children: [
            SvgPicture.asset('assets/images/koin-logo.svg', height: 50),
            const SizedBox(height: 16),
            Column(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'FoodLAB Koin',
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                  ),
                ),
                Text(
                  '${authProvider.user.nama}',
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildNominalSelection(),
            const SizedBox(height: 16),
            _buildDropdown(topUpProvider),
            const SizedBox(height: 12),
            if (selectedValue != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      (selectedValue != 'VA Mandiri' && selectedValue != 'QRIS')
                          ? 'Pengisian saldo dengan metode ini hanya dilayani pada jam tertentu dengan durasi 30 menit (09.00, 12.00, 15.00, 18.00)'
                          : 'Lakukan refresh halaman beranda setelah pembayaran dengan cara scroll ke atas pada halaman beranda!',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 28),
            PrimaryButton(
              isLoading: isLoading,
              waitingText: topUpProvider.manualTransfer == "1"
                  ? 'Pilih Nominal Terlebih Dahulu'
                  : 'Metode ini tidak tersedia, coba lain waktu',
              isEnabled: selectedValue != null &&
                  _selectedNominal != null &&
                  manualTopUp,
              child: Text('Bayar',
                  style: GoogleFonts.poppins(
                    color: selectedValue != null && _selectedNominal != null
                        ? AppColors.whiteColor
                        : AppColors.blackColor300,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  )),
              onPressed: () async {
                final internetConnection = await hasInternetAccess();
                if (!internetConnection) {
                  Fluttertoast.showToast(msg: "Tidak ada koneksi internet");
                  return;
                }
                if (selectedValue != null && _selectedNominal != null) {
                  await topUpProvider.getDataTopUp(authProvider.user.token);
                  print(
                      "aktifVa: ${topUpProvider.aktifVa}, aktifQris: ${topUpProvider.aktifQris}");
                  if (selectedValue == 'VA Mandiri' &&
                      topUpProvider.aktifVa == '0') {
                    setState(() {
                      selectedValue = null;
                      _selectedNominal = null;
                    });
                    Fluttertoast.showToast(
                      msg: 'Metode VA Mandiri tidak tersedia',
                      backgroundColor: AppColors.errorColor,
                      textColor: Colors.white,
                    );
                    return;
                  }

                  if (selectedValue == 'QRIS' &&
                      topUpProvider.aktifQris == '0') {
                    setState(() {
                      selectedValue = null;
                      _selectedNominal = null;
                    });
                    Fluttertoast.showToast(
                      msg: 'Metode QRIS tidak tersedia',
                      backgroundColor: AppColors.errorColor,
                      textColor: Colors.white,
                    );
                    return;
                  }

                  if (selectedValue == 'VA Mandiri' &&
                      topUpProvider.aktifVa == '1') {
                    setState(() {
                      isLoading = true;
                    });
                    try {
                      final success = await topUpProvider.createVirtualAccount(
                          authProvider.user.token, _selectedNominal.toString());
                      if (success && topUpProvider.topUp != null) {
                        Fluttertoast.showToast(
                          msg: "Virtual Account berhasil dibuat",
                          backgroundColor: AppColors.successColor,
                          textColor: Colors.white,
                        );
                        Navigator.pushReplacement(
                            context,
                            CustomPageBuilder(
                                page: KodeVaPage(
                                    currentVa: topUpProvider.topUp!)));
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(e.toString()),
                      ));
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  } else if (selectedValue == 'QRIS' &&
                      topUpProvider.aktifQris == '1') {
                    setState(() {
                      isLoading = true;
                    });
                    try {
                      final success = await topUpProvider.createQRIS(
                          authProvider.user.token, _selectedNominal.toString());
                      if (success && topUpProvider.topUp != null) {
                        Navigator.pushReplacement(
                            context,
                            CustomPageBuilder(
                                page: KodeVaPage(
                                    currentVa: topUpProvider.topUp!)));
                        Fluttertoast.showToast(
                          msg: "QRIS berhasil dibuat",
                          backgroundColor: AppColors.successColor,
                          textColor: Colors.white,
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(e.toString()),
                      ));
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  } else if (selectedValue != 'QRIS' ||
                      selectedValue != 'VA Mandiri') {
                    if (topUpProvider.manualTransfer == "1") {
                      Navigator.pushReplacement(
                          context,
                          CustomPageBuilder(
                              page: PembayaranTopUp(
                                  selectedMethod: selectedValue!,
                                  selectedNominal: _selectedNominal!)));
                    } else {
                      Fluttertoast.showToast(
                          msg:
                              "Mohon maaf, manual transfer tidak tersedia saat ini",
                          backgroundColor: AppColors.errorColor,
                          textColor: Colors.white);
                    }
                  }
                }
              },
              borderRadius: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(TopupProvider topUpProvider) {
    if (topUpProvider.paymentMethods.isEmpty) return Container();
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        iconStyleData: IconStyleData(
            icon: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Icon(
            Iconsax.arrow_down_1_copy,
            color: selectedValue != null
                ? AppColors.primaryColor
                : AppColors.blackColor400,
          ),
        )),
        isExpanded: true,
        hint: Text(
          'Pilih Metode Bayar',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.blackColor400,
          ),
        ),
        items: topUpProvider.paymentMethods
            .map((ruangan) => DropdownMenuItem<String>(
                  value: ruangan,
                  child: Text(
                    ruangan,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.primaryColor,
                      fontWeight: regular,
                    ),
                  ),
                ))
            .toList(),
        value: selectedValue,
        onChanged: (value) {
          setState(() {
            selectedValue = value;
          });
        },
        buttonStyleData: ButtonStyleData(
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: selectedValue != null
                  ? AppColors.primaryColor300
                  : AppColors.blackColor400,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
        ),
        dropdownStyleData: const DropdownStyleData(
          maxHeight: 200,
          elevation: 4,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
        ),
      ),
    );
  }

  Widget _buildNominalSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pilih Nominal",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.blackColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3,
          ),
          itemCount: nominalList.length,
          itemBuilder: (context, index) {
            final isSelected = _selectedNominal == nominalList[index];
            return GestureDetector(
              onTap: () =>
                  setState(() => _selectedNominal = nominalList[index]),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor.withOpacity(0.1)
                      : null,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.blackColor400,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    FormatCurrency.formatNumber(nominalList[index].toString()),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.blackColor400,
                      fontWeight: isSelected ? semibold : regular,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
