import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
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
import 'package:testgetdata/presentation/views/pembeli/kode_va_page.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/molecules/custom_snackbar.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class TopupPage extends StatefulWidget {
  const TopupPage({super.key});

  @override
  _TopupPageState createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  final List<int> nominalList = [
    10000,
    15000,
    20000,
    30000,
    50000,
    100000,
    300000,
    500000
  ];
  int? _selectedNominal;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  String? selectedValue;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupFirebaseListener();
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
    coinProvider.getHistoryCoin(user.token, true);
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        child: Column(
          children: [
            Image.asset('assets/images/icon-koin-blue.png', height: 50),
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
                      'Lakukan refresh halaman beranda setelah pembayaran dengan cara scroll ke atas pada halaman beranda!',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 28),
            PrimaryButton(
              key: const Key('bayarButton'),
              isLoading: isLoading,
              waitingText: isLoading
                  ? 'Tunggu sebentar'
                  : selectedValue == null
                      ? 'Pilih Metode Pembayaran'
                      : 'Pilih Nominal Pembayaran',
              isEnabled: selectedValue != null && _selectedNominal != null,
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
                  CustomSnackbar.warning("Tidak ada koneksi internet");
                  return;
                }
                if (selectedValue != null && _selectedNominal != null) {
                  if (selectedValue == 'QRIS') {
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
                        CustomSnackbar.success("QRIS berhasil dibuat");
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
    return DropdownButtonHideUnderline(
      key: const Key('dropDownButton'),
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
        items: const [
          DropdownMenuItem(
            key: const Key('qrisDropDown'),
            value: 'QRIS',
            child: Text('QRIS'),
          ),
        ],
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
            return Semantics(
              identifier: "${nominalList[index].toString()}Nominal",
              button: true,
              child: GestureDetector(
                key: Key("${nominalList[index].toString()}Nominal"),
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
                      FormatCurrency.formatNumber(
                          nominalList[index].toString()),
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
              ),
            );
          },
        ),
      ],
    );
  }
}
