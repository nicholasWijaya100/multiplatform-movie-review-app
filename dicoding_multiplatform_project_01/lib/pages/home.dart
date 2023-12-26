import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/movie_provider.dart';
import 'movie_detail.dart';

Map<int, String> genreMap = {
  28: "Action",
  12: "Adventure",
  16: "Animation",
  35: "Comedy",
  80: "Crime",
  99: "Documentary",
  18: "Drama",
  10751: "Family",
  14: "Fantasy",
  36: "History",
  27: "Horror",
  10402: "Music",
  9648: "Mystery",
  10749: "Romance",
  878: "Science Fiction",
  10770: "TV Movie",
  53: "Thriller",
  10752: "War",
  37: "Western",
};

String getGenreNames(List<dynamic> genreIds, Map<int, String> genreMap) {
  return genreIds.map((id) => genreMap[id] ?? "Unknown").join(', ');
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<MovieProvider>(context, listen: false).fetchMovies();

    int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 5 : 2;

    return Scaffold(
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, _) {
          if (movieProvider.movies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.5,
              ),
              itemCount: movieProvider.movies.length,
              itemBuilder: (BuildContext context, int index) {
                final movie = movieProvider.movies[index];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MovieDetailPage(movie: movie),
                      ),
                    );                  },
                  child: Card(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w500${movie["poster_path"]}',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie["original_title"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              Text(getGenreNames(movie["genre_ids"], genreMap)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
