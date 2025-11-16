// lib/controllers/route_feedback_controller.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/route_feedback_model.dart';

class RouteFeedbackController {
  final _client = Supabase.instance.client;

  /// Fetch all feedback for a given route, including user name
  Future<List<RouteFeedback>> fetchForRoute(int routeId) async {
    final data = await _client
        .from('route_feedback')
        .select(
          // Join with profiles table to get full_name
          'id, route_id, user_id, rating, comment, created_at, profiles(full_name)',
        )
        .eq('route_id', routeId)
        .order('created_at', ascending: false);

    final list = (data as List)
        .map((row) => RouteFeedback.fromJson(row as Map<String, dynamic>))
        .toList();

    return list;
  }

  /// Add a new feedback entry
  Future<String?> addFeedback({
    required int routeId,
    required int rating, // 1–5
    required String comment,
  }) async {
    final userId = _client.auth.currentUser?.id;

    if (userId == null) {
      return 'You must be logged in to leave feedback.';
    }

    try {
      await _client.from('route_feedback').insert({
        'route_id': routeId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
      });

      return null; // success
    } catch (e) {
      return 'Failed to submit feedback: $e';
    }
  }

  /// Delete feedback (only if owned by the current user)
  Future<String?> deleteFeedback(int feedbackId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return 'You must be logged in.';
    }

    try {
      await _client
          .from('route_feedback')
          .delete()
          .eq('id', feedbackId)
          .eq('user_id', userId);

      return null;
    } catch (e) {
      return 'Failed to delete feedback: $e';
    }
  }

  /// Compute average rating for a route from the feedback table
  Future<double?> averageForRoute(int routeId) async {
    final res = await _client
        .from('route_feedback')
        .select('rating')
        .eq('route_id', routeId);

    // res is a List<dynamic>
    if (res.isEmpty) return null;

    double sum = 0;
    for (final row in res) {
      sum += (row['rating'] as num).toDouble();
    }

    return sum / res.length;
  }
}
