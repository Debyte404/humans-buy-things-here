import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class AnimatedHeader extends ConsumerStatefulWidget {
  final double scrollOffset;
  final VoidCallback? onSignOut;
  final VoidCallback? onShopPressed;

  const AnimatedHeader({
    super.key,
    required this.scrollOffset,
    this.onSignOut,
    this.onShopPressed,
  });

  @override
  ConsumerState<AnimatedHeader> createState() => _AnimatedHeaderState();
}

class _AnimatedHeaderState extends ConsumerState<AnimatedHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  int _hoveredIndex = -1;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showSolid = widget.scrollOffset > 80;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: showSolid ? 0 : (isWide ? 40 : 16),
              vertical: showSolid ? 0 : 20,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(showSolid ? 0 : 20),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: showSolid ? 20 : 15,
                  sigmaY: showSolid ? 20 : 15,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 32 : 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(showSolid ? 0 : 20),
                    color: showSolid
                        ? const Color(0xFF0A0A0A).withAlpha(200)
                        : Colors.white.withAlpha(10),
                    border: Border.all(
                      color: showSolid
                          ? const Color(0xFF64FFDA).withAlpha(30)
                          : Colors.white.withAlpha(30),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF64FFDA)
                            .withAlpha((30 * _glowController.value).toInt()),
                        blurRadius: 30,
                        spreadRadius: -5,
                      ),
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        // Animated Logo
                        _buildLogo(isWide),
                        const Spacer(),
                        // Navigation Links
                        if (isWide) ...[
                          _buildNavItem('Home', 0, true, null),
                          _buildNavItem('Collection', 1, false, widget.onShopPressed),
                          _buildNavItem('About', 2, false, () => context.push('/about')),
                          _buildNavItem('Contact', 3, false, () => context.push('/contact')),
                          const SizedBox(width: 24),
                        ],
                        // CTA Button with glow effect
                        _buildCTAButton(),
                        if (!isWide) ...[
                          const SizedBox(width: 12),
                          _buildMenuButton(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2);
  }

  Widget _buildLogo(bool isWide) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated Icon
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF64FFDA),
                      const Color(0xFF64FFDA).withAlpha(150),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF64FFDA)
                          .withAlpha((80 * _glowController.value).toInt()),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bolt,
                  color: Colors.black,
                  size: 18,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          // Logo Text with shimmer effect
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
                  _glowController.value,
                  1.0,
                ],
              ).createShader(bounds);
            },
            child: Text(
              isWide ? 'REVOLUTIONARY' : 'REV',
              style: GoogleFonts.outfit(
                fontSize: isWide ? 18 : 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String text, int index, bool active, VoidCallback? onTap) {
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: (active || isHovered)
                ? const Color(0xFF64FFDA).withAlpha(15)
                : Colors.transparent,
            border: Border.all(
              color: (active || isHovered)
                  ? const Color(0xFF64FFDA).withAlpha(40)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (active)
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF64FFDA),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF64FFDA).withAlpha(150),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              Text(
                text,
                style: GoogleFonts.outfit(
                  color: active
                      ? const Color(0xFF64FFDA)
                      : (isHovered ? Colors.white : Colors.white70),
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCTAButton() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF64FFDA)
                    .withAlpha((60 * _glowController.value).toInt()),
                blurRadius: 20,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onSignOut,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF64FFDA),
                      Color(0xFF4FD1C7),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: Colors.black,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sign Out',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuButton() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withAlpha(10),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: const Icon(
        Icons.menu_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
