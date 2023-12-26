import 'package:flutter/material.dart';

class ReviewProvider with ChangeNotifier {
  Map<String, List<Map<String, String>>> _reviews = {};

  void addReview(String movieTitle, String username, String comment) {
    if (!_reviews.containsKey(movieTitle)) {
      _reviews[movieTitle] = [];
    }

    _reviews[movieTitle]?.add({
      'username': username,
      'comment': comment,
    });

    notifyListeners();
  }

  List<Map<String, String>> getReviews(String movieTitle) {
    return _reviews[movieTitle] ?? [];
  }
}
