import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/actors.dart';
import '../models/actor.dart'; // Importamos el modelo

class ActorCard extends StatelessWidget {
  final Actor actor;

  const ActorCard({super.key, required this.actor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Ancho fijo para la tarjeta
      margin: const EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGEN (Píldora)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                image: DecorationImage(
                  image: NetworkImage(actor.imageUrl),
                  fit: BoxFit.cover,
                ),
                color: Colors.grey[300],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // TEXTOS
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  actor.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                ),
                Text(
                  actor.surname,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}