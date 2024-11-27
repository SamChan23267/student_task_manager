// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/homepage.dart';
// Import other dependencies or internal packages as needed.

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}