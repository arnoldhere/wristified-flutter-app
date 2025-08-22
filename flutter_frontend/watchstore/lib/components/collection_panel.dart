import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchstore/providers/category_provider.dart';

class CollectionPanel extends StatefulWidget {
  const CollectionPanel({super.key});

  @override
  State<CollectionPanel> createState() => _CollectionPanelState();
}

class _CollectionPanelState extends State<CollectionPanel> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<CategoryProvider>(
        context,
        listen: false,
      ).fetchCategories(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    if (categoryProvider.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: categoryProvider.categories.map<Widget>((category) {
          return Chip(
            label: Text(
              category['name'], // ✅ Ensure DB column is `name`
              style: const TextStyle(fontSize: 14),
            ),
            backgroundColor: Colors.white70,
            labelStyle: const TextStyle(color: Colors.redAccent),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          );
        }).toList(),
      ),
    );
  }
}
