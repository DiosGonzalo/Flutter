import 'package:equatable/equatable.dart';
import 'package:flutter_tmdb/core/models/people_changes_response.dart';

abstract class PeopleChangesState extends Equatable {
  const PeopleChangesState();

  @override
  List<Object?> get props => [];
}

class PeopleChangesInitial extends PeopleChangesState {
  const PeopleChangesInitial();
}

class PeopleChangesLoading extends PeopleChangesState {
  const PeopleChangesLoading();
}

class PeopleChangesLoaded extends PeopleChangesState {
  final List<PersonChange> changes;

  const PeopleChangesLoaded(this.changes);

  @override
  List<Object?> get props => [changes];
}

class PeopleChangesFailure extends PeopleChangesState {
  final String message;

  const PeopleChangesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
