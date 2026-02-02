import 'dart:convert';

import 'people.dart';

class PeopleListResponse {
  int? count;
  String? next;
  dynamic previous;
  List<People>? results;

  PeopleListResponse({this.count, this.next, this.previous, this.results});

  factory PeopleListResponse.fromMap(Map<String, dynamic> data) {
    return PeopleListResponse(
      count: data['count'] as int?,
      next: data['next'] as String?,
      previous: data['previous'] as dynamic,
      results: (data['results'] as List<dynamic>?)
          ?.map((e) => People.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'count': count,
        'next': next,
        'previous': previous,
        'results': results?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [PeopleListResponse].
  factory PeopleListResponse.fromJson(String data) {
    return PeopleListResponse.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [PeopleListResponse] to a JSON string.
  String toJson() => json.encode(toMap());
}