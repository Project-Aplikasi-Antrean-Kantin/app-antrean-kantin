import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/remote/transaction_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat.dart';
import 'package:testgetdata/core/theme/text_theme.dart';

class RiwayatPage extends StatefulWidget {
  final String role;

  const RiwayatPage({super.key, required this.role});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<Pesanan> listPesanan = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);

    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;

    List<Pesanan> pesananList = await TransactionRemoteDataSource()
        .getHistory(context, user.token, widget.role);

    if (!mounted) return; // Cek apakah widget masih ada sebelum setState
    setState(() {
      isLoading = false;
      listPesanan = pesananList;
    });
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    await _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: isLoading
            ? _buildLoading()
            : listPesanan.isEmpty
                ? _buildEmptyState()
                : _buildPesananList(),
      ),
    );
  }

  /// **Widget tampilan loading**
  Widget _buildLoading() {
    return Container(
      color: AppColors.backgroundColor,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// **Widget tampilan jika pesanan kosong**
  Widget _buildEmptyState() {
    return Container(
      color: AppColors.backgroundColor,
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Text(
          "Belum ada riwayat",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: medium,
          ),
        ),
      ),
    );
  }

  /// **Widget tampilan daftar pesanan**
  Widget _buildPesananList() {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(color: AppColors.backgroundColor),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: Column(
                children: listPesanan
                    .map((pesanan) => _buildPesananItem(pesanan))
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// **Widget untuk menampilkan satu item pesanan**
  Widget _buildPesananItem(Pesanan pesanan) {
    Route detailRiwayatPage() {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DetailRiwayat(
          pesanan: pesanan,
          refreshData: _refreshData,
        ),
        transitionsBuilder: (context, animation, secondaryWAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset(0.0, 0.0);
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          detailRiwayatPage(),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 0.2),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPesananHeader(pesanan),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: AppColors.lineDividerColor, height: 1),
            ),
            _buildPesananFooter(pesanan),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  /// **Widget untuk header pesanan (gambar dan nama tenant)**
  Widget _buildPesananHeader(Pesanan pesanan) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPesananImage(pesanan),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${pesanan.listTransaksiDetail[0].menus?.tenants?.namaTenant}",
                style: GoogleFonts.poppins(
                  color: AppColors.textColorBlack,
                  fontSize: 14,
                  fontWeight: semibold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                FormatDate.formatDateTimeWithWIB(pesanan.createdAt),
                style: GoogleFonts.poppins(
                  color: AppColors.textColorBlack,
                  fontSize: 12,
                  fontWeight: regular,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "${pesanan.listTransaksiDetail[0].jumlah} Item Menu",
                style: GoogleFonts.poppins(
                  color: AppColors.textColorBlack,
                  fontSize: 12,
                  fontWeight: medium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// **Widget untuk gambar pesanan**
  Widget _buildPesananImage(Pesanan pesanan) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        image: DecorationImage(
          image: NetworkImage(
            "${pesanan.listTransaksiDetail[0].menus?.tenants?.gambar}",
          ),
          fit: BoxFit.cover,
        ),
      ),
      height: 80,
      width: 80,
      margin: const EdgeInsets.only(right: 15),
    );
  }

  /// **Widget untuk footer pesanan (harga dan status)**
  Widget _buildPesananFooter(Pesanan pesanan) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
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
          Center(
            child: Text(
              pesanan.status.replaceAll('_', ' ').toUpperCase(),
              style: GoogleFonts.poppins(
                color: getStatusColor(pesanan.status),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
