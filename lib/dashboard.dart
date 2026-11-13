import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/gradient_background.dart';
import 'module_intro.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

                        // Learning Path Grid / Nodes
                        // Row 1: Saludos & Z'Oowa Kaffe
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPathNode(
                              icon: Icons.back_hand_rounded,
                              nodeColor: const Color(0xFF1B5E20),
                              badgeIcon: Icons.check_circle_rounded,
                              badgeColor: Colors.lightBlue,
                              title: '1. Saludos',
                              subtitle: 'Completado',
                              subtitleColor: const Color(0xFF2E7D32),
                              isCompleted: true,
                            ),
                            _buildPathNode(
                              icon: Icons.coffee_rounded,
                              nodeColor: const Color(0xFF6D4C41),
                              badgeIcon: Icons.access_time_filled_rounded,
                              badgeColor: Colors.deepOrange,
                              title: "2. Z'Oowa Kaffe",
                              subtitle: 'En curso',
                              subtitleColor: const Color(0xFFD84315),
                              topPill: '¡Comenzar!',
                              isCurrent: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ModuleIntroPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Center Node: Relato
                        Column(
                          children: [
                            _buildPathNode(
                              icon: Icons.record_voice_over_rounded,
                              nodeColor: Colors.grey.shade400,
                              badgeIcon: Icons.lock_rounded,
                              badgeColor: Colors.grey.shade300,
                              title: 'Relato',
                              bottomPill: 'Ich bin',
                              isLocked: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Row 2: Famili & Asa un trinka
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPathNode(
                              icon: Icons.group_rounded,
                              nodeColor: Colors.grey.shade400,
                              badgeIcon: Icons.lock_rounded,
                              badgeColor: Colors.grey.shade300,
                              title: '3. Famili',
                              subtitle: 'Parentesco',
                              subtitleColor: Colors.grey.shade600,
                              isLocked: true,
                            ),
                            _buildPathNode(
                              icon: Icons.restaurant_rounded,
                              nodeColor: Colors.grey.shade400,
                              badgeIcon: Icons.lock_rounded,
                              badgeColor: Colors.grey.shade300,
                              title: '4. Asa un trinka',
                              subtitle: 'Gastronomia',
                              subtitleColor: Colors.grey.shade600,
                              isLocked: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Row 3: Oostra & Expresiones
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPathNode(
                              icon: Icons.local_florist_rounded,
                              nodeColor: Colors.grey.shade400,
                              badgeIcon: Icons.lock_rounded,
                              badgeColor: Colors.grey.shade300,
                              title: '5. Oostra',
                              subtitle: 'Festividades',
                              subtitleColor: Colors.grey.shade600,
                              isLocked: true,
                            ),
                            _buildPathNode(
                              icon: Icons.chat_bubble_rounded,
                              nodeColor: Colors.grey.shade400,
                              badgeIcon: Icons.lock_rounded,
                              badgeColor: Colors.grey.shade300,
                              title: '6. Expresiones',
                              subtitle: 'Modismos',
                              subtitleColor: Colors.grey.shade600,
                              isLocked: true,
                            ),
                          ],
                        ),

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
