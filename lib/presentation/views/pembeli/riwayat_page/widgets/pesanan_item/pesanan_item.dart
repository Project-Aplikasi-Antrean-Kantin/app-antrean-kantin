import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/remote/transaction_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat/detail_riwayat.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page/widgets/pesanan_item/molecule/footer_pesanan_item.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page/widgets/pesanan_item/molecule/header_pesanan_item.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class PesananItem extends StatelessWidget {
  final Pesanan pesanan;
  final String role;
  final String tabLabel;

  const PesananItem(
      {super.key,
      required this.pesanan,
      required this.role,
      required this.tabLabel});

  @override
  Widget build(BuildContext context) {
    return Consumer3<HistoryProvider, AuthProvider, CartProvider>(
        builder: (context, historyProvider, authProvider, cartProvider, child) {
      bool isLoading = false;
      return Semantics(
        button: true,
        label: 'Buka pesanan ${pesanan.id}',
        child: GestureDetector(
          key: Key("${pesanan.id.toString()}pesananItem"),
          onTap: () async {
            if (isLoading) return;
            isLoading = true;
            final internetConnection = await hasInternetAccess();
            // final prefs = await SharedPreferences.getInstance();
            if (!internetConnection) {
              Fluttertoast.showToast(msg: "Tidak ada koneksi internet");
              return;
            }
            historyProvider.updateSelectedPesanan(pesanan);
            Navigator.of(context).push(
              CustomPageBuilder(
                page: DetailRiwayat(
                  pesanan: pesanan,
                  label: tabLabel,
                  refreshData: () {
                    TransactionRemoteDataSource()
                        .getOrderById(
                            authProvider.user.token, pesanan.id.toString())
                        .then((pesanan) {
                      historyProvider.updateSelectedPesanan(pesanan);
                      historyProvider.updatedPesanan(pesanan, role);
                    });
                  },
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.whiteColor100,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                  color: pesanan.status == "selesai"
                      ? AppColors.primaryColor
                      : AppColors.whiteColor900),
            ),
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderPesananItem(pesanan: pesanan),
                DashedDivider(height: 1, color: AppColors.blackColor100),
                FooterPesananItem(pesanan: pesanan, tabLabel: tabLabel)
              ],
            ),
          ),
        ),
      );
    });
  }
}
