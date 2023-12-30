import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Update addReview to create and add a Review object and save it to Firestore
  Future<void> addReview(String movieTitle, String username, String date, String comment) async {
    final review = Review(
        movieTitle: movieTitle,
        username: username,
        date: date,
        comment: comment
    );

    // Add the review to Firestore
    await _firestore.collection('reviews').add({
      'movieTitle': movieTitle,
      'username': username,
      'date': date,
      'comment': comment
    });

    _reviews.add(review);
    notifyListeners();
  }

  Future<bool> hasUserReviewed(String movieTitle, String userName) async {
    try {
      // Query Firestore for reviews matching the movieTitle and userName
      final querySnapshot = await _firestore.collection('reviews')
          .where('movieTitle', isEqualTo: movieTitle)
          .where('username', isEqualTo: userName)
          .limit(1)
          .get();

      // Return true if such a review exists, otherwise false
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // Handle or log the error as needed
      print('Error checking review: $e');
      return false;
    }
  }

  // Update getReviews to fetch reviews from Firestore
  Future<List<Review>> getReviews(String movieTitle) async {
    List<Review> fetchedReviews = [];

    try {
      // Query Firestore for reviews matching the movieTitle
      final querySnapshot = await _firestore.collection('reviews')
          .where('movieTitle', isEqualTo: movieTitle)
          .get();

      // Convert each document to a Review object and add to the list
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        fetchedReviews.add(Review(
            movieTitle: data['movieTitle'],
            username: data['username'],
            date: data['date'],
            comment: data['comment']
        ));
      }
    } catch (e) {
      // Handle or log the error as needed
      print('Error fetching reviews: $e');
    }

    return fetchedReviews;
  }
}
