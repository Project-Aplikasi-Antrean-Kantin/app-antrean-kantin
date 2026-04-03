import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/remote/driver_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/delivery_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/chat_page.dart';
import 'package:testgetdata/presentation/views/pengantar/delivery_card/widgets/action_button/widgets/finish_delivery_button.dart';
import 'package:testgetdata/presentation/views/pengantar/delivery_card/widgets/action_button/widgets/primary_action_button.dart';
import 'package:testgetdata/presentation/views/pengantar/delivery_card/widgets/action_button/widgets/priority_slider.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/delivery_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/molecules/chat_ping_action.dart';
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/show_bottom_sheet_ping.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class ActionButtonDelivery extends StatefulWidget {
  final DeliveryStatus status;
  final Pesanan pesanan;
  final String token;
  final VoidCallback onSuccess;

  const ActionButtonDelivery({
    super.key,
    required this.status,
    required this.pesanan,
    required this.token,
    required this.onSuccess,
  });

  @override
  State<ActionButtonDelivery> createState() => _ActionButtonDeliveryState();
}

class _ActionButtonDeliveryState extends State<ActionButtonDelivery> {
  bool _isCooldown = false;
  Timer? _timer;
  String? deliveryImagePath;

  // ================== COOLDOWN ==================
  void _startCooldown() {
    setState(() => _isCooldown = true);

    _timer = Timer(const Duration(seconds: 30), () {
      if (mounted) setState(() => _isCooldown = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ================== HANDLERS ==================
  Future<void> _handleChat(HistoryProvider historyProvider) async {
    final hasInternet = await hasInternetAccess();
    if (!hasInternet) {
      Fluttertoast.showToast(msg: 'Tidak ada koneksi internet');
      showNoConnectionBottomSheet(context: context, onRetry: () {});
      return;
    }

    historyProvider.removeUnreadMessages(widget.pesanan.id);

    Navigator.push(
      context,
      CustomPageBuilder(
        page: ChatPage(
          pesanan: widget.pesanan,
          chatType: "driver",
        ),
      ),
    );
  }

  Future<void> _handlePing() async {
    final hasInternet = await hasInternetAccess();
    if (!hasInternet) {
      Fluttertoast.showToast(msg: 'Tidak ada koneksi internet');
      showNoConnectionBottomSheet(context: context, onRetry: () {});
      return;
    }

    try {
      final result = await DriverDataSource()
          .pingCustomer(widget.token, widget.pesanan.id.toString());

      if (result.success) {
        Fluttertoast.showToast(msg: 'Ping terkirim');
        _startCooldown();
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: result.error ?? 'Ping gagal terkirim');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  // ================== BUILD ==================
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Consumer3<DeliveryProvider, HistoryProvider, AuthProvider>(
      builder: (context, delivery, history, auth, _) {
        final pesanan = widget.pesanan;

        final bool hasDriver = pesanan.driverId != null;
        final bool isReady = pesanan.status == 'siap_diantar';
        final bool isDiantar = widget.status == DeliveryStatus.diantar &&
            pesanan.status == 'diantar';

        final bool showTakeButton = isReady || !hasDriver;

        final bool showPrioritySlider = (pesanan.status == 'pesanan_masuk' ||
                pesanan.status == 'pesanan_diproses') &&
            pesanan.isPriority == 1 &&
            hasDriver;

        final isThereNewChat = history.unreadMessagesList.contains(pesanan.id);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (hasDriver)
                ChatPingAction(
                  orderId: pesanan.id,
                  isCooldown: _isCooldown,
                  isThereNewChat: isThereNewChat,
                  onChat: () => _handleChat(history),
                  onPing: () => showBottomSheetPing(
                    context: context,
                    onFinish: _handlePing,
                  ),
                ),
              if (!hasDriver && widget.status == DeliveryStatus.siapDiantar)
                const Spacer(),
              if (showTakeButton)
                PrimaryActionButton(
                  screenSize: screenSize,
                  isLoading: delivery.isLoading,
                  text: _getPrimaryText(pesanan),
                  onPressed: () => _handlePrimaryAction(
                    delivery,
                    auth,
                  ),
                ),
              if (showPrioritySlider)
                Expanded(
                  child: PrioritySlider(
                    onConfirm: () => _handlePriority(delivery, auth),
                    status: pesanan.status,
                  ),
                ),
              if (isDiantar) ...[
                const Spacer(),
                FinishDeliveryButton(
                  screenSize: screenSize,
                  isLoading: delivery.isLoading,
                  onFinish: () => _showFinishBottomSheet(delivery, auth),
                ),
              ]
            ],
          ),
        );
      },
    );
  }

  String _getPrimaryText(Pesanan p) {
    if (widget.status == DeliveryStatus.siapDiantar) {
      return p.driverId == null ? 'Antar Pesanan' : 'Ambil';
    }
    return 'Selesai Diantar';
  }

  Future<void> _handlePrimaryAction(
      DeliveryProvider delivery, AuthProvider auth) async {
    if (delivery.isLoading) return;

    final result = await delivery.updateOrder(
      auth.user.id,
      widget.status == DeliveryStatus.siapDiantar ? 'diantar' : 'selesai',
      widget.token,
      widget.pesanan.id,
      widget.status,
      widget.pesanan,
    );

    Fluttertoast.showToast(
      msg: result.success
          ? 'Berhasil'
          : result.error ??
              'ORDER-${widget.pesanan.id} telah diambil driver lain',
    );

    if (result.success) widget.onSuccess();
  }

  void _handlePriority(DeliveryProvider delivery, AuthProvider auth) {
    delivery.updateOrder(
      auth.user.id,
      widget.pesanan.status == 'pesanan_masuk' ? 'pesanan_diproses' : 'diantar',
      widget.token,
      widget.pesanan.id,
      widget.status,
      widget.pesanan,
    );
  }

  void _showFinishBottomSheet(DeliveryProvider delivery, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return DeliveryBottomSheet(
          onLoading: delivery.isLoading,
          onImageSelected: (path) => deliveryImagePath = path,
          canSend: true,
          onFinish: () async {
            if (deliveryImagePath == null) {
              Fluttertoast.showToast(msg: 'Foto tidak boleh kosong');
              return;
            }

            final result = await delivery.updateOrder(
              auth.user.id,
              'selesai',
              widget.token,
              widget.pesanan.id,
              widget.status,
              widget.pesanan,
              buktiPath: deliveryImagePath,
            );

            Navigator.pop(context);

            Fluttertoast.showToast(
              msg: result.success
                  ? 'Pesanan selesai 🎉'
                  : result.error ?? 'Gagal',
            );
          },
        );
      },
    );
  }
}
