import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/coin_provider.dart';
import 'package:testgetdata/presentation/provider/topup_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/widgets/shimmer_card.dart';

class KoinInfoPage extends StatefulWidget {
  const KoinInfoPage({super.key});

  @override
  State<KoinInfoPage> createState() => _KoinInfoPageState();
}

class _KoinInfoPageState extends State<KoinInfoPage> {
  ScrollController _scrollController = ScrollController();
  bool _isInit = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final coinProvider = Provider.of<CoinProvider>(context, listen: false);
      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          coinProvider.getHistoryCoin(authProvider.user.token, false);
        }
      });
    });

    _initializeProviders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInit) {
        _isInit = true;
        _initializeProviders();
      }
    });
  }

  void _initializeProviders() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    final user = authProvider.user;

    coinProvider.getHistoryCoin(user.token, true);
    coinProvider.getCoinAmount(user.token);
  }

  Map<String, List<dynamic>> _groupTransactions(List<dynamic> transactions) {
    List<dynamic> filtered = [];

    // Terapkan filter
    switch (selectedIndex) {
      case 1:
        filtered = transactions.where((t) => t.jumlah > 0).toList(); // Masuk
        break;
      case 2:
        filtered = transactions.where((t) => t.jumlah < 0).toList(); // Keluar
        break;
      default:
        filtered = transactions; // Semua
    }

    // Group by tanggal
    Map<String, List<dynamic>> grouped = {};
    for (var transaction in filtered) {
      final date = FormatDate.dateTimeToStringDate(
          transaction.createdAt); // ex: 28 Juli 2025
      if (grouped[date] == null) {
        grouped[date] = [];
      }
      grouped[date]!.add(transaction);
    }
    return grouped;
  }

  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: SafeArea(
            child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 4.25,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.98, 0.96),
                  end: Alignment(-0.14, -0.13),
                  colors: [const Color(0xFF0064E6), const Color(0xFF4294FF)],
                ),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 5,
                    left: 12,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.whiteColor,
                        ),
                        child: HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowLeft02,
                            color: AppColors.blackColor),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32, top: 16),
                    child: Column(
                      children: [
                        Text(
                          'Transaksi',
                          style: GoogleFonts.poppins(
                              color: AppColors.whiteColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 26,
                        ),
                        SvgPicture.asset(
                          'assets/images/koin-logo.svg',
                          color: AppColors.whiteColor,
                          height: 32,
                        ),
                        Consumer<CoinProvider>(
                          builder: (context, provider, child) => Text(
                              FormatCurrency.intToStringCoin(
                                  provider.saldoKoin),
                              style: GoogleFonts.poppins(
                                color: AppColors.whiteColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text('FoodLAB Koin',
                            style: GoogleFonts.poppins(
                              color: AppColors.whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ))
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _buildListFilter(),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: _buildTransactionList(_scrollController),
              ),
            )
          ],
        )));
  }

  Widget _buildFilterButton(String label, int index) {
    final isSelected = selectedIndex == index;
    return OutlinedButton(
      onPressed: () {
        setState(() {
          selectedIndex = index;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor:
            isSelected ? AppColors.primaryColor : Colors.transparent,
        side: BorderSide(color: AppColors.primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8), // ⬅️ padding ditambahkan di sini
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: isSelected ? Colors.white : AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildListFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 8,
        children: [
          _buildFilterButton("Semua", 0),
          _buildFilterButton("Masuk", 1),
          _buildFilterButton("Keluar", 2),
        ],
      ),
    );
  }

  Widget _buildTransactionList(ScrollController scrollController) {
    return Consumer<CoinProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return ShimmerCard(pageType: 'listTransaksiCoin');
        }

        final grouped = _groupTransactions(provider.transactionCoin);

        if (grouped.isEmpty) {
          return const Center(child: Text('Tidak ada transaksi.'));
        }

        return ListView(
          controller: scrollController,
          children: [
            ...grouped.entries.map((entry) {
              final date = entry.key;
              final transactions = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 10),
                    child: Text(
                      date,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackColor100,
                      ),
                    ),
                  ),
                  ...transactions.map((t) => _buildTransactionItem(t)).toList(),
                ],
              );
            }).toList(),

            // ✅ Tambahin skeleton item di paling bawah kalau lagi load more
            if (provider.isLoadMore)
              Skeletonizer(
                  child: _buildTransactionItem({
                "id": 1234,
                "user_id": 374,
                "jumlah": -5000,
                "tipe": "keluar",
                "deskripsi": "Pembayaran pesanan #1123",
                "created_at": "2025-09-01 14:21:26",
                "updated_at": "2025-09-01 14:21:26",
                "deleted_at": null
              })),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(dynamic transaction) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          HugeIcon(
            icon: transaction.jumlah < 0
                ? HugeIcons.strokeRoundedLogoutCircle01
                : HugeIcons.strokeRoundedLoginCircle01,
            size: 30,
            color: AppColors.primaryColor,
          ),
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
            '${transaction.jumlah < 0 ? '' : '+'}' +
                FormatCurrency.intToStringCoin(transaction.jumlah ?? 0),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: semibold,
              color: transaction.jumlah < 0
                  ? AppColors.blackColor
                  : AppColors.successColor,
            ),
          ),
        ],
      ),
    );
  }
}
