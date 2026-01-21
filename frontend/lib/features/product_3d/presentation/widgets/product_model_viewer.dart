import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class ProductModelViewer extends StatefulWidget {
  final String src;

  const ProductModelViewer({super.key, required this.src});

  @override
  State<ProductModelViewer> createState() => _ProductModelViewerState();
}

class _ProductModelViewerState extends State<ProductModelViewer> {
  late Flutter3DController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Flutter3DController();
  }

  @override
  Widget build(BuildContext context) {
    return Flutter3DViewer(
      controller: _controller,
      src: widget.src,
      progressBarColor: const Color(0xFF64FFDA),
    );
  }
}
