import 'package:flutter/material.dart';
import 'pages/home_page.dart'; // Importamos la página

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Actores App',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomePage(), // Llamamos a la página externa
    );
  }
}