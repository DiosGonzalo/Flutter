import 'package:flutter/material.dart';

class puntuacionWidget extends StatelessWidget {
  final String nombre;
  final double puntuacion; // Valor entre 0 y 5 (o 100 para porcentaje)
  final String? fotaUrl;

  const puntuacionWidget({
    super.key,
    required this.nombre,
    required this.puntuacion,
    this.fotaUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Foto y Nombre
          Row(
            children: [
              // Foto
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: fotaUrl != null
                    ? Image.network(
                        fotaUrl!,
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        child: Text(
                          'FOTO',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              // Nombre
              Expanded(
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: nombre,
                    hintStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Barra de Puntuación
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BARRA DE Puntuaje',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: puntuacion / 5, // Asumiendo escala de 0-5
                  minHeight: 20,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getPuntuacionColor(puntuacion),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${puntuacion.toStringAsFixed(1)} / 5.0',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPuntuacionColor(double puntuacion) {
    if (puntuacion >= 4) return Colors.green;
    if (puntuacion >= 3) return Colors.yellow[700]!;
    if (puntuacion >= 2) return Colors.orange;
    return Colors.red;
  }
}