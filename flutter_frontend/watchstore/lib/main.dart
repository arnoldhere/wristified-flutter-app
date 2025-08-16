import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchstore/providers/auth_provider.dart';
import 'package:watchstore/providers/theme_provider.dart';
import 'package:watchstore/routes/app_routes.dart';
import 'package:watchstore/routes/route_generator.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.tryAutoLogin();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
      // <-- switch based on provider
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
      initialRoute: AppRoutes.splash,
      onGenerateRoute: RouteGenerator.generateRoute,
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) =>
            const Scaffold(body: Center(child: Text("Page not found"))),
      ),
    );
  }
}
