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
                "Pesanan masih kurang?",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textColorBlack,
                  fontWeight: semibold,
                  height: 1.5,
                ),
              ),
              Text(
                "Tambah menu lainnya disini",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textColorBlack,
                  fontWeight: regular,
                  height: 1.5,
                ),
              ),
            ],
          ),
          PrimaryButton(
            elevation: 0,
            color: AppColors.primaryColor,
            borderColor: AppColors.primaryColor,
            width: 25,
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
