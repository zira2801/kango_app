import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EnhancedImageViewer extends StatefulWidget {
  final String imageUrl;

  const EnhancedImageViewer({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  State<EnhancedImageViewer> createState() => _EnhancedImageViewerState();
}

class _EnhancedImageViewerState extends State<EnhancedImageViewer>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  TapDownDetails? _doubleTapDetails;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (_animation != null) {
          _transformationController.value = _animation!.value;
        }
      });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      // Currently zoomed in, so zoom out
      _resetAnimation();
    } else {
      // Currently zoomed out, so zoom in
      final position = _doubleTapDetails!.localPosition;
      _zoominAnimation(position);
    }
  }

  void _zoominAnimation(Offset position) {
    final endMatrix = Matrix4.identity()
      ..translate(-position.dx * 2, -position.dy * 2)
      ..scale(3.0);

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward(from: 0);
  }

  void _resetAnimation() {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Image Container
            Center(
              child: GestureDetector(
                onDoubleTapDown: _handleDoubleTapDown,
                onDoubleTap: _handleDoubleTap,
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Hero(
                    tag: 'imageHero${widget.imageUrl}',
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Center(
                        child: SizedBox(
                          height: 30.w,
                          width: 30.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[900],
                        child: Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 50.w,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Top Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 28.w),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.rotate_left,
                              color: Colors.white, size: 24.w),
                          onPressed: _resetAnimation,
                        ),
                        /*IconButton(
                          icon: Icon(Icons.share,
                              color: Colors.white, size: 24.w),
                          onPressed: () {
                            // Implement share functionality
                          },
                        ),*/
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Instructions
            Positioned(
              bottom: 20.h,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  'Nhấn đúp để phóng to • Chụm để thu phóng',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
