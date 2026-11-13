import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'login.dart';
import 'users_admin.dart';
import 'widgets/protected_route.dart';
import 'widgets/gradient_background.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  BackendUser? _backendUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _fetchBackendUser();
  }

  Future<void> _fetchBackendUser() async {
    try {
      final user = await ApiService.getMe();
      if (mounted) {
        setState(() {
          _backendUser = user;
          _isLoadingUser = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  void _showEditProfileDialog() {
    final user = _backendUser;
    final usernameController = TextEditingController(text: user?.nombreUsuario ?? '');
    final fullNameController = TextEditingController(text: user?.nombreCompleto ?? '');

    String? usernameError;
    String? fullNameError;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text(
                'Editar Perfil',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nombre de usuario
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de usuario',
                      errorText: usernameError,
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nombre completo
                  TextField(
                    controller: fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre completo',
                      errorText: fullNameError,
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setDialogState(() {
                            isSubmitting = true;
                            usernameError = null;
                            fullNameError = null;
                          });

                          try {
                            final updatedUser = await ApiService.updateMe(
                              nombreUsuario: usernameController.text.trim(),
                              nombreCompleto: fullNameController.text.trim(),
                            );

                            if (context.mounted) {
                              setState(() {
                                _backendUser = updatedUser;
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Perfil actualizado correctamente'),
                                  backgroundColor: Color(0xFF27AE60),
                                ),
                              );
                            }
                          } on ApiException catch (e) {
                            setDialogState(() {
                              isSubmitting = false;
                              if (e.fieldErrors != null) {
                                if (e.fieldErrors!.containsKey('nombre_usuario')) {
                                  usernameError = (e.fieldErrors!['nombre_usuario'] as List).join(', ');
                                }
                                if (e.fieldErrors!.containsKey('nombre_completo')) {
                                  fullNameError = (e.fieldErrors!['nombre_completo'] as List).join(', ');
                                }
                              }
                            });
                          } catch (e) {
                            setDialogState(() {
                              isSubmitting = false;
                            });
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? firebaseUser = _authService.currentUser;

    final String displayName = _backendUser?.nombreCompleto.isNotEmpty == true
        ? _backendUser!.nombreCompleto
        : (firebaseUser?.displayName ?? 'Edgar Pro');
    final String username = _backendUser?.nombreUsuario.isNotEmpty == true
        ? '@${_backendUser!.nombreUsuario}'
        : '';
    final String email = _backendUser?.correo.isNotEmpty == true
        ? _backendUser!.correo
        : (firebaseUser?.email ?? 'edgar@alemancoloniero.com');
    final String role = _backendUser?.rol ?? 'aprendiz';
    final String? photoUrl = firebaseUser?.photoURL;

    final bool isAdmin = esAdministrador(_backendUser);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Mi Perfil',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 20),

                // User Info Card
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF27AE60), width: 3),
                        ),
                        child: ClipOval(
                          child: photoUrl != null
                              ? Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.amber.shade100,
                                    child: const Center(
                                      child: Text('🦔', style: TextStyle(fontSize: 50)),
                                    ),
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/mascot.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.amber.shade100,
                                    child: const Center(
                                      child: Text('🦔', style: TextStyle(fontSize: 50)),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      if (username.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: role == 'administrador'
                              ? Colors.purple.shade50
                              : role == 'editor'
                                  ? Colors.blue.shade50
                                  : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: role == 'administrador'
                                ? Colors.purple
                                : role == 'editor'
                                    ? Colors.blue
                                    : const Color(0xFF27AE60),
                          ),
                        ),
                        child: Text(
                          'Rol: ${role.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: role == 'administrador'
                                ? Colors.purple.shade700
                                : role == 'editor'
                                    ? Colors.blue.shade700
                                    : const Color(0xFF1B5E20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Stats Summary Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatTile(
                        icon: Icons.record_voice_over_rounded,
                        value: '1',
                        label: 'Hablantes',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatTile(
                        icon: Icons.menu_book_rounded,
                        value: '34',
                        label: 'Palabras',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatTile(
                        icon: Icons.star_rounded,
                        value: 'Nivel 2',
                        label: 'Módulo',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Menu Options List
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Editar Perfil',
                        onTap: _showEditProfileDialog,
                      ),
                      if (isAdmin) ...[
                        Divider(color: Colors.grey.shade200, height: 1),
                        _buildMenuItem(
                          icon: Icons.admin_panel_settings_outlined,
                          title: 'Administración de Usuarios',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProtectedRoute(
                                  rolMinimo: 'administrador',
                                  child: UsersAdminPage(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                      Divider(color: Colors.grey.shade200, height: 1),
                      _buildMenuItem(
                        icon: Icons.wifi_calling_3_rounded,
                        title: 'Probar Conexión Backend',
                        onTap: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Comprobando conexión con la API...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          final result = await ApiService.checkHealth();
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: Row(
                                  children: [
                                    Icon(
                                      result['success'] == true ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                                      color: result['success'] == true ? const Color(0xFF27AE60) : Colors.red,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      result['success'] == true ? 'Backend Conectado' : 'Error de Conexión',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                content: Text(
                                  'Status: ${result['status'] ?? 'N/A'}\nMensaje: ${result['message']}',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Aceptar', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                      Divider(color: Colors.grey.shade200, height: 1),
                      _buildMenuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Ayuda y Soporte',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Cerrar Sesión Button (Solid Red)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _authService.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    label: const Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE74C3C),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0xFFC0392B).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile({required IconData icon, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1B5E20), size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF27AE60)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }
}
