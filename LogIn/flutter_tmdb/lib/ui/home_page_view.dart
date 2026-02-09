import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tmdb/core/bloc/people_changes/people_changes_bloc.dart';
import 'package:flutter_tmdb/core/bloc/people_changes/people_changes_event.dart';
import 'package:flutter_tmdb/core/bloc/people_changes/people_changes_state.dart';
import 'package:flutter_tmdb/core/bloc/popular_movies/popular_movies_bloc.dart';
import 'package:flutter_tmdb/core/bloc/popular_movies/popular_movies_event.dart';
import 'package:flutter_tmdb/core/bloc/popular_movies/popular_movies_state.dart';
import 'package:flutter_tmdb/core/models/movies_list_popular_response.dart';
import 'package:flutter_tmdb/core/models/people_changes_response.dart';
import 'package:flutter_tmdb/core/services/movie_service.dart';
import 'package:flutter_tmdb/core/services/people_changes_service.dart';

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TMDB')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Populares',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8.0),
              SizedBox(
                height: 220,
                child: BlocProvider(
                  create: (_) => PopularMoviesBloc(service: MovieService())
                    ..add(const FetchPopularMovies()),
                  child: BlocBuilder<PopularMoviesBloc, PopularMoviesState>(
                    builder: (context, state) {
                      if (state is PopularMoviesLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is PopularMoviesFailure) {
                        return Center(child: Text(state.message));
                      }
                      if (state is PopularMoviesLoaded) {
                        return _HorizontalMoviesList(movies: state.movies);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Cambios Recientes',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8.0),
              SizedBox(
                height: 220,
                child: BlocProvider(
                  create: (_) => PeopleChangesBloc(changesService: PeopleChangesService())
                    ..add(const FetchPeopleChanges()),
                  child: BlocBuilder<PeopleChangesBloc, PeopleChangesState>(
                    builder: (context, state) {
                      if (state is PeopleChangesLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is PeopleChangesFailure) {
                        return Center(child: Text(state.message));
                      }
                      if (state is PeopleChangesLoaded) {
                        return _HorizontalPeopleChangesList(changes: state.changes);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HorizontalMoviesList extends StatelessWidget {
  final List<Movie> movies;

  const _HorizontalMoviesList({required this.movies});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(child: Text('Sin resultados'));
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) {
        final movie = movies[index];
        return _MovieCard(movie: movie);
      },
      separatorBuilder: (context, index) => const SizedBox(width: 12.0),
      itemCount: movies.length,
    );
  }
}

class _MovieCard extends StatelessWidget {
  final Movie movie;

  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    final imageUrl = movie.posterPath != null
        ? 'https://image.tmdb.org/t/p/w300${movie.posterPath}'
        : null;

    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: AspectRatio(
              aspectRatio: 2/3,
              child: imageUrl != null
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.movie, size: 48),
                    ),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _HorizontalPeopleChangesList extends StatelessWidget {
  final List<PersonChange> changes;

  const _HorizontalPeopleChangesList({required this.changes});

  @override
  Widget build(BuildContext context) {
    if (changes.isEmpty) {
      return const Center(child: Text('Sin cambios'));
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) {
        final change = changes[index];
        return _PersonChangeCard(change: change);
      },
      separatorBuilder: (context, index) => const SizedBox(width: 12.0),
      itemCount: changes.length,
    );
  }
}

class _PersonChangeCard extends StatelessWidget {
  final PersonChange change;

  const _PersonChangeCard({required this.change});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              change.adult ? Icons.person : Icons.person_outline,
              size: 48,
              color: Colors.blue,
            ),
            const SizedBox(height: 8.0),
            Text(
              'ID: ${change.id}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4.0),
            Text(
              change.adult ? 'Mayor de edad' : 'No especificado',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
