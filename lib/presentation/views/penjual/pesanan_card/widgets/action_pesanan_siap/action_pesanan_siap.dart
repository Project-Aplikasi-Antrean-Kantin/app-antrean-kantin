import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_card/widgets/action_pesanan_siap/widgets/chat_button.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_card/widgets/action_pesanan_siap/widgets/outline_chat_button.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_card/widgets/action_pesanan_siap/widgets/selesai_button.dart';

class ActionPesananSiap extends StatefulWidget {
  final Pesanan pesanan;
  final List<Pesanan> listPesanan;
  const ActionPesananSiap(
      {super.key, required this.pesanan, required this.listPesanan});

  @override
  State<ActionPesananSiap> createState() => _ActionPesananSiapState();
}

class _ActionPesananSiapState extends State<ActionPesananSiap> {
  @override
  Widget build(BuildContext context) {
    return widget.pesanan.isAntar != 1
        ? Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ChatButton(pesanan: widget.pesanan),
              SelesaiButton(
                  pesanan: widget.pesanan, listPesanan: widget.listPesanan),
            ],
          )
        : widget.pesanan.status == 'siap_diantar' &&
                widget.pesanan.driverId == null
            ? OutlineChatButton(pesanan: widget.pesanan)
            : SizedBox.shrink();
  }
}
