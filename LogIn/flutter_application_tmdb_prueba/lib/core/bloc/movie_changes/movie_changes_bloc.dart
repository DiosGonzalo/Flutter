import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_tmdb_prueba/core/models/movie_list_popular_response.dart';
import 'package:flutter_application_tmdb_prueba/core/services/movie_changes_service.dart';

import 'movie_changes_event.dart';
import 'movie_changes_state.dart';

class MovieChangesBloc extends Bloc<MovieChangesEvent, MovieChangesState> {
  final MovieChangesService changesService;

  MovieChangesBloc({MovieChangesService? service})
      : changesService = service ?? MovieChangesService(),
        super(const MovieChangesInitial()) {
    on<FetchMovieChanges>(_onFetchMovieChanges);
  }

  Future<void> _onFetchMovieChanges(
    FetchMovieChanges event,
    Emitter<MovieChangesState> emit,
  ) async {
    emit(const MovieChangesLoading());
    try {
      final List<Movie> movies = await changesService.getPopularMovies();
      emit(MovieChangesLoaded(movies));
    } catch (e) {
      emit(const MovieChangesFailure(
          'No se pudieron cargar las películas populares'));
    }
  }
}
