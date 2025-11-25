import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/user_model.dart';

class UserController {
  final SupabaseClient _client = Supabase.instance.client;

  /// Create a new profile row in `profiles`
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _client.from('profiles').insert(user.toJson());
    } catch (e) {
      throw Exception('Error creating user profile: $e');
    }
  }

  /// Fetch the logged-in user's profile including is_admin
  Future<UserModel?> fetchCurrentUserProfile() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    try {
      final data = await _client
          .from('profiles')
          .select('id, email, full_name, is_admin')
          .eq('id', authUser.id)
          .single();

      return UserModel.fromJson(data);
    } catch (e) {
      throw Exception('Error loading user profile: $e');
    }
  }
}
