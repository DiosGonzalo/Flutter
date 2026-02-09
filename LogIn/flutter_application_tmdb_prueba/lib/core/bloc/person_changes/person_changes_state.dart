import 'package:equatable/equatable.dart';
import 'package:flutter_application_tmdb_prueba/core/models/people_list_popular_response.dart';

abstract class PersonChangesState extends Equatable {
  const PersonChangesState();

  @override
  List<Object?> get props => [];
}

class PersonChangesInitial extends PersonChangesState {
  const PersonChangesInitial();
}

class PersonChangesLoading extends PersonChangesState {
  const PersonChangesLoading();
}

class PersonChangesLoaded extends PersonChangesState {
  final List<Person> people;

  const PersonChangesLoaded(this.people);

  @override
  List<Object?> get props => [people];
}

class PersonChangesFailure extends PersonChangesState {
  final String message;

  const PersonChangesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
