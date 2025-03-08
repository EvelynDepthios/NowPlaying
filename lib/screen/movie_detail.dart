import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/movie.dart';
import '../services/services.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final APIservices _apiService = APIservices();
  String genreNames = "Loading...";
  bool isSaved = false; // Ganti dari isInWatchlist ke isSaved

  @override
  void initState() {
    super.initState();
    _loadGenres();
    _checkSavedStatus();
  }

  Future<void> _loadGenres() async {
    await _apiService.fetchGenres();
    setState(() {
      genreNames = _apiService.getGenreNames(widget.movie.genreIds);
    });
  }

  Future<void> _checkSavedStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedList = prefs.getStringList('watchlist') ?? [];

    setState(() {
      isSaved = savedList.contains(widget.movie.id.toString());
    });
  }

  Future<void> _toggleSaved() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedList = prefs.getStringList('watchlist') ?? [];

    setState(() {
      if (isSaved) {
        savedList.remove(widget.movie.id.toString());
      } else {
        savedList.add(widget.movie.id.toString());
      }
      isSaved = !isSaved;
    });

    await prefs.setStringList('watchlist', savedList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.movie.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold, 
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border, 
              color: isSaved ? Colors.yellow : Colors.grey, 
            ),
            onPressed: _toggleSaved,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              "https://image.tmdb.org/t/p/w500${widget.movie.backDropPath}",
              fit: BoxFit.cover,
              width: double.infinity,
              height: 250,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Genre Display
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children: widget.movie.genreIds.map((id) {
                      String genreName = APIservices.genreMap[id] ?? "Unknown";
                      Color genreColor = genreColors[genreName] ?? Colors.grey;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: genreColor.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          genreName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 10),
                  Text("Release Date: ${widget.movie.releaseDate}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        widget.movie.voteAverage.toString(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Text(
                    widget.movie.overview,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Map Warna untuk Genre
Map<String, Color> genreColors = {
  "Action": Colors.red,
  "Adventure": Colors.orange,
  "Animation": Colors.blue,
  "Comedy": Colors.yellow,
  "Crime": Colors.brown,
  "Documentary": Colors.grey,
  "Drama": Colors.purple,
  "Family": Colors.pink,
  "Fantasy": Colors.teal,
  "History": Colors.indigo,
  "Horror": Colors.black,
  "Music": Colors.green,
  "Mystery": Colors.deepPurple,
  "Romance": Colors.pinkAccent,
  "Science Fiction": Colors.cyan,
  "TV Movie": Colors.lightBlue,
  "Thriller": Colors.redAccent,
  "War": Colors.deepOrange,
  "Western": Colors.amber,
};