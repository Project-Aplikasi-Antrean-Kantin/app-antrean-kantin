import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/chat_page.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/molecules/badge_chat.dart';
import 'package:testgetdata/presentation/widgets/molecules/custom_snackbar.dart';
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class ChatButton extends StatelessWidget {
  final Pesanan pesanan;
  const ChatButton({super.key, required this.pesanan});

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
      final isThereNewChat =
          historyProvider.unreadMessagesList.contains(pesanan.id);
      return Expanded(
          child: BadgeChat(
        isActive: isThereNewChat,
        child: PrimaryButton(
          key: Key('chatButton${pesanan.id}'),
          borderRadius: 12,
          elevation: 0,
          color: AppColors.primaryColor100,
          onPressed: () async {
            final connectivityResult = await hasInternetAccess();
            if (!connectivityResult) {
              CustomSnackbar.warning(
                'Tidak ada koneksi internet',
              );
              showNoConnectionBottomSheet(context: context, onRetry: () {});
              return;
            }
            if (pesanan.driverId != null) {
              CustomSnackbar.info("Pesanan ini sudah ditangani oleh driver");
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Text(
                'Chat Pembeli',
                style: GoogleFonts.poppins(
                  color: AppColors.primaryColor,
                  fontSize: 14,
                  fontWeight: semibold,
                ),
              ),
            ],
          ),
        ),
      ));
    });
  }
}
