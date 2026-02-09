import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tmdb/core/models/people_changes_response.dart';
import 'package:flutter_tmdb/core/services/people_changes_service.dart';

import 'people_changes_event.dart';
import 'people_changes_state.dart';

class PeopleChangesBloc
    extends Bloc<PeopleChangesEvent, PeopleChangesState> {
  final PeopleChangesService service;

  PeopleChangesBloc({PeopleChangesService? changesService})
      : service = changesService ?? PeopleChangesService(),
        super(const PeopleChangesInitial()) {
    on<FetchPeopleChanges>(_onFetchPeopleChanges);
  }

  Future<void> _onFetchPeopleChanges(
    FetchPeopleChanges event,
    Emitter<PeopleChangesState> emit,
  ) async {
    emit(const PeopleChangesLoading());
    try {
      final List<PersonChange> changes = await service.getChanges(
        page: event.page,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(PeopleChangesLoaded(changes));
    } catch (e) {
      emit(const PeopleChangesFailure(
          'No se pudieron cargar los cambios de personas'));
    }
  }
}
