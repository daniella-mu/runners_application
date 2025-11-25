// lib/controllers/route_feedback_controller.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/route_feedback_model.dart';

class RouteFeedbackController {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch all feedback for a route, including the user's name from profiles
  Future<List<RouteFeedback>> fetchForRoute(int routeId) async {
    try {
      final data = await _client
          .from('route_feedback')
          .select(
            'id, route_id, user_id, rating, comment, created_at, profiles(full_name)',
          )
          .eq('route_id', routeId)
          .order('created_at', ascending: false);

      final list = data as List<dynamic>;
      return list
          .map((row) => RouteFeedback.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      debugPrint('fetchForRoute error: $e');
      debugPrint('$st');
      return [];
    }
  }

  /// Optional helper – read the current average_rating from routes
  Future<double> averageForRoute(int routeId) async {
    try {
      final resp = await _client
          .from('routes')
          .select('average_rating')
          .eq('route_id', routeId) // your PK is route_id
          .maybeSingle();

      if (resp == null) return 0.0;
      final val = resp['average_rating'];
      return (val as num?)?.toDouble() ?? 0.0;
    } catch (e, st) {
      debugPrint('averageForRoute error: $e');
      debugPrint('$st');
      return 0.0;
    }
  }

  /// Add feedback. Returns null on success, or an error message on failure.
  Future<String?> addFeedback({
    required int routeId,
    required int rating,
    required String comment,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return 'You must be logged in to leave feedback.';
    }

    // 1) Insert feedback – this is what the user actually cares about.
    try {
      await _client.from('route_feedback').insert({
        'route_id': routeId,
        'user_id': user.id,
        'rating': rating,
        'comment': comment,
      });
    } catch (e, st) {
      debugPrint('addFeedback insert error: $e');
      debugPrint('$st');
      return 'Failed to submit feedback. Please try again.';
    }

    // 2) Recompute aggregate stats in routes (best-effort; errors are logged only)
    try {
      await _recomputeRouteStats(routeId);
    } catch (e, st) {
      debugPrint('recomputeRouteStats error (ignored for UI): $e');
      debugPrint('$st');
    }

    return null; // success
  }

  /// Delete feedback (only if owned by the current user), then recompute stats.
  /// Returns null on success, or an error message on failure.
  Future<String?> deleteFeedback(int feedbackId, int routeId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return 'You must be logged in.';
    }

    // 1) Delete only this user's feedback row
    try {
      await _client
          .from('route_feedback')
          .delete()
          .eq('id', feedbackId)
          .eq('user_id', user.id);
    } catch (e, st) {
      debugPrint('deleteFeedback error: $e');
      debugPrint('$st');
      return 'Failed to delete feedback.';
    }

    // 2) Best-effort recompute stats after delete
    try {
      await _recomputeRouteStats(routeId);
    } catch (e, st) {
      debugPrint('recomputeRouteStats after delete error (ignored): $e');
      debugPrint('$st');
    }

    return null;
  }

  /// INTERNAL: recompute average_rating & popularity in routes from route_feedback.
  Future<void> _recomputeRouteStats(int routeId) async {
    // Get all ratings for this route
    final rows =
        await _client
                .from('route_feedback')
                .select('rating')
                .eq('route_id', routeId)
            as List<dynamic>;

    if (rows.isEmpty) {
      // No feedback → reset stats
      await _client
          .from('routes')
          .update({'average_rating': 0, 'popularity': 0})
          .eq('route_id', routeId); // your PK here
      return;
    }

    double sum = 0;
    for (final r in rows) {
      sum += (r['rating'] as num).toDouble();
    }
    final count = rows.length;
    final avg = sum / count;

    await _client
        .from('routes')
        .update({'average_rating': avg, 'popularity': count})
        .eq('route_id', routeId);
  }
}
