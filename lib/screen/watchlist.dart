import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/movie.dart';
import 'movie_detail.dart';
import '../widget/appbar.dart';

class WatchListScreen extends StatefulWidget {
  const WatchListScreen({super.key});

  @override
  State<WatchListScreen> createState() => _WatchListScreenState();
}

class _WatchListScreenState extends State<WatchListScreen> {
  List<Movie> _watchlistMovies = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWatchlistMovies();
  }

  Future<void> _fetchWatchlistMovies() async {
    setState(() => isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> watchlist = prefs.getStringList('watchlist') ?? [];

    List<Movie> fetchedMovies = [];
    for (String id in watchlist) {
      final response = await http.get(Uri.parse(
          "https://api.themoviedb.org/3/movie/$id?api_key=4de293b17f3059110541d94584b1727e"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        fetchedMovies.add(Movie.fromMap(data));
      }
    }

    setState(() {
      _watchlistMovies = fetchedMovies;
      isLoading = false;
    });
  }

  Future<void> _removeFromWatchlist(String movieId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> watchlist = prefs.getStringList('watchlist') ?? [];

    setState(() {
      watchlist.remove(movieId);
      _watchlistMovies.removeWhere((movie) => movie.id.toString() == movieId);
    });

    await prefs.setStringList('watchlist', watchlist);
  }

  void _confirmDelete(Movie movie) {
    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: const Text(
            "Remove from Watchlist",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text("Are you sure you want to remove '${movie.title}' from your watchlist?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: colorScheme.onSurface)),
            ),
            TextButton(
              onPressed: () {
                _removeFromWatchlist(movie.id.toString());
                Navigator.pop(context);
              },
              child: const Text("Remove", style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text("Watchlist", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _watchlistMovies.isEmpty
              ? const Center(
                  child: Text(
                    "No movies in watchlist",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _watchlistMovies.length,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  itemBuilder: (context, index) {
                    final movie = _watchlistMovies[index];
                    return Card(
                      color: colorScheme.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            "https://image.tmdb.org/t/p/w200${movie.backDropPath}",
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          movie.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          "Release Date: ${movie.releaseDate}",
                          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(movie),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailScreen(movie: movie),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 2),
    );
  }
}