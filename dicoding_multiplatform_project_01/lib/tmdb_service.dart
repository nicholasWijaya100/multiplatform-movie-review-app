import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie.dart'; // Import your Movie model

class TMDBService {
  final String apiKey = 'YOUR_API_KEY';
  final String baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> fetchMovies() async {
    final response = await http.get(Uri.parse('$baseUrl/movie/popular?api_key=$apiKey'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data['results']);
      List<Movie> movies = (data['results'] as List).map((movie) => Movie.fromJson(movie)).toList();
      return movies;
    } else {
      throw Exception('Failed to load movies');
    }
  }
}
