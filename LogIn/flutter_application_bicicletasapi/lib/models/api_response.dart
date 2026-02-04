import 'package:equatable/equatable.dart';
import 'aparcamiento.dart';

/// Modelo que representa la respuesta del API de Valencia
class ApiResponse extends Equatable {
  final int totalCount;
  final List<Aparcamiento> results;

  const ApiResponse({
    required this.totalCount,
    required this.results,
  });

  /// Crea una instancia de ApiResponse desde JSON
  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      totalCount: json['total_count'] ?? 0,
      results: (json['results'] as List<dynamic>?)
              ?.map((item) => Aparcamiento.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Convierte la respuesta a JSON
  Map<String, dynamic> toJson() {
    return {
      'total_count': totalCount,
      'results': results.map((aparcamiento) => aparcamiento.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [totalCount, results];
}
