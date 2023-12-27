import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';

class MovieDetailPage extends StatelessWidget {
  final dynamic movie;
  const MovieDetailPage({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    UserProvider userProvider = Provider.of<UserProvider>(context);

    Movie movieObject = Movie.fromJson(movie);
    bool isFavorite = userProvider.isMovieFavorite(movieObject.originalTitle);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Image.network(
                      'https://image.tmdb.org/t/p/w500${movie["backdrop_path"]}',
                      fit: BoxFit.cover,
                      height: 300,
                      width: double.infinity,
                    ),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        movie["original_title"],
                        style: textTheme.headline4?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RatingBarIndicator(
                              rating: movie["vote_average"] / 2,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 25.0,
                              direction: Axis.horizontal,
                            ),
                            IconButton(
                              icon: isFavorite
                                  ? const Icon(Icons.favorite, color: Colors.red)
                                  : const Icon(Icons.favorite_border, color: Colors.grey),
                              onPressed: () {
                                if (isFavorite) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${movie["original_title"]} removed from favorites')),
                                  );
                                  userProvider.removeMovieFromFavorites(movieObject.originalTitle);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${movie["original_title"]} added to favorites')),
                                  );
                                  userProvider.addMovieToFavorites(movieObject);
                                }
                                // This will cause the widget to rebuild and show the new favorite status.
                                userProvider.notifyListeners();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Release Date : ${movie["release_date"]}', style: textTheme.titleMedium),
                        movie["adult"] == true
                            ? Text('Minimum Age: 18+', style: textTheme.titleMedium)
                            : Text('Minimum Age: 13+', style: textTheme.titleMedium),
                        const SizedBox(height: 16),
                        Text('Overview', style: textTheme.headline6),
                        const SizedBox(height: 8),
                        Text(
                          movie["overview"],
                          style: textTheme.bodyText2?.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipOval(
                child: Material(
                  color: Colors.black.withOpacity(0.5),
                  child: InkWell(
                    splashColor: Colors.white.withOpacity(0.2),
                    onTap: () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
