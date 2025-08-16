import 'package:flutter/material.dart';

class CollectionPanel extends StatelessWidget {
  const CollectionPanel({super.key});

  final List<String> collections = const [
    'Men',
    'Women',
    'Smart Watches',
    'Classic Watches',
    'Premium Watches',
    'Luxury Watches',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: collections.map((collection) {
            return Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: GestureDetector(
                onTap: () {
                  // Add navigation/filter logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening $collection collection')),
                  );
                },
                child: Chip(
                  label: Text(collection),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.indigo,
                  ),
                  backgroundColor: theme.brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.grey[200],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
