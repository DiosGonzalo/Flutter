import 'package:equatable/equatable.dart';

abstract class MovieChangesEvent extends Equatable {
  const MovieChangesEvent();

  @override
  List<Object?> get props => [];
}

class FetchMovieChanges extends MovieChangesEvent {
  const FetchMovieChanges();
}
