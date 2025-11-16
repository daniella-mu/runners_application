class RouteFeedback {
  final int id;
  final int routeId;
  final String userId;
  final int rating; // 1–5
  final String comment;
  final DateTime createdAt;
  final String? userName; // 👈 from profiles.full_name

  RouteFeedback({
    required this.id,
    required this.routeId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.userName,
  });

  factory RouteFeedback.fromJson(Map<String, dynamic> json) {
    // Supabase join: profiles(full_name)
    final profile = json['profiles'] as Map<String, dynamic>?;

    return RouteFeedback(
      id: json['id'] as int,
      routeId: json['route_id'] as int,
      userId: json['user_id'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: profile?['full_name'] as String?, // may be null
    );
  }
}
