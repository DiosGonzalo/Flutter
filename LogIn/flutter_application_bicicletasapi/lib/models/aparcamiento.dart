import 'package:equatable/equatable.dart';

/// Modelo que representa un aparcamiento de bicicletas
class Aparcamiento extends Equatable {
  final String tipo;
  final int objectid;
  final int numplazas;
  final GeoPoint geoPoint;

  const Aparcamiento({
    required this.tipo,
    required this.objectid,
    required this.numplazas,
    required this.geoPoint,
  });

  /// Crea una instancia de Aparcamiento desde JSON
  factory Aparcamiento.fromJson(Map<String, dynamic> json) {
    return Aparcamiento(
      tipo: json['tipo'] ?? 'Desconocido',
      objectid: json['objectid'] ?? 0,
      numplazas: json['numplazas'] ?? 0,
      geoPoint: GeoPoint.fromJson(json['geo_point_2d'] ?? {}),
    );
  }

  /// Convierte el aparcamiento a JSON
  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'objectid': objectid,
      'numplazas': numplazas,
      'geo_point_2d': geoPoint.toJson(),
    };
  }

  @override
  List<Object?> get props => [tipo, objectid, numplazas, geoPoint];
}

/// Modelo que representa las coordenadas geográficas
class GeoPoint extends Equatable {
  final double lon;
  final double lat;

  const GeoPoint({
    required this.lon,
    required this.lat,
  });

  /// Crea una instancia de GeoPoint desde JSON
  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      lon: (json['lon'] ?? 0.0).toDouble(),
      lat: (json['lat'] ?? 0.0).toDouble(),
    );
  }

  /// Convierte las coordenadas a JSON
  Map<String, dynamic> toJson() {
    return {
      'lon': lon,
      'lat': lat,
    };
  }

  @override
  List<Object?> get props => [lon, lat];
}
