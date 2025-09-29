// lib/controllers/home_controller.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/user_model.dart';
import 'auth_controller.dart';
import 'package:flutter/material.dart';

class HomeController {
  final SupabaseClient _client = Supabase.instance.client;
  final AuthController _authController = AuthController();

  /// Get the currently logged-in user as a UserModel (manual mapping)
  UserModel? getCurrentUserModel() {
    final user = _authController.getCurrentUser();
    if (user != null) {
      return UserModel(
        id: user.id,
        email: user.email,
        fullName: null, // fullName will be fetched from Supabase if available
      );
    }
    return null;
  }

  /// Fetch full profile from Supabase "profiles" table
  Future<UserModel?> fetchUserProfile(String uid) async {
    try {
      final data = await _client
          .from('profiles')
          .select('*')
          .eq('id', uid)
          .maybeSingle(); // ✅ safe: won't throw if 0 rows

      final authUser = _authController.getCurrentUser();

      if (data == null) {
        debugPrint('No profile found for user $uid');
        return UserModel(
          id: uid,
          email: authUser?.email,
          fullName: "Runner",
        );
      }

      //  inject email from auth into the model
      return UserModel.fromJson(data, email: authUser?.email);
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    try {
      await _authController.logout();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }
}
