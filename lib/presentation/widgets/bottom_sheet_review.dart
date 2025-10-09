import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/review_provider.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

void showBottomSheetReview({
  required BuildContext context,
  required UserModel user,
}) {
  final screenSize = MediaQuery.of(context).size;
  final isSmallScreen = screenSize.height < 600;
  final _textController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: false,
    builder: (context) {
      return AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.decelerate,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
            decoration: const BoxDecoration(
              color: AppColors.whiteColor100,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              // ini penting biar bisa scroll waktu keyboard muncul
              child: Consumer<ReviewProvider>(
                builder: (context, reviewProvider, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // === semua isi kamu di sini ===
                      Text(
                        'Seberapa besar kemungkinan merekomendasikan FoodLAB ke orang lain?',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        spacing: 5,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ...List.generate(10, (index) {
                            return GestureDetector(
                              onTap: () {
                                reviewProvider.selectRating(index + 1);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(9.5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: reviewProvider.selectedRating ==
                                            index + 1
                                        ? getSelectedColor(index + 1)
                                        : AppColors.blackColor100,
                                  ),
                                  shape: BoxShape.circle,
                                  color:
                                      reviewProvider.selectedRating == index + 1
                                          ? getSelectedColor(index + 1)
                                          : AppColors.whiteColor100,
                                ),
                                child: Text("${index + 1}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: reviewProvider.selectedRating ==
                                              index + 1
                                          ? Colors.white
                                          : AppColors.textColorBlack,
                                    )),
                              ),
                            );
                          })
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Sangat Tidak Mungkin",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.errorColor,
                              )),
                          Text("Sangat Mungkin",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.successColor,
                              ))
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text('Apa yang baik dari Aplikasi FoodLAB?'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          reviewProvider.reviewSelection.length,
                          (index) {
                            final item = reviewProvider.reviewSelection[index];
                            return GestureDetector(
                              onTap: () {
                                reviewProvider.selectReviewSelection(item);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: reviewProvider
                                            .selectedReviewSelection
                                            .contains(item)
                                        ? AppColors.primaryColor
                                        : AppColors.blackColor100,
                                    width: 1,
                                  ),
                                  color: reviewProvider.selectedReviewSelection
                                          .contains(item)
                                      ? AppColors.primaryColor
                                      : AppColors.whiteColor100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${item.name}',
                                  style: GoogleFonts.poppins(
                                    color: reviewProvider
                                            .selectedReviewSelection
                                            .contains(item)
                                        ? Colors.white
                                        : AppColors.blackColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (reviewProvider.selectedReviewSelection.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primaryColor,
                              width: 1.5,
                            ),
                          ),
                          height: 124,
                          child: TextField(
                            controller: _textController,
                            decoration: const InputDecoration(
                              hintStyle: TextStyle(fontSize: 14),
                              hintText:
                                  'Mengapa aplikasi FoodLAB dirasa baik dalam beberapa aspek?',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              border: InputBorder.none,
                              counter: SizedBox.shrink(),
                            ),
                            maxLines: null,
                            maxLength: 200,
                          ),
                        ),
                      const SizedBox(height: 8),

                      PrimaryButton(
                        borderRadius: 16,
                        waitingText:
                            reviewProvider.selectedReviewSelection.isEmpty
                                ? "Pilih minimal satu"
                                : null,
                        isLoading: reviewProvider.isSubmitting,
                        isEnabled:
                            reviewProvider.selectedReviewSelection.isNotEmpty &&
                                !reviewProvider.isSubmitting,
                        child: Text("Kirim",
                            style: GoogleFonts.poppins(color: Colors.white)),
                        onPressed: () async {
                          try {
                            await reviewProvider.submitReview(
                                user.token, _textController.text);
                            Navigator.of(context).pop();
                          } catch (e) {}
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}

Color getSelectedColor(int value) {
  if (value <= 3) {
    return AppColors.errorColor;
  }
  if (value <= 7) {
    return AppColors.warningColor;
  }
  if (value <= 10) {
    return AppColors.successColor;
  } else {
    return AppColors.primaryColor;
  }
}
