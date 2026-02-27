import 'dart:io';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AuthController {
  final SupabaseClient _client = Supabase.instance.client;

  static const String _offlineMsg =
      "No internet connection. Please connect and try again.";

  bool _looksLikeOffline(String message) {
    final m = message.toLowerCase();
    return m.contains('clientexception') ||
        m.contains('socketexception') ||
        m.contains('failed host lookup') ||
        m.contains('no address associated with hostname') ||
        m.contains('connection failed') ||
        m.contains('network is unreachable');
  }

  /// --------------------------------------------------------
  /// LOGIN — includes is_active account check (IMPORTANT)
  /// --------------------------------------------------------
  Future<dynamic> login(String email, String password) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user;

      if (user == null) {
        return "Incorrect email or password.";
      }

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

      if (!isActive) {
        debugPrint("❌ Login blocked — inactive account ${user.id}");
        await _client.auth.signOut();
        return "Your account has been deactivated. Please contact the admin.";
      }

      debugPrint("✅ Login successful: ${user.id}");
      return true;
    } on SocketException {
      return _offlineMsg;
    } on ClientException {
      return _offlineMsg;
    } on AuthException catch (e) {
      // IMPORTANT: Supabase sometimes wraps offline errors inside AuthException.message
      if (_looksLikeOffline(e.message)) return _offlineMsg;
      return e.message;
    } catch (e) {
      debugPrint("Login unexpected error: $e");
      // If the exception text looks like offline, show offline msg
      if (_looksLikeOffline(e.toString())) return _offlineMsg;
      return "Something went wrong. Please try again.";
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
        final response = await _client.from('profiles').upsert({
          'id': user.id,
          'full_name': fullName.isNotEmpty ? fullName : email,
        }).select();

        debugPrint("Profile upsert: $response");
        return true;
      }

      return "Registration failed. Please try again.";
    } on SocketException {
      return _offlineMsg;
    } on ClientException {
      return _offlineMsg;
    } on AuthException catch (e) {
      if (_looksLikeOffline(e.message)) return _offlineMsg;
      return e.message;
    } catch (e) {
      debugPrint("Register unexpected error: $e");
      if (_looksLikeOffline(e.toString())) return _offlineMsg;
      return "Something went wrong. Please try again.";
    }
  }

  /// --------------------------------------------------------
  /// FORGOT PASSWORD
  /// --------------------------------------------------------
  Future<dynamic> forgotPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return true;
    } on SocketException {
      return _offlineMsg;
    } on ClientException {
      return _offlineMsg;
    } on AuthException catch (e) {
      if (_looksLikeOffline(e.message)) return _offlineMsg;
      return e.message;
    } catch (e) {
      debugPrint("Forgot password unexpected error: $e");
      if (_looksLikeOffline(e.toString())) return _offlineMsg;
      return "Something went wrong. Please try again.";
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

      if (res.user != null) return true;
      return "Failed to update password.";
    } on SocketException {
      return _offlineMsg;
    } on ClientException {
      return _offlineMsg;
    } on AuthException catch (e) {
      if (_looksLikeOffline(e.message)) return _offlineMsg;
      return e.message;
    } catch (e) {
      debugPrint("Update password unexpected error: $e");
      if (_looksLikeOffline(e.toString())) return _offlineMsg;
      return "Something went wrong. Please try again.";
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
  /// UTILS
  /// --------------------------------------------------------
  User? getCurrentUser() => _client.auth.currentUser;
  Session? getCurrentSession() => _client.auth.currentSession;
}
