import 'package:flutter/material.dart';

void main() {
  runApp(const WristifiedApp());
}

class WristifiedApp extends StatelessWidget {
  const WristifiedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wristified',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: DemoScreen(),
    );
  }
}

class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wristified")),
      body: Center(
        child: Text(
          'Hello, World! Your watch store starts here. ⌚',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
