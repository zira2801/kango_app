import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RechargeImageWidget extends StatelessWidget {
  final String imageUrl;

  const RechargeImageWidget({Key? key, required this.imageUrl})
      : super(key: key);

  Future<Uint8List?> fetchImageBytes(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      } else {
        debugPrint("Lỗi tải ảnh: Mã lỗi ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Lỗi tải ảnh: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 300.h,
        child: SizedBox(
          width: 60.w,
          height: 60.w,
          child: FutureBuilder<Uint8List?>(
            future: fetchImageBytes(imageUrl),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 20.w,
                  width: 20.w,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.data == null || snapshot.hasError) {
                return const Icon(Icons.error);
              }

              try {
                return Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint("Lỗi giải mã ảnh: $error");
                    return const Icon(Icons.error);
                  },
                );
              } catch (e) {
                debugPrint("Lỗi giải mã ảnh: $e");
                return const Icon(Icons.error);
              }
            },
          ),
        ),
      ),
    );
  }
}
