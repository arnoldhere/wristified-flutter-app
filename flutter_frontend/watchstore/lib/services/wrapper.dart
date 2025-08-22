import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchstore/providers/auth_provider.dart';
import 'package:watchstore/screens/admin/dasboard.dart';
import 'package:watchstore/screens/auth/login_screen.dart';
import 'package:watchstore/screens/home/home_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoggedIn) {
      // ✅ Role-based navigation
      if (authProvider.role == "admin") {
        return const AdminDashboard();
      }
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
