import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tmdb/core/interfaces/movies_list_interface.dart';
import 'package:flutter_tmdb/core/models/movies_list_popular_response.dart';
import 'package:flutter_tmdb/core/services/movie_service.dart';

import 'popular_movies_event.dart';
import 'popular_movies_state.dart';

class PopularMoviesBloc
    extends Bloc<PopularMoviesEvent, PopularMoviesState> {
  final MoviesListInterface moviesService;

  PopularMoviesBloc({MoviesListInterface? service})
      : moviesService = service ?? MovieService(),
        super(const PopularMoviesInitial()) {
    on<FetchPopularMovies>(_onFetchPopularMovies);
  }

  Future<void> _onFetchPopularMovies(
    FetchPopularMovies event,
    Emitter<PopularMoviesState> emit,
  ) async {
    emit(const PopularMoviesLoading());
    try {
      final List<Movie> movies =
          await moviesService.getList(MovieListType.popular);
      emit(PopularMoviesLoaded(movies));
    } catch (e) {
      emit(const PopularMoviesFailure(
          'No se pudieron cargar las películas populares'));
    }
  }
}
