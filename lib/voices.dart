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
  bool _isLoading = true;
  List<Map<String, dynamic>> _speakers = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final user = await ApiService.getMe();
      final speakers = await ApiService.getSpeakers();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _speakers = speakers;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

              // 2-Column Grid of Speaker Cards
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF27AE60)))
                    : _speakers.isEmpty
                        ? Center(
                            child: Text(
                              'No hay hablantes registrados en el servidor por el momento.',
                              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: GridView.builder(
                              itemCount: _speakers.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.62,
                              ),
                              itemBuilder: (context, index) {
                                final speaker = _speakers[index];

                                final String name = speaker['name'] ?? speaker['nombre'] ?? 'Hablante Nativo';
                                final String bio = speaker['bio'] ?? speaker['biografia'] ?? 'Hablante nativo del dialecto alemán coloniero.';
                                final String audiosCount = speaker['audiosCount'] ?? speaker['audios_conteo']?.toString() ?? '10 audios';
                                final String? imageUrl = speaker['image'] ?? speaker['foto_url'] ?? speaker['foto'];

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SpeakerStoryPage(
                                          speakerName: name,
                                        ),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade900,
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.12),
                                            blurRadius: 15,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          // Background Photo
                                          Positioned.fill(
                                            child: imageUrl != null && imageUrl.startsWith('http')
                                                ? Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => Container(
                                                      color: Colors.amber.shade100,
                                                      child: const Center(
                                                        child: Text('👵', style: TextStyle(fontSize: 60)),
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    color: Colors.amber.shade100,
                                                    child: const Center(
                                                      child: Text('👵', style: TextStyle(fontSize: 60)),
                                                    ),
                                                  ),
                                          ),

                                          // Dark Gradient Overlay
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black.withOpacity(0.3),
                                                    Colors.black.withOpacity(0.85),
                                                    Colors.black.withOpacity(0.95),
                                                  ],
                                                  stops: const [0.0, 0.35, 0.75, 1.0],
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Editor Options Button
                                          if (canEdit)
                                            Positioned(
                                              top: 10,
                                              right: 10,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.5),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: PopupMenuButton<String>(
                                                  icon: const Icon(Icons.more_vert_rounded, size: 20, color: Colors.white),
                                                  onSelected: (action) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Acción $action en $name'),
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

                                          // Bottom Content Details
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Padding(
                                              padding: const EdgeInsets.all(14.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          name,
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                            height: 1.2,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      const Icon(
                                                        Icons.verified_rounded,
                                                        color: Color(0xFFE67E22),
                                                        size: 18,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    bio,
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.white.withOpacity(0.85),
                                                      height: 1.3,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.mic_none_rounded,
                                                            size: 13,
                                                            color: Colors.white.withOpacity(0.8),
                                                          ),
                                                          const SizedBox(width: 3),
                                                          Text(
                                                            audiosCount,
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.w600,
                                                              color: Colors.white.withOpacity(0.8),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(16),
                                                        ),
                                                        child: const Row(
                                                          children: [
                                                            Text(
                                                              'Escuchar',
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                fontWeight: FontWeight.bold,
                                                                color: Color(0xFF1E293B),
                                                              ),
                                                            ),
                                                            SizedBox(width: 2),
                                                            Icon(
                                                              Icons.add_rounded,
                                                              size: 12,
                                                              color: Color(0xFF1E293B),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
