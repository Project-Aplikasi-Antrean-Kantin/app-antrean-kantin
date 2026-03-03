import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

Future showBottomSheetPenolakan(BuildContext context, Pesanan pesanan) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.whiteColor,
    builder: (context) => SafeArea(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 18,
              left: 18,
              right: 18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'Catatan Penolakan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.blackColor100,
                      width: 2,
                    ),
                  ),
                  height: 124,
                  child: TextField(
                    controller: TextEditingController(
                      text: pesanan.catatanPenolakan,
                    ),
                    readOnly: true,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan catatan...',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 8,
                      ),
                      border: InputBorder.none,
                    ),
                    expands: true,
                    maxLines: null,
                    minLines: null,
                  ),
                ),
                SizedBox(height: 40),
                PrimaryButton(
                  borderRadius: 16,
                  height: 48,
                  color: AppColors.primaryColor,
                  child: Text(
                    'Tutup',
                    style: GoogleFonts.poppins(
                      color: AppColors.whiteColor100,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
