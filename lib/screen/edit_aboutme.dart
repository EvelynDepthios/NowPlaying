import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nowplaying/services/shared_prefs_service.dart';
import 'package:nowplaying/services/services.dart';

class EditAboutScreen extends StatefulWidget {
  final String fullName;
  final String nickname;
  final String hobby;
  final String profileImage;
  final List<Map<String, String>> socialMedia;
  final List<String> moviePreferences;

  const EditAboutScreen({
    super.key,
    required this.fullName,
    required this.nickname,
    required this.hobby,
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
  late TextEditingController _hobbyController;
  String profileImage = "";
  List<Map<String, String>> socialMedia = [];
  List<String> selectedGenres = [];
  List<String> allGenres = [];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.fullName);
    _nicknameController = TextEditingController(text: widget.nickname);
    _hobbyController = TextEditingController(text: widget.hobby);
    profileImage = widget.profileImage;
    socialMedia = List<Map<String, String>>.from(widget.socialMedia);
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
      if (kIsWeb) {
        // Pada web, baca gambar sebagai bytes lalu encode ke base64
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          profileImage = base64Encode(bytes);
        });
      } else {
        setState(() {
          profileImage = pickedFile.path;
        });
      }
    }
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

  void _addSocialMedia() {
    setState(() {
      socialMedia.add({"platform": "", "username": ""});
    });
  }

  Future<void> _saveAboutMe() async {
    await _prefsService.saveAboutMe(
      fullName: _fullNameController.text,
      nickname: _nicknameController.text,
      hobby: _hobbyController.text,
    );
    await _prefsService.saveProfileImage(profileImage);
    await _prefsService.saveSocialMedia(List<Map<String, String>>.from(socialMedia));
    await _prefsService.saveMoviePreferences(selectedGenres);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text("Edit About Me", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture
            Center(
              child: CircleAvatar(
                radius: 80,
                backgroundImage: _getProfileImage(profileImage),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
              ),
              child: const Text("Upload Photo"),
            ),
            const SizedBox(height: 10),
            _buildTextField("Full Name", _fullNameController),
            _buildTextField("Nickname", _nicknameController),
            _buildTextField("Hobby", _hobbyController),
            const SizedBox(height: 20),
            const Text("Social Media", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Column(
              children: socialMedia.asMap().entries.map((entry) {
                int index = entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: TextStyle(color: colorScheme.onSurface),
                          controller: TextEditingController(text: socialMedia[index]["platform"]),
                          decoration: _customInputDecoration("Platform", colorScheme),
                          onChanged: (value) => socialMedia[index]["platform"] = value,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          style: TextStyle(color: colorScheme.onSurface),
                          controller: TextEditingController(text: socialMedia[index]["username"]),
                          decoration: _customInputDecoration("Username", colorScheme),
                          onChanged: (value) => socialMedia[index]["username"] = value,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => setState(() => socialMedia.removeAt(index)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: _addSocialMedia,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
              ),
              child: const Text("Add Social Media"),
            ),
            const SizedBox(height: 20),
            const Text("Movie Preferences", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allGenres.map((genre) {
                return FilterChip(
                  label: Text(
                    genre,
                    style: TextStyle(
                      color: selectedGenres.contains(genre) ? colorScheme.onSecondary : colorScheme.onSurface,
                    ),
                  ),
                  selectedColor: colorScheme.secondary,
                  backgroundColor: colorScheme.surface,
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
            ElevatedButton(
              onPressed: _saveAboutMe,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _customInputDecoration(String label, ColorScheme colorScheme) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.secondary),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: _customInputDecoration(label, Theme.of(context).colorScheme),
      ),
    );
  }
}