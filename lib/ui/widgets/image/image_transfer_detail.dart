import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImageDetailScreen extends StatelessWidget {
  final File imageFile;
  final String heroTag;

  const ImageDetailScreen({
    Key? key,
    required this.imageFile,
    required this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5, // Giới hạn thu nhỏ tối đa (0.5x)
          maxScale: 4.0, // Giới hạn phóng to tối đa (4x)
          boundaryMargin: const EdgeInsets.all(
              double.infinity), // Cho phép kéo ra ngoài biên
          child: Hero(
            tag: heroTag,
            child: Image.file(
              imageFile,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
