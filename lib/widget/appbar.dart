import 'package:flutter/material.dart';
import 'package:nowplaying/screen/home.dart';
import 'package:nowplaying/screen/all_movies.dart';
import 'package:nowplaying/screen/watchlist.dart';
import 'package:nowplaying/screen/about_me.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex; 

  const CustomBottomNavBar({super.key, required this.selectedIndex});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  void _navigateToPage(int index) {
    if (index == widget.selectedIndex) return; 

    Widget targetPage;
    if (index == 0) {
      targetPage = const HomeScreen();
    } else if (index == 1) {
      targetPage = const AllMoviesScreen();
    } else if (index == 2) {
      targetPage = const WatchListScreen();
    } else {
      targetPage = const AboutScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black,
      selectedItemColor: const Color.fromARGB(255, 138, 56, 254), 
      unselectedItemColor: Colors.grey, 
      currentIndex: widget.selectedIndex, 
      onTap: _navigateToPage,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.movie), label: "All Movies"),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "Watch List"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}