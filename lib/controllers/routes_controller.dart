import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/route_model.dart';
import 'package:flutter/foundation.dart';

class RoutesController {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch all routes from Supabase `routes` table
  Future<List<RouteModel>> fetchRoutes() async {
    try {
      final response = await _client.from('routes').select();

      // response is a List<dynamic>
      final data = response as List<dynamic>;

      return data.map((json) => RouteModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error fetching routes: $e");
      return [];
    }
  }
}
