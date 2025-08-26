import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

class AddMoreItemsButton extends StatelessWidget {
  const AddMoreItemsButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mau tambah",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.blackColor,
                ),
              ),
              Text(
                "Pesanan?",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.blackColor,
                  fontWeight: regular,
                ),
              ),
            ],
          ),
          PrimaryButton(
            borderRadius: 16,
            elevation: 0,
            color: AppColors.primaryColor,
            borderColor: AppColors.primaryColor,
            width: 128,
            height: 50,
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Tambah',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textColorwhite,
                fontWeight: semibold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
