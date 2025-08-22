import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:watchstore/constants/env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchstore/models/UserModel.dart';
import 'package:watchstore/providers/auth_provider.dart';

class AdminService {
  static final String baseUrl = API_URL;
  static final String getUsers = "admin/get-users";
  static final String getCounts = "admin/get-counts";

  /// Fetch counts for dashboard
  static Future<Map<String, dynamic>> fetchCounts(context) async {
    final res = await http.get(Uri.parse("$baseUrl/$getCounts"));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to fetch scorecards')),
      );
      throw Exception("Failed to load counts");
    }
  }

  static Future<List<UserModel>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/$getUsers'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => UserModel.fromJson(e))
          .toList();
    } else {
      throw Exception("Failed to load users: ${response.body}");
    }
  }
}
