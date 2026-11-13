import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/user_model.dart';
import 'services/api_service.dart';
import 'widgets/gradient_background.dart';

class UsersAdminPage extends StatefulWidget {
  const UsersAdminPage({super.key});

  @override
  State<UsersAdminPage> createState() => _UsersAdminPageState();
}

class _UsersAdminPageState extends State<UsersAdminPage> {
  List<BackendUser> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedRoleFilter;
  bool? _selectedActiveFilter;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await ApiService.getUsers(
        rol: _selectedRoleFilter,
        activo: _selectedActiveFilter,
        q: _searchQuery,
      );
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar usuarios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateUserRole(BackendUser user, String newRole) async {
    try {
      final updated = await ApiService.updateUser(user.id, rol: newRole);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rol de ${updated.nombreCompleto} actualizado a ${updated.rol}'),
            backgroundColor: const Color(0xFF27AE60),
          ),
        );
        _fetchUsers();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
        _fetchUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar rol: $e'),
            backgroundColor: Colors.red,
          ),
        );
        _fetchUsers();
      }
    }
  }

  Future<void> _updateUserActive(BackendUser user, bool newActive) async {
    try {
      final updated = await ApiService.updateUser(user.id, activo: newActive);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${updated.nombreCompleto} ${updated.activo ? "activado" : "desactivado"}',
            ),
            backgroundColor: const Color(0xFF27AE60),
          ),
        );
        _fetchUsers();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
        _fetchUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar estado: $e'),
            backgroundColor: Colors.red,
          ),
        );
        _fetchUsers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentFirebaseUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Administración de Usuarios',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: _fetchUsers,
                    ),
                  ],
                ),
              ),

              // Filter Bar Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        _searchQuery = val.trim();
                        _fetchUsers();
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre, correo o usuario...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF27AE60)),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchQuery = '';
                                  _fetchUsers();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Filter Dropdowns Row
                    Row(
                      children: [
                        // Filter by Role
                        Expanded(
                          child: DropdownButtonFormField<String?>(
                            value: _selectedRoleFilter,
                            decoration: InputDecoration(
                              labelText: 'Rol',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: null, child: Text('Todos los roles')),
                              DropdownMenuItem(value: 'aprendiz', child: Text('Aprendiz')),
                              DropdownMenuItem(value: 'editor', child: Text('Editor')),
                              DropdownMenuItem(value: 'administrador', child: Text('Administrador')),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedRoleFilter = val;
                              });
                              _fetchUsers();
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Filter by Active Status
                        Expanded(
                          child: DropdownButtonFormField<bool?>(
                            value: _selectedActiveFilter,
                            decoration: InputDecoration(
                              labelText: 'Estado',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: null, child: Text('Todos')),
                              DropdownMenuItem(value: true, child: Text('Activos')),
                              DropdownMenuItem(value: false, child: Text('Inactivos')),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedActiveFilter = val;
                              });
                              _fetchUsers();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Users List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF27AE60)))
                    : _users.isEmpty
                        ? Center(
                            child: Text(
                              'No se encontraron usuarios.',
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _users.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final user = _users[index];
                              final bool isSelf = user.firebaseUid == currentFirebaseUid;

                              return Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: isSelf
                                      ? Border.all(color: const Color(0xFF27AE60), width: 2)
                                      : Border.all(color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: user.activo
                                              ? const Color(0xFFE8F5E9)
                                              : Colors.red.shade50,
                                          child: Text(
                                            user.nombreCompleto.isNotEmpty
                                                ? user.nombreCompleto[0].toUpperCase()
                                                : 'U',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: user.activo
                                                  ? const Color(0xFF1B5E20)
                                                  : Colors.red,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      user.nombreCompleto.isNotEmpty
                                                          ? user.nombreCompleto
                                                          : 'Sin Nombre',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF1E293B),
                                                      ),
                                                    ),
                                                  ),
                                                  if (isSelf)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF27AE60),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: const Text(
                                                        'Tú',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                user.correo,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              if (user.nombreUsuario.isNotEmpty)
                                                Text(
                                                  '@${user.nombreUsuario}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF1B5E20),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),
                                    const Divider(height: 1),
                                    const SizedBox(height: 8),

                                    // Role Selector and Active Switch Row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Role Dropdown
                                        Row(
                                          children: [
                                            const Text(
                                              'Rol: ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                            DropdownButton<String>(
                                              value: user.rol,
                                              underline: const SizedBox(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Color(0xFF1B5E20),
                                              ),
                                              onChanged: isSelf
                                                  ? null // Disable for current admin self
                                                  : (newRole) {
                                                      if (newRole != null && newRole != user.rol) {
                                                        _updateUserRole(user, newRole);
                                                      }
                                                    },
                                              items: const [
                                                DropdownMenuItem(
                                                  value: 'aprendiz',
                                                  child: Text('Aprendiz'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'editor',
                                                  child: Text('Editor'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'administrador',
                                                  child: Text('Administrador'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        // Active Switch
                                        Row(
                                          children: [
                                            Text(
                                              user.activo ? 'Activo' : 'Inactivo',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: user.activo
                                                    ? const Color(0xFF27AE60)
                                                    : Colors.red,
                                              ),
                                            ),
                                            Switch(
                                              value: user.activo,
                                              activeColor: const Color(0xFF27AE60),
                                              onChanged: isSelf
                                                  ? null // Disable for current admin self
                                                  : (val) {
                                                      _updateUserActive(user, val);
                                                    },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
