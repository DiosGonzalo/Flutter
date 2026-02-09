import 'package:equatable/equatable.dart';

abstract class PersonChangesEvent extends Equatable {
  const PersonChangesEvent();

  @override
  List<Object?> get props => [];
}

class FetchPersonChanges extends PersonChangesEvent {
  const FetchPersonChanges();
}
