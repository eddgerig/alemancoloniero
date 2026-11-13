import 'package:flutter/material.dart';
import 'widgets/gradient_background.dart';
import 'archive_detail.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  final List<Map<String, dynamic>> _acervoItems = [
    {
      'title': 'Sproch',
      'meaning': 'Idioma',
      'speaker': 'Yolanda Fehr',
      'icon': Icons.translate_rounded,
      'color': const Color(0xFF1B5E20),
    },
    {
      'title': "Z'Oowa Kaffe",
      'meaning': 'Merienda',
      'speaker': 'Yolanda Fehr',
      'icon': Icons.coffee_rounded,
      'color': const Color(0xFF6D4C41),
    },
    {
      'title': 'Mischung',
      'meaning': 'Tradición',
      'speaker': 'Hans Ruh',
      'icon': Icons.account_balance_rounded,
      'color': const Color(0xFF2980B9),
    },
    {
      'title': 'Geschicht',
      'meaning': 'Historias',
      'speaker': 'Simon Rudmann',
      'icon': Icons.auto_stories_rounded,
      'color': const Color(0xFF8E44AD),
    },
  ];

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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    itemCount: _acervoItems.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.74, // Vertical cards
                    ),
                    itemBuilder: (context, index) {
                      final item = _acervoItems[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArchiveDetailPage(
                                title: item['title'] as String,
                                speakerName: item['speaker'] as String,
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
                                color: (item['color'] as Color).withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  item['icon'] as IconData,
                                  size: 40,
                                  color: item['color'] as Color,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Acervo Title (e.g. "Sproch")
                            Text(
                              item['title'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),

                            // Meaning/Subtext
                            if (item['meaning'] != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                '(${item['meaning']})',
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
                                    item['speaker'] as String,
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
