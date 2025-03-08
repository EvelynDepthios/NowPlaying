import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nowplaying/services/shared_prefs_service.dart';
import 'package:nowplaying/services/services.dart';

class EditAboutScreen extends StatefulWidget {
  final String fullName;
  final String nickname;
  final String hobbies;
  final String profileImage;
  final List<Map<String, String>> socialMedia;
  final List<String> moviePreferences;

  const EditAboutScreen({
    super.key,
    required this.fullName,
    required this.nickname,
    required this.hobbies,
    required this.profileImage,
    required this.socialMedia,
    required this.moviePreferences,
  });

  @override
  State<EditAboutScreen> createState() => _EditAboutScreenState();
}

class _EditAboutScreenState extends State<EditAboutScreen> {
  final SharedPrefsService _prefsService = SharedPrefsService();
  final APIservices _apiService = APIservices();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _fullNameController;
  late TextEditingController _nicknameController;
  late TextEditingController _hobbiesController;
  String profileImage = "";
  List<Map<String, String>> socialMedia = [];
  List<String> selectedGenres = [];
  List<String> allGenres = []; // Akan diisi dari API

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.fullName);
    _nicknameController = TextEditingController(text: widget.nickname);
    _hobbiesController = TextEditingController(text: widget.hobbies);
    profileImage = widget.profileImage;
    socialMedia = widget.socialMedia.isNotEmpty
          ? List<Map<String, String>>.from(widget.socialMedia)
          : [];    
    selectedGenres = List<String>.from(widget.moviePreferences);
    _loadGenres();
  }


  Future<void> _loadGenres() async {
    await _apiService.fetchGenres();
    setState(() {
      allGenres = APIservices.genreMap.values.toList();
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = pickedFile.path;
      });
    }
  }

  void _addSocialMedia() {
    setState(() {
      socialMedia.add({"platform": "", "username": ""});
    });
  }

  Future<void> _saveAboutMe() async {
    await _prefsService.saveAboutMe(
      fullName: _fullNameController.text,
      nickname: _nicknameController.text,
      hobbies: _hobbiesController.text,
    );

    await _prefsService.saveProfileImage(profileImage);
    await _prefsService.saveSocialMedia(List<Map<String, String>>.from(socialMedia));
    await _prefsService.saveMoviePreferences(selectedGenres);

    Navigator.pop(context, true); // Kembali ke AboutScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit About Me")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 70,
              backgroundImage: profileImage.isNotEmpty
                  ? Image.file(File(profileImage)).image
                  : const AssetImage("assets/profile.jpg"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _pickImage, child: const Text("Upload Photo")),

            _buildTextField("Full Name", _fullNameController),
            _buildTextField("Nickname", _nicknameController),
            _buildTextField("Hobbies", _hobbiesController),

            const SizedBox(height: 20),
            const Text("Social Media", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Column(
              children: socialMedia.asMap().entries.map((entry) {
                int index = entry.key;
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: socialMedia[index]["platform"]), // ✅ Pastikan controller ada
                        decoration: const InputDecoration(labelText: "Platform"),
                        onChanged: (value) => socialMedia[index]["platform"] = value,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: socialMedia[index]["username"]), // ✅ Pastikan controller ada
                        decoration: const InputDecoration(labelText: "Username"),
                        onChanged: (value) => socialMedia[index]["username"] = value,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setState(() => socialMedia.removeAt(index)),
                    ),
                  ],
                );
              }).toList(),
            ),
            ElevatedButton(onPressed: _addSocialMedia, child: const Text("Add Social Media")),

            const SizedBox(height: 20),
            const Text("Movie Preferences", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: allGenres.map((genre) {
                return FilterChip(
                  label: Text(genre),
                  selected: selectedGenres.contains(genre),
                  onSelected: (isSelected) {
                    setState(() {
                      if (isSelected) {
                        selectedGenres.add(genre);
                      } else {
                        selectedGenres.remove(genre);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveAboutMe, child: const Text("Save")),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      ),
    );
  }
}