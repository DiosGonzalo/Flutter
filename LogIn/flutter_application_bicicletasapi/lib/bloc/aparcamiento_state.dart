import 'package:equatable/equatable.dart';
import '../models/aparcamiento.dart';

/// Clase base para todos los estados del AparcamientoBloc
abstract class AparcamientoState extends Equatable {
  const AparcamientoState();

  @override
  List<Object> get props => [];
}

/// Estado inicial
class AparcamientoInitial extends AparcamientoState {
  const AparcamientoInitial();
}

/// Estado de carga
class AparcamientoLoading extends AparcamientoState {
  const AparcamientoLoading();
}

/// Estado de éxito con datos cargados
class AparcamientoLoaded extends AparcamientoState {
  final List<Aparcamiento> aparcamientos;
  final int totalCount;

  const AparcamientoLoaded({
    required this.aparcamientos,
    required this.totalCount,
  });

  @override
  List<Object> get props => [aparcamientos, totalCount];
}

/// Estado de error
class AparcamientoError extends AparcamientoState {
  final String message;

  const AparcamientoError({required this.message});

  @override
  List<Object> get props => [message];
}
