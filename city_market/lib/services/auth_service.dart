import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateChangesProvider = StreamProvider<firebase_auth.User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  
  // Stream for auth state changes
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Configure action code settings for email verification
  firebase_auth.ActionCodeSettings get _actionCodeSettings {
    return firebase_auth.ActionCodeSettings(
      url: 'https://kigali-city-directory-a10cd.firebaseapp.com',
      handleCodeInApp: true,
      androidPackageName: 'com.example.city_market',
      androidInstallApp: true,
      androidMinimumVersion: '21',
    );
  }

  // Sign up with email and password
  Future<firebase_auth.User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Send verification email with ActionCodeSettings
      if (credential.user != null) {
        try {
          await credential.user!.sendEmailVerification(_actionCodeSettings);
          debugPrint('✅ Verification email sent to: ${credential.user!.email}');
        } catch (e) {
          debugPrint('❌ Failed to send verification email: $e');
          // Try again without ActionCodeSettings
          try {
            await credential.user!.sendEmailVerification();
            debugPrint('✅ Verification email sent (fallback) to: ${credential.user!.email}');
          } catch (e2) {
            debugPrint('❌ Fallback verification email also failed: $e2');
            throw 'Account created but verification email failed. Please use "Resend" later.';
          }
        }
      }
      
      return credential.user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _getAuthErrorMessage(e.code);
    }
  }

  // Sign in with email and password
  Future<firebase_auth.User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null && !user.emailVerified) {
        // Resend verification email
        try {
          await user.sendEmailVerification(_actionCodeSettings);
          debugPrint('✅ Verification email resent to: ${user.email}');
        } catch (e) {
          debugPrint('❌ Failed to resend verification email: $e');
          // Try fallback
          try {
            await user.sendEmailVerification();
            debugPrint('✅ Verification email resent (fallback) to: ${user.email}');
          } catch (e2) {
            debugPrint('❌ Fallback verification email failed: $e2');
          }
        }
        
        await _auth.signOut();
        throw 'Please verify your email first. Check your inbox (and spam folder) for the verification link.';
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _getAuthErrorMessage(e.code);
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Check your connection';
      default:
        return 'Authentication failed. Please try again';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  firebase_auth.User? get currentUser => _auth.currentUser;

  // Resend verification email
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification(_actionCodeSettings);
        debugPrint('✅ Verification email sent to: ${user.email}');
      } catch (e) {
        debugPrint('❌ Error sending verification email: $e');
        // Fallback without ActionCodeSettings
        try {
          await user.sendEmailVerification();
          debugPrint('✅ Verification email sent (fallback) to: ${user.email}');
        } catch (e2) {
          debugPrint('❌ Fallback also failed: $e2');
          rethrow;
        }
      }
    } else if (user == null) {
      debugPrint('❌ No user logged in');
      throw 'No user is currently logged in';
    } else {
      debugPrint('ℹ️ Email already verified');
    }
  }

  Future<bool> reloadAndCheckEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  void resetSessionTimer() {
    // Session management can be added here if needed
  }

  void dispose() {
    // Cleanup if needed
  }
}
