import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchstore/providers/auth_provider.dart';
import 'package:watchstore/providers/category_provider.dart';
import 'package:watchstore/providers/theme_provider.dart';
import 'package:watchstore/routes/route_generator.dart';
import 'package:watchstore/services/wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.tryAutoLogin(); // Restore session

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => CategoryProvider()), // ✅
      ],
      child: const WristifiedApp(),
    ),
  );
}

class WristifiedApp extends StatelessWidget {
  const WristifiedApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Wristified',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const Wrapper(),
      // ✅ handles login persistence
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
