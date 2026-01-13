import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/actors.dart';
import '../models/actor.dart';
import '../widgets/actor_card.dart'; // Importamos el componente

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulamos los datos aquí (en el futuro vendrán de un servicio/API)
    final List<Actor> actors = [
      Actor(
          name: "Golshifteh",
          surname: "Farahani",
          imageUrl: "https://image.tmdb.org/t/p/w500/AhX8mXwX1hC8tN8YqFq2r6q6q5y.jpg"),
      Actor(
          name: "Navid",
          surname: "Mohammadzadeh",
          imageUrl: "https://image.tmdb.org/t/p/w500/kZ9X4j2j5X6j5X6j5X6j5X6j5X6.jpg"),
      Actor(
          name: "Taraneh",
          surname: "Alidoosti",
          imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Taraneh_Alidoosti_Cannes_2016.jpg/800px-Taraneh_Alidoosti_Cannes_2016.jpg"),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("HomePage", style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Títulos
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Best Iranian Actors\nand Actresses",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.1),
                ),
                SizedBox(height: 8),
                Text("March 2020", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // LISTA HORIZONTAL
          SizedBox(
            height: 450, // Altura del carrusel
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // <--- CLAVE
              itemCount: actors.length,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 24),
              itemBuilder: (context, index) {
                // Usamos el componente personalizado
                return ActorCard(actor: actors[index]);
              },
            ),
          ),
        ],
      ),
      
      // Barra inferior decorativa
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }
}