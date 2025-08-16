import 'package:flutter/material.dart';
import 'package:watchstore/components/collection_panel.dart';
import 'package:watchstore/components/home_carousel_slider.dart';
import 'package:watchstore/components/menubar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Navbar(), // Top navigation bar
          CarouselSection(), //  Watch highlight carousel
          const CollectionPanel(), // collection panel for various watch categories
         const SizedBox(height: 30),
          // Add more sections here
        ],
      ),
    );
  }
}
