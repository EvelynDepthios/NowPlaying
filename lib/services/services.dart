import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nowplaying/model/movie.dart';
import 'package:nowplaying/services/shared_prefs_service.dart';

const apiKey = "4de293b17f3059110541d94584b1727e";

class APIservices {
  final nowShowingApi =
      "https://api.themoviedb.org/3/movie/now_playing?api_key=$apiKey";
  final upComingApi =
      "https://api.themoviedb.org/3/movie/upcoming?api_key=$apiKey";
  final popularApi =
      "https://api.themoviedb.org/3/movie/popular?api_key=$apiKey";
  final genreApi =
      "https://api.themoviedb.org/3/genre/movie/list?api_key=$apiKey";

  final SharedPrefsService _prefsService = SharedPrefsService();


  // Map untuk menyimpan genre ID dan nama genre
  static Map<int, String> genreMap = {};

  // Ambil daftar genre dari TMDB API dan simpan ke genreMap
  Future<void> fetchGenres() async {
    Uri url = Uri.parse(genreApi);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> genres = json.decode(response.body)['genres'];
      genreMap = {
        for (var genre in genres) genre['id']: genre['name']
      };

      // Simpan daftar genre ke SharedPreferences
      await _prefsService.saveGenres(genreMap.values.toList());
    } else {
      throw Exception("Failed to load genres");
    }
  }


  // Fungsi untuk mendapatkan nama genre berdasarkan genre ID
  String getGenreNames(List<int> genreIds) {
    return genreIds.map((id) => genreMap[id] ?? "Unknown").join(", ");
  }

  // for nowShowing movies
  Future<List<Movie>> getNowShowing() async {
    Uri url = Uri.parse(nowShowingApi);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      List<Movie> movies = data.map((movie) => Movie.fromMap(movie)).toList();
      return movies;
    } else {
      throw Exception("Failed to load data");
    }
  }

  // for up coming movies
  Future<List<Movie>> getUpComing() async {
    Uri url = Uri.parse(upComingApi);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      List<Movie> movies = data.map((movie) => Movie.fromMap(movie)).toList();
      return movies;
    } else {
      throw Exception("Failed to load data");
    }
  }

  // for popular movies
  Future<List<Movie>> getPopular() async {
    Uri url = Uri.parse(popularApi);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      List<Movie> movies = data.map((movie) => Movie.fromMap(movie)).toList();
      return movies;
    } else {
      throw Exception("Failed to load data");
    }
  }
}