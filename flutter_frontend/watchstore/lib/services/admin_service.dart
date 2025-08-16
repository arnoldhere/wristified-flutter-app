import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:watchstore/constants/env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchstore/models/UserModel.dart';
import 'package:watchstore/providers/auth_provider.dart';

class AdminService {
  static final String baseUrl = API_URL;
  static final String getUsers = "admin/get-users";

  static Future<List<UserModel>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/$getUsers'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => UserModel.fromJson(e))
          .toList(); // ✅ Proper parsing
    } else {
      throw Exception("Failed to load users: ${response.body}");
    }
  }
}
