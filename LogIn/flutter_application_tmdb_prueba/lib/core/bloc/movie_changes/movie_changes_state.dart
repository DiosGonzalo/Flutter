import 'package:equatable/equatable.dart';
import 'package:flutter_application_tmdb_prueba/core/models/movie_list_popular_response.dart';

abstract class MovieChangesState extends Equatable {
  const MovieChangesState();

  @override
  List<Object?> get props => [];
}

class MovieChangesInitial extends MovieChangesState {
  const MovieChangesInitial();
}

class MovieChangesLoading extends MovieChangesState {
  const MovieChangesLoading();
}

class MovieChangesLoaded extends MovieChangesState {
  final List<Movie> movies;

  const MovieChangesLoaded(this.movies);

  @override
  List<Object?> get props => [movies];
}

class MovieChangesFailure extends MovieChangesState {
  final String message;

  const MovieChangesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
