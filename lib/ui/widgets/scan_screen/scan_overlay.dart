import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double cornerSize = 20.0; // size of the corner squares
        const double cornerThickness = 3.0; // thickness of the corner borders

        return Stack(
          children: [
            // Top-left corner
            Positioned(
              left: constraints.maxWidth * 0.04,
              top: constraints.maxHeight * 0.3,
              child: Container(
                width: cornerSize,
                height: cornerSize,
                decoration: const BoxDecoration(
                  border: Border(
                    top:
                        BorderSide(color: Colors.white, width: cornerThickness),
                    left:
                        BorderSide(color: Colors.white, width: cornerThickness),
                  ),
                ),
              ),
            ),
            // Top-right corner
            Positioned(
              right: constraints.maxWidth * 0.04,
              top: constraints.maxHeight * 0.3,
              child: Container(
                width: cornerSize,
                height: cornerSize,
                decoration: const BoxDecoration(
                  border: Border(
                    top:
                        BorderSide(color: Colors.white, width: cornerThickness),
                    right:
                        BorderSide(color: Colors.white, width: cornerThickness),
                  ),
                ),
              ),
            ),
            // Bottom-left corner
            Positioned(
              left: constraints.maxWidth * 0.04,
              bottom: constraints.maxHeight * 0.3,
              child: Container(
                width: cornerSize,
                height: cornerSize,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom:
                        BorderSide(color: Colors.white, width: cornerThickness),
                    left:
                        BorderSide(color: Colors.white, width: cornerThickness),
                  ),
                ),
              ),
            ),
            // Bottom-right corner
            Positioned(
              right: constraints.maxWidth * 0.04,
              bottom: constraints.maxHeight * 0.3,
              child: Container(
                width: cornerSize,
                height: cornerSize,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom:
                        BorderSide(color: Colors.white, width: cornerThickness),
                    right:
                        BorderSide(color: Colors.white, width: cornerThickness),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
