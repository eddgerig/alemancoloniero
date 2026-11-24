import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/gradient_background.dart';
import 'widgets/error_modal.dart';
import 'widgets/loading_screen.dart';
import 'module_intro.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/cache_service.dart';
import 'profile.dart';
import 'dictionary.dart';
import 'archive.dart';
import 'voices.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  List<Map<String, dynamic>> _apiMapNodes = [];
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fetchMapNodes();
  }

  Future<void> _fetchMapNodes() async {
    // 1. Instant render from local cache if available (0ms load time)
    final cachedNodes = await MapCacheService.getCachedMapNodes();
    if (cachedNodes.isNotEmpty && mounted) {
      setState(() {
        _apiMapNodes = cachedNodes;
        _isInitialLoading = false;
      });
    }

    // 2. Fetch fresh map nodes from API in background
    final result = await ApiService.getMapNodes();
    if (!mounted) return;

    if (result['success'] == true) {
      final List<Map<String, dynamic>> freshNodes =
          List<Map<String, dynamic>>.from(result['data']);
      setState(() {
        _apiMapNodes = freshNodes;
        _isInitialLoading = false;
      });
      // Save fresh data to local persistent storage
      await MapCacheService.saveMapNodes(freshNodes);
    } else {
      if (_apiMapNodes.isEmpty) {
        // Show error modal only if no cached map is available
        final String errorMsg = result['error'] ?? 'Error de conexión';
        _showNoModulesBottomSheet(errorMsg);
      }
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  void _showNoModulesBottomSheet(String errorDetails) {
    if (!mounted) return;
    ErrorModal.show(
      context: context,
      title: 'No hay módulos disponibles',
      message: 'No tenemos módulos disponibles en este momento. Vuelve más tarde.',
      errorDetails: errorDetails,
      showExitButton: true,
      exitText: 'Salir',
      confirmText: 'Reintentar',
      onConfirm: () {
        Navigator.pop(context);
        _fetchMapNodes();
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading && _apiMapNodes.isEmpty) {
      return const LoadingScreen(
        message: 'Cargando tu ruta de aprendizaje...',
      );
    }

    if (_currentIndex == 1) {
      return Scaffold(
        body: const DictionaryPage(),
        bottomNavigationBar: _buildBottomNavigationBar(),
      );
    }

    if (_currentIndex == 2) {
      return Scaffold(
        body: const ArchivePage(),
        bottomNavigationBar: _buildBottomNavigationBar(),
      );
    }

    if (_currentIndex == 3) {
      return Scaffold(
        body: const VoicesPage(),
        bottomNavigationBar: _buildBottomNavigationBar(),
      );
    }

    if (_currentIndex == 4) {
      return Scaffold(
        body: const ProfilePage(),
        bottomNavigationBar: _buildBottomNavigationBar(),
      );
    }

    final User? currentUser = AuthService().currentUser;
    String userName = 'Edgar';
    if (currentUser != null) {
      if (currentUser.displayName != null && currentUser.displayName!.isNotEmpty) {
        userName = currentUser.displayName!.split(' ').first;
      } else if (currentUser.email != null && currentUser.email!.isNotEmpty) {
        final emailPrefix = currentUser.email!.split('@').first;
        userName = emailPrefix[0].toUpperCase() + emailPrefix.substring(1);
      }
    }

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
                // 1. Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Vertical Tricolor Flag (Black, Yellow, Red)
                      Container(
                        width: 28,
                        height: 20,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Container(color: Colors.black)),
                            Expanded(child: Container(color: const Color(0xFFFFCC00))),
                            Expanded(child: Container(color: const Color(0xFFDD0000))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Alemán Coloniero',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      // M-2 Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF333333),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'M-2',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Main Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Welcome Card (Kuat Ocumma!)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Mascot Image
                              SizedBox(
                                width: 70,
                                height: 70,
                                child: Image.asset(
                                  'assets/images/mascot.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text('🦔', style: TextStyle(fontSize: 40)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Kuat Ocumma!',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Bienvenido, $userName',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Learning Path Grid / Nodes (Dynamic from API or fallback)
                        _buildDynamicMapNodes(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDynamicMapNodes() {
    if (_apiMapNodes.isEmpty) {
      return const SizedBox.shrink();
    }

    // Dynamic Map Nodes Layout from Backend
    List<Widget> rows = [];
    List<Map<String, dynamic>> currentRowNodes = [];

    for (int i = 0; i < _apiMapNodes.length; i++) {
      final node = _apiMapNodes[i];
      final posicion = node['posicion'] ?? 'centro';

      if (posicion == 'centro') {
        if (currentRowNodes.isNotEmpty) {
          rows.add(_buildRowFromNodes(currentRowNodes));
          rows.add(const SizedBox(height: 30));
          currentRowNodes = [];
        }
        rows.add(Column(children: [_buildSingleNodeFromApi(node)]));
        rows.add(const SizedBox(height: 30));
      } else {
        currentRowNodes.add(node);
        if (currentRowNodes.length == 2 || i == _apiMapNodes.length - 1) {
          rows.add(_buildRowFromNodes(currentRowNodes));
          rows.add(const SizedBox(height: 30));
          currentRowNodes = [];
        }
      }
    }

    return Column(children: rows);
  }

  Widget _buildRowFromNodes(List<Map<String, dynamic>> nodes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: nodes.map((node) => _buildSingleNodeFromApi(node)).toList(),
    );
  }

  Widget _buildSingleNodeFromApi(Map<String, dynamic> node) {
    // Flag de desarrollo: en modo Debug (kDebugMode), todos los módulos y relatos se desbloquean automáticamente.
    const bool devUnlockAll = kDebugMode;

    final String estado = node['estado'] ?? 'bloqueado';
    final bool isCompleted = estado == 'completado';
    final bool isCurrent = estado == 'en_curso' || (devUnlockAll && estado == 'bloqueado');
    final bool isLocked = devUnlockAll ? false : (estado == 'bloqueado');

    return _buildPathNode(
      icon: _parseIcon(node['icono']),
      nodeColor: _parseColor(node['color_hex']),
      badgeIcon: _parseBadgeIcon(node['badge_tipo']),
      badgeColor: _parseBadgeColor(node['badge_tipo']),
      title: node['titulo'] ?? '',
      subtitle: node['subtitulo'],
      subtitleColor: isCompleted
          ? const Color(0xFF2E7D32)
          : (isCurrent ? const Color(0xFFD84315) : Colors.grey.shade600),
      topPill: node['top_pill'],
      bottomPill: node['bottom_pill'],
      isCompleted: isCompleted,
      isCurrent: isCurrent,
      isLocked: isLocked,
      onTap: () {
        if (isLocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Este módulo o relato aún está bloqueado'),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }
        final int moduloId = node['id'] is int
            ? node['id']
            : (int.tryParse(node['id'].toString()) ?? 1);
        if (node['tipo'] == 'modulo' || node['numero'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ModuleIntroPage(moduloId: moduloId),
            ),
          );
        }
      },
    );
  }

  IconData _parseIcon(String? name) {
    switch (name) {
      case 'back_hand':
        return Icons.back_hand_rounded;
      case 'coffee':
        return Icons.coffee_rounded;
      case 'record_voice_over':
        return Icons.record_voice_over_rounded;
      case 'group':
        return Icons.group_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'local_florist':
        return Icons.local_florist_rounded;
      case 'chat_bubble':
        return Icons.chat_bubble_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey.shade400;
    try {
      final cleanHex = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleanHex', radix: 16));
    } catch (_) {
      return Colors.grey.shade400;
    }
  }

  IconData _parseBadgeIcon(String? badgeType) {
    switch (badgeType) {
      case 'check':
        return Icons.check_circle_rounded;
      case 'reloj':
        return Icons.access_time_filled_rounded;
      case 'candado':
      default:
        return Icons.lock_rounded;
    }
  }

  Color _parseBadgeColor(String? badgeType) {
    switch (badgeType) {
      case 'check':
        return Colors.lightBlue;
      case 'reloj':
        return Colors.deepOrange;
      case 'candado':
      default:
        return Colors.grey.shade300;
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF1B5E20),
      unselectedItemColor: Colors.grey.shade600,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Diccionario'),
        BottomNavigationBarItem(icon: Icon(Icons.graphic_eq_rounded), label: 'Acervo'),
        BottomNavigationBarItem(icon: Icon(Icons.record_voice_over_rounded), label: 'Voces'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
      ],
    );
  }

  // Helper Widget for Path Nodes
  Widget _buildPathNode({
    required IconData icon,
    required Color nodeColor,
    required IconData badgeIcon,
    required Color badgeColor,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    String? topPill,
    String? bottomPill,
    bool isCompleted = false,
    bool isCurrent = false,
    bool isLocked = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        // Top Pill (e.g. ¡Comenzar!)
        if (topPill != null) ...[
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isCurrent ? _pulseAnimation.value : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4332),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (isCurrent)
                        BoxShadow(
                          color: const Color(0xFF1B4332).withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        topPill,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],

        // Circular Node Button with Badge
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final double scale = isCurrent ? _pulseAnimation.value : 1.0;

            return Transform.scale(
              scale: scale,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Outer Ring
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isLocked ? Colors.grey.shade200 : Colors.white,
                      border: Border.all(
                        color: isLocked ? Colors.grey.shade300 : nodeColor,
                        width: isCurrent ? 4.5 : 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isCurrent
                              ? nodeColor.withOpacity(0.4)
                              : Colors.black.withOpacity(0.08),
                          blurRadius: isCurrent ? 14 : 8,
                          spreadRadius: isCurrent ? 2 : 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isLocked
                              ? Colors.grey.shade100
                              : (isCompleted || isCurrent ? nodeColor : Colors.grey.shade300),
                        ),
                        child: Icon(
                          icon,
                          size: 32,
                          color: isLocked
                              ? Colors.grey.shade400
                              : (isCompleted || isCurrent ? Colors.white : Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ),

                  // Badge Icon (bottom right)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        badgeIcon,
                        size: 22,
                        color: badgeColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // Bottom Pill (e.g., Ich bin)
        if (bottomPill != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 12),
                const SizedBox(width: 2),
                Text(
                  bottomPill,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Node Title
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isLocked ? Colors.grey.shade700 : const Color(0xFF1E293B),
          ),
        ),

        // Node Subtitle
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: subtitleColor ?? Colors.grey.shade600,
            ),
          ),
        ],
      ],
    ),
    );
  }
}
