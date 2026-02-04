import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/aparcamiento_bloc.dart';
import 'repositories/aparcamiento_repository.dart';
import 'screens/aparcamientos_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aparcamientos de Bicicletas - Valencia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => AparcamientoBloc(
          repository: AparcamientoRepository(),
        ),
        child: const AparcamientosScreen(),
      ),
    );
  }
}
