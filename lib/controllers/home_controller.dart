// lib/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/models/user_model.dart';
import 'auth_controller.dart';

class HomeController {
  final SupabaseClient _client = Supabase.instance.client;
  final AuthController _authController = AuthController();

  /// Get the currently logged-in user as a minimal UserModel
  /// (used as a fallback if the profile row is missing).
  UserModel? getCurrentUserModel() {
    final user = _authController.getCurrentUser();
    if (user != null) {
      return UserModel(
        id: user.id,
        email: user.email ?? '',
        fullName: 'Runner', // fallback name
        // isAdmin defaults to false
      );
    }
    return null;
  }

  /// Fetch full profile from Supabase "profiles" table.
  /// Includes id, email, full_name, is_admin and all extra profile fields.
  Future<UserModel?> fetchUserProfile(String uid) async {
    try {
      final authUser = _authController.getCurrentUser();

      final data = await _client
          .from('profiles')
          .select('''
            id,
            email,
            full_name,
            is_admin,
            dob,
            gender,
            location,
            experience,
            preferred_time,
            emergency_contact,
            profile_image_url
            ''')
          .eq('id', uid)
          .maybeSingle(); // won't throw if 0 rows

      if (data == null) {
        debugPrint('No profile found for user $uid');

        if (authUser == null) return null;

        // Fallback: build a minimal UserModel
        return UserModel(
          id: uid,
          email: authUser.email ?? '',
          fullName: 'Runner',
          // isAdmin defaults to false
        );
      }

      // Normal case: map directly from DB into UserModel
      return UserModel.fromJson(data);
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
