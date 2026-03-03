import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/remote/driver_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/chat_page.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/show_bottom_sheet_ping.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class HubungiPembeli extends StatefulWidget {
  final Pesanan pesanan;
  final HistoryProvider historyProvider;
  const HubungiPembeli(
      {super.key, required this.pesanan, required this.historyProvider});

  @override
  State<HubungiPembeli> createState() => _HubungiPembeliState();
}

class _HubungiPembeliState extends State<HubungiPembeli> {
  bool _isCooldown = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isThereNewChat = widget.historyProvider.unreadMessagesList.contains(
      widget.pesanan.id,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hubungi Pembeli',
            style: GoogleFonts.poppins(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: semibold,
            ),
          ),
          Row(
            spacing: 8,
            mainAxisAlignment: widget.pesanan.status == 'diantar'
                ? MainAxisAlignment.end
                : MainAxisAlignment.center,
            children: [
              if (widget.pesanan.status == 'diantar')
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape:
                                const CircleBorder(), // ✅ ini yang bikin benar-benar bundar
                            side: BorderSide(
                              color: AppColors.primaryColor300,
                              width: 2,
                            ),
                            padding: const EdgeInsets.all(
                              12,
                            ), // jarak icon dengan border
                          ),
                          onPressed: () async {
                            final connectivityResult =
                                await hasInternetAccess();
                            if (!connectivityResult) {
                              Fluttertoast.showToast(
                                msg: 'Tidak ada koneksi internet',
                              );
                              showNoConnectionBottomSheet(
                                context: context,
                                onRetry: () {},
                              );
                              return;
                            }
                            widget.historyProvider.removeUnreadMessages(
                              widget.pesanan.id,
                            );

                            Navigator.push(
                              context,
                              CustomPageBuilder(
                                page: ChatPage(
                                  pesanan: widget.pesanan,
                                  chatType: "driver",
                                ),
                              ),
                            );
                          },
                          child: const Icon(
                            Iconsax.message_text_copy,
                            size: 24,
                            color: AppColors.primaryColor300,
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
                    OutlinedButton(
                      key: const Key('PingButton'),
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        side: BorderSide(
                          color: _isCooldown
                              ? Colors.grey // abu kalau cooldown
                              : AppColors.primaryColor300,
                          width: 2,
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                      onPressed: _isCooldown
                          ? null
                          : () => showBottomSheetPing(
                                context: context,
                                onFinish: _handlePress,
                                canSend: !_isCooldown,
                              ), // disable pas cooldown
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedMegaphone02,
                        color: _isCooldown
                            ? Colors.grey
                            : AppColors.primaryColor300,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handlePress() async {
    final connectivityResult = await hasInternetAccess();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (!connectivityResult) {
      Fluttertoast.showToast(msg: 'Tidak ada koneksi internet');
      showNoConnectionBottomSheet(context: context, onRetry: () {});
      return;
    }
    try {
      final success = await DriverDataSource().pingCustomer(
        user.token,
        widget.pesanan.id.toString(),
      );

      if (success.success) {
        Fluttertoast.showToast(msg: 'Ping terkirim');
        _startCooldown(); // mulai cooldown kalau sukses
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
            msg: '${success.error ?? 'Ping gagal terkirim'}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void _startCooldown() {
    setState(() {
      _isCooldown = true;
    });

    _timer = Timer(Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _isCooldown = false;
        });
      }
    });
  }
}
