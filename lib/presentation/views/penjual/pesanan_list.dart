import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/order_provider.dart';
import 'package:testgetdata/presentation/views/penjual/order_status.dart';
import 'package:testgetdata/presentation/widgets/pesanan_card.dart';

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

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
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

    switch (status) {
      case OrderStatus.pesananMasuk:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () async {
                final success =
                    await orderProvider.cancelOrder(token, pesanan.id);
                if (success) {
                  Fluttertoast.showToast(
                    msg: "Pesanan ditolak",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.grey,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                side: BorderSide(color: AppColors.primaryColor),
                backgroundColor: AppColors.backgroundColor,
                fixedSize: const Size(160, 30),
              ),
              child: Text(
                'Tolak',
                style: GoogleFonts.poppins(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
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
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                backgroundColor: AppColors.primaryColor,
                fixedSize: const Size(160, 30),
              ),
              child: Text(
                'Terima',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      case OrderStatus.pesananDiproses:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
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
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                backgroundColor: AppColors.primaryColor,
                fixedSize: const Size(180, 30),
              ),
              child: Text(
                'Pesanan Siap',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      // // case OrderStatus.pesananMenunggu:
      //   // Placeholder untuk status baru
      //   return const SizedBox.shrink();
    }
  }
}
