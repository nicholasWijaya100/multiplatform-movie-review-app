import 'package:flutter/material.dart';

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
}


class UserProvider with ChangeNotifier {
  List<User> _users = [];
  User? _currentUser;

  bool register(String name, String email, String password) {
    if (_users.any((user) => user.email == email)) {
      return false; // Pengguna sudah ada
    } else {
      _users.add(User(name: name, email: email, password: password));
      notifyListeners();
      return true; // Pendaftaran berhasil
    }
  }

  bool login(String email, String password) {
    _currentUser = _users.firstWhere(
          (user) => user.email == email && user.password == password,
    );

    if (_currentUser != null) {
      notifyListeners();
      return true; // Login successful
    }
    return false; // Login failed
  }

  String? getCurrentUserEmail() {
    return _currentUser?.email;
  }

  String? getCurrentUserName() {
    return _currentUser?.name;
  }

  String? getCurrentPassword() {
    return _currentUser?.password;
  }

// Example: Adding a movie to favorites
  void addMovieToFavorites(Movie movie) {
    // Find the index of the current user in the _users list
    int userIndex = _users.indexWhere((user) => user.email == _currentUser!.email);

    // Check if userIndex is valid
    if (userIndex != -1) {
      _users[userIndex].favoriteMovies.add(movie);
    }

    notifyListeners();
  }

  void removeMovieFromFavorites(String movieTitle) {
    if (_currentUser == null) return;

    // Find the index of the movie in the current user's favoriteMovies list
    int movieIndex = _currentUser!.favoriteMovies.indexWhere((movie) => movie.originalTitle == movieTitle);

    // Check if the movie is found
    if (movieIndex != -1) {
      // Find the index of the current user in the _users list
      int userIndex = _users.indexWhere((user) => user.email == _currentUser!.email);

      // Check if userIndex is valid
      if (userIndex != -1) {
        // Remove the movie from the user in the _users list
        _users[userIndex].favoriteMovies.removeAt(movieIndex);
      }

      notifyListeners();
    }
  }

// Example: Checking if a movie is in favorites
  bool isMovieFavorite(String movieTitle) {
    return _currentUser?.favoriteMovies.any((movie) => movie.originalTitle == movieTitle) ?? false;
  }
  // Function to get the current user's favorite movies
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