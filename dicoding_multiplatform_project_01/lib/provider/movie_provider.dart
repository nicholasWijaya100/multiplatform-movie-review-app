import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MovieProvider with ChangeNotifier {
  List<dynamic> _movies = [];

  List<dynamic> get movies => _movies;

  Future<void> fetchMovies() async {
    const url = 'https://api.themoviedb.org/3/movie/popular?api_key=c134d59a441925eab703b8f8aab26c39';
    final response = await http.get(Uri.parse(url));
    final json = jsonDecode(response.body);
    _movies = json['results'];
    notifyListeners();
  }
}
