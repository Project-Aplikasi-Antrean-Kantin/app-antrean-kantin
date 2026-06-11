import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/provider/order_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/chat_page.dart';
import 'package:testgetdata/presentation/views/penjual/order_status.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_card/widgets/bottom_sheet_penolakan.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/molecules/custom_snackbar.dart';
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class ActionPesananDiproses extends StatelessWidget {
  final Pesanan pesanan;
  final OrderStatus statusPesanan = OrderStatus.pesananDiproses;
  final List<Pesanan> listPesanan;
  const ActionPesananDiproses(
      {super.key, required this.pesanan, required this.listPesanan});

  @override
  Widget build(BuildContext context) {
    return Consumer3<HistoryProvider, AuthProvider, OrderProvider>(builder:
        (context, historyProvider, authProvider, orderProvider, child) {
      final isThereNewChat =
          historyProvider.unreadMessagesList.contains(pesanan.id);
      return Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Row(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                identifier: 'tolakButton${pesanan.id}',
                child: IconButton(
                  key: Key('tolakButton${pesanan.id}'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.errorColor100,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  onPressed: () => bottomSheetPenolakan(context, pesanan),
                  icon: Icon(
                    Iconsax.close_circle,
                    color: AppColors.errorColor,
                  ),
                ),
              ),
              if (pesanan.driverId == null)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      style: OutlinedButton.styleFrom(
                        shape:
                            const CircleBorder(), // ✅ ini yang bikin benar-benar bundar
                        backgroundColor: AppColors.primaryColor100,
                        padding: const EdgeInsets.all(
                            12), // jarak icon dengan border
                      ),
                      onPressed: () async {
                        final connectivityResult = await hasInternetAccess();
                        if (!connectivityResult) {
                          CustomSnackbar.warning('Tidak ada koneksi internet');
                          showNoConnectionBottomSheet(
                              context: context, onRetry: () {});
                          return;
                        }
                        historyProvider.removeUnreadMessages(pesanan.id);

                        Navigator.push(
                          context,
                          CustomPageBuilder(
                            page: ChatPage(
                              pesanan: pesanan,
                              chatType: "tenant",
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Iconsax.message,
                        size: 24,
                        color: AppColors.primaryColor,
                      ),
                    ),

                    // bulatan indikator
                    if (isThereNewChat)
                      Positioned(
                        right: 8,
                        top: 4,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          )),
          Expanded(
            child: Semantics(
              identifier: 'siapButton${pesanan.id}',
              child: PrimaryButton(
                key: Key('siapButton${pesanan.id}'),
                isLoading: orderProvider.isLoading,
                elevation: 0,
                borderRadius: 12,
                color: AppColors.primaryColor,
                child: Text(
                  'Pesanan Siap',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () async {
                  final status =
                      pesanan.isAntar == 1 ? 'siap_diantar' : 'siap_diambil';
                  final success = await orderProvider.updateOrder(
                      status, authProvider.user.token, pesanan.id, pesanan);

                  if (success) {
                    listPesanan.remove(pesanan);
                    CustomSnackbar.success("Pesanan siap");
                  } else {
                    await orderProvider.fetchOrders(
                        context, authProvider.user.token, statusPesanan);
                    CustomSnackbar.error(
                        "Gagal memperbarui pesanan, ${orderProvider.errorUpdate ?? 'terjadi kesalahan'}");
                  }
                },
              ),
            ),
          ),
        ],
      );
    });
  }
}
