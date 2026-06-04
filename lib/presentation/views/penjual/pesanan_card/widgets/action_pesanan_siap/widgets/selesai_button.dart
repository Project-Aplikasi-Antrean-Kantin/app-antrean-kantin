import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/provider/order_provider.dart';
import 'package:testgetdata/presentation/views/penjual/order_status.dart';
import 'package:testgetdata/presentation/widgets/molecules/custom_snackbar.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

class SelesaiButton extends StatelessWidget {
  final Pesanan pesanan;
  final List<Pesanan> listPesanan;
  final OrderStatus statusPesanan = OrderStatus.pesananSiapDiambil;
  const SelesaiButton(
      {super.key, required this.pesanan, required this.listPesanan});

  @override
  Widget build(BuildContext context) {
    return Consumer3<HistoryProvider, AuthProvider, OrderProvider>(builder:
        (context, historyProvider, authProvider, orderProvider, child) {
      return Expanded(
        child: PrimaryButton(
          key: Key('selesaiButton${pesanan.id}'),
          isLoading: orderProvider.isLoading,
          elevation: 0,
          borderRadius: 12,
          color: AppColors.primaryColor,
          child: Text(
            'Selesai',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () async {
            final status = 'selesai';
            final success = await orderProvider.updateOrder(
                status, authProvider.user.token, pesanan.id, pesanan);
            historyProvider.removeUnreadMessages(pesanan.id);

            if (success) {
              listPesanan.remove(pesanan);

              CustomSnackbar.success("Pesanan selesai");
            } else {
              await orderProvider.fetchOrders(
                  context, authProvider.user.token, statusPesanan);
              CustomSnackbar.error(
                  "Gagal memperbarui pesanan, ${orderProvider.errorUpdate ?? 'terjadi kesalahan'}");
            }
          },
        ),
      );
    });
  }
}
