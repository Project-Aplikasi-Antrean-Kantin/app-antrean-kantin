import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:testgetdata/data/model/review_selection.dart';
import 'package:testgetdata/data/remote/public_remote_data_source.dart';

class ReviewProvider extends ChangeNotifier {
  int selectedRating = 7;
  List<ReviewSelection> reviewSelection = [];
  List<ReviewSelection> reviewSelectionTop = [];
  List<ReviewSelection> reviewSelectionBottom = [];
  List<ReviewSelection> selectedTop = [];
  ReviewSelection? selectedBottom;
  bool isSubmitting = false;

  void selectRating(int rating) {
    selectedRating = rating;
    notifyListeners();
  }

  void selectReviewSelection(ReviewSelection item) {
    // cek apakah item dari TOP
    if (reviewSelectionTop.contains(item)) {
      if (selectedTop.contains(item)) {
        selectedTop.remove(item);
      } else {
        selectedTop.add(item);
      }
    }
    // kalau dari BOTTOM (single select)
    else if (reviewSelectionBottom.contains(item)) {
      if (selectedBottom == item) {
        selectedBottom = null; // toggle off
      } else {
        selectedBottom = item; // replace
      }
    }

    notifyListeners();
  }

  Future<void> submitReview(String token, String description) async {
    final List<int> ratingMoods = [
      ...selectedTop.map((e) => e.id),
      if (selectedBottom != null) selectedBottom!.id,
    ];
    isSubmitting = true;
    notifyListeners();

    try {
      final response = await PublicRemoteDataSource().submitReview(
        token,
        selectedRating,
        description,
        ratingMoods,
      );
      selectedTop = [];
      selectedBottom = null;
      Fluttertoast.showToast(msg: response);
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

      if (reviewSelection.length >= 3) {
        reviewSelectionTop = reviewSelection.sublist(0, 3);
        reviewSelectionBottom = reviewSelection.sublist(3);
      } else {
        // kalau datanya kurang dari 3
        reviewSelectionTop = reviewSelection;
        reviewSelectionBottom = [];
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    notifyListeners();
  }
}
