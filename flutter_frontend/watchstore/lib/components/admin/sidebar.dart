import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchstore/providers/auth_provider.dart';
import 'package:watchstore/screens/admin/category.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return ListView(
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: Colors.indigo),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage("assets/images/wristified.jpg"),
              ),
              SizedBox(height: 10),
              Text(
                "Admin Dashboard",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text("Dashboard"),
          selected: selectedIndex == 0,
          onTap: () => onItemSelected(0),
        ),
        ListTile(
          leading: const Icon(Icons.category),
          title: const Text("Category"),
          selected: selectedIndex == 1,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CategoryPage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.watch),
          title: const Text("Manage Watches"),
          selected: selectedIndex == 2,
          onTap: () => onItemSelected(2),
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text("Logout"),
          onTap: () {
            authProvider.logout();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Logout successful')));
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );
  }
}
