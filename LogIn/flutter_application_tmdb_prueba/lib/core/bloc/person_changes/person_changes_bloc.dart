import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_tmdb_prueba/core/models/people_list_popular_response.dart';
import 'package:flutter_application_tmdb_prueba/core/services/person_changes_service.dart';

import 'person_changes_event.dart';
import 'person_changes_state.dart';

class PersonChangesBloc extends Bloc<PersonChangesEvent, PersonChangesState> {
  final PersonChangesService changesService;

  PersonChangesBloc({PersonChangesService? service})
      : changesService = service ?? PersonChangesService(),
        super(const PersonChangesInitial()) {
    on<FetchPersonChanges>(_onFetchPersonChanges);
  }

  Future<void> _onFetchPersonChanges(
    FetchPersonChanges event,
    Emitter<PersonChangesState> emit,
  ) async {
    emit(const PersonChangesLoading());
    try {
      final List<Person> people = await changesService.getPopularPeople();
      emit(PersonChangesLoaded(people));
    } catch (e) {
      emit(const PersonChangesFailure(
          'No se pudieron cargar las personas populares'));
    }
  }
}
