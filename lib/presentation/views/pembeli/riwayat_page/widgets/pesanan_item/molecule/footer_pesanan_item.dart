import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page/widgets/pesanan_item/atom/footer_chat_button.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page/widgets/pesanan_item/atom/footer_pay_button.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page/widgets/pesanan_item/atom/footer_price_info.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page/widgets/pesanan_item/atom/footer_reorder_button.dart';

class FooterPesananItem extends StatelessWidget {
  final Pesanan pesanan;
  final String tabLabel;

  const FooterPesananItem({
    super.key,
    required this.pesanan,
    required this.tabLabel,
  });

  static const finishedStatuses = {
    'refund_selesai',
    'selesai',
    'pending',
    'gagal_bayar',
  };

  static const reorderStatuses = {
    'selesai',
    'pesanan_ditolak',
    'refund_selesai',
    'gagal_bayar',
  };

  @override
  Widget build(BuildContext context) {
    return Consumer3<HistoryProvider, CartProvider, AuthProvider>(
      builder: (context, historyProvider, cartProvider, authProvider, child) {
        final List<CartMenuModel> cartMenu = pesanan.toCartMenuList();

        final chatType = _getChatType(
          pesanan,
          authProvider.user.nama,
        );

        final isThereNewChat =
            historyProvider.unreadMessagesList.contains(pesanan.id);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_shouldShowPriceInfo()) FooterPriceInfo(pesanan: pesanan),
            if (_shouldShowPriceInfo()) const Spacer(),
            if (_shouldShowChatButton())
              FooterChatButton(
                pesanan: pesanan,
                tabLabel: tabLabel,
                chatType: chatType,
                isThereNewChat: isThereNewChat,
              ),
            if (_shouldShowPayButton())
              FooterPayButton(
                pesanan: pesanan,
              ),
            if (_shouldShowReorderButton())
              FooterReorderButton(
                pesanan: pesanan,
                cartMenu: cartMenu,
                cartProvider: cartProvider,
              ),
          ],
        );
      },
    );
  }

  bool _shouldShowPriceInfo() {
    return finishedStatuses.contains(pesanan.status);
  }

  bool _shouldShowChatButton() {
    return !finishedStatuses.contains(pesanan.status) &&
        !(tabLabel == 'Jual' && pesanan.status == 'diantar');
  }

  bool _shouldShowPayButton() {
    return pesanan.status == 'pending' && tabLabel == 'Beli';
  }

  bool _shouldShowReorderButton() {
    return tabLabel == 'Beli' && reorderStatuses.contains(pesanan.status);
  }

  String _getChatType(Pesanan pesanan, String namaUser) {
    if (pesanan.status == 'diantar') return 'driver';

    final isDriver = (pesanan.driverId != null && tabLabel == 'Beli') ||
        (pesanan.namaDriver != null && pesanan.namaDriver == namaUser);

    return isDriver ? 'driver' : 'tenant';
  }
}
