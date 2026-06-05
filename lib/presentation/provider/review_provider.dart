import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testgetdata/data/model/review_selection.dart';
import 'package:testgetdata/data/remote/public_remote_data_source.dart';
import 'package:testgetdata/presentation/widgets/molecules/custom_snackbar.dart';

class ReviewProvider extends ChangeNotifier {
  int selectedRating = 7;
  List<ReviewSelection> reviewSelection = [];
  List<ReviewSelection> selectedReviewSelection = [];
  ReviewSelection? selectedDemographyReviewSelection;
  List<ReviewSelection> optionReviewSelection = [];
  List<ReviewSelection> demographyReviewSelection = [];
  bool isSubmitting = false;

  void selectRating(int rating) {
    selectedRating = rating;
    notifyListeners();
  }

  void selectReviewSelection(ReviewSelection reviewSelection) {
    if (selectedReviewSelection.contains(reviewSelection)) {
      selectedReviewSelection.remove(reviewSelection);
    } else {
      selectedReviewSelection.add(reviewSelection);
    }
    notifyListeners();
  }

  void selectDemographyReviewSelection(ReviewSelection reviewSelection) {
    selectedDemographyReviewSelection = reviewSelection;
    notifyListeners();
  }

  Future<void> submitReview(String token, String description) async {
    final List<int> ratingMoods =
        selectedReviewSelection.map((e) => e.id).toList();

    final ratings = [...ratingMoods, selectedDemographyReviewSelection!.id];
    isSubmitting = true;
    notifyListeners();

    try {
      final response = await PublicRemoteDataSource().submitReview(
        token,
        selectedRating,
        description,
        ratings,
      );
      CustomSnackbar.success(response);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_review', false);
    } catch (e) {
      CustomSnackbar.error(e.toString());
    } finally {
      isSubmitting = false;
    }
    notifyListeners();
  }

  Future<void> setReviewSelection(String token) async {
    try {
      final List<ReviewSelection> result =
          await PublicRemoteDataSource().getReviewSelection(token);
      this.reviewSelection = result;
      optionReviewSelection = result.sublist(
        0,
        result.length - 3,
      );
      demographyReviewSelection = result.sublist(
        result.length - 3,
        result.length,
      );
    } catch (e) {
      CustomSnackbar.error(e.toString());
    }
    notifyListeners();
  }
}
