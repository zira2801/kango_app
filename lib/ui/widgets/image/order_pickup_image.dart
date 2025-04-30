import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderPickupImage extends StatelessWidget {
  final String imageUrl;

  const OrderPickupImage({Key? key, required this.imageUrl}) : super(key: key);

  Future<Uint8List?> fetchImageBytes(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      // Kiểm tra nếu ảnh hợp lệ
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      } else {
        debugPrint("Lỗi tải ảnh: Mã lỗi ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Lỗi tải ảnh: $e");
    }
    return null; // Nếu lỗi, trả về null
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: fetchImageBytes(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Nếu có lỗi hoặc dữ liệu ảnh không hợp lệ
        if (snapshot.data == null || snapshot.hasError) {
          return const Icon(Icons.broken_image, size: 50, color: Colors.red);
        }

        try {
          // Kiểm tra ảnh có bị lỗi khi giải mã không
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(snapshot.data!, fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
              debugPrint("Lỗi giải mã ảnh: $error");
              return Icon(Icons.broken_image,
                  size: 50, color: Theme.of(context).colorScheme.primary);
            }),
          );
        } catch (e) {
          debugPrint("Lỗi giải mã ảnh: $e");
          return Icon(Icons.broken_image,
              size: 50, color: Theme.of(context).colorScheme.primary);
        }
      },
    );
  }
}
