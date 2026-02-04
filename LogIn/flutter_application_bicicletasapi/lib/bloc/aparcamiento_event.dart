import 'package:equatable/equatable.dart';

/// Clase base para todos los eventos del AparcamientoBloc
abstract class AparcamientoEvent extends Equatable {
  const AparcamientoEvent();

  @override
  List<Object> get props => [];
}

/// Evento para cargar los aparcamientos
class LoadAparcamientos extends AparcamientoEvent {
  final int limit;
  final int offset;

  const LoadAparcamientos({this.limit = 100, this.offset = 0});

  @override
  List<Object> get props => [limit, offset];
}

/// Evento para recargar los aparcamientos
class RefreshAparcamientos extends AparcamientoEvent {
  const RefreshAparcamientos();
}
