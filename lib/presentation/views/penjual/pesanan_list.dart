import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/order_provider.dart';
import 'package:testgetdata/presentation/views/penjual/order_status.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_card.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

class PesananList extends StatelessWidget {
  final OrderStatus status;
  final Future<void> Function() onRefresh;

  const PesananList({
    Key? key,
    required this.status,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final user = authProvider.user;
    final pesanan = orderProvider.getPesananByStatus(status);

    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: AppColors.backgroundColor,
      color: AppColors.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pesanan.length,
          itemBuilder: (context, index) {
            final pesananItem = pesanan[index];
            return PesananCard(
              pesanan: pesananItem,
              actionButton:
                  _buildActionButton(context, pesananItem, user.token),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, Pesanan pesanan, String token) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final isLoading = context.watch<OrderProvider>().isLoadingItem;
    final screenSize = MediaQuery.of(context).size;

    switch (status) {
      case OrderStatus.pesananMasuk:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: PrimaryButton(
                isEnabled: !isLoading,
                elevation: 0,
                forgroundColor: AppColors.debugColor,
                borderColor: AppColors.debugColor,
                color: AppColors.containerColorWhite,
                height: screenSize.height * 0.05,
                borderRadius: 100,
                child: Text(
                  'Tolak',
                  style: GoogleFonts.poppins(
                    color: !isLoading
                        ? AppColors.debugColor
                        : AppColors.containerColorGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () async {
                  final success =
                      await orderProvider.cancelOrder(token, pesanan.id);
                  if (success) {
                    Fluttertoast.showToast(
                      msg: "Pesanan telah ditolak",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.grey,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
              ),
            ),
            SizedBox(width: screenSize.width * 0.03),
            Expanded(
              child: PrimaryButton(
                isEnabled: !isLoading,
                isLoading: isLoading,
                elevation: 0,
                height: screenSize.height * 0.05,
                borderRadius: 100,
                child: Text(
                  'Terima',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () async {
                  final success = await orderProvider.updateOrder(
                      'pesanan_diproses', token, pesanan.id, pesanan);
                  if (success) {
                    Fluttertoast.showToast(
                      msg: "Segera proses pesanan!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.grey,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
              ),
            ),
          ],
        );
      case OrderStatus.pesananDiproses:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PrimaryButton(
              isLoading: isLoading,
              elevation: 0,
              width: screenSize.width * 0.5,
              height: screenSize.height * 0.05,
              borderRadius: 100,
              color: AppColors.primaryColor,
              child: Text(
                'Pesanan Siap',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () async {
                final status =
                    pesanan.isAntar == 1 ? 'siap_diantar' : 'selesai';
                final success = await orderProvider.updateOrder(
                    status, token, pesanan.id, pesanan);
                if (success) {
                  Fluttertoast.showToast(
                    msg: "Pesanan Siap",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.grey,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
            ),
          ],
        );
    }
  }
}
