import 'dart:convert';

import 'package:flutter_tmdb/core/models/people_changes_response.dart';
import 'package:http/http.dart' as http;

class PeopleChangesService {
  final String _apiBaseUrl = "https://api.themoviedb.org/3/person/changes";
  final String _bearerToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmNTEzMzQ2NGVhNjAyMTBhN2Q1NmZmZDJhMzI2N2RjNSIsIm5iZiI6MTc2MzM2Nzc5OS43ODIsInN1YiI6IjY5MWFkYjc3YTU0YWM4MDdiNDgxYzAyMSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.ezqzpkgAfuLHPMWf2AKsJYR2u0KqYzHBNgSubp6CkQs";

  Future<List<PersonChange>> getChanges({
    int page = 1,
    String? startDate,
    String? endDate,
  }) async {
    String url = "$_apiBaseUrl?page=$page";
    
    if (startDate != null) {
      url += "&start_date=$startDate";
    }
    if (endDate != null) {
      url += "&end_date=$endDate";
    }

    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_bearerToken',
        'accept': 'application/json',
      },
    );
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var changesList = PeopleChangesResponse.fromJson(
          json.decode(response.body),
        ).results;
        return changesList;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("Error al obtener los cambios de personas");
    }
  }
}
