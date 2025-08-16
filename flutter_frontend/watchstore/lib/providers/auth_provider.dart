import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = '';
  String _role = '';
  String? _token;

  bool get isLoggedIn => _token != null;

  String get userName => _userName;

  String get role => _role;

  void login(String name, String role, String token) async {
    _userName = name;
    _isLoggedIn = true;
    _role = role;
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    notifyListeners();
  }

  void logout() async{
    _isLoggedIn = false;
    _userName = '';
    _role = '';
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('auth_token')) return;
    _token = prefs.getString('auth_token');
    notifyListeners();
  }
}
