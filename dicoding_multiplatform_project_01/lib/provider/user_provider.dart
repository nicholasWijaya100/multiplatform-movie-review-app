import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  String originalTitle;
  String posterPath;
  bool adult;
  String releaseDate;
  String overview;
  double voteAverage;
  String backdropPath;
  List<dynamic> genreIds;

  Movie({
    required this.originalTitle,
    required this.posterPath,
    required this.adult,
    required this.releaseDate,
    required this.overview,
    required this.voteAverage,
    required this.backdropPath,
    required this.genreIds,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      originalTitle: json['original_title'],
      posterPath: json['poster_path'],
      adult: json['adult'],
      releaseDate: json['release_date'],
      overview: json['overview'],
      voteAverage: json['vote_average'].toDouble(),
      backdropPath: json['backdrop_path'],
      genreIds: json['genre_ids'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original_title': originalTitle,
      'poster_path': posterPath,
      'adult': adult,
      'release_date': releaseDate,
      'overview': overview,
      'vote_average': voteAverage,
      'backdrop_path': backdropPath,
      'genre_ids': genreIds,
    };
  }
}


class User {
  String name;
  String email;
  String password;
  List<Movie> favoriteMovies;

  User({
    required this.name,
    required this.email,
    required this.password,
    List<Movie>? favoriteMovies,
  }) : this.favoriteMovies = favoriteMovies ?? [];

  // Add this factory constructor
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String, // Replace with your actual field names
      email: json['email'] as String,
      password: json['password'] as String,
      // For the list of movies, you need to convert each item in the list
      favoriteMovies: json['favoriteMovies'] != null
          ? List<Movie>.from(
        json['favoriteMovies'].map((x) => Movie.fromJson(x)),
      )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    // Implement if needed for converting User object to Map<String, dynamic>
    return {
      'name': name,
      'email': email,
      'password': password,
      'favoriteMovies': favoriteMovies.map((x) => x.toJson()).toList(),
    };
  }
}


class UserProvider with ChangeNotifier {
  List<User> _users = [];
  User? _currentUser;

  // Function to fetch users from Firebase Firestore
  Future<void> fetchUsersFromFirebase() async {
    try {
      // Reference to the users collection in Firestore
      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

      // Fetch the snapshot of the users collection
      QuerySnapshot snapshot = await usersCollection.get();

      // Clear existing users
      _users.clear();

      // Convert each document to a User object and add to _users list
      for (var doc in snapshot.docs) {
        var userData = doc.data() as Map<String, dynamic>;
        _users.add(User.fromJson(userData));
      }

      notifyListeners();
    } catch (e) {
      // Handle any errors here
      print("Error fetching users: $e");
    }
  }

  // Convert Firebase User to App User
  User? _userFromFirebaseUser(firebase_auth.User? user) {
    if (user == null) return null;
    // Ensure that the `User` class here is the one defined in your application
    return User(
      name: user.displayName ?? '',
      email: user.email ?? '',
      password: '', // You might want to handle the password differently as it's not directly available from Firebase user
      favoriteMovies: [], // Handle favoriteMovies initialization if necessary
    );
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      firebase_auth.UserCredential userCredential = await firebase_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

      // Create a user object
      User newUser = User(
        name: name,
        email: email,
        password: password, // Consider not storing password here for security reasons
      );

      // Store user details in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(newUser.toJson());

      _currentUser = newUser;
      notifyListeners();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Handle Firebase Auth exceptions
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      firebase_auth.UserCredential userCredential = await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      // Query Firestore for user document with matching email
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance.collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userQuerySnapshot.docs.first;
        _currentUser = User.fromJson(userDoc.data() as Map<String, dynamic>);
      } else {
        // Handle the case where no user data is found in Firestore
        return false;
      }

      notifyListeners();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      return false;
    }
  }

  String? getCurrentUserEmail() {
    return _currentUser?.email;
  }

  String? getCurrentUserName() {
    return _currentUser?.name;
  }

  User? getCurrentUser() {
    return _currentUser;
  }

  String? getCurrentPassword() {
    return _currentUser?.password;
  }

  Future<void> addMovieToFavorites(Movie movie) async {
    if (_currentUser == null) return;

    _currentUser!.favoriteMovies.add(movie);

    // Update the favorite movies in Firestore
    var userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: _currentUser!.email)
        .get();
    if (userQuery.docs.isNotEmpty) {
      var userDoc = userQuery.docs.first;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userDoc.id)
          .update({
        'favoriteMovies': FieldValue.arrayUnion([movie.toJson()]),
      });
    }
    notifyListeners();
  }

  Future<void> removeMovieFromFavorites(String movieTitle) async {
    if (_currentUser == null) return;

    int movieIndex = _currentUser!.favoriteMovies.indexWhere((movie) => movie.originalTitle == movieTitle);

    if (movieIndex != -1) {
      Movie movieToRemove = _currentUser!.favoriteMovies[movieIndex];
      _currentUser!.favoriteMovies.removeAt(movieIndex);

      // Query for the user document by email
      var userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _currentUser!.email)
          .get();

      // Check if the user document exists
      if (userQuery.docs.isNotEmpty) {
        var userDoc = userQuery.docs.first;

        // Update Firestore document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.id)
            .update({
          'favoriteMovies': FieldValue.arrayRemove([movieToRemove.toJson()]),
        });
      }

      notifyListeners();
    }
  }

  bool isMovieFavorite(String movieTitle) {
    return _currentUser?.favoriteMovies.any((movie) => movie.originalTitle == movieTitle) ?? false;
  }

  List<Movie> getCurrentUserFavoriteMovies() {
    if (_currentUser != null) {
      return _currentUser!.favoriteMovies;
    } else {
      return []; // Return an empty list if there's no current user
    }
  }

  bool updateUser(String newName, String newEmail, String newPassword) {
    if (_currentUser == null) {
      return false; // No current user to update
    }

    // Check if the new email is already in use by another user
    if (_users.any((user) => user.email == newEmail && user.email != _currentUser!.email)) {
      return false; // Email already in use
    }

    // Find the index of the current user in the _users list
    int userIndex = _users.indexWhere((user) => user.email == _currentUser!.email);

    // Check if userIndex is valid
    if (userIndex != -1) {
      // Update the user's details
      _users[userIndex].name = newName;
      _users[userIndex].email = newEmail;
      _users[userIndex].password = newPassword;

      // Update the current user reference
      _currentUser = _users[userIndex];
      notifyListeners();
      return true; // Update successful
    }

    return false; // Update failed
  }

}