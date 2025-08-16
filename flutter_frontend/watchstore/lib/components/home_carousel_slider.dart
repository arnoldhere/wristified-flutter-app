import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselSection extends StatelessWidget {
  CarouselSection({super.key});

  final List<String> imageList = [
    'assets/images/banner01.jpg',
    'assets/images/banner02.png',
    'assets/images/banner03.jpg',
    'assets/images/banner04.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      child: CarouselSlider(
        options: CarouselOptions(
          height: screenWidth > 600 ? 420.0 : 280.0,
          // More responsive
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          enlargeCenterPage: true,
          viewportFraction: 0.7,
        ),
        items: imageList.map((item) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: screenWidth * 0.65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    item,
                    fit: BoxFit.fill,
                    alignment: Alignment.center,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
