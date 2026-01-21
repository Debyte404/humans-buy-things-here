import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:revolutionary_commerce/features/shop/data/product_repository.dart';
import 'package:revolutionary_commerce/features/shop/domain/product.dart';
import 'package:revolutionary_commerce/features/product_3d/presentation/widgets/product_model_viewer.dart';
import 'package:revolutionary_commerce/features/cart/application/cart_provider.dart';
import 'package:revolutionary_commerce/features/cart/presentation/cart_drawer.dart';
import 'package:revolutionary_commerce/core/presentation/widgets/glass_container.dart';

// ... (ProductListProvider remains same, omitting for brevity in tool call if not modifying)

// Redefining proper imports and keeping provider
final productListProvider = StreamProvider<List<Product>>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  repo.seedInitialData();
  return repo.getProducts();
});

class ProductListingScreen extends ConsumerWidget {
  const ProductListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050505), // Deep dark background
      endDrawer: const CartDrawer(),
      appBar: AppBar(
        title: Text(
          'COLLECTION',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            letterSpacing: 3.0,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
         actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
        leading: IconButton(
           icon: const Icon(Icons.arrow_back, color: Colors.white),
           onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
         children: [
           // Ambient Background Glows
           Positioned(
             top: -200,
             right: -200,
             child: Container(
               width: 600,
               height: 600,
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 gradient: RadialGradient(
                   colors: [
                     const Color(0xFF64FFDA).withOpacity(0.05),
                     Colors.transparent
                   ],
                 ),
               ),
             ),
           ),
           
           productsAsync.when(
            data: (products) => Padding(
              padding: const EdgeInsets.only(top: 100.0, left: 16, right: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  childAspectRatio: 0.75, // Taller cards
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(product: product)
                      .animate()
                      .fadeIn(duration: 600.ms, delay: (100 * index).ms)
                      .slideY(begin: 0.1, curve: Curves.easeOutQuad);
                },
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF64FFDA))),
            error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
          ),
         ]
      ),
    );
  }
}

class ProductCard extends ConsumerStatefulWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: 200.ms,
        child: GlassContainer(
          borderRadius: 24,
          blur: 20,
          opacity: 0.05,
          color: Colors.white,
          border: Border.all(
            color: _isHovered ? const Color(0xFF64FFDA).withOpacity(0.5) : Colors.white.withOpacity(0.1),
            width: 1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                     // 3D Viewer
                     ClipRRect(
                       borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                       child: ProductModelViewer(src: widget.product.modelUrl),
                     ),
                     
                     // 360 Badge
                     Positioned(
                       top: 16,
                       right: 16,
                       child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                         decoration: BoxDecoration(
                           color: Colors.black.withOpacity(0.6),
                           borderRadius: BorderRadius.circular(20),
                           border: Border.all(color: Colors.white.withOpacity(0.2)),
                         ),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             const Icon(Icons.view_in_ar, size: 14, color: Color(0xFF64FFDA)),
                             const SizedBox(width: 4),
                             Text(
                               '360°', 
                               style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                             ),
                           ],
                         ),
                       ),
                     )
                  ],
                ),
              ),
              
              // Product Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.product.category.toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product.name.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: Colors.white,
                          height: 1.0,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${widget.product.price.toStringAsFixed(0)}',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF64FFDA),
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          
                          // Add Button
                          InkWell(
                            onTap: () {
                              ref.read(cartProvider.notifier).addToCart(widget.product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${widget.product.name} added to cart', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                  backgroundColor: const Color(0xFF64FFDA),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  width: 250,
                                ),
                              );
                            },
                             child: Container(
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                 color: Colors.white,
                                 shape: BoxShape.circle,
                                 boxShadow: [
                                   if (_isHovered)
                                     BoxShadow(
                                       color: Colors.white.withOpacity(0.3),
                                       blurRadius: 10,
                                       spreadRadius: 2,
                                     )
                                 ]
                               ),
                               child: const Icon(Icons.add, size: 20, color: Colors.black),
                             ),
                          )
                        ],
                      ),
                    ],
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
