// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _status = AuthStatus.unauthenticated;
        _user = null;
      } else {
        if (firebaseUser.emailVerified) {
          _user = await _authService.getCurrentUserProfile();
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
          _user = null;
        }
      }
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading();
    try {
      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading();
    try {
      final user = await _authService.signIn(email: email, password: password);
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        _clearError();
        notifyListeners();
        return true;
      }
      _setError('Sign in failed.');
      return false;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> resendVerificationEmail() async {
    await _authService.resendVerificationEmail();
  }

  Future<bool> resetPassword(String email) async {
    _setLoading();
    try {
      await _authService.resetPassword(email);
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> updateNotificationPreference(bool value) async {
    if (_user == null) return;
    await _authService.updateUserProfile(_user!.uid, {
      'notificationsEnabled': value,
    });
    _user = _user!.copyWith(notificationsEnabled: value);
    notifyListeners();
  }

  Future<void> updateLocationPreference(bool value) async {
    if (_user == null) return;
    await _authService.updateUserProfile(_user!.uid, {
      'locationEnabled': value,
    });
    _user = _user!.copyWith(locationEnabled: value);
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}