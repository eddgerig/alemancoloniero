import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'widgets/exit_lesson_dialog.dart';

class SpeakerStoryPage extends StatefulWidget {
  final String speakerName;

  const SpeakerStoryPage({
    super.key,
    this.speakerName = 'Yolanda Fehr',
  });

  @override
  State<SpeakerStoryPage> createState() => _SpeakerStoryPageState();
}

class _SpeakerStoryPageState extends State<SpeakerStoryPage> {
  int _activeBubbleIndex = 0;
  bool _isSlowSpeed = true;

  final List<Map<String, dynamic>> _bubbles = [
    {'text': 'Hallo', 'isLocked': false},
    {'text': 'Ich bin Yola', 'isLocked': false},
    {'text': '...', 'isLocked': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Progress Bar & Close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 0.4,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF29B6F6)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 28, color: Color(0xFF2C3E50)),
                    onPressed: () => showExitLessonDialog(context),
                  ),
                ],
              ),
            ),

            // Relato Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'RELATO',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Speaker Photo Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: 190,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                  ),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Text('👵', style: TextStyle(fontSize: 90)),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Voice Attribution
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

            // Interactive Audio Speech Bubbles
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                itemCount: _bubbles.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final bubble = _bubbles[index];
                  final bool isActive = _activeBubbleIndex == index;
                  final bool isLocked = bubble['isLocked'] == true;

                  if (isLocked) {
                    return _buildLockedBubble();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _activeBubbleIndex = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive ? const Color(0xFF1B5E20) : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isActive ? const Color(0xFF29B6F6) : Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.volume_up_rounded,
                                  color: Colors.white,
                                  size: isActive ? 22 : 18,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                bubble['text'],
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                  color: isActive ? const Color(0xFF1E293B) : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSlowSpeed = !_isSlowSpeed;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              _isSlowSpeed ? '0.5x' : '1.0x',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Button 1: Escuchar el relato completo
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1B5E20), width: 1.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Escuchar el relato completo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Button 2: Continuar
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const DashboardPage()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0xFF1E8449).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Continuar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildLockedBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_rounded,
              color: Colors.grey.shade600,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 90,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
