class RunModel {
  final int id;
  final String userId;
  final int? routeId;
  final double distanceM;
  final int durationS;
  final DateTime startedAt;
  final DateTime endedAt;

  RunModel({
    required this.id,
    required this.userId,
    required this.routeId,
    required this.distanceM,
    required this.durationS,
    required this.startedAt,
    required this.endedAt,
  });

  double get distanceKm => distanceM / 1000.0;
  Duration get duration => Duration(seconds: durationS);

  /// Minutes per km; 0 if distance is 0.
  double get paceMinPerKm {
    if (distanceM <= 0) return 0;
    return duration.inSeconds / 60.0 / (distanceM / 1000.0);
  }

  factory RunModel.fromMap(Map<String, dynamic> m) => RunModel(
    id: m['id'] as int,
    userId: m['user_id'] as String,
    routeId: m['route_id'] as int?,
    distanceM: (m['distance_m'] as num).toDouble(),
    durationS: m['duration_s'] as int,
    startedAt: DateTime.parse(m['started_at'] as String),
    endedAt: DateTime.parse(m['ended_at'] as String),
  );
}
