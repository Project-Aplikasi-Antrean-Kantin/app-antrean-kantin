import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/chat_page.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class FooterChatButton extends StatelessWidget {
  final Pesanan pesanan;
  final String tabLabel;
  final String chatType;
  final bool isThereNewChat;

  const FooterChatButton({
    super.key,
    required this.pesanan,
    required this.tabLabel,
    required this.chatType,
    required this.isThereNewChat,
  });

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.read<HistoryProvider>();

    return GestureDetector(
      key: Key('chat${pesanan.id}'),
      onTap: () async {
        final connectivityResult = await hasInternetAccess();

        if (!connectivityResult) {
          Fluttertoast.showToast(msg: 'Tidak ada koneksi internet');

          showNoConnectionBottomSheet(
            context: context,
            onRetry: () {},
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryColor100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Iconsax.message,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  _chatLabel(),
                  style: GoogleFonts.poppins(
                    color: AppColors.whiteColor900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (isThereNewChat)
            Positioned(
              right: 4,
              top: -2,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _chatLabel() {
    if (chatType == 'driver') {
      return tabLabel == 'Antar' ? 'Chat Pembeli' : 'Chat Driver';
    }

    return tabLabel == 'Jual' ? 'Chat Pembeli' : 'Chat Penjual';
  }
}
