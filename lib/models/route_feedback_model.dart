// lib/models/route_feedback_model.dart

class RouteFeedback {
  final int id;
  final int routeId;
  final String userId;
  final int rating; // 1–5
  final String comment;
  final DateTime createdAt;

  // 👇 Joins
  final String? userName; // from profiles.full_name
  final String? routeName; // from routes.name (for admin)

  RouteFeedback({
    required this.id,
    required this.routeId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.userName,
    this.routeName,
  });

  factory RouteFeedback.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'];
    final route = json['routes'];

    return RouteFeedback(
      id: json['id'] as int,
      routeId: json['route_id'] as int,
      userId: json['user_id'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: profile is Map<String, dynamic>
          ? profile['full_name'] as String?
          : null,
      routeName: route is Map<String, dynamic>
          ? route['name'] as String?
          : null,
    );
  }
}
