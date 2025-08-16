import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchstore/providers/auth_provider.dart';
import 'package:watchstore/routes/app_routes.dart';
import '../providers/theme_provider.dart';

class Navbar extends StatefulWidget implements PreferredSizeWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _NavbarState extends State<Navbar> {
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      centerTitle: false,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image.asset(
            'assets/images/wristified.jpg',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showSearch
            ? TextField(
          key: const ValueKey('search'),
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search watches...',
            hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            border: InputBorder.none,
          ),
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
        )
            : const Text(
          'Wristified',
          key: ValueKey('title'),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _showSearch ? Icons.close_rounded : Icons.search_rounded,
            size: 24,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () {
            setState(() {
              _showSearch = !_showSearch;
              _searchController.clear();
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: PopupMenuButton<int>(
            offset: const Offset(0, kToolbarHeight),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: isDark ? Colors.grey[850] : Colors.white,
            elevation: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark ? Colors.white10 : Colors.grey.shade200,
                border: Border.all(
                  color: isDark ? Colors.white30 : Colors.grey.shade400,
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: isDark ? Colors.white : Colors.black87, size: 20),
                  if (authProvider.isLoggedIn) ...[
                    const SizedBox(width: 8),
                    Text(
                      authProvider.userName,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            onSelected: (value) {
              if (!authProvider.isLoggedIn) {
                if (value == 0) {
                  Navigator.pushNamed(context, AppRoutes.login);
                } else if (value == 1) {
                  Navigator.pushNamed(context, AppRoutes.signup);
                }
              } else {
                if (value == 0) {
                  Navigator.pushNamed(context, AppRoutes.profile);
                } else if (value == 1) {
                  authProvider.logout();
                }
              }
            },
            itemBuilder: (context) {
              if (!authProvider.isLoggedIn) {
                return [
                  const PopupMenuItem(value: 0, child: Text('Login')),
                  const PopupMenuItem(value: 1, child: Text('Signup')),
                ];
              } else {
                return [
                  const PopupMenuItem(value: 0, child: Text('Profile')),
                  const PopupMenuItem(value: 1, child: Text('Logout')),
                ];
              }
            },
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
