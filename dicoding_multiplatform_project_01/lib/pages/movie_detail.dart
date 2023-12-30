import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../provider/review_provider.dart';
import '../provider/user_provider.dart';

class MovieDetailPage extends StatelessWidget {
  final dynamic movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    ReviewProvider reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    final userName = userProvider.getCurrentUserName();
    final isUserLoggedIn = userName != null;

    Movie movieObject = Movie.fromJson(movie);
    final TextEditingController reviewController = TextEditingController();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Movie image and other UI elements
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
                    child: FutureBuilder<bool>(
                      future: isUserLoggedIn ? reviewProvider.hasUserReviewed(movieObject.originalTitle, userName) : Future.value(false),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        bool hasReviewed = snapshot.data ?? false;
                        return buildReviewSection(context, textTheme, movieObject, hasReviewed, reviewController, reviewProvider, userProvider);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Back button
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

  Widget buildReviewSection(BuildContext context, TextTheme textTheme, Movie movieObject, bool hasReviewed, TextEditingController reviewController, ReviewProvider reviewProvider, UserProvider userProvider) {
    bool isFavorite = userProvider.isMovieFavorite(movieObject.originalTitle);

    return Column(
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
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Reviews', style: textTheme.headline6),
            if (!hasReviewed)
              ElevatedButton(
                onPressed: () {
                  String? currentUserName = userProvider.getCurrentUserName();
                  if (currentUserName != null) {
                    showAddReviewDialog(context, movieObject, reviewController, reviewProvider, currentUserName);
                  } else {
                    // Handle the case where the user is not logged in or the userName is not available
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('You need to be logged in to add a review.')),
                    );
                  }
                },
                child: const Text('Add A Review'),
              ),
          ],
        ),
        FutureBuilder<List<Review>>(
          future: reviewProvider.getReviews(movieObject.originalTitle),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            List<Review> reviews = snapshot.data ?? [];

            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                var review = reviews[index];
                return Card(
                  child: ListTile(
                    title: Text(review.username),
                    subtitle: Text(review.comment),
                    trailing: Text(review.date),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void showAddReviewDialog(BuildContext context, Movie movieObject, TextEditingController reviewController, ReviewProvider reviewProvider, String userName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Comment'),
          content: TextField(
            controller: reviewController,
            decoration: const InputDecoration(hintText: "Enter your comment here"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                final comment = reviewController.text;
                if (comment.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fill in your comments first!')),
                  );
                  return;
                }

                DateTime now = DateTime.now();
                await reviewProvider.addReview(movieObject.originalTitle, userName, DateFormat('yyyy-MM-dd').format(now), comment);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Comment added.')),
                );
                Navigator.of(context).pop();
                reviewController.clear();
              },
            ),
          ],
        );
      },
    );
  }
}
