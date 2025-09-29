import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/user_model.dart';

class UserController {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> createUserProfile(UserModel user) async {
    try {
      await _client.from('users').insert(user.toJson());
    } catch (e) {
      throw Exception('Error creating user profile: $e');
    }
  }
}
