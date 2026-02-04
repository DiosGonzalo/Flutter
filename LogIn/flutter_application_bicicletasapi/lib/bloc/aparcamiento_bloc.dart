import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/aparcamiento_repository.dart';
import 'aparcamiento_event.dart';
import 'aparcamiento_state.dart';

/// BLoC para gestionar el estado de los aparcamientos
class AparcamientoBloc extends Bloc<AparcamientoEvent, AparcamientoState> {
  final AparcamientoRepository repository;

  AparcamientoBloc({required this.repository}) : super(const AparcamientoInitial()) {
    // Registrar manejadores de eventos
    on<LoadAparcamientos>(_onLoadAparcamientos);
    on<RefreshAparcamientos>(_onRefreshAparcamientos);
  }

  /// Maneja el evento LoadAparcamientos
  Future<void> _onLoadAparcamientos(
    LoadAparcamientos event,
    Emitter<AparcamientoState> emit,
  ) async {
    emit(const AparcamientoLoading());

    try {
      final response = await repository.getAparcamientos(
        limit: event.limit,
        offset: event.offset,
      );

      emit(AparcamientoLoaded(
        aparcamientos: response.results,
        totalCount: response.totalCount,
      ));
    } catch (e) {
      emit(AparcamientoError(message: e.toString()));
    }
  }

  /// Maneja el evento RefreshAparcamientos
  Future<void> _onRefreshAparcamientos(
    RefreshAparcamientos event,
    Emitter<AparcamientoState> emit,
  ) async {
    // Reutilizamos la lógica de LoadAparcamientos
    add(const LoadAparcamientos());
  }

  @override
  Future<void> close() {
    repository.dispose();
    return super.close();
  }
}
