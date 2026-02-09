import 'dart:convert';

import 'package:flutter_tmdb/core/interfaces/movies_list_interface.dart';
import 'package:flutter_tmdb/core/models/movies_list_popular_response.dart';
import 'package:http/http.dart' as http;

enum MovieListType {
  popular("popular"),
  topRated("top_rated"),
  nowPlaying("now_playing"),
  upcoming("upcoming");

  final String value;
  const MovieListType(this.value);

}

class MovieService implements MoviesListInterface {
  final String _apiBaseUrl = "https://api.themoviedb.org/3/movie";
  final String _bearerToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmNTEzMzQ2NGVhNjAyMTBhN2Q1NmZmZDJhMzI2N2RjNSIsIm5iZiI6MTc2MzM2Nzc5OS43ODIsInN1YiI6IjY5MWFkYjc3YTU0YWM4MDdiNDgxYzAyMSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.ezqzpkgAfuLHPMWf2AKsJYR2u0KqYzHBNgSubp6CkQs";

  @override
  Future<List<Movie>> getList(MovieListType listType) async {
    var response = await http.get(
      Uri.parse("$_apiBaseUrl/${listType.value}"),
      headers: {
        'Authorization': 'Bearer $_bearerToken',
        'accept': 'application/json',
      },
    );
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var moviesList = MovieListPopularResponse.fromJson(
          json.decode(response.body),
        ).results;
        return moviesList;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("Error al obtener las películas populares");
    }
  }
}
