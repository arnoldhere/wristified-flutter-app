import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = '';
  String _role = '';
  String? _token;

  bool get isLoggedIn => _isLoggedIn;

  String get userName => _userName;

  String get role => _role;

  String? get token => _token;

  /// Login and save session
  Future<void> login(String name, String role, String token) async {
    _userName = name;
    _role = role;
    _token = token;
    _isLoggedIn = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_name', name);
    await prefs.setString('user_role', role);

    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('auth_token')) return;

    _token = prefs.getString('auth_token');
    _userName = prefs.getString('user_name') ?? '';
    _role = prefs.getString('user_role') ?? '';
    _isLoggedIn = true;

    notifyListeners();
  }

  /// Logout and clear session
  Future<void> logout() async {
    _isLoggedIn = false;
    _userName = '';
    _role = '';
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_role');

    notifyListeners();
  }

}
