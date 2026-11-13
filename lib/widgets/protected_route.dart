import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../login.dart';
import 'gradient_background.dart';

class ProtectedRoute extends StatefulWidget {
  final Widget child;
  final String? rolMinimo;

  const ProtectedRoute({
    super.key,
    required this.child,
    this.rolMinimo,
  });

  @override
  State<ProtectedRoute> createState() => _ProtectedRouteState();
}

class _ProtectedRouteState extends State<ProtectedRoute> {
  bool _isLoading = true;
  User? _firebaseUser;
  BackendUser? _backendUser;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _firebaseUser = null;
        });
      }
      return;
    }

    try {
      final backendUser = await ApiService.getMe();
      if (mounted) {
        setState(() {
          _firebaseUser = user;
          _backendUser = backendUser;
          _isLoading = false;
        });
      }
    } on UserDisabledException catch (e) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _firebaseUser = null;
          _isLoading = false;
        });
      }
    } catch (_) {
      // Fallback if backend is unreachable
      if (mounted) {
        setState(() {
          _firebaseUser = user;
          _backendUser = BackendUser(
            id: 0,
            firebaseUid: user.uid,
            correo: user.email ?? '',
            nombreUsuario: user.displayName?.split(' ').first ?? 'Usuario',
            nombreCompleto: user.displayName ?? 'Usuario',
            rol: 'aprendiz',
            activo: true,
          );
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: GradientBackground(
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF27AE60),
            ),
          ),
        ),
      );
    }

    if (_firebaseUser == null) {
      if (_errorMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
      return const LoginPage();
    }

    if (widget.rolMinimo != null && !tieneRol(_backendUser, widget.rolMinimo!)) {
      return Scaffold(
        body: GradientBackground(
          child: SafeArea(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(24.0),
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_rounded, size: 60, color: Color(0xFFE74C3C)),
                    const SizedBox(height: 16),
                    const Text(
                      'Acceso Restringido',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Se requiere rol de "${widget.rolMinimo}" o superior para acceder a esta sección.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Volver', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
