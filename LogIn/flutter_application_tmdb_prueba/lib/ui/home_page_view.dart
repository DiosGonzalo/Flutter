import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_tmdb_prueba/core/bloc/movie_changes/movie_changes_bloc.dart';
import 'package:flutter_application_tmdb_prueba/core/bloc/movie_changes/movie_changes_event.dart';
import 'package:flutter_application_tmdb_prueba/core/bloc/movie_changes/movie_changes_state.dart';
import 'package:flutter_application_tmdb_prueba/core/bloc/person_changes/person_changes_bloc.dart';
import 'package:flutter_application_tmdb_prueba/core/bloc/person_changes/person_changes_event.dart';
import 'package:flutter_application_tmdb_prueba/core/bloc/person_changes/person_changes_state.dart';
import 'package:flutter_application_tmdb_prueba/core/models/movie_list_popular_response.dart';
import 'package:flutter_application_tmdb_prueba/core/models/people_list_popular_response.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  bool showMovies = true; // true = películas, false = personas

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TMDB Populares'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showMovies = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            color: showMovies ? Colors.black : Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Center(
                            child: Text(
                              'Películas',
                              style: TextStyle(
                                color: showMovies ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showMovies = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            color: !showMovies ? Colors.black : Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Center(
                            child: Text(
                              'Actores',
                              style: TextStyle(
                                color: !showMovies ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: showMovies ? const _MoviesView() : const _PersonsView(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoviesView extends StatefulWidget {
  const _MoviesView();

  @override
  State<_MoviesView> createState() => _MoviesViewState();
}

class _MoviesViewState extends State<_MoviesView> {
  int? _selectedMovieId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
          child: Text(
            'Películas Populares',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: BlocProvider(
            create: (_) => MovieChangesBloc()..add(const FetchMovieChanges()),
            child: BlocBuilder<MovieChangesBloc, MovieChangesState>(
              builder: (context, state) {
                if (state is MovieChangesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MovieChangesFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                      ],
                    ),
                  );
                }
                if (state is MovieChangesLoaded) {
                  return _MoviesList(
                    movies: state.movies,
                    selectedMovieId: _selectedMovieId,
                    onMovieSelected: (movieId) {
                      setState(() {
                        _selectedMovieId = _selectedMovieId == movieId ? null : movieId;
                      });
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _PersonsView extends StatefulWidget {
  const _PersonsView();

  @override
  State<_PersonsView> createState() => _PersonsViewState();
}

class _PersonsViewState extends State<_PersonsView> {
  int? _selectedPersonId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
          child: Text(
            'Actores Populares',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: BlocProvider(
            create: (_) =>
                PersonChangesBloc()..add(const FetchPersonChanges()),
            child: BlocBuilder<PersonChangesBloc, PersonChangesState>(
              builder: (context, state) {
                if (state is PersonChangesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is PersonChangesFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                      ],
                    ),
                  );
                }
                if (state is PersonChangesLoaded) {
                  return _PersonsList(
                    people: state.people,
                    selectedPersonId: _selectedPersonId,
                    onPersonSelected: (personId) {
                      setState(() {
                        _selectedPersonId = _selectedPersonId == personId ? null : personId;
                      });
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MoviesList extends StatelessWidget {
  final List<Movie> movies;
  final int? selectedMovieId;
  final Function(int) onMovieSelected;

  const _MoviesList({
    required this.movies,
    required this.selectedMovieId,
    required this.onMovieSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Sin películas'),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        final isSelected = selectedMovieId == movie.id;
        return _MovieCard(
          movie: movie,
          isSelected: isSelected,
          onTap: () => onMovieSelected(movie.id),
        );
      },
    );
  }
}

class _MovieCard extends StatelessWidget {
  final Movie movie;
  final bool isSelected;
  final VoidCallback onTap;

  const _MovieCard({
    required this.movie,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = movie.posterPath != null
        ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
        : null;

    return InkWell(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: isSelected ? 8 : 4,
        color: isSelected ? Colors.deepPurple.shade50 : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? Colors.deepPurple : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade300,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.movie, size: 48);
                        },
                      )
                    : const Icon(Icons.movie, size: 48),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? Colors.deepPurple : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: isSelected ? Colors.deepPurple : Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        movie.voteAverage.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.deepPurple : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonsList extends StatelessWidget {
  final List<Person> people;
  final int? selectedPersonId;
  final Function(int) onPersonSelected;

  const _PersonsList({
    required this.people,
    required this.selectedPersonId,
    required this.onPersonSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Sin actores'),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
      ),
      itemCount: people.length,
      itemBuilder: (context, index) {
        final person = people[index];
        final isSelected = selectedPersonId == person.id;
        return _PersonCard(
          person: person,
          isSelected: isSelected,
          onTap: () => onPersonSelected(person.id),
        );
      },
    );
  }
}

class _PersonCard extends StatelessWidget {
  final Person person;
  final bool isSelected;
  final VoidCallback onTap;

  const _PersonCard({
    required this.person,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = person.profilePath != null
        ? 'https://image.tmdb.org/t/p/w500${person.profilePath}'
        : null;

    return InkWell(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: isSelected ? 8 : 4,
        color: isSelected ? Colors.blue.shade50 : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade300,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, size: 48);
                        },
                      )
                    : const Icon(Icons.person, size: 48),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? Colors.blue.shade800 : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    person.knownForDepartment,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
