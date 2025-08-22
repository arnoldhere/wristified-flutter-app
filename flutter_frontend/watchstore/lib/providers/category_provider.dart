import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/env.dart';

class CategoryProvider with ChangeNotifier {
  List<dynamic> _categories = [];
  static final String baseUrl = API_URL;

  List<dynamic> get categories => _categories;

  Future<void> fetchCategories() async {
    final response = await http.get(
      Uri.parse("$API_URL/user/get-all-categories"),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _categories = data["categories"]; // ✅ FIXED
      notifyListeners();
    } else {
      throw Exception("Failed to load categories");
    }
  }
}
