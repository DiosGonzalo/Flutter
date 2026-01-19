import 'package:flutter/material.dart';

class CaculadoraButton extends StatelessWidget {
  final String texto;
  final Color colorFondo;

  const CaculadoraButton({
    super.key,
    required this.texto,
    required this.colorFondo,
  });

  @override
  Widget build(BuildContext context) {

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(15), 
        height: 100, 
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorFondo,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(200), 
            ),
          ),
          onPressed: () {}, 
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}