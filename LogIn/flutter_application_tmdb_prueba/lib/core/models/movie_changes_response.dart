class MovieChangesResponse {
  final List<MovieChange> results;
  final int page;
  final int totalPages;
  final int totalResults;

  MovieChangesResponse({
    required this.results,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  });

  factory MovieChangesResponse.fromJson(Map<String, dynamic> json) =>
      MovieChangesResponse(
        results: List<MovieChange>.from(
          json["results"].map((x) => MovieChange.fromJson(x)),
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

class MovieChange {
  final int id;
  final bool adult;

  MovieChange({
    required this.id,
    required this.adult,
  });

  factory MovieChange.fromJson(Map<String, dynamic> json) => MovieChange(
    id: json["id"] ?? 0,
    adult: json["adult"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "adult": adult,
  };
}
