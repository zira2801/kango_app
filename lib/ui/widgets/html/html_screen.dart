import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class HtmlViewer extends StatelessWidget {
  final String htmlData;

  const HtmlViewer({super.key, required this.htmlData});

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      htmlData,
      customStylesBuilder: (element) {
        if (element.localName == 'img') {
          return {'max-width': '100%', 'height': 'auto'};
        }
        if (element.localName == 'div' && element.classes.contains('alert')) {
          if (element.classes.contains('alert-info')) {
            return {
              'background-color':
                  '#D1ECF1', // Light blue background for info alert
              'border-color': '#BEE5EB',
              'color': '#0C5460',
              'padding': '15px',
              'border-radius': '4px',
              'margin-bottom': '15px'
            };
          }
          if (element.classes.contains('alert-warning')) {
            return {
              'background-color':
                  '#FFF3CD', // Light yellow background for warning
              'border-color': '#FFEEBA',
              'color': '#856404',
              'padding': '15px',
              'border-radius': '4px',
              'margin-bottom': '15px'
            };
          }
        }

        // Styling for title dividers
        if (element.localName == 'div' && element.classes.contains('title')) {
          return {
            'color': '#1e8c96', // Primary blue color
            'text-transform': 'uppercase',
            'font-weight': 'bold',
            'margin-bottom': '15px',
            'position': 'relative',
            'padding-bottom': '10px',
            'border-bottom': '2px solid #1e8c96'
          };
        }

        // Strong text styling
        if (element.localName == 'strong') {
          return {
            'color': '#212529' // Dark text color for important information
          };
        }

        return null;
      },
      customWidgetBuilder: (element) {
        if (element.localName == 'img') {
          final String? src = element.attributes['src'];
          if (src != null) {
            return GestureDetector(
              onTap: () {
                _showImageFullScreen(context, src);
              },
              child: _buildImageWidget(src),
            );
          }
        }
        return null;
      },
      renderMode: RenderMode.column,
      buildAsync: false,
      textStyle: const TextStyle(fontSize: 13),
    );
  }

  Widget _buildImageWidget(String src) {
    if (src.startsWith('data:image')) {
      return _buildBase64Image(src);
    } else {
      return Image.network(
        src,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.image_not_supported, color: Colors.grey);
        },
      );
    }
  }

  Widget _buildBase64Image(String src) {
    try {
      final int commaIndex = src.indexOf(',');
      if (commaIndex == -1) {
        return const Icon(Icons.image_not_supported, color: Colors.grey);
      }

      final String base64Data = src.substring(commaIndex + 1);
      final Uint8List bytes = base64Decode(base64Data);

      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.image_not_supported, color: Colors.grey);
        },
      );
    } catch (e) {
      return const Icon(Icons.image_not_supported, color: Colors.red);
    }
  }

  void _showImageFullScreen(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(imageUrl: imageUrl),
      ),
    );
  }
}

class FullScreenImage extends StatefulWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  final TransformationController _transformationController =
      TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: GestureDetector(
          onDoubleTapDown: (details) => _doubleTapDetails = details,
          onDoubleTap: _handleDoubleTap,
          child: InteractiveViewer(
            transformationController: _transformationController,
            panEnabled: true,
            boundaryMargin: EdgeInsets.zero,
            minScale: 1.0,
            maxScale: 4.0,
            child: widget.imageUrl.startsWith('data:image')
                ? _buildBase64Image(widget.imageUrl)
                : Container(
                    height: double.infinity,
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported,
                            size: 60, color: Colors.grey);
                      },
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBase64Image(String src) {
    try {
      final int commaIndex = src.indexOf(',');
      if (commaIndex == -1) {
        return const Icon(Icons.image_not_supported, color: Colors.grey);
      }

      final String base64Data = src.substring(commaIndex + 1);
      final Uint8List bytes = base64Decode(base64Data);

      return Container(
        height: double.infinity,
        child: Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.image_not_supported, color: Colors.grey);
          },
        ),
      );
    } catch (e) {
      return const Icon(Icons.image_not_supported, color: Colors.red);
    }
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails!.localPosition;
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(2.0);
    }
  }
}
