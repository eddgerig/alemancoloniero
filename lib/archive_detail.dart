import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ArchiveDetailPage extends StatefulWidget {
  final String title;
  final String speakerName;
  final String? audioUrl;

  const ArchiveDetailPage({
    super.key,
    this.title = 'Sproch',
    this.speakerName = 'Haidy Collin',
    this.audioUrl = 'https://res.cloudinary.com/dsefkkkp/video/upload/v1794357254/gct_zoba_kaffe.mp4',
  });

  @override
  State<ArchiveDetailPage> createState() => _ArchiveDetailPageState();
}

class _ArchiveDetailPageState extends State<ArchiveDetailPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = true;
  int _activeSentenceIndex = 1; // Default index 1 "EN REPRODUCCIÓN" as in screenshot

  final List<Map<String, String>> _transcriptSentences = [
    {
      'original': 'Ti maista vu uns, wu to haar kumma sin',
      'translation': 'La mayoría de nosotros que vinimos hacia acá',
    },
    {
      'original': 'Vu furshchitini tarfli vum Kaiserthul gsi',
      'translation': 'De distintos pueblitos éramos',
    },
    {
      'original': 'Und a poor wenick Frankraich',
      'translation': 'Y unos pocos venían de Francia',
    },
    {
      'original': 'To sin kamarota un nochbara worra famili.',
      'translation': 'Aquí nos hicimos amigos, vecinos y familia.',
    },
    {
      'original':
          'mr han olli wor nit klich gschwatzt, ober mr han uns fuschtonta, wes tr klich dialeckt gsi isch.',
      'translation':
          'Aunque no todos hablábamos exactamente igual, nos entendíamos porque era el mismo dialecto.',
    },
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, size: 26, color: Color(0xFF1E293B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'WITSLI',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 26, color: Color(0xFF1E293B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Title
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Speaker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.mic_none_rounded, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Voz: ${widget.speakerName}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Waveform Visualizer Card
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(35, (index) {
                          final double height = (index % 5 + 1) * 6.0 + (index % 3) * 4.0;
                          final bool isPlayed = index < 18;

                          return Container(
                            width: 3.5,
                            height: height,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: isPlayed ? const Color(0xFF27AE60) : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '30/10/2026',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Transcript Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.record_voice_over_outlined, size: 20, color: Color(0xFF1E293B)),
                            SizedBox(width: 8),
                            Text(
                              'Transcripción contextual',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF1B5E20)),
                              SizedBox(width: 4),
                              Text(
                                'Traducción',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Transcript Sentences
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _transcriptSentences.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _transcriptSentences[index];
                        final bool isPlayingThis = index == _activeSentenceIndex;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _activeSentenceIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isPlayingThis ? const Color(0xFF27AE60) : Colors.grey.shade200,
                                width: isPlayingThis ? 2.0 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isPlayingThis
                                      ? const Color(0xFF27AE60).withOpacity(0.08)
                                      : Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isPlayingThis) ...[
                                  Container(
                                    width: 4,
                                    height: 48,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF27AE60),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (isPlayingThis) ...[
                                        const Row(
                                          children: [
                                            Icon(Icons.volume_up_rounded, size: 14, color: Color(0xFF475569)),
                                            SizedBox(width: 4),
                                            Text(
                                              'EN REPRODUCCIÓN',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF475569),
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                      ],
                                      Text(
                                        item['original']!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item['translation']!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Audio Control Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '0:42',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  // Audio Buttons Row
                  Row(
                    children: [
                      // Rewind 10s Button
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.replay_10_rounded,
                          color: Color(0xFF475569),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Main Play/Pause Button
                      GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            color: Color(0xFF29B6F6),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x4029B6F6),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Forward 10s Button
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.forward_10_rounded,
                          color: Color(0xFF475569),
                          size: 22,
                        ),
                      ),
                    ],
                  ),

                  const Text(
                    '2:15',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
