class Movie {
  final String title;
  final String backDropPath;
  final String overview;
  final double popularity;
  final double voteAverage;
  final int voteCount;
  final String releaseDate;
  final List<int> genreIds; 
  final String id;

  Movie({
    required this.title,
    required this.backDropPath,
    required this.overview,
    required this.popularity,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    required this.genreIds,
    required this.id,
  });

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      title: map['title'],
      backDropPath: map['backdrop_path'],
      overview: map['overview'],
      popularity: map['popularity'],
      voteAverage: map['vote_average'],
      voteCount: map['vote_count'],
      releaseDate: map['release_date'],
      genreIds: List<int>.from(map['genre_ids'] ?? []),
      id: map['id'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'backDropPath': backDropPath,
      'overview': overview,
      'popularity': popularity,
      'voteAverage': voteAverage,
      'voteCount': voteCount,
      'releaseDate': releaseDate,
      'genreIds': genreIds,
      'id': id,
    };
  }
}