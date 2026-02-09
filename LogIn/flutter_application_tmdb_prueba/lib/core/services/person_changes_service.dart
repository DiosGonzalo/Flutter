import 'dart:convert';

import 'package:flutter_application_tmdb_prueba/core/models/people_list_popular_response.dart';
import 'package:http/http.dart' as http;

class PersonChangesService {
  final String _apiBaseUrl = "https://api.themoviedb.org/3/person/popular";
  final String _bearerToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmNTEzMzQ2NGVhNjAyMTBhN2Q1NmZmZDJhMzI2N2RjNSIsIm5iZiI6MTc2MzM2Nzc5OS43ODIsInN1YiI6IjY5MWFkYjc3YTU0YWM4MDdiNDgxYzAyMSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.ezqzpkgAfuLHPMWf2AKsJYR2u0KqYzHBNgSubp6CkQs";

  Future<List<Person>> getPopularPeople({
    int page = 1,
  }) async {
    String url = "$_apiBaseUrl?page=$page";

    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_bearerToken',
        'accept': 'application/json',
      },
    );
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var peopleList = PeopleListPopularResponse.fromJson(
          json.decode(response.body),
        ).results;
        return peopleList;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("Error al obtener las personas populares");
    }
  }
}
