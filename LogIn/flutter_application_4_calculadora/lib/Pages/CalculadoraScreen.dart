import 'package:flutter/material.dart';

class CalculadoraScreen extends StatelessWidget {
  const CalculadoraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.bottomRight,
      color: Colors.black,
      child: const Text(
        '0',
        style: TextStyle(
          fontSize: 80,
          color: Colors.white,
          fontWeight: FontWeight.w200,
        ),
      ),
    );
  }
}