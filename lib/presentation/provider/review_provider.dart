import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testgetdata/data/model/review_selection.dart';
import 'package:testgetdata/data/remote/public_remote_data_source.dart';

class ReviewProvider extends ChangeNotifier {
  int selectedRating = 7;
  List<ReviewSelection> reviewSelection = [];
  List<ReviewSelection> selectedReviewSelection = [];
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

  Future<void> submitReview(String token, String description) async {
    final List<int> ratingMoods =
        selectedReviewSelection.map((e) => e.id).toList();
    isSubmitting = true;
    notifyListeners();

    try {
      final response = await PublicRemoteDataSource().submitReview(
        token,
        selectedRating,
        description,
        ratingMoods,
      );
      Fluttertoast.showToast(msg: response);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_review', false);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isSubmitting = false;
    }
    notifyListeners();
  }

  Future<void> setReviewSelection(String token) async {
    try {
      final List<ReviewSelection> reviewSelection =
          await PublicRemoteDataSource().getReviewSelection(token);
      this.reviewSelection = reviewSelection;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    notifyListeners();
  }
}
