// lib/controllers/admin_users_controller.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/user_model.dart';

class AdminUsersController {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch ALL users from profiles table.
  Future<List<UserModel>> fetchAllUsers() async {
    try {
      final resp = await _client
          .from('profiles')
          // 🔹 Select *all* existing columns, no fragile list
          .select()
          .order('full_name', ascending: true);

      debugPrint('AdminUsersController: raw resp = $resp');

      final list = resp as List<dynamic>;

      return list.map((row) {
        final map = Map<String, dynamic>.from(row as Map<String, dynamic>);

        // Make sure these are never null for the model
        map['is_admin'] = map['is_admin'] ?? false;
        map['is_active'] = map['is_active'] ?? true;

        // There is no 'email' column in your table, so this will just become ''
        // because your UserModel.fromJson does: json['email'] as String? ?? ''
        return UserModel.fromJson(map);
      }).toList();
    } catch (e, st) {
      debugPrint("Admin fetch error: $e");
      debugPrint("STACK: $st");
      return [];
    }
  }

  /// Toggle admin role.
  Future<String?> setAdminStatus({
    required String userId,
    required bool isAdmin,
  }) async {
    try {
      await _client
          .from('profiles')
          .update({'is_admin': isAdmin})
          .eq('id', userId);
      return null;
    } catch (e) {
      debugPrint("setAdminStatus error: $e");
      return 'Failed to update admin status.';
    }
  }

  /// Activate / deactivate user.
  Future<String?> setActiveStatus({
    required String userId,
    required bool isActive,
  }) async {
    try {
      await _client
          .from('profiles')
          .update({'is_active': isActive})
          .eq('id', userId);
      return null;
    } catch (e) {
      debugPrint("setActiveStatus error: $e");
      return 'Failed to update user status.';
    }
  }
}
