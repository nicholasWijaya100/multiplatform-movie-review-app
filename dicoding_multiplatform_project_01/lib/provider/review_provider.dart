import 'package:flutter/material.dart';

class Review {
  String movieTitle;
  String username;
  String date;
  String comment;

  Review({
    required this.movieTitle,
    required this.username,
    required this.date,
    required this.comment
  });
}

class ReviewProvider with ChangeNotifier {
  // Change the structure to a simple list since each review now contains the movie title
  List<Review> _reviews = [];

  // Update addReview to create and add a Review object
  void addReview(String movieTitle, String username, String date, String comment) {
    final review = Review(
        movieTitle: movieTitle,
        username: username,
        date: date,
        comment: comment
    );

    _reviews.add(review);

    notifyListeners();
  }

  bool hasUserReviewed(String movieTitle, String userName) {
    // Search through the list of reviews for a match on both movieTitle and username
    return _reviews.any((review) => review.movieTitle == movieTitle && review.username == userName);
  }

  // Update getReviews to filter reviews by movie title
  List<Review> getReviews(String movieTitle) {
    return _reviews.where((review) => review.movieTitle == movieTitle).toList();
  }
}
