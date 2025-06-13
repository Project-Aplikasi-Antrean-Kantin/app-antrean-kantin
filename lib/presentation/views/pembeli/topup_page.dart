import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/coin_provider.dart';
import 'package:testgetdata/presentation/provider/topup_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/widgets/payment_topup_dialog.dart';
import 'package:testgetdata/presentation/widgets/shimmer_card.dart';

class TopupPage extends StatefulWidget {
  final String email;

  const TopupPage({super.key, required this.email});

  @override
  _TopupPageState createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  final List<int> nominalList = [5000, 10000, 25000, 50000, 100000, 200000];
  int? _selectedNominal;
  DateTime? _lastFetch;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
    _setupFirebaseListener();
  }

  void _initializeProviders() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    final topUpProvider = Provider.of<TopupProvider>(context, listen: false);
    final user = authProvider.user;

    coinProvider.getHistoryCoin(user.token);
    coinProvider.getCoinAmount(user.token);
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
    final coinProvider = Provider.of<CoinProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: _buildAppBar(),
        body: _buildBody(coinProvider),
        bottomNavigationBar: _buildBottomNavigationBar(),
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
        'TopUp',
        style: GoogleFonts.poppins(
          color: AppColors.textColorBlack,
          fontSize: 18,
          fontWeight: semibold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(CoinProvider coinProvider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoinBalance(coinProvider),
            const SizedBox(height: 10),
            _buildNominalSelection(),
            const SizedBox(height: 20),
            _buildTransactionList(coinProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinBalance(CoinProvider coinProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Saldo Koin: ",
          style: GoogleFonts.poppins(
              fontSize: 14, color: AppColors.textColorBlack),
        ),
        Row(
          children: [
            Icon(Icons.toll, size: 30, color: Colors.yellow[700]),
            const SizedBox(width: 5),
            Text(
              FormatCurrency.intToStringCoin(coinProvider.saldoKoin),
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: AppColors.textColorBlack,
                fontWeight: semibold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNominalSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pilih Nominal",
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: AppColors.textColorBlack,
            fontWeight: FontWeight.w500,
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
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.containerColorGrey,
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
                          : AppColors.textColorBlack,
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

  Widget _buildTransactionList(CoinProvider coinProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'List Transaksi',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: semibold),
        ),
        const SizedBox(height: 10),
        Consumer<CoinProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return ShimmerCard(pageType: 'listTransaksiCoin');
            }
            if (provider.transactionCoin.isEmpty) {
              return const Center(child: Text('Tidak ada transaksi.'));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.transactionCoin.length,
              itemBuilder: (context, index) {
                final transaction = provider.transactionCoin[index];
                return _buildTransactionItem(transaction);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildTransactionItem(dynamic transaction) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(Icons.toll, size: 30, color: Colors.yellow[700]),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (transaction.deskripsi ?? '').replaceAllMapped(
                    RegExp(r'#(\d+)'),
                    (m) => '#ORDER-0${m.group(1)}',
                  ),
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: regular),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  FormatDate.formatDateTimeWithWIB(transaction.createdAt),
                  style:
                      GoogleFonts.poppins(fontSize: 12, fontWeight: semibold),
                ),
              ],
            ),
          ),
          Text(
            FormatCurrency.intToStringCoin(transaction.jumlah ?? 0),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: semibold,
              color: transaction.jumlah < 0 ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border.all(width: 0.2, color: AppColors.containerColorGrey),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: ElevatedButton(
        onPressed: () =>
            PaymentTopupDialog.show(context, widget.email, _selectedNominal),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: Text(
          'Topup sekarang',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: semibold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
