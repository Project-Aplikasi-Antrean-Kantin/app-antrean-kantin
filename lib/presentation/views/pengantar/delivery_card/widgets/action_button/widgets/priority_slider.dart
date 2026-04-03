import 'package:flutter/material.dart';
import 'package:testgetdata/presentation/widgets/slide_to_confirm.dart';

class PrioritySlider extends StatelessWidget {
  final VoidCallback onConfirm;
  final String status;

  const PrioritySlider({
    required this.onConfirm,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return SlideToConfirm(
      onConfirmed: onConfirm,
      placeholder:
          status == 'pesanan_masuk' ? 'Pesanan Diproses' : 'Ubah ke Antar',
    );
  }
}
