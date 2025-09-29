import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AuthController {
  final SupabaseClient _client = Supabase.instance.client;

  /// Login user with email and password
  Future<dynamic> login(String email, String password) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null || res.session != null) {
        debugPrint(" Login successful. Current user: ${_client.auth.currentUser}");
        return true;
      }
      return "Login failed. Please try again.";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  /// Register new user with email, password, and full name
  Future<dynamic> register(String email, String password, String fullName) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user != null) {
        // Insert or update profile row with fallback to email
        final response = await _client.from('profiles').upsert({
          'id': user.id,
          'full_name': fullName.isNotEmpty ? fullName : email, //  fallback
        }). select();

        debugPrint("Upsert result: $response");

        debugPrint(" Registration successful. User + profile created.");
        return true;
      }

      return "Registration failed. Please try again.";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  /// Send password reset email
  Future<dynamic> forgotPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      debugPrint(" Password reset email sent to $email");
      return true;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  /// Update current user's password
  Future<dynamic> updatePassword(String newPassword) async {
    try {
      final res = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (res.user != null) {
        debugPrint(" Password updated successfully.");
        return true;
      }
      return "Failed to update password.";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
      debugPrint(" User logged out.");
    } catch (e) {
      debugPrint("Error during logout: $e");
    }
  }

  /// Get current authenticated user
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  /// Get current active session
  Session? getCurrentSession() {
    return _client.auth.currentSession;
  }
}
