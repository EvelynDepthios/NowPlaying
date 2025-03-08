import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  bool isSaved = false;
  List<String> genreNames = [];
  bool isFetchingGenres = false;

  @override
  void initState() {
    super.initState();
    _checkSavedStatus();
    _loadGenres();
  }

  Future<void> _checkSavedStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedList = prefs.getStringList('watchlist') ?? [];

    setState(() {
      isSaved = savedList.contains(widget.movie.id.toString());
    });
  }

  Future<void> _loadGenres() async {
    if (widget.movie.genreIds.isNotEmpty) {
      // Jika genre sudah ada, langsung gunakan
      setState(() {
        genreNames = widget.movie.genreIds
            .map((id) => APIservices.genreMap[id] ?? "Unknown")
            .toList();
      });
    } else {
      // Jika genre kosong, fetch dari API
      await _fetchMovieGenres();
    }
  }

  Future<void> _fetchMovieGenres() async {
    setState(() => isFetchingGenres = true);

    final response = await http.get(Uri.parse(
        "https://api.themoviedb.org/3/movie/${widget.movie.id}?api_key=4de293b17f3059110541d94584b1727e"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> genres = data['genres'];

      setState(() {
        genreNames = genres.map((g) => g['name'] as String).toList();
        isFetchingGenres = false;
      });
    } else {
      setState(() => isFetchingGenres = false);
    }
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.movie.title,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: colorScheme.onPrimary),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **Movie Image & Bookmark Button**
            Stack(
              children: [
                Image.network(
                  "https://image.tmdb.org/t/p/w500${widget.movie.backDropPath}",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300,
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: _toggleSaved,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.6),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved ? Colors.yellow : Colors.white,
                          key: ValueKey(isSaved),
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Text(
                      widget.movie.title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // **Genre Chips**
                  if (isFetchingGenres)
                    const Center(child: CircularProgressIndicator())
                  else if (genreNames.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: genreNames.map((genre) {
                        Color genreColor = genreColors[genre] ?? Colors.grey;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: genreColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            genre,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 16),

                  // **Movie Details**
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Release Date: ${widget.movie.releaseDate}",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.star, size: 22, color: Colors.yellow),
                      const SizedBox(width: 5),
                      Text(
                        "${widget.movie.voteAverage} / 10",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // **Movie Overview**
                  const Text(
                    "Overview",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.movie.overview,
                    style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurface.withOpacity(0.7)),
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

// **Map Warna untuk Genre**
Map<String, Color> genreColors = {
  "Action": const Color(0xFFD32F2F),
  "Adventure": const Color(0xFFFF9800),
  "Animation": const Color(0xFF64B5F6),
  "Comedy": const Color.fromARGB(255, 206, 185, 0),
  "Crime": const Color(0xFF795548),
  "Documentary": const Color.fromARGB(255, 76, 107, 122),
  "Drama": const Color(0xFFBA68C8),
  "Family": const Color(0xFFFF80AB),
  "Fantasy": const Color(0xFF4DB6AC),
  "History": const Color(0xFF7986CB),
  "Horror": const Color(0xFFB71C1C),
  "Music": const Color(0xFF81C784),
  "Mystery": const Color(0xFF9575CD),
  "Romance": const Color(0xFFF06292),
  "Science Fiction": const Color(0xFF4DD0E1),
  "TV Movie": const Color(0xFF42A5F5),
  "Thriller": const Color(0xFFFF5252),
  "War": const Color(0xFFFF7043),
  "Western": const Color(0xFFFFA726),
};
