import 'package:supabase_flutter/supabase_flutter.dart';

export 'supabase_user_provider.dart';

final _authManager = SupabaseAuthManager();
SupabaseAuthManager get authManager => _authManager;

class SupabaseAuthManager {
  /// Sign in with email and password
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      print('Error signing in with email: $e');
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      return response.user;
    } catch (e) {
      print('Error signing up with email: $e');
      rethrow;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.harmonyhub://login-callback/',
      );
      return true;
    } catch (e) {
      print('Error signing in with Google: $e');
      return false;
    }
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.harmonyhub://login-callback/',
      );
      return true;
    } catch (e) {
      print('Error signing in with Apple: $e');
      return false;
    }
  }

  /// Sign in anonymously
  Future<User?> signInAnonymously() async {
    try {
      final response = await Supabase.instance.client.auth.signInAnonymously();
      return response.user;
    } catch (e) {
      print('Error signing in anonymously: $e');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  /// Get current user
  User? get currentUser => Supabase.instance.client.auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;
}

// Helper getters
String get currentUserUid => authManager.currentUser?.id ?? '';
String get currentUserEmail => authManager.currentUser?.email ?? '';
String? get currentUserDisplayName =>
    authManager.currentUser?.userMetadata?['display_name'] as String?;
String? get currentUserPhoto =>
    authManager.currentUser?.userMetadata?['avatar_url'] as String?;
String? get currentPhoneNumber => authManager.currentUser?.phone;
bool get currentUserEmailVerified =>
    authManager.currentUser?.emailConfirmedAt != null;
