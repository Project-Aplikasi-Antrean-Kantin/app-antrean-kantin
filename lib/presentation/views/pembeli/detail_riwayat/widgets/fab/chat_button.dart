import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/chat_page.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat/widgets/fab/button_text.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class ChatButton extends StatelessWidget {
  final String chatType;
  final Pesanan pesanan;
  final String label;
  final bool canChatTenant;
  final HistoryProvider historyProvider;
  const ChatButton(
      {super.key,
      required this.chatType,
      required this.pesanan,
      required this.canChatTenant,
      required this.historyProvider,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('chatButton'),
      width: MediaQuery.of(context).size.width - 48,
      child: FloatingActionButton.extended(
        onPressed: () async {
          if (!await hasInternetAccess()) {
            Fluttertoast.showToast(
              msg: "Tidak ada koneksi internet",
              backgroundColor: AppColors.errorColor,
              textColor: Colors.white,
            );
            return;
          }

          await historyProvider.removeUnreadMessages(pesanan.id);

          Navigator.push(
            context,
            CustomPageBuilder(
              page: ChatPage(
                pesanan: pesanan,
                chatType: chatType,
              ),
            ),
          );
        },
        backgroundColor: chatType == 'tenant'
            ? (canChatTenant ? AppColors.primaryColor : Colors.grey)
            : AppColors.primaryColor,
        label: ButtonText(text: _chatLabel(chatType, label)),
      ),
    );
  }

  String _chatLabel(String chatType, String label) {
    if (chatType == 'driver') {
      return label == 'Antar' ? 'Chat Pembeli' : 'Chat Driver';
    }

    return label == 'Beli' ? 'Chat Penjual' : 'Chat Pembeli';
  }
}
