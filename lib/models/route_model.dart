class RouteModel {
  final int routeId;
  final String name;
  final String description;
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  final int distanceM;
  final double averageRating;
  final int popularity;

  RouteModel({
    required this.routeId,
    required this.name,
    required this.description,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.distanceM,
    required this.averageRating,
    required this.popularity,
  });

  // Factory for Supabase row → Dart object
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      routeId: json['route_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      startLatitude: (json['start_latitude'] as num).toDouble(),
      startLongitude: (json['start_longitude'] as num).toDouble(),
      endLatitude: (json['end_latitude'] as num).toDouble(),
      endLongitude: (json['end_longitude'] as num).toDouble(),
      distanceM: json['distance_m'] as int,
      averageRating: (json['average_rating'] as num).toDouble(),
      popularity: json['popularity'] as int,
    );
  }

  // Convert Dart object → JSON (for inserts/updates)
  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'name': name,
      'description': description,
      'start_latitude': startLatitude,
      'start_longitude': startLongitude,
      'end_latitude': endLatitude,
      'end_longitude': endLongitude,
      'distance_m': distanceM,
      'average_rating': averageRating,
      'popularity': popularity,
    };
  }
}
