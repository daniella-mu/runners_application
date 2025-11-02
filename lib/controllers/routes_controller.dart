import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/route_model.dart';
import 'package:flutter/foundation.dart';

class RoutesController {
  final SupabaseClient _client = Supabase.instance.client;

  /// 🔹 Fetch routes with optional filters
  Future<List<RouteModel>> fetchRoutes({
    double? maxDistance,   // e.g., 5000 meters
    double? minRating,     // e.g., 4.0
    int? minPopularity,    // e.g., 70
  }) async {
    try {
      var query = _client.from('routes').select();

      // Apply filters only if provided
      if (maxDistance != null) query = query.lt('distance_m', maxDistance);
      if (minRating != null) query = query.gte('average_rating', minRating);
      if (minPopularity != null) query = query.gte('popularity', minPopularity);

      final response = await query;
      final data = response as List<dynamic>;

      return data.map((json) => RouteModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error fetching routes: $e");
      return [];
    }
  }

  /// 🔍 Search routes by name or description
  Future<List<RouteModel>> searchRoutes(String term) async {
    try {
      final resp = await _client
          .from('routes')
          .select()
          .or('name.ilike.%$term%,description.ilike.%$term%'); // match either column

      final data = resp as List<dynamic>;
      return data.map((j) => RouteModel.fromJson(j)).toList();
    } catch (e) {
      debugPrint('searchRoutes error: $e');
      return [];
    }
  }

  /// 🟢 Add a new route (CREATE)
  Future<bool> addRoute({
    required String name,
    required String description,
    required int distanceM,
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    try {
      final uid = Supabase.instance.client.auth.currentUser!.id; // current logged-in user

      await _client.from('routes').insert({
        'name': name,
        'description': description,
        'distance_m': distanceM,
        'start_latitude': startLat,
        'start_longitude': startLng,
        'end_latitude': endLat,
        'end_longitude': endLng,
        'average_rating': 0,   // default
        'popularity': 0,       // default
        'user_id': uid,        // link route to logged-in user
      });

      return true; // success
    } catch (e) {
      debugPrint("Error adding route: $e");
      return false; // fail
    }
  }
}
