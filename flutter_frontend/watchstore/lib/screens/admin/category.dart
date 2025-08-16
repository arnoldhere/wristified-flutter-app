import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List categories = [];
  int totalCategories = 0;
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  final String baseUrl = "http://192.168.1.78:5000/api/admin";

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchCategoryCount();
  }

  Future<void> fetchCategories() async {
    final res = await http.get(Uri.parse("$baseUrl/categories"));
    if (res.statusCode == 200) {
      setState(() {
        var data = jsonDecode(res.body);
        categories = data['categories']; // use the correct key
      });
    }
  }

  Future<void> fetchCategoryCount() async {
    final res = await http.get(Uri.parse("$baseUrl/categories"));
    if (res.statusCode == 200) {
      setState(() {
        totalCategories = jsonDecode(res.body)['count'];
      });
    }
  }

  Future<void> addCategory() async {
    final res = await http.post(
      Uri.parse("$baseUrl/category/add"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": nameCtrl.text, "description": descCtrl.text}),
    );

    if (res.statusCode == 200) {
      Navigator.pop(context);
      nameCtrl.clear();
      descCtrl.clear();
      fetchCategories();
      fetchCategoryCount();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Category added successfully")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: ${res.body}")));
      print("Error ${res.statusCode}: ${res.body}");
    }
  }

  Future<void> updateCategory(int id, String oldName, String oldDesc) async {
    nameCtrl.text = oldName;
    descCtrl.text = oldDesc;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: "Description"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final res = await http.put(
                Uri.parse("$baseUrl/update/$id"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "name": nameCtrl.text,
                  "description": descCtrl.text,
                }),
              );
              if (res.statusCode == 200) {
                Navigator.pop(context);
                nameCtrl.clear();
                descCtrl.clear();
                fetchCategories();
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Future<void> deleteCategory(int id) async {
    await http.delete(Uri.parse("$baseUrl/del/$id"));
    fetchCategories();
    fetchCategoryCount();
  }

  void showAddCategoryDialog() {
    nameCtrl.clear();
    descCtrl.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: "Description"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(onPressed: addCategory, child: const Text("Add")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Categories")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Text(
                "Total Categories: $totalCategories",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: showAddCategoryDialog,
              child: const Text("Add Category"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: categories.map((cat) {
                  return Card(
                    child: ListTile(
                      title: Text(cat['name']),
                      subtitle: Text(cat['description'] ?? ""),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => updateCategory(
                              cat['id'],
                              cat['name'],
                              cat['description'] ?? "",
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteCategory(cat['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
