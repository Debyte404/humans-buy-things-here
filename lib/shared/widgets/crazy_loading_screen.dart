import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CrazyLoadingScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final Duration duration;

  const CrazyLoadingScreen({
    super.key,
    this.onComplete,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<CrazyLoadingScreen> createState() => _CrazyLoadingScreenState();
}

class _CrazyLoadingScreenState extends State<CrazyLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _particleController;
  late Animation<double> _progressAnimation;
  double _displayProgress = 0;

  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Main progress controller
    _mainController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _progressAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOutCubic,
    );

    _progressAnimation.addListener(() {
      setState(() {
        _displayProgress = _progressAnimation.value * 100;
      });
    });

    // Pulse effect controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Rotation controller for orbiting elements
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Particle controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(_updateParticles);
    _particleController.repeat();

    // Generate initial particles
    _generateParticles();

    // Start the loading animation
    _mainController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onComplete?.call();
      });
    });
  }

  void _generateParticles() {
    for (int i = 0; i < 50; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble() * 400 - 200,
        y: _random.nextDouble() * 400 - 200,
        size: _random.nextDouble() * 4 + 1,
        speed: _random.nextDouble() * 2 + 0.5,
        angle: _random.nextDouble() * math.pi * 2,
        opacity: _random.nextDouble() * 0.5 + 0.2,
      ));
    }
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.angle += particle.speed * 0.02;
      particle.x = math.cos(particle.angle) * (100 + particle.speed * 50);
      particle.y = math.sin(particle.angle) * (100 + particle.speed * 50);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          // Animated gradient background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.5 + (_pulseController.value * 0.3),
                      colors: [
                        const Color(0xFF64FFDA).withAlpha(15),
                        const Color(0xFF050505),
                        Colors.black,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),

          // Grid lines background
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(
                animation: _pulseController,
                color: const Color(0xFF64FFDA),
              ),
            ).animate().fadeIn(duration: 1000.ms),
          ),

          // Floating particles
          Center(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(size.width, size.height),
                  painter: _ParticlePainter(
                    particles: _particles,
                    progress: _progressAnimation.value,
                  ),
                );
              },
            ),
          ),

          // Main loading content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Orbiting rings
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ring
                          Transform.rotate(
                            angle: _rotationController.value * math.pi * 2,
                            child: _buildOrbitRing(180, 3),
                          ),
                          // Middle ring (reverse)
                          Transform.rotate(
                            angle: -_rotationController.value * math.pi * 2 * 1.5,
                            child: _buildOrbitRing(140, 2),
                          ),
                          // Inner ring
                          Transform.rotate(
                            angle: _rotationController.value * math.pi * 2 * 2,
                            child: _buildOrbitRing(100, 2),
                          ),
                          // Center pulsing logo
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 70 + (_pulseController.value * 10),
                                height: 70 + (_pulseController.value * 10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const RadialGradient(
                                    colors: [
                                      Color(0xFF64FFDA),
                                      Color(0xFF1A5F5A),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF64FFDA)
                                          .withAlpha((150 * _pulseController.value).toInt()),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.bolt,
                                  color: Colors.black,
                                  size: 35,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ).animate().scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                    ),

                const SizedBox(height: 60),

                // Brand name with glitch effect
                _buildGlitchText(),

                const SizedBox(height: 40),

                // Progress bar
                _buildProgressBar(),

                const SizedBox(height: 20),

                // Loading text with typing effect
                _buildLoadingText(),
              ],
            ),
          ),

          // Corner decorations
          ..._buildCornerDecorations(size),

          // Scanlines overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  backgroundBlendMode: BlendMode.overlay,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: List.generate(
                      50,
                      (index) => index.isEven
                          ? Colors.transparent
                          : Colors.black.withAlpha(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrbitRing(double size, double strokeWidth) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(size, size),
          painter: _OrbitRingPainter(
            progress: _progressAnimation.value,
            pulseValue: _pulseController.value,
            strokeWidth: strokeWidth,
          ),
        );
      },
    );
  }

  Widget _buildGlitchText() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glitchOffset = math.sin(_pulseController.value * math.pi * 4) * 2;

        return Stack(
          children: [
            // Red offset
            Transform.translate(
              offset: Offset(-glitchOffset, 0),
              child: Text(
                'REVOLUTIONARY',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                  color: Colors.red.withAlpha(100),
                ),
              ),
            ),
            // Cyan offset
            Transform.translate(
              offset: Offset(glitchOffset, 0),
              child: Text(
                'REVOLUTIONARY',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                  color: Colors.cyan.withAlpha(100),
                ),
              ),
            ),
            // Main text
            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    Colors.white,
                    const Color(0xFF64FFDA),
                    Colors.white,
                  ],
                  stops: [
                    0.0,
                    _pulseController.value,
                    1.0,
                  ],
                ).createShader(bounds);
              },
              child: Text(
                'REVOLUTIONARY',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildProgressBar() {
    return Container(
      width: 280,
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: Colors.white.withAlpha(20),
      ),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              // Progress fill
              FractionallySizedBox(
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF64FFDA),
                        Color(0xFF4FD1C7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF64FFDA).withAlpha(150),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
              // Shimmer effect
              Positioned.fill(
                child: FractionallySizedBox(
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withAlpha(100),
                          Colors.transparent,
                        ],
                        stops: [
                          0.0,
                          (_pulseController.value),
                          1.0,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3);
  }

  Widget _buildLoadingText() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Text(
              '${_displayProgress.toInt()}%',
              style: GoogleFonts.outfit(
                fontSize: 42,
                fontWeight: FontWeight.w200,
                color: const Color(0xFF64FFDA),
                letterSpacing: 4,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        _AnimatedLoadingText(),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }

  List<Widget> _buildCornerDecorations(Size size) {
    return [
      // Top left
      Positioned(
        top: 40,
        left: 40,
        child: _CornerDecoration(animation: _pulseController, corner: 'TL'),
      ),
      // Top right
      Positioned(
        top: 40,
        right: 40,
        child: _CornerDecoration(animation: _pulseController, corner: 'TR'),
      ),
      // Bottom left
      Positioned(
        bottom: 40,
        left: 40,
        child: _CornerDecoration(animation: _pulseController, corner: 'BL'),
      ),
      // Bottom right
      Positioned(
        bottom: 40,
        right: 40,
        child: _CornerDecoration(animation: _pulseController, corner: 'BR'),
      ),
    ];
  }
}

class _AnimatedLoadingText extends StatefulWidget {
  @override
  State<_AnimatedLoadingText> createState() => _AnimatedLoadingTextState();
}

class _AnimatedLoadingTextState extends State<_AnimatedLoadingText> {
  final List<String> _loadingTexts = [
    'INITIALIZING SYSTEMS',
    'LOADING ASSETS',
    'PREPARING EXPERIENCE',
    'ALMOST READY',
  ];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _cycleText();
  }

  void _cycleText() {
    Future.delayed(const Duration(milliseconds: 750), () {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _loadingTexts.length;
        });
        _cycleText();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _loadingTexts[_currentIndex],
        key: ValueKey(_currentIndex),
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.white38,
          letterSpacing: 3,
        ),
      ),
    );
  }
}

