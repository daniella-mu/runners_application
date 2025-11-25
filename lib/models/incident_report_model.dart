class IncidentReport {
  final int incidentId;
  final int routeId;
  final String userId;
  final String incidentType;
  final String severity;
  final String? description;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  // Existing fields
  final List<String>? photoUrls;
  final String? userName;

  // NEW: route name from routes(name)
  final String? routeName;

  IncidentReport({
    required this.incidentId,
    required this.routeId,
    required this.userId,
    required this.incidentType,
    required this.severity,
    this.description,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.photoUrls,
    this.userName,
    this.routeName, // NEW
  });

  factory IncidentReport.fromJson(Map<String, dynamic> json) {
    // --------- profiles(full_name) ----------
    String? name;
    final profiles = json['profiles'];
    if (profiles is Map<String, dynamic>) {
      name = profiles['full_name'] as String?;
    }

    // --------- routes(name) ----------
    String? rName;
    final routes = json['routes'];
    if (routes is Map<String, dynamic>) {
      rName = routes['name'] as String?;
    }

    // --------- photo_urls ----------
    List<String>? photos;
    final rawPhotos = json['photo_urls'];
    if (rawPhotos is List) {
      photos = rawPhotos.map((e) => e.toString()).toList();
    }

    return IncidentReport(
      incidentId: json['incident_id'] as int,
      routeId: json['route_id'] as int,
      userId: json['user_id'] as String,
      incidentType: json['incident_type'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),

      photoUrls: photos,
      userName: name,
      routeName: rName, // NEW (this fixes admin screen)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'incident_id': incidentId,
      'route_id': routeId,
      'user_id': userId,
      'incident_type': incidentType,
      'severity': severity,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'photo_urls': photoUrls,
    };
  }
}
