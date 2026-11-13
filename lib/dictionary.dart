import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'widgets/gradient_background.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _searchQuery = '';
  int? _playingIndex;

  final List<Map<String, String>> _dictionaryWords = [
    {
      'word': "Z'Oowa Kaffe",
      'translation': 'Café de la tarde / Merienda',
      'speaker': 'Yolanda Fehr',
      'audioUrl': 'https://res.cloudinary.com/dsefkkkp/video/upload/v1794357254/gct_zoba_kaffe.mp4',
      'module': 'Módulo 2',
    },
    {
      'word': 'Brot',
      'translation': 'Pan',
      'speaker': 'Yolanda Fehr',
      'audioUrl': 'https://res.cloudinary.com/dsefkkkp/video/upload/v1794357254/gct_zoba_kaffe.mp4',
      'module': 'Módulo 2',
    },
    {
      'word': 'Milich',
      'translation': 'Leche',
      'speaker': 'Hans Ruh',
      'audioUrl': 'https://res.cloudinary.com/dsefkkkp/video/upload/v1794357254/gct_zoba_kaffe.mp4',
      'module': 'Módulo 2',
    },
    {
      'word': 'Schisili',
      'translation': 'Tazón / Vasija para leche',
      'speaker': 'Yolanda Fehr',
      'audioUrl': 'https://res.cloudinary.com/dsefkkkp/video/upload/v1794357254/gct_zoba_kaffe.mp4',
      'module': 'Módulo 2',
    },
    {
      'word': 'Kaffe',
      'translation': 'Café',
      'speaker': 'Hans Ruh',
      'audioUrl': 'https://res.cloudinary.com/dsefkkkp/video/upload/v1794357254/gct_zoba_kaffe.mp4',
      'module': 'Módulo 2',
    },
    {
      'word': 'Kuat Ocumma',
      'translation': '¡Bienvenido / Buenos días!',
      'speaker': 'Yolanda Fehr',
      'audioUrl': 'https://res.cloudinary.com/dsefkkkp/video/upload/v1794357254/gct_zoba_kaffe.mp4',
      'module': 'Módulo 1',
    },
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String url, int index) async {
    try {
      if (_playingIndex == index) {
        await _audioPlayer.stop();
        setState(() {
          _playingIndex = null;
        });
      } else {
        await _audioPlayer.stop();
        setState(() {
          _playingIndex = index;
        });
        await _audioPlayer.play(UrlSource(url));
        _audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() {
              _playingIndex = null;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reproducir audio: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredWords = _dictionaryWords.where((item) {
      final word = item['word']!.toLowerCase();
      final translation = item['translation']!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return word.contains(query) || translation.contains(query);
    }).toList();

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Title Header
              const Text(
                'Diccionario',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar palabra o traducción...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF27AE60)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.8), width: 1.5),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Word Cards List
              Expanded(
                child: filteredWords.isEmpty
                    ? Center(
                        child: Text(
                          'No se encontraron palabras para "$_searchQuery"',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        itemCount: filteredWords.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final item = filteredWords[index];
                          final isPlaying = _playingIndex == index;

                          return Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Left Audio Button
                                GestureDetector(
                                  onTap: () => _playAudio(item['audioUrl']!, index),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: isPlaying ? const Color(0xFF0288D1) : const Color(0xFF29B6F6),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF29B6F6).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      isPlaying ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Center Word & Translation Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Word in Alemán Coloniero
                                      Text(
                                        item['word']!,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),

                                      // Spanish Translation
                                      Text(
                                        item['translation']!,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1B5E20),
                                        ),
                                      ),
                                      const SizedBox(height: 6),

                                      // Speaker Name
                                      Row(
                                        children: [
                                          const Icon(Icons.mic_none_rounded, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Voz: ${item['speaker']}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Module Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    item['module']!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1B5E20),
                                    ),
                                  ),
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
