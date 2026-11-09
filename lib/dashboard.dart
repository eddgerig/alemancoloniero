import 'package:flutter/material.dart';
import 'widgets/gradient_background.dart';
import 'module_intro.dart';
import 'services/api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
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
                      // Flag Emoji/Container
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: const Text('🇩🇪', style: TextStyle(fontSize: 20)),
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
                      const SizedBox(width: 10),
                      // API Health Check Button
                      GestureDetector(
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
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.wifi_calling_3_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // User Profile Icon
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1B4332),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
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
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kuat Ocumma!',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Bienvenido, Edgar',
                                    style: TextStyle(
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
      bottomNavigationBar: BottomNavigationBar(
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
        ],
      ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1B4332),
              borderRadius: BorderRadius.circular(12),
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
        ],

        // Circular Node Button with Badge
        Stack(
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
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
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
