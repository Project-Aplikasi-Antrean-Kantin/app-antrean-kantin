import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/shimmer_card.dart';

class RiwayatPage extends StatefulWidget {
  final String role;

  const RiwayatPage({super.key, required this.role});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;

  bool _hasInitialized = false;
  DateTime? _lastFetchTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchDataIfNeeded();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh data ketika app kembali dari background
    if (state == AppLifecycleState.resumed) {
      _fetchDataIfNeeded(forceRefresh: true);
    }
  }

  // Method untuk mengecek apakah perlu fetch data
  void _fetchDataIfNeeded({bool forceRefresh = false}) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);

    final now = DateTime.now();
    final shouldRefresh = forceRefresh ||
        !_hasInitialized ||
        historyProvider.getListPesanan(widget.role).isEmpty ||
        (_lastFetchTime != null &&
            now.difference(_lastFetchTime!).inMinutes >
                5); // Refresh setiap 5 menit

    if (shouldRefresh && !historyProvider.getIsLoading(widget.role)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        historyProvider.fetchHistory(context, authProvider.user, widget.role);
        _lastFetchTime = now;
        _hasInitialized = true;
      });
    }
  }

  // Method yang dipanggil saat tab menjadi visible
  void _onTabVisible() {
    _fetchDataIfNeeded(forceRefresh: false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Panggil _onTabVisible setiap kali build (ketika tab menjadi aktif)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onTabVisible();
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    return Scaffold(
      body: RefreshIndicator(
        backgroundColor: AppColors.backgroundColor,
        color: AppColors.primaryColor,
        onRefresh: () async {
          final historyProvider =
              Provider.of<HistoryProvider>(context, listen: false);
          await historyProvider.refreshHistory(context, user, widget.role);
          _lastFetchTime = DateTime.now();
        },
        child: Consumer<HistoryProvider>(
          builder: (context, historyProvider, _) {
            final isLoading = historyProvider.getIsLoading(widget.role);
            final errorMessage = historyProvider.getErrorMessage(widget.role);
            final listPesanan = historyProvider.getListPesanan(widget.role);

            return Container(
              color: AppColors.backgroundColor,
              height: MediaQuery.of(context).size.height,
              child: isLoading
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: List.generate(
                          4,
                          (index) => ShimmerCard(
                            pageType: 'riwayat',
                          ),
                        ),
                      ),
                    )
                  : errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                errorMessage,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: regular,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  historyProvider.fetchHistory(
                                      context, user, widget.role);
                                  _lastFetchTime = DateTime.now();
                                },
                                child: const Text("Coba Lagi"),
                              ),
                            ],
                          ),
                        )
                      : listPesanan.isEmpty
                          ? Center(
                              child: Text(
                                "Belum ada riwayat",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: regular,
                                  color: AppColors.textColorBlack,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics(),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                children: listPesanan
                                    .map((pesanan) =>
                                        _buildPesananItem(pesanan, context))
                                    .toList(),
                              ),
                            ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPesananItem(Pesanan pesanan, BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);
    final user = authProvider.user;

    final totalItemMenu = pesanan.listTransaksiDetail
        .map((item) => item.jumlah)
        .fold(0, (prev, jumlah) => prev + jumlah);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CustomPageBuilder(
            page: DetailRiwayat(
              token: user.token.toString(),
              pesanan: pesanan,
              refreshData: () {
                historyProvider.fetchHistory(
                    context, authProvider.user, widget.role);
                _lastFetchTime = DateTime.now();
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          border: Border.all(color: Colors.grey, width: 0.2),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    image: DecorationImage(
                      image: NetworkImage(
                        pesanan.listTransaksiDetail.isNotEmpty
                            ? pesanan.listTransaksiDetail[0].menus?.tenants
                                    ?.gambar ??
                                ''
                            : '',
                      ),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) =>
                          const AssetImage('assets/placeholder.png'),
                    ),
                  ),
                  height: 80,
                  width: 80,
                  margin: const EdgeInsets.only(right: 15),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pesanan.listTransaksiDetail.isNotEmpty
                          ? pesanan.listTransaksiDetail[0].menus?.tenants
                                  ?.namaTenant ??
                              '-'
                          : '-',
                      style: GoogleFonts.poppins(
                        color: AppColors.textColorBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      FormatDate.formatDateTimeWithWIB(pesanan.createdAt),
                      style: GoogleFonts.poppins(
                        color: AppColors.textColorBlack,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "$totalItemMenu Item Menu",
                      style: GoogleFonts.poppins(
                        color: AppColors.textColorBlack,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: AppColors.lineDividerColor, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  FormatCurrency.intToStringCurrency(pesanan.total),
                  style: GoogleFonts.poppins(
                    color: AppColors.textColorBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  pesanan.status == 'refund_selesai'
                      ? 'PESANAN DITOLAK'
                      : pesanan.status.replaceAll('_', ' ').toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: pesanan.status == 'refund_selesai'
                        ? Colors.red
                        : getStatusColor(pesanan.status),
                    fontWeight: bold,
                    fontSize: 12,
                  ),
                )
              ],
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