class _CornerDecoration extends StatelessWidget {
  final Animation<double> animation;
  final String corner;

  const _CornerDecoration({
    required this.animation,
    required this.corner,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border(
              top: corner.contains('T')
                  ? BorderSide(
                      color: const Color(0xFF64FFDA)
                          .withAlpha((100 + animation.value * 80).toInt()),
                      width: 2,
                    )
                  : BorderSide.none,
              bottom: corner.contains('B')
                  ? BorderSide(
                      color: const Color(0xFF64FFDA)
                          .withAlpha((100 + animation.value * 80).toInt()),
                      width: 2,
                    )
                  : BorderSide.none,
              left: corner.contains('L')
                  ? BorderSide(
                      color: const Color(0xFF64FFDA)
                          .withAlpha((100 + animation.value * 80).toInt()),
                      width: 2,
                    )
                  : BorderSide.none,
              right: corner.contains('R')
                  ? BorderSide(
                      color: const Color(0xFF64FFDA)
                          .withAlpha((100 + animation.value * 80).toInt()),
                      width: 2,
                    )
                  : BorderSide.none,
            ),
          ),
        );
      },
    ).animate().fadeIn(delay: 800.ms);
  }
}

class _Particle {
  double x;
  double y;
  double size;
  double speed;
  double angle;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (var particle in particles) {
      final paint = Paint()
        ..color = const Color(0xFF64FFDA).withAlpha((particle.opacity * 255 * progress).toInt())
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(center.dx + particle.x, center.dy + particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _OrbitRingPainter extends CustomPainter {
  final double progress;
  final double pulseValue;
  final double strokeWidth;

  _OrbitRingPainter({
    required this.progress,
    required this.pulseValue,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw dashed arc
    final paint = Paint()
      ..color = const Color(0xFF64FFDA).withAlpha((80 + pulseValue * 50).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw arc based on progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      paint,
    );

    // Draw orbiting dot
    final dotAngle = (progress * math.pi * 2) - (math.pi / 2);
    final dotX = center.dx + radius * math.cos(dotAngle);
    final dotY = center.dy + radius * math.sin(dotAngle);

    final dotPaint = Paint()
      ..color = const Color(0xFF64FFDA)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dotX, dotY), 4, dotPaint);

    // Glow for dot
    final glowPaint = Paint()
      ..color = const Color(0xFF64FFDA).withAlpha(50)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(Offset(dotX, dotY), 8, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _GridPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _GridPainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha((10 + animation.value * 5).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 50.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
