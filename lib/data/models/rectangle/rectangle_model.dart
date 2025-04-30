import 'package:image/image.dart' as img;

class Rectangle {
  final int x;
  final int y;
  final int width;
  final int height;

  Rectangle(this.x, this.y, this.width, this.height);
}

// Tìm các vùng kết nối lớn trong ảnh nhị phân
List<Rectangle> findLargeConnectedRegions(img.Image binaryImage) {
  // Giả lập tìm vùng kết nối đơn giản
  // Trong thực tế, bạn sẽ cần sử dụng thuật toán connected component labeling
  // Đây là phương pháp đơn giản hóa

  int minSize = binaryImage.width *
      binaryImage.height ~/
      20; // Tối thiểu 5% diện tích ảnh
  List<Rectangle> results = [];

  // Thuật toán đơn giản để tìm vùng sáng
  // Quét từng dòng để tìm vùng sáng liên tục
  for (int y = 0; y < binaryImage.height; y += binaryImage.height ~/ 10) {
    int startX = -1;
    for (int x = 0; x < binaryImage.width; x++) {
      img.Pixel pixel = binaryImage.getPixel(x, y);

      // Nếu là điểm sáng và chưa bắt đầu vùng
      if (pixel == 0xFFFFFFFF && startX == -1) {
        startX = x;
      }
      // Nếu là điểm tối và đã bắt đầu vùng
      else if ((pixel != 0xFFFFFFFF || x == binaryImage.width - 1) &&
          startX != -1) {
        int endX = pixel != 0xFFFFFFFF ? x - 1 : x;
        int width = endX - startX + 1;

        // Ước tính chiều cao bằng cách quét xuống
        int height = 0;
        for (int testY = y; testY < binaryImage.height; testY++) {
          if (binaryImage.getPixel((startX + endX) ~/ 2, testY) == 0xFFFFFFFF) {
            height++;
          } else if (height > 0) {
            break;
          }
        }

        // Thêm vào danh sách nếu đủ lớn
        if (width * height > minSize) {
          results.add(Rectangle(startX, y, width, height));
        }

        startX = -1;
      }
    }
  }

  return results;
}
