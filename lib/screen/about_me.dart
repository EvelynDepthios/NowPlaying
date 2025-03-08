import 'dart:io';
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
  String hobbies = "Your Hobbies";
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
    hobbies = data['hobbies'] ?? "Your Hobbies";
    profileImage = data['profileImage'] ?? "";
    socialMedia = List<Map<String, String>>.from(data['socialMedia']);
    moviePreferences = List<String>.from(data['moviePreferences']);
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("About Me"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditAboutScreen(
                    fullName: fullName,
                    nickname: nickname,
                    hobbies: hobbies,
                    profileImage: profileImage,
                    socialMedia: List<Map<String, String>>.from(socialMedia), // ✅ Convert to List<Map<String, String>>
                    moviePreferences: List<String>.from(moviePreferences),
                  ),
                ),
              );

              if (updated == true) {
                _loadAboutMe(); // Refresh data setelah diedit
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Foto Profil dengan Animasi
            GestureDetector(
              onTap: () {
                if (profileImage.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(File(profileImage), fit: BoxFit.cover),
                      ),
                    ),
                  );
                }
              },
              child: CircleAvatar(
                radius: 70,
                backgroundImage: profileImage.isNotEmpty
                    ? FileImage(File(profileImage))
                    : const AssetImage("assets/profile.jpg") as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),

            // Nama dalam Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "@$nickname",
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Informasi Lainnya
            _buildInfoTile(Icons.favorite, "Hobbies", hobbies),
            const SizedBox(height: 10),

            // Social Media List
            const Text(
              "Social Media",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: socialMedia.isNotEmpty
                    ? socialMedia.map((social) {
                        return Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.link, color: Colors.blueAccent),
                              title: Text(
                                "${social['platform']}: ${social['username']}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            _buildDivider(),
                          ],
                        );
                      }).toList()
                    : [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            "No social media added.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ],
              ),
            ),
            const SizedBox(height: 20),

            // Movie Preferences List (Mirip dengan Movie Detail)
            const Text(
              "Movie Preferences",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: moviePreferences.isNotEmpty
                    ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: moviePreferences.map((genre) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      )
                    : const Text(
                        "No movie preferences selected.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 3),
    );
  }

  // Widget untuk Menampilkan Informasi dengan Icon
  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  // Garis Pembatas antar Informasi
  Widget _buildDivider() {
    return const Divider(
      thickness: 1,
      color: Colors.grey,
      indent: 16,
      endIndent: 16,
    );
  }

  // Warna Khusus untuk Genre
  Color _getGenreColor(String genre) {
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
    return genreColors[genre] ?? Colors.grey;
  }
}