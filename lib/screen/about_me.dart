import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nowplaying/services/shared_prefs_service.dart';
import 'package:nowplaying/screen/edit_aboutme.dart';
import 'package:nowplaying/widget/appbar.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final SharedPrefsService _prefsService = SharedPrefsService();

  String fullName = "Your Name";
  String nickname = "Your Nickname";
  String hobby = "Your hobby";
  String profileImage = "";
  List<Map<String, String>> socialMedia = [];
  List<String> moviePreferences = [];

  @override
  void initState() {
    super.initState();
    _loadAboutMe();
  }

  Future<void> _loadAboutMe() async {
    Map<String, dynamic> data = await _prefsService.getAboutMe();
    setState(() {
      fullName = data['fullName'] ?? "Your Name";
      nickname = data['nickname'] ?? "Your Nickname";
      hobby = data['hobby'] ?? "Your hobby";
      profileImage = data['profileImage'] ?? "";
      socialMedia = List<Map<String, String>>.from(data['socialMedia']);
      moviePreferences = List<String>.from(data['moviePreferences']);
    });
  }

  // Helper untuk mendapatkan ImageProvider sesuai platform
  ImageProvider _getProfileImage(String imageStr) {
    if (imageStr.isEmpty) {
      return const AssetImage("assets/profile.jpg");
    }
    if (kIsWeb) {
      return MemoryImage(base64Decode(imageStr));
    } else {
      return FileImage(File(imageStr));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditAboutScreen(
                    fullName: fullName,
                    nickname: nickname,
                    hobby: hobby,
                    profileImage: profileImage,
                    socialMedia: List<Map<String, String>>.from(socialMedia),
                    moviePreferences: List<String>.from(moviePreferences),
                  ),
                ),
              );

              if (updated == true) {
                _loadAboutMe();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture
            Center(
              child: GestureDetector(
                onTap: () {
                  if (profileImage.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: kIsWeb
                              ? Image.memory(base64Decode(profileImage), fit: BoxFit.cover)
                              : Image.file(File(profileImage), fit: BoxFit.cover),
                        ),
                      ),
                    );
                  }
                },
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: _getProfileImage(profileImage),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Personal Information
            _buildInfoField("Full Name", fullName),
            _buildInfoField("Nickname", nickname),
            _buildInfoField("Hobby", hobby),

            const SizedBox(height: 20),

            // Social Media & Movie Preferences
            _buildSocialMediaCard(),
            const SizedBox(height: 16),
            _buildMoviePreferencesCard(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 3),
    );
  }

  // Widget untuk menampilkan informasi pribadi
  Widget _buildInfoField(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Card untuk Social Media
  Widget _buildSocialMediaCard() {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Social Media", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            socialMedia.isNotEmpty
                ? Column(
                    children: socialMedia.map((social) {
                      return Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.link, color: Colors.deepPurpleAccent),
                            title: Text(
                              "${social['platform']}: ${social['username']}",
                              style: const TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                          _buildDivider(),
                        ],
                      );
                    }).toList(),
                  )
                : const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("No social media added.", style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ),
          ],
        ),
      ),
    );
  }

  // Card untuk Movie Preferences
  Widget _buildMoviePreferencesCard() {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Movie Preferences",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            moviePreferences.isNotEmpty
                ? Center( 
                    child: Wrap(
                      spacing: 8, 
                      runSpacing: 8, 
                      alignment: WrapAlignment.center, 
                      children: moviePreferences.map((genre) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getGenreColor(genre),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            genre,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "No movie preferences selected.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      thickness: 1,
      color: Colors.grey,
      indent: 16,
      endIndent: 16,
    );
  }

  Color _getGenreColor(String genre) {
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
    return genreColors[genre] ?? Colors.grey;
  }
}