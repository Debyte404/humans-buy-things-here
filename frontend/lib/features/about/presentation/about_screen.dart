import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:revolutionary_commerce/core/presentation/widgets/glass_container.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    const Color(0xFF64FFDA).withOpacity(0.05),
                    const Color(0xFF050505),
                  ],
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? size.width * 0.15 : 24,
              vertical: 100,
            ),
            child: Column(
              children: [
                Text(
                  'OUR STORY',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF64FFDA),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ).animate().fadeIn().slideY(begin: -0.2),
                
                const SizedBox(height: 24),
                
                Text(
                  'Redefining the\nFuture of Commerce',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: isWide ? 64 : 42,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 60),

                GlassContainer(
                  borderRadius: 24,
                  blur: 20,
                  opacity: 0.05,
                  padding: const EdgeInsets.all(40),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  child: Column(
                    children: [
                      Text(
                        'We believe that shopping online should be more than just clicking buttons—it should be an experience. By integrating cutting-edge 3D technology, we perform the gap between physical and digital retail, allowing you to interact with products as if they were right in front of you.',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 18,
                          height: 1.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStat('50K+', 'Users'),
                          _buildStat('100+', 'Products'),
                          _buildStat('4.9', 'Rating'),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95)),
                
                const SizedBox(height: 80),
                
                Text(
                  'OUR VISION',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF64FFDA),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ).animate().fadeIn(),
                 
                const SizedBox(height: 32),

                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildValueCard(Icons.rocket_launch, 'Innovation', 'Pushing boundaries of what web can do.'),
                    _buildValueCard(Icons.security, 'Trust', 'Secure transactions and distinct quality.'),
                    _buildValueCard(Icons.eco, 'Sustainability', 'Green hosting and eco-friendly products.'),
                  ],
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white38,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildValueCard(IconData icon, String title, String desc) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF64FFDA), size: 40),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white54,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
