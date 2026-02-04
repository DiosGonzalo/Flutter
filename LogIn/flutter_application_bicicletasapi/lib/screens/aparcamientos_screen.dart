import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/aparcamiento_bloc.dart';
import '../bloc/aparcamiento_event.dart';
import '../bloc/aparcamiento_state.dart';
import '../models/aparcamiento.dart';

/// Pantalla principal que muestra el listado de aparcamientos
class AparcamientosScreen extends StatelessWidget {
  const AparcamientosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aparcamientos de Bicicletas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AparcamientoBloc>().add(const RefreshAparcamientos());
            },
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: BlocBuilder<AparcamientoBloc, AparcamientoState>(
        builder: (context, state) {
          if (state is AparcamientoInitial) {
            // Cargar datos al iniciar
            context.read<AparcamientoBloc>().add(const LoadAparcamientos());
            return const Center(child: CircularProgressIndicator());
          } else if (state is AparcamientoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AparcamientoLoaded) {
            return _buildAparcamientosList(state);
          } else if (state is AparcamientoError) {
            return _buildErrorWidget(context, state.message);
          }
          return const Center(child: Text('Estado desconocido'));
        },
      ),
    );
  }

  /// Construye el widget de la lista de aparcamientos
  Widget _buildAparcamientosList(AparcamientoLoaded state) {
    return Column(
      children: [
        // Header con información total
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total de aparcamientos: ${state.totalCount}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Mostrando: ${state.aparcamientos.length}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        // Lista de aparcamientos
        Expanded(
          child: state.aparcamientos.isEmpty
              ? const Center(
                  child: Text('No se encontraron aparcamientos'),
                )
              : ListView.builder(
                  itemCount: state.aparcamientos.length,
                  itemBuilder: (context, index) {
                    return _buildAparcamientoCard(state.aparcamientos[index]);
                  },
                ),
        ),
      ],
    );
  }

  /// Construye la tarjeta de cada aparcamiento
  Widget _buildAparcamientoCard(Aparcamiento aparcamiento) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTipoColor(aparcamiento.tipo),
          child: Text(
            '${aparcamiento.numplazas}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          aparcamiento.tipo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Plazas disponibles: ${aparcamiento.numplazas}'),
            Text('ID: ${aparcamiento.objectid}'),
            Text(
              'Ubicación: ${aparcamiento.geoPoint.lat.toStringAsFixed(6)}, '
              '${aparcamiento.geoPoint.lon.toStringAsFixed(6)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Aquí se podría navegar a una pantalla de detalle
          // o abrir un mapa con la ubicación
        },
      ),
    );
  }

  /// Construye el widget de error
  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar los datos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AparcamientoBloc>().add(const RefreshAparcamientos());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Obtiene el color según el tipo de aparcamiento
  Color _getTipoColor(String tipo) {
    if (tipo.contains('Horquilla')) {
      return Colors.blue;
    } else if (tipo.contains('Barra')) {
      return Colors.green;
    } else if (tipo.contains('Soporte')) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }
}
