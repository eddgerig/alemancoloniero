import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _firebaseUser;
  BackendUser? _backendUser;
  bool _isLoading = true;
  String? _errorMessage;

  User? get firebaseUser => _firebaseUser;
  BackendUser? get backendUser => _backendUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthNotifier() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) async {
      _firebaseUser = user;
      _errorMessage = null;

      if (user != null) {
        _isLoading = true;
        notifyListeners();
        try {
          _backendUser = await ApiService.getMe();
        } on UserDisabledException catch (e) {
          _errorMessage = e.message;
          await _authService.signOut();
          _firebaseUser = null;
          _backendUser = null;
        } catch (_) {
          // If backend server is offline or unreachable, fallback gracefully
          _backendUser = BackendUser(
            id: 0,
            firebaseUid: user.uid,
            correo: user.email ?? '',
            nombreUsuario: user.displayName?.split(' ').first ?? 'Usuario',
            nombreCompleto: user.displayName ?? 'Usuario',
            rol: 'aprendiz',
            activo: true,
          );
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      } else {
        _backendUser = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  /// Translates Firebase Auth error codes into clear Spanish messages
  static String translateFirebaseError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
        case 'invalid-email':
          return 'Credenciales inválidas. Por favor verifica tu correo y contraseña.';
        case 'email-already-in-use':
          return 'El correo electrónico ya está registrado en otra cuenta.';
        case 'weak-password':
          return 'La contraseña es muy débil. Debe tener al menos 6 caracteres.';
        case 'too-many-requests':
          return 'Demasiados intentos fallidos. Por favor intenta más tarde.';
        default:
          return error.message ?? 'Error de autenticación.';
      }
    }
    return error.toString();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.signInWithEmail(email: email, password: password);
      return true;
    } catch (e) {
      _errorMessage = translateFirebaseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final cred = await _authService.signInWithGoogle();
      if (cred == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      _errorMessage = translateFirebaseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.registerWithEmail(name: name, email: email, password: password);
      return true;
    } catch (e) {
      _errorMessage = translateFirebaseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = translateFirebaseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authService.signOut();
    _firebaseUser = null;
    _backendUser = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshBackendUser() async {
    if (_firebaseUser != null) {
      try {
        _backendUser = await ApiService.getMe();
        notifyListeners();
      } catch (_) {}
    }
  }
}
