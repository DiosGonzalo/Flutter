import 'package:flutter/material.dart';
import 'package:flutter_application_2/shared/puntuacion.dart';

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de usuarios con sus datos
    final usuarios = [
      {
        'nombre': 'Juan Pérez',
        'puntuacion': 4.5,
        'foto': null,
      },
      {
        'nombre': 'María González',
        'puntuacion': 3.8,
        'foto': null,
      },
      {
        'nombre': 'Carlos López',
        'puntuacion': 4.2,
        'foto': null,
      },
      {
        'nombre': 'Ana Martínez',
        'puntuacion': 5.0,
        'foto': null,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Puntuaciones'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: usuarios.length,
        itemBuilder: (context, index) {
          final usuario = usuarios[index];
          return puntuacionWidget(
            nombre: usuario['nombre'] as String,
            puntuacion: usuario['puntuacion'] as double,
            fotaUrl: usuario['foto'] as String?,
          );
        },
      ),
    );
  }
}
