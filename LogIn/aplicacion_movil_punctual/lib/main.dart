import 'package:aplicacion_movil_punctual/Screens/Log%20in/login_screen.dart';
import 'package:flutter/material.dart';
// Importa la ruta exacta donde guardaste el archivo
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Proyecto App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      // Aquí llamas a la clase que creamos en la otra carpeta
      home: const LoginScreen(), 
    );
  }
}