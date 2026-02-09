class PeopleChangesResponse {
  final List<PersonChange> results;
  final int page;
  final int totalPages;
  final int totalResults;

  PeopleChangesResponse({
    required this.results,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  });

  factory PeopleChangesResponse.fromJson(Map<String, dynamic> json) =>
      PeopleChangesResponse(
        results: List<PersonChange>.from(
          json["results"].map((x) => PersonChange.fromJson(x)),
        ),
        page: json["page"] ?? 1,
        totalPages: json["total_pages"] ?? 0,
        totalResults: json["total_results"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "results": List<dynamic>.from(results.map((x) => x.toJson())),
    "page": page,
    "total_pages": totalPages,
    "total_results": totalResults,
  };
}

class PersonChange {
  final int id;
  final bool adult;

  PersonChange({
    required this.id,
    required this.adult,
  });

  factory PersonChange.fromJson(Map<String, dynamic> json) => PersonChange(
    id: json["id"] ?? 0,
    adult: json["adult"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "adult": adult,
  };
}
