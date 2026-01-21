import 'package:flutter/material.dart';

class ProductModelViewer extends StatelessWidget {
  final String src;

  const ProductModelViewer({super.key, required this.src});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Text('3D Model Viewer Placeholder'),
      ),
    );
  }
}
