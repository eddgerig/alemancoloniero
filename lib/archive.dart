import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'widgets/gradient_background.dart';
import 'archive_detail.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _acervoItems = [];

  @override
  void initState() {
    super.initState();
    _fetchArchives();
  }

  Future<void> _fetchArchives() async {
    final items = await ApiService.getArchiveItems();
    if (mounted) {
      setState(() {
        _acervoItems = items;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Header Title
              const Text(
                'Acervo Cultural',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Colección de audios y relatos tradicionales',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 16),

              // 2-Column Vertical Grid of Cards
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF27AE60)))
                    : _acervoItems.isEmpty
                        ? Center(
                            child: Text(
                              'No hay relatos en el acervo por el momento.',
                              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: GridView.builder(
                              itemCount: _acervoItems.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.74,
                              ),
                              itemBuilder: (context, index) {
                                final item = _acervoItems[index];

                                final String title = item['title'] ?? item['titulo'] ?? 'Acervo';
                                final String? meaning = item['meaning'] ?? item['significado'];
                                final String speaker = item['speaker'] ?? item['hablante'] ?? 'Hablante Nativo';

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ArchiveDetailPage(
                                          title: title,
                                          speakerName: speaker,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
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
                                        // Top Icon Container
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1B5E20).withOpacity(0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.translate_rounded,
                                              size: 40,
                                              color: Color(0xFF1B5E20),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 16),

                                        // Acervo Title
                                        Text(
                                          title,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),

                                        // Meaning/Subtext
                                        if (meaning != null && meaning.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            '($meaning)',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: Color(0xFF1B5E20),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],

                                        const SizedBox(height: 12),

                                        // Speaker Name
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.mic_none_rounded, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                speaker,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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
