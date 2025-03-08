import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String keyFullName = 'full_name';
  static const String keyNickname = 'nickname';
  static const String keyHobbies = 'hobbies';
  static const String keyProfileImage = 'profile_image';
  static const String keySocialMedia = 'social_media'; 
  static const String keyMoviePreferences = 'movie_preferences'; 
  static const String keyGenres = 'genres'; // Tambahkan key untuk genre

  Future<void> saveAboutMe({
    required String fullName,
    required String nickname,
    required String hobbies,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyFullName, fullName);
    await prefs.setString(keyNickname, nickname);
    await prefs.setString(keyHobbies, hobbies);
  }

  Future<void> saveProfileImage(String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyProfileImage, imagePath);
  }

  Future<void> saveSocialMedia(List<Map<String, String>> socialMediaList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = jsonEncode(socialMediaList);
    await prefs.setString(keySocialMedia, jsonData);
  }

  Future<void> saveMoviePreferences(List<String> genres) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyMoviePreferences, jsonEncode(genres));
  }

  Future<void> saveGenres(List<String> genres) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyGenres, jsonEncode(genres));
  }

  Future<Map<String, dynamic>> getAboutMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    return {
      'fullName': prefs.getString(keyFullName) ?? "",
      'nickname': prefs.getString(keyNickname) ?? "",
      'hobbies': prefs.getString(keyHobbies) ?? "",
      'profileImage': prefs.getString(keyProfileImage) ?? "",
      'socialMedia': jsonDecode(prefs.getString(keySocialMedia) ?? '[]')
        .map<Map<String, String>>((item) => Map<String, String>.from(item))
        .toList(),
      'moviePreferences': jsonDecode(prefs.getString(keyMoviePreferences) ?? '[]'),
    };
  }
}