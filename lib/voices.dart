import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'services/api_service.dart';
import 'widgets/gradient_background.dart';
import 'speaker_story.dart';

class VoicesPage extends StatefulWidget {
  const VoicesPage({super.key});

  @override
  State<VoicesPage> createState() => _VoicesPageState();
}

class _VoicesPageState extends State<VoicesPage> {
  BackendUser? _currentUser;

  final List<Map<String, String>> _speakers = [
    {
      'name': 'Yolanda Fehr',
      'storyName': "Z'Oowa Kaffe",
      'image': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
      'emoji': '👵',
    },
    {
      'name': 'Haidy Collin',
      'storyName': 'Sproch',
      'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
      'emoji': '👩',
    },
    {
      'name': 'Simon Rudmann',
      'storyName': 'Mischung',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
      'emoji': '👨',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final user = await ApiService.getMe();
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final bool canEdit = esEditor(_currentUser);

    return Scaffold(
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Formulario de creación de hablante (Rol Editor/Admin)'),
                    backgroundColor: Color(0xFF27AE60),
                  ),
                );
              },
              backgroundColor: const Color(0xFF1B5E20),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Nuevo Hablante',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Header Title
              const Text(
                'Voces de la Colonia',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Conoce a los hablantes nativos del dialecto',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 16),

              // 2-Column Vertical Grid of Speaker Cards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    itemCount: _speakers.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final speaker = _speakers[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SpeakerStoryPage(
                                speakerName: speaker['name']!,
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFFC5A059), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Speaker Photo
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFC5A059), width: 2),
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        speaker['image']!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: Colors.amber.shade100,
                                          child: Center(
                                            child: Text(speaker['emoji']!, style: const TextStyle(fontSize: 45)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  // Speaker Name
                                  Text(
                                    speaker['name']!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  // Story Badge / Name
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Relato: ${speaker['storyName']}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B5E20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Editor Actions Overlay Badge (Edit / Delete buttons)
                            if (canEdit)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                                    ],
                                  ),
                                  child: PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert_rounded, size: 20, color: Color(0xFF1B5E20)),
                                    onSelected: (action) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Acción $action en ${speaker['name']}'),
                                          backgroundColor: const Color(0xFF27AE60),
                                        ),
                                      );
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(value: 'editar', child: Text('Editar Hablante')),
                                      PopupMenuItem(value: 'eliminar', child: Text('Eliminar Hablante')),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
