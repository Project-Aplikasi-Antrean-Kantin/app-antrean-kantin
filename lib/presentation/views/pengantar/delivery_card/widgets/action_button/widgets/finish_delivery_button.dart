import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

class FinishDeliveryButton extends StatelessWidget {
  final Size screenSize;
  final bool isLoading;
  final VoidCallback onFinish;

  const FinishDeliveryButton({
    required this.screenSize,
    required this.isLoading,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      isLoading: isLoading,
      width: screenSize.width * 0.3,
      height: screenSize.height * 0.065,
      borderRadius: 20,
      onPressed: onFinish,
      child: Text(
        'Selesai Diantar',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
