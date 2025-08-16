import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:watchstore/constants/env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchstore/providers/auth_provider.dart';

class AuthService {
  // static final String API_URL="http://10.0.2.2:5000/api";
  static final String AUTH_LOGIN = "auth/login";
  static final String AUTH_SIGNUP = "auth/signup";
  static final String baseUrl = API_URL;

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      // final SharedPreferences prefs = await SharedPreferences.getInstance();
      final url = Uri.parse('$baseUrl/$AUTH_LOGIN');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      // return _handleResponse(response);
      // handled response in case of Login process for saving data into shared preferences
      final res = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Save token & user in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', res['token']);
        await prefs.setString('user', jsonEncode(res['user']));
        await prefs.setString('role', res['user']['role']);
        // Get provider from context and update it
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.login(
          res['user']['name'],
          res['user']['role'],
          res['token'],
        );
        // return {'success': true};
        return {'success': true, 'role': res['user']['role']}; // instead of just {'success': true}
      } else {
        return {'success': false, 'error': res['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> signup(
    String fname,
    String lname,
    String email,
    String phone,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/$AUTH_SIGNUP');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fname': fname,
        'lname': lname,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );

    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (!response.headers['content-type']!.contains('application/json')) {
      return {
        'success': false,
        'error': 'Invalid response format. Got HTML instead of JSON.',
      };
    }
    final res = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'success': true, 'data': res};
    } else {
      return {
        'success': false,
        'error': res['message'] ?? 'Something went wrong',
      };
    }
  }
}
