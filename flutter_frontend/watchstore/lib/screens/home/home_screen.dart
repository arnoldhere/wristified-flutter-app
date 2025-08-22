import 'package:flutter/material.dart';
import 'package:watchstore/components/collection_panel.dart';
import 'package:watchstore/components/home_carousel_slider.dart';
import 'package:watchstore/components/menubar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        // ✅ makes the whole page scrollable
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Navbar(), // Top navigation bar
            CarouselSection(), // Watch highlight carousel
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Shop by Category",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            const CollectionPanel(), // ✅ pills instead of grid
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
