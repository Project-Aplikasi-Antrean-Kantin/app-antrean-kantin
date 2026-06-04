import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/order_provider.dart';
import 'package:testgetdata/presentation/views/penjual/order_status.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_card/widgets/bottom_sheet_penolakan.dart';
import 'package:testgetdata/presentation/widgets/molecules/custom_snackbar.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

class ActionPesananMasuk extends StatefulWidget {
  final Pesanan pesanan;
  final OrderStatus status = OrderStatus.pesananMasuk;

  const ActionPesananMasuk({super.key, required this.pesanan});

  @override
  State<ActionPesananMasuk> createState() => _ActionPesananMasukState();
}

class _ActionPesananMasukState extends State<ActionPesananMasuk> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Consumer2<OrderProvider, AuthProvider>(
        builder: (context, orderProvider, authProvider, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: PrimaryButton(
              key: Key('tolakButton${widget.pesanan.id}'),
              isEnabled: !_isLoading,
              elevation: 0,
              color: AppColors.errorColor100,
              borderRadius: 12,
              child: Text(
                'Tolak',
                style: GoogleFonts.poppins(
                  color: !_isLoading
                      ? AppColors.errorColor
                      : AppColors.containerColorGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                bottomSheetPenolakan(context, widget.pesanan);
              },
            ),
          ),
          SizedBox(width: screenSize.width * 0.03),
          Expanded(
            child: PrimaryButton(
              key: Key('terimaButton${widget.pesanan.id}'),
              isLoading: _isLoading,
              elevation: 0,
              borderRadius: 12,
              child: Text(
                'Terima',
                style: GoogleFonts.poppins(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                final success = await orderProvider.updateOrder(
                    'pesanan_diproses',
                    authProvider.user.token,
                    widget.pesanan.id,
                    widget.pesanan);

                if (success) {
                  CustomSnackbar.success("Segera proses pesanan!");
                } else {
                  await orderProvider.fetchOrders(
                      context, authProvider.user.token, widget.status);
                  CustomSnackbar.error(
                      "Gagal memperbarui pesanan, ${orderProvider.errorUpdate ?? 'terjadi kesalahan'}");
                }
                if (mounted) {
                  // Check if the widget is still mounted
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
            ),
          ),
        ],
      );
    });
  }
}
