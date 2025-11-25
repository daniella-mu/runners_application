// lib/controllers/admin_feedback_controller.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/route_feedback_model.dart';

class AdminFeedbackController {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<RouteFeedback>> fetchAllFeedback() async {
    try {
      final resp = await _client
          .from('route_feedback')
          .select(
            'id, route_id, user_id, rating, comment, created_at, '
            'profiles(full_name), routes(name)',
          )
          .order('created_at', ascending: false);

      final list = resp as List<dynamic>;
      return list
          .map((row) => RouteFeedback.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      debugPrint('fetchAllFeedback error: $e');
      debugPrint('$st');
      return [];
    }
  }

  /// ADMIN: delete feedback and recalc route average
  Future<String?> adminDeleteFeedback({
    required int feedbackId,
    required int routeId,
  }) async {
    try {
      // 1) delete the feedback row
      await _client.from('route_feedback').delete().eq('id', feedbackId);

      // 2) recalc average rating for that route
      final ratingsResp = await _client
          .from('route_feedback')
          .select('rating')
          .eq('route_id', routeId);

      final ratingsList = ratingsResp as List<dynamic>;

      double newAvg = 0;
      int newCount = ratingsList.length;

      if (newCount > 0) {
        int sum = 0;
        for (final row in ratingsList) {
          sum += (row['rating'] as num).toInt();
        }
        newAvg = sum / newCount;
      }

      // 3) update routes table
      await _client
          .from('routes')
          .update({
            'average_rating': newAvg,
            'popularity': newCount, // optional if you use this as count
          })
          .eq('route_id', routeId);

      return null;
    } catch (e, st) {
      debugPrint('adminDeleteFeedback error: $e');
      debugPrint('$st');
      return 'Failed to delete feedback.';
    }
  }
}
