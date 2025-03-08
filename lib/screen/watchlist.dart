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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Watchlist", style: TextStyle(fontWeight: FontWeight.bold))),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _watchlistMovies.isEmpty
              ? const Center(child: Text("No movies in watchlist"))
              : ListView.builder(
                  itemCount: _watchlistMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _watchlistMovies[index];
                    return ListTile(
                      leading: Image.network(
                        "https://image.tmdb.org/t/p/w200${movie.backDropPath}",
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        movie.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, // Membuat teks menjadi bold
                        ),
                      ),
                      subtitle: Text("Release Date: ${movie.releaseDate}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeFromWatchlist(movie.id.toString()),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieDetailScreen(movie: movie),
                          ),
                        );
                      },
                    );
                  },
                ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 2),
    );
  }
}