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
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class OutlineChatButton extends StatelessWidget {
  final Pesanan pesanan;
  const OutlineChatButton({super.key, required this.pesanan});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, _) => BadgeChat(
        isActive: historyProvider.unreadMessagesList.contains(pesanan.id),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize:
                Size(screenSize.width * 0.385, screenSize.height * 0.075),
            side: BorderSide(color: AppColors.primaryColor), // border warna
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          onPressed: () async {
            final connectivityResult = await hasInternetAccess();
            if (!connectivityResult) {
              Fluttertoast.showToast(
                msg: 'Tidak ada koneksi internet',
              );
              showNoConnectionBottomSheet(context: context, onRetry: () {});
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
          child: Text(
            'Chat Pembeli',
            style: GoogleFonts.poppins(
              color: AppColors.primaryColor,
              fontSize: 14,
              fontWeight: semibold,
            ),
          ),
        ),
      ),
    );
  }
}
