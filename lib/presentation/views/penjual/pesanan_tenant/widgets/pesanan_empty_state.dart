import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/views/penjual/order_status.dart';

class PesananEmptyState extends StatelessWidget {
  final OrderStatus status;
  final String? errorMessage;
  final VoidCallback onRetry;

  const PesananEmptyState({
    Key? key,
    required this.status,
    required this.errorMessage,
    required this.onRetry,
  }) : super(key: key);

  bool get _isConnectionError =>
      errorMessage != null &&
      (errorMessage!.contains('lookup') ||
          errorMessage!.contains('Connection'));

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: AppColors.backgroundColor,
      color: AppColors.primaryColor,
      onRefresh: () async => onRetry(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height -
              kToolbarHeight -
              kBottomNavigationBarHeight -
              80,
          child: Center(child: _buildContent(context)),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (errorMessage == null) {
      return Text(
        'Pesanan ${status.label} kosong',
        style: GoogleFonts.poppins(
          color: AppColors.textColorBlack,
          fontSize: 14,
        ),
      );
    }

    return _ErrorContent(
      title: _isConnectionError
          ? 'Upss Koneksimu Hilang!'
          : 'Gagal memuat pesanan!',
      subtitle: _isConnectionError
          ? 'Cek jaringan internet kamu dulu, ya. Tenang, kami tetap nungguin kamu balik 😄'
          : 'Memuat pesanan gagal, silahkan coba lagi',
      onRetry: onRetry,
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  const _ErrorContent({
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Image(image: AssetImage('assets/images/No-connection.png')),
        Text(title,
            style: GoogleFonts.poppins(
              color: AppColors.whiteColor900,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            )),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF585858),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            )),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width - 48,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text('Coba Lagi',
                  style: GoogleFonts.poppins(
                    color: AppColors.whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ),
        ),
      ],
    );
  }
}
