import 'package:flutter/material.dart';
import '../models/actor.dart';
import '../widgets/actor_card.dart'; // Importamos el componente

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulamos los datos aquí (en el futuro vendrán de un servicio/API)
    final List<Actor> actors = [
      Actor(
          name: "Miguel",
          surname: "Campos",
          imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdcRXoBU4UZoOLrBmDtkVmy0NoKHwmlXVgaw&s"),
      Actor(
          name: "Angel",
          surname: "Naranjo",
          imageUrl: "https://triana.salesianos.edu/wp-content/uploads/photo-gallery/2019.06.19._Despedida_Ciclos_Formativos_2019/20190619_DespedidaCiclos_4.jpg?bwg=1561502552"),
      Actor(
          name: "Luis",
          surname: "Miguel",
          imageUrl: "https://cdn.openwebinars.net/media/teachers/luis-miguel-lopez-f2.png"),
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
                  "Salesiano's teachers",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.1),
                ),
                SizedBox(height: 8),
                Text("March 2025", style: TextStyle(color: Colors.grey)),
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