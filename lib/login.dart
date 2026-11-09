import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'widgets/gradient_background.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Top App Title
                const Text(
                  'SprochKanschtrli',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8899A6),
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 20),

                // Mascot & White Card Container
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Mascot Image peeking behind the card
                    SizedBox(
                      height: 150,
                      child: Image.asset(
                        'assets/images/mascot.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Text('🦔', style: TextStyle(fontSize: 90)),
                        ),
                      ),
                    ),

                    // White Card
                    Container(
                      margin: const EdgeInsets.only(top: 110),
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Correo o Usuario Label
                          const Text(
                            'Correo o Usuario',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Correo Input
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'ejemplo@aprender.com',
                              hintStyle: const TextStyle(color: Color(0xFF95A5A6)),
                              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF7F8C8D)),
                              filled: true,
                              fillColor: const Color(0xFFEBF5F0),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Contraseña Label + ¿Olvidaste tu contraseña?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Contraseña',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: const Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF27AE60),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Contraseña Input
                          TextField(
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: const TextStyle(color: Color(0xFF95A5A6)),
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF7F8C8D)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: const Color(0xFF7F8C8D),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: const Color(0xFFEBF5F0),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Iniciar Sesión Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const DashboardPage()),
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
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // O CONTINÚA CON Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text(
                                  'O CONTINÚA CON',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Google Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xFFEBF5F0),
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Google icon placeholder / Text
                                  Text(
                                    'G',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Google',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Footer Text
                const Text(
                  '¿Aún no tienes una cuenta?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF34495E),
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {},
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Regístrate gratis',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E8449),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF1E8449),
                        size: 20,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Bottom App Title
                const Text(
                  'Alemán Coloniero',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
