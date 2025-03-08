import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nowplaying/model/movie.dart';
import 'package:nowplaying/screen/movie_detail.dart';
import 'package:nowplaying/widget/appbar.dart';

const String apiKey = "4de293b17f3059110541d94584b1727e"; 

class AllMoviesScreen extends StatefulWidget {
  final bool startWithSearch;

  const AllMoviesScreen({super.key, this.startWithSearch = false});

  @override
  State<AllMoviesScreen> createState() => _AllMoviesScreenState();
}

class _AllMoviesScreenState extends State<AllMoviesScreen> {
  int currentPage = 1;
  List<Movie> _movies = [];
  bool isLoading = false;
  bool isSearching = false;
  TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchMovies();
    if (widget.startWithSearch) {
      isSearching = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        _searchFocus.requestFocus();
      });
    }
  }

  Future<void> _fetchMovies() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(
          "https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&page=$currentPage"));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['results'];
        setState(() {
          _movies = data.map((movie) => Movie.fromMap(movie)).toList();
        });
      } else {
        throw Exception("Failed to load movies");
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) {
      _fetchMovies();
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(
          "https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query"));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['results'];
        setState(() {
          _movies = data.map((movie) => Movie.fromMap(movie)).toList();
        });
      } else {
        throw Exception("Failed to search movies");
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _nextPage() {
    setState(() {
      currentPage++;
      _fetchMovies();
    });
  }

  void _previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        _fetchMovies();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                style: TextStyle(color: colorScheme.onPrimary),
                decoration: InputDecoration(
                  hintText: "Search movies...",
                  hintStyle: TextStyle(color: colorScheme.onPrimary.withOpacity(0.7)),
                  border: InputBorder.none,
                ),
                onChanged: (query) => _searchMovies(query),
              )
            : const Text("All Movies", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.clear : Icons.search, color: colorScheme.onPrimary),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  _searchController.clear();
                  _fetchMovies();
                }
                isSearching = !isSearching;
                if (isSearching) _searchFocus.requestFocus();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _movies.isEmpty
                    ? const Center(child: Text("No movies found", style: TextStyle(fontSize: 16)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: _movies.length,
                        itemBuilder: (context, index) {
                          final movie = _movies[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MovieDetailScreen(movie: movie),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://image.tmdb.org/t/p/w500${movie.backDropPath}",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                                        color: Colors.black.withOpacity(0.7),
                                      ),
                                      child: Text(
                                        movie.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          if (!isSearching) 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: currentPage > 1 ? _previousPage : null,
                    icon: const Icon(Icons.arrow_back_ios),
                    color: currentPage > 1 ? colorScheme.primary : Colors.grey, 
                  ),
                  Text(
                    "Page $currentPage",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: colorScheme.onSurface),
                  ),
                  IconButton(
                    onPressed: _nextPage,
                    icon: const Icon(Icons.arrow_forward_ios),
                    color: colorScheme.primary, 
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }
}