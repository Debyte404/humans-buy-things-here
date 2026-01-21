import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:revolutionary_commerce/features/product_3d/presentation/widgets/product_model_viewer.dart';
import 'package:revolutionary_commerce/core/presentation/widgets/glass_container.dart';
import 'package:revolutionary_commerce/shared/widgets/animated_header.dart';
import '../auth/application/auth_notifier.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // SECTION 1: Hero
              SliverToBoxAdapter(
                child: _buildHeroSection(size, isWide),
              ),

              // SECTION 2: Featured Products
              SliverToBoxAdapter(
                child: _buildFeaturedSection(size, isWide),
              ),

              // SECTION 3: Product Spotlight
              SliverToBoxAdapter(
                child: _buildSpotlightSection(size, isWide),
              ),

              // SECTION 4: Trust & Features
              SliverToBoxAdapter(
                child: _buildTrustSection(size),
              ),

              // SECTION 5: CTA Banner
              SliverToBoxAdapter(
                child: _buildCtaBanner(size, isWide),
              ),

              // Footer
              SliverToBoxAdapter(
                child: _buildFooter(size),
              ),
            ],
          ),

          // Beautiful Animated Header
          Consumer(
            builder: (context, ref, _) => AnimatedHeader(
              scrollOffset: _scrollOffset,
              onSignOut: () => ref.read(authNotifierProvider.notifier).signOut(),
              onShopPressed: () => context.push('/shop'),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildHeroSection(Size size, bool isWide) {
    return Container(
      height: size.height,
      width: size.width,
      child: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    const Color(0xFF64FFDA).withAlpha(30),
                    const Color(0xFF050505),
                    const Color(0xFF050505),
                  ],
                ),
              ),
            ),
          ),

          // Parallax text
          Positioned(
            top: 150 - (_scrollOffset * 0.3),
            left: isWide ? 80 : 24,
            child: Text(
              'THE\nFUTURE\nIS NOW',
              style: GoogleFonts.outfit(
                fontSize: isWide ? 140 : 80,
                fontWeight: FontWeight.w900,
                height: 0.9,
                color: Colors.white.withAlpha(10),
                letterSpacing: -5,
              ),
            ).animate().fadeIn(duration: 1200.ms).slideX(begin: -0.1),
          ),

          // Content
          Positioned(
            left: isWide ? 80 : 24,
            right: isWide ? size.width * 0.5 : 24,
            top: size.height * 0.35,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF64FFDA)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'NEW ARRIVAL',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF64FFDA),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                const SizedBox(height: 24),

                Text(
                  'LIMITLESS\nSNEAKER',
                  style: GoogleFonts.outfit(
                    fontSize: isWide ? 72 : 48,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                const SizedBox(height: 16),

                Text(
                  'Experience the future of footwear with adaptive fit\ntechnology and reactive cushioning system.',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.white60,
                    height: 1.6,
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Text(
                      '\$299',
                      style: GoogleFonts.outfit(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '\$399',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        color: Colors.white30,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 800.ms),

                const SizedBox(height: 32),

                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => context.push('/shop'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF64FFDA),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'SHOP NOW',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w700, letterSpacing: 1),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.play_circle_outline, size: 20),
                          const SizedBox(width: 8),
                          Text('Watch Video', style: GoogleFonts.outfit()),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2),
              ],
            ),
          ),

          // 3D Model on right
          if (isWide)
            Positioned(
              right: 0,
              top: size.height * 0.15,
              width: size.width * 0.5,
              height: size.height * 0.7,
              child: Transform.translate(
                offset: Offset(0, -_scrollOffset * 0.2),
                child: const ProductModelViewer(
                  src: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/MaterialsVariantsShoe/glTF-Binary/MaterialsVariantsShoe.glb',
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 1000.ms).scale(begin: const Offset(0.9, 0.9)),
            ),

          // Scroll indicator
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  Text(
                    'SCROLL TO EXPLORE',
                    style: GoogleFonts.outfit(
                      color: Colors.white30,
                      fontSize: 10,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withAlpha(51),
                  ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms),
                ],
              ),
            ).animate().fadeIn(delay: 1500.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(Size size, bool isWide) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 80 : 24, vertical: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FEATURED COLLECTION',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF64FFDA),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Curated for you',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.push('/shop'),
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: GoogleFonts.outfit(color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 16, color: Colors.white70),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn().slideY(begin: 0.1),

          const SizedBox(height: 48),

          // Product Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = isWide ? 3 : 1;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 0.75,
                children: [
                  _ProductCard(
                    name: 'Limitless Sneaker',
                    price: 299,
                    modelUrl: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/MaterialsVariantsShoe/glTF-Binary/MaterialsVariantsShoe.glb',
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                  _ProductCard(
                    name: 'Damaged Helmet',
                    price: 450,
                    modelUrl: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/DamagedHelmet/glTF-Binary/DamagedHelmet.glb',
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  _ProductCard(
                    name: 'Avocado',
                    price: 99,
                    modelUrl: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Avocado/glTF-Binary/Avocado.glb',
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpotlightSection(Size size, bool isWide) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 80 : 24, vertical: 80),
      child: isWide
          ? Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: const ProductModelViewer(
                      src: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/DamagedHelmet/glTF-Binary/DamagedHelmet.glb',
                    ),
                  ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
                ),
                const SizedBox(width: 80),
                Expanded(
                  child: _spotlightContent(),
                ),
              ],
            )
          : Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: const ProductModelViewer(
                    src: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/DamagedHelmet/glTF-Binary/DamagedHelmet.glb',
                  ),
                ),
                const SizedBox(height: 48),
                _spotlightContent(),
              ],
            ),
    );
  }

  Widget _spotlightContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'PRODUCT SPOTLIGHT',
          style: GoogleFonts.outfit(
            color: const Color(0xFF64FFDA),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),
        Text(
          'Cyberpunk\nHelmet',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
        const SizedBox(height: 24),
        Text(
          'High-tech protective gear designed for the urban jungle. Features advanced ventilation system and integrated HUD compatibility.',
          style: GoogleFonts.outfit(
            color: Colors.white60,
            fontSize: 16,
            height: 1.6,
          ),
        ).animate().fadeIn(delay: 600.ms),
        const SizedBox(height: 32),
        Row(
          children: [
            _featureChip(Icons.shield, 'Impact Resistant'),
            const SizedBox(width: 16),
            _featureChip(Icons.air, 'Breathable'),
            const SizedBox(width: 16),
            _featureChip(Icons.bluetooth, 'Smart Ready'),
          ],
        ).animate().fadeIn(delay: 800.ms),
        const SizedBox(height: 40),
        Text(
          '\$450',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w700,
          ),
        ).animate().fadeIn(delay: 1000.ms),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => context.push('/shop'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            'ADD TO CART',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700, letterSpacing: 1),
          ),
        ).animate().fadeIn(delay: 1200.ms),
      ],
    );
  }

  Widget _featureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64FFDA)),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustSection(Size size) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.white.withAlpha(15)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _trustItem(Icons.local_shipping_outlined, 'Free Shipping', 'On orders over \$100'),
          _trustItem(Icons.refresh, '30-Day Returns', 'No questions asked'),
          _trustItem(Icons.verified_outlined, '2-Year Warranty', 'Full coverage'),
          _trustItem(Icons.support_agent_outlined, '24/7 Support', 'Always here to help'),
        ],
      ).animate().fadeIn().slideY(begin: 0.1),
    );
  }

  Widget _trustItem(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(icon, size: 32, color: const Color(0xFF64FFDA)),
        const SizedBox(height: 16),
        Text(
          title,
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCtaBanner(Size size, bool isWide) {
    return Container(
      margin: EdgeInsets.all(isWide ? 80 : 24),
      padding: EdgeInsets.all(isWide ? 80 : 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF64FFDA).withAlpha(30),
            const Color(0xFF64FFDA).withAlpha(10),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF64FFDA).withAlpha(50)),
      ),
      child: Column(
        children: [
          Text(
            'Join the Revolution',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: isWide ? 48 : 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Subscribe for exclusive drops and early access',
            style: GoogleFonts.outfit(color: Colors.white60, fontSize: 16),
          ),
          const SizedBox(height: 32),
          Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: GoogleFonts.outfit(color: Colors.white30),
                      filled: true,
                      fillColor: Colors.white.withAlpha(10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF64FFDA),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Subscribe', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildFooter(Size size) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(5),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REVOLUTIONARY',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pushing boundaries in e-commerce\nwith immersive 3D experiences.',
                      style: GoogleFonts.outfit(color: Colors.white38, height: 1.6),
                    ),
                  ],
                ),
              ),
              Expanded(child: _footerColumn('Shop', ['All Products', 'New Arrivals', 'Best Sellers'])),
              Expanded(child: _footerColumn('Company', ['About Us', 'Careers', 'Press'])),
              Expanded(child: _footerColumn('Support', ['Contact', 'FAQs', 'Shipping'])),
            ],
          ),
          const SizedBox(height: 48),
          Divider(color: Colors.white.withAlpha(15)),
          const SizedBox(height: 24),
          Text(
            '© 2026 Revolutionary Commerce. All rights reserved.',
            style: GoogleFonts.outfit(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _footerColumn(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                item,
                style: GoogleFonts.outfit(color: Colors.white38, fontSize: 14),
              ),
            )),
      ],
    );
  }
}

class _ProductCard extends StatefulWidget {
  final String name;
  final double price;
  final String modelUrl;

  const _ProductCard({
    required this.name,
    required this.price,
    required this.modelUrl,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(_isHovered ? 15 : 8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? const Color(0xFF64FFDA).withAlpha(100) : Colors.white.withAlpha(15),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF64FFDA).withAlpha(20),
                    blurRadius: 30,
                    spreadRadius: 0,
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    ProductModelViewer(src: widget.modelUrl),
                    if (_isHovered)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF64FFDA).withAlpha(15),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.name.toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${widget.price.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF64FFDA),
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isHovered ? const Color(0xFF64FFDA) : Colors.white.withAlpha(15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: _isHovered ? Colors.black : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
