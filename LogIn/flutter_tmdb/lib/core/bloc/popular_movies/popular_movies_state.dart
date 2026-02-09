import 'package:equatable/equatable.dart';
import 'package:flutter_tmdb/core/models/movies_list_popular_response.dart';

abstract class PopularMoviesState extends Equatable {
  const PopularMoviesState();

  @override
  List<Object?> get props => [];
}

class PopularMoviesInitial extends PopularMoviesState {
  const PopularMoviesInitial();
}

class PopularMoviesLoading extends PopularMoviesState {
  const PopularMoviesLoading();
}

class PopularMoviesLoaded extends PopularMoviesState {
  final List<Movie> movies;

  const PopularMoviesLoaded(this.movies);

  @override
  List<Object?> get props => [movies];
}

class PopularMoviesFailure extends PopularMoviesState {
  final String message;

  const PopularMoviesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
