import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AuthController {
  final SupabaseClient _client = Supabase.instance.client;

  /// --------------------------------------------------------
  /// LOGIN — includes is_active account check (IMPORTANT)
  /// --------------------------------------------------------
  Future<dynamic> login(String email, String password) async {
    try {
      // 1) Attempt login with Supabase
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user;

      // If no user, invalid email/password
      if (user == null) {
        return "Incorrect email or password.";
      }

      // 2) Fetch user profile to check is_active
      final profile = await _client
          .from('profiles')
          .select('is_active')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        debugPrint("❗ Profile row missing for ${user.id}");
        return "Your account setup is incomplete. Please contact support.";
      }

      final isActive = (profile['is_active'] as bool?) ?? true;

      // 3) Block login if account is inactive
      if (!isActive) {
        debugPrint("❌ Login blocked — inactive account ${user.id}");

        // Must logout because Supabase still signs them in temporarily
        await _client.auth.signOut();

        return "Your account has been deactivated. Please contact the admin.";
      }

      // 4) Login is successful
      debugPrint("✅ Login successful: ${user.id}");
      return true;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  /// --------------------------------------------------------
  /// REGISTER
  /// --------------------------------------------------------
  Future<dynamic> register(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final res = await _client.auth.signUp(email: email, password: password);

      final user = res.user;
      if (user != null) {
        // Insert profile with fallback
        final response = await _client.from('profiles').upsert({
          'id': user.id,
          'full_name': fullName.isNotEmpty ? fullName : email,
        }).select();

        debugPrint("Profile upsert: $response");
        debugPrint("✅ Registration complete");
        return true;
      }

      return "Registration failed. Please try again.";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  /// --------------------------------------------------------
  /// FORGOT PASSWORD
  /// --------------------------------------------------------
  Future<dynamic> forgotPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      debugPrint("📧 Reset email sent to $email");
      return true;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  /// --------------------------------------------------------
  /// UPDATE PASSWORD
  /// --------------------------------------------------------
  Future<dynamic> updatePassword(String newPassword) async {
    try {
      final res = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (res.user != null) {
        debugPrint("🔐 Password updated successfully.");
        return true;
      }
      return "Failed to update password.";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  /// --------------------------------------------------------
  /// LOGOUT
  /// --------------------------------------------------------
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
      debugPrint("🚪 User logged out.");
    } catch (e) {
      debugPrint("Logout error: $e");
    }
  }

  /// --------------------------------------------------------
  /// UTILS — Get current user / session
  /// --------------------------------------------------------
  User? getCurrentUser() => _client.auth.currentUser;

  Session? getCurrentSession() => _client.auth.currentSession;
}
