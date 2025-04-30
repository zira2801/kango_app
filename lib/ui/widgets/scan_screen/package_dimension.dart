import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart'
    as mlkit;
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

// Lớp chính để đo kích thước kiện hàng
class PackageDimensionMeasurement {
  // Kích thước của vật tham chiếu tính bằng cm
  // Thẻ tín dụng tiêu chuẩn: 8.56 cm x 5.398 cm
  static const double REFERENCE_WIDTH = 8.56;
  static const double REFERENCE_HEIGHT = 5.398;

  // Khởi động quá trình đo kích thước
  static Future<void> startMeasurement(BuildContext context,
      Function(Map<String, double>) onMeasurementComplete) async {
    // Hiển thị hướng dẫn
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Hướng dẫn đo kích thước'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('1. Đặt kiện hàng trên mặt phẳng'),
            Text('2. Đặt thẻ ngân hàng hoặc vật tham chiếu cạnh kiện hàng'),
            Text(
                '3. Chụp ảnh từ phía trên, đảm bảo nhìn thấy toàn bộ kiện hàng'),
            Text('4. Đảm bảo ánh sáng tốt và không có bóng đổ'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hiểu rồi'),
          ),
        ],
      ),
    );

    // Khởi tạo camera và hiển thị màn hình chụp
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeasurementCameraScreen(
          camera: camera,
          onMeasurementComplete: onMeasurementComplete,
        ),
      ),
    );
  }
}

class MeasurementCameraScreen extends StatefulWidget {
  final CameraDescription camera;
  final Function(Map<String, double>) onMeasurementComplete;

  const MeasurementCameraScreen({
    Key? key,
    required this.camera,
    required this.onMeasurementComplete,
  }) : super(key: key);

  @override
  _MeasurementCameraScreenState createState() =>
      _MeasurementCameraScreenState();
}

class _MeasurementCameraScreenState extends State<MeasurementCameraScreen> {
  late CameraController _cameraController;
  bool _isInitialized = false;
  bool _isProcessing = false;

  // Thêm các biến mới để lưu trữ kết quả phát hiện đối tượng
  List<DetectedObject> _detectedObjects = [];
  Map<int, Map<String, double>> _objectDimensions = {};
  double _pixelsPerCM = 1.0;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cameraController.initialize();

      // Tối ưu cài đặt camera
      await _cameraController.setFlashMode(FlashMode.auto);
      await _cameraController.setFocusMode(FocusMode.auto);
      await _cameraController.setExposureMode(ExposureMode.auto);

      // Bắt đầu phát hiện đối tượng theo thời gian thực
      _startRealTimeDetection();

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Lỗi khởi tạo camera: $e');
    }
  }

  // Thêm phương thức mới để phát hiện đối tượng trong thời gian thực
  void _startRealTimeDetection() {
    if (_isDetecting) return;

    _isDetecting = true;

    Future.delayed(Duration(milliseconds: 500), () async {
      if (!mounted) return;

      try {
        // Chụp ảnh tạm thời
        final XFile imageFile = await _cameraController.takePicture();

        // Đọc ảnh để phát hiện box dựa trên màu sắc
        final File file = File(imageFile.path);
        final img.Image? originalImage =
            img.decodeImage(await file.readAsBytes());

        if (originalImage != null) {
          final boxRect = _detectBoxByColor(originalImage);

          if (boxRect != null) {
            // Tạo đối tượng đã phát hiện
            final detectedBox = DetectedObject(
              boundingBox: boxRect,
              labels: [
                Label(
                  text: "Package",
                  index: 0,
                  confidence: 0.95,
                ),
              ],
            );

            // Cập nhật UI
            setState(() {
              _detectedObjects = [detectedBox];

              // Tính toán kích thước
              final double pixelsPerCM = originalImage.width / 30.0;
              _pixelsPerCM = pixelsPerCM;

              _objectDimensions.clear();
              _objectDimensions[0] = {
                'width': double.parse(
                    (boxRect.width / pixelsPerCM).toStringAsFixed(1)),
                'length': double.parse(
                    (boxRect.height / pixelsPerCM).toStringAsFixed(1)),
                'height': double.parse(
                    (min(boxRect.width, boxRect.height) * 0.5 / pixelsPerCM)
                        .toStringAsFixed(1)),
              };
            });
          } else {
            // Nếu không nhận diện được bằng màu, thử phát hiện bằng phương pháp thông thường
            final objects = await _detectObjects(imageFile.path);
            setState(() {
              _detectedObjects = objects;
              _calculateDimensionsForObjects();
            });
          }
        }
      } catch (e) {
        print('Lỗi phát hiện thời gian thực: $e');
      }

      _isDetecting = false;

      // Tiếp tục vòng lặp phát hiện nếu màn hình vẫn hiển thị
      if (mounted) {
        _startRealTimeDetection();
      }
    });
  }

  // Phát hiện đối tượng trong ảnh
  Future<List<DetectedObject>> _detectObjects(String imagePath) async {
    try {
      // Sử dụng ML Kit để phát hiện đối tượng
      final inputImage = InputImage.fromFilePath(imagePath);
      final options = mlkit.ObjectDetectorOptions(
        mode: mlkit.DetectionMode.single,
        classifyObjects: true,
        multipleObjects: true,
      );
      final objectDetector = mlkit.ObjectDetector(options: options);

      final List<mlkit.DetectedObject> objects =
          await objectDetector.processImage(inputImage);

      // Giải phóng tài nguyên
      objectDetector.close();

      return Future.value(objects.map((mlkit.DetectedObject obj) {
        return DetectedObject(
          boundingBox: obj.boundingBox,
          labels: obj.labels.map((mlkit.Label label) {
            return Label(
              text: label.text,
              index: label.index,
              confidence: label.confidence,
            );
          }).toList(),
        );
      }).toList());
    } catch (e) {
      print('Lỗi phát hiện đối tượng: $e');
      return [];
    }
  }

  // Tính toán kích thước cho các đối tượng phát hiện được
  void _calculateDimensionsForObjects() {
    if (_detectedObjects.isEmpty) return;

    // Reset kích thước
    _objectDimensions.clear();

    // Nếu chỉ có một đối tượng (box), ước tính kích thước
    if (_detectedObjects.length == 1) {
      final box = _detectedObjects[0].boundingBox;

      // Ước tính với tỷ lệ mặc định (có thể điều chỉnh)
      final estimatedPixelsPerCM =
          box.width / 30.0; // Giả sử box ~30cm chiều rộng

      final width = box.width / estimatedPixelsPerCM;
      final length = box.height / estimatedPixelsPerCM;
      final height = min(width, length) * 0.5;

      _objectDimensions[0] = {
        'width': double.parse(width.toStringAsFixed(1)),
        'length': double.parse(length.toStringAsFixed(1)),
        'height': double.parse(height.toStringAsFixed(1)),
      };
      return;
    }

    // Nếu có cả box và vật tham chiếu
    if (_detectedObjects.length >= 2) {
      final boxObject = _detectedObjects[0];
      final referenceObject = _detectedObjects[1];

      final boxBox = boxObject.boundingBox;
      final refBox = referenceObject.boundingBox;

      // Tính tỷ lệ pixel/cm từ vật tham chiếu
      final widthRatio =
          refBox.width / PackageDimensionMeasurement.REFERENCE_WIDTH;
      final heightRatio =
          refBox.height / PackageDimensionMeasurement.REFERENCE_HEIGHT;

      // Lấy giá trị trung bình
      _pixelsPerCM = (widthRatio + heightRatio) / 2;

      // Tính kích thước thực tế
      final width = boxBox.width / _pixelsPerCM;
      final length = boxBox.height / _pixelsPerCM;
      final height = min(width, length) * 0.5;

      _objectDimensions[0] = {
        'width': double.parse(width.toStringAsFixed(1)),
        'length': double.parse(length.toStringAsFixed(1)),
        'height': double.parse(height.toStringAsFixed(1)),
      };
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Hiển thị overlay loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Đang xử lý...'),
                ],
              ),
            ),
          );
        },
      );

      // Chụp ảnh
      final XFile imageFile = await _cameraController.takePicture();

      // Xử lý ảnh và tính toán kích thước
      final dimensions = await _processDimensionMeasurement(imageFile.path);

      // Đóng dialog loading
      Navigator.pop(context);

      // Trả về kết quả
      Navigator.pop(context);
      widget.onMeasurementComplete(dimensions);
    } catch (e) {
      // Đóng dialog loading nếu có lỗi
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );

      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<Map<String, double>> _processDimensionMeasurement(
      String imagePath) async {
    try {
      // 1. Tiền xử lý ảnh
      final processedImagePath = await _preprocessImage(imagePath);

      // 2. Phát hiện và đo vật thể
      final dimensions = await _detectObjectsAndMeasure(processedImagePath);

      return dimensions;
    } catch (e) {
      print('Lỗi xử lý ảnh: $e');
      throw e;
    }
  }

  Future<String> _preprocessImage(String imagePath) async {
    try {
      // Đọc file ảnh
      final File file = File(imagePath);
      final img.Image? originalImage =
          img.decodeImage(await file.readAsBytes());

      if (originalImage == null) {
        throw Exception('Không thể đọc ảnh');
      }

      // Xử lý ảnh để tăng độ tương phản
      img.Image processedImage = img.adjustColor(
        originalImage,
        contrast: 1.2,
        brightness: 0.05,
      );

      // Lưu ảnh đã xử lý
      final Directory tempDir = await getTemporaryDirectory();
      final String processedPath = '${tempDir.path}/processed_image.jpg';
      final File processedFile = File(processedPath);
      await processedFile
          .writeAsBytes(img.encodeJpg(processedImage, quality: 90));

      return processedPath;
    } catch (e) {
      print('Lỗi tiền xử lý ảnh: $e');
      return imagePath; // Trả về ảnh gốc nếu có lỗi
    }
  }

  Future<Map<String, double>> _detectObjectsAndMeasure(String imagePath) async {
    try {
      // Đọc ảnh
      final File file = File(imagePath);
      final img.Image? originalImage =
          img.decodeImage(await file.readAsBytes());
      if (originalImage == null) throw Exception('Không thể đọc ảnh');

      // Tách các đối tượng dựa trên màu sắc - đặc biệt là màu vàng/cam của box
      final boxRect = _detectBoxByColor(originalImage);

      if (boxRect != null) {
        // Tính toán kích thước với tỷ lệ mặc định
        final double pixelsPerCM = originalImage.width / 30.0; // Ước lượng

        return {
          'width':
              double.parse((boxRect.width / pixelsPerCM).toStringAsFixed(1)),
          'length':
              double.parse((boxRect.height / pixelsPerCM).toStringAsFixed(1)),
          'height': double.parse(
              (min(boxRect.width, boxRect.height) * 0.5 / pixelsPerCM)
                  .toStringAsFixed(1)),
        };
      }

      // Fallback sang phương pháp cũ nếu không nhận diện được bằng màu sắc
      throw Exception('Không thể phát hiện box bằng màu sắc');
    } catch (e) {
      print('Lỗi khi phát hiện đối tượng: $e');
      // Fallback sang phương pháp cũ
      return await _fallbackImageSegmentation(imagePath);
    }
  }

//   }
// int _minR = 180;
// int _minG = 100;
// int _maxB = 80;
// void _showColorAdjustmentDialog() {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Điều chỉnh tham số màu'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Điều chỉnh các tham số để phát hiện chính xác hộp'),
//             SizedBox(height: 10),
//             Text('Kênh Đỏ (R) tối thiểu: $_minR'),
//             Slider(
//               value: _minR.toDouble(),
//               min: 0,
//               max: 255,
//               divisions: 255,
//               onChanged: (value) {
//                 setState(() {
//                   _minR = value.toInt();
//                 });
//               },
//             ),
//             Text('Kênh Xanh lá (G) tối thiểu: $_minG'),
//             Slider(
//               value: _minG.toDouble(),
//               min: 0,
//               max: 255,
//               divisions: 255,
//               onChanged: (value) {
//                 setState(() {
//                   _minG = value.toInt();
//                 });
//               },
//             ),
//             Text('Kênh Xanh dương (B) tối đa: $_maxB'),
//             Slider(
//               value: _maxB.toDouble(),
//               min: 0,
//               max: 255,
//               divisions: 255,
//               onChanged: (value) {
//                 setState(() {
//                   _maxB = value.toInt();
//                 });
//               },
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Đóng'),
//           ),
//         ],
//       );
//     },
//   );
// }
  Rect? _detectBoxByColor(img.Image image) {
    // Điều chỉnh ngưỡng màu cho phù hợp với box của bạn
    // Nếu box màu vàng/cam/nâu cần tăng R, giảm B
    // Nếu box màu trắng/xám cần tăng tất cả các kênh
    const int _minR = 160; // Giảm xuống để bắt được nhiều màu hơn
    const int _minG = 80; // Giảm xuống để bắt được nhiều màu hơn
    const int _maxB = 120; // Tăng lên để bắt được các màu có chút xanh

    // Tỷ lệ màu có thể giúp phân biệt tốt hơn
    const double _minRGRatio = 1.2; // R phải lớn hơn G một lượng nhất định

    int minX = image.width;
    int minY = image.height;
    int maxX = 0;
    int maxY = 0;
    bool foundPixels = false;

    // Thêm bộ đếm để lọc nhiễu
    int matchedPixelCount = 0;
    final int minRequiredPixels =
        500; // Số pixel tối thiểu để coi là box hợp lệ

    // Tìm các pixel có màu phù hợp
    for (int y = 0; y < image.height; y += 2) {
      // Bước nhảy 2 để tăng tốc độ
      for (int x = 0; x < image.width; x += 2) {
        // Bước nhảy 2 để tăng tốc độ
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        // Kiểm tra màu dựa trên ngưỡng và tỷ lệ
        if (r > _minR && g > _minG && b < _maxB && r / g > _minRGRatio) {
          minX = min(minX, x);
          minY = min(minY, y);
          maxX = max(maxX, x);
          maxY = max(maxY, y);
          foundPixels = true;
          matchedPixelCount++;
        }
      }
    }

    if (foundPixels && matchedPixelCount > minRequiredPixels) {
      // Mở rộng box một chút để đảm bảo bắt đủ toàn bộ hộp
      final int padding = 15; // Tăng padding
      minX = max(0, minX - padding);
      minY = max(0, minY - padding);
      maxX = min(image.width - 1, maxX + padding);
      maxY = min(image.height - 1, maxY + padding);

      // Kiểm tra kích thước tối thiểu và tỷ lệ
      final int width = maxX - minX;
      final int height = maxY - minY;

      if (width < 50 || height < 50) {
        return null; // Box quá nhỏ, có thể là nhiễu
      }

      // Kiểm tra tỷ lệ width/height để phân biệt box với đồ vật khác
      final double ratio = width / height;
      if (ratio < 0.3 || ratio > 3.0) {
        return null; // Không phải hình dạng của box thông thường
      }

      return Rect.fromLTRB(
          minX.toDouble(), minY.toDouble(), maxX.toDouble(), maxY.toDouble());
    }

    return null;
  }

  // Convert image to input tensor format
  List<List<List<double>>> _imageToByteList(img.Image image) {
    var convertedBytes = List<List<List<double>>>.generate(
      1,
      (i) => List<List<double>>.generate(
        640,
        (y) => List<double>.generate(
          640 * 3, // 640 pixels with 3 channels (RGB)
          (index) {
            int x = index ~/ 3; // Calculate x coordinate
            int channel = index % 3; // 0 for R, 1 for G, 2 for B
            var pixel = image.getPixel(x, y);
            if (channel == 0) return pixel.r / 255.0; // Red
            if (channel == 1) return pixel.g / 255.0; // Green
            return pixel.b / 255.0; // Blue
          },
        ),
      ),
    );
    return convertedBytes;
  }

  // Process YOLOv5 output to get bounding boxes
  List<Map<String, dynamic>> _processYoloOutput(
      List<List<List<double>>> output, int imageWidth, int imageHeight) {
    final List<Map<String, dynamic>> detections = [];

    // YOLOv5 output format processing
    for (var i = 0; i < output[0].length; i++) {
      final confidence = output[0][i][4];

      // Filter by confidence threshold
      if (confidence > 0.5) {
        final x = output[0][i][0] * imageWidth;
        final y = output[0][i][1] * imageHeight;
        final w = output[0][i][2] * imageWidth;
        final h = output[0][i][3] * imageHeight;
        final classId = output[0][i].sublist(5).indexOf(output[0][i]
            .sublist(5)
            .reduce((curr, next) => curr > next ? curr : next));

        detections.add({
          'x': x,
          'y': y,
          'width': w,
          'height': h,
          'class': classId,
          'confidence': confidence,
        });
      }
    }

    return detections;
  }

  Future<Map<String, double>> _fallbackImageSegmentation(
      String imagePath) async {
    try {
      // Đọc ảnh
      final File file = File(imagePath);
      final img.Image? originalImage =
          img.decodeImage(await file.readAsBytes());

      if (originalImage == null) {
        throw Exception('Không thể đọc ảnh');
      }

      // Chuyển đổi sang ảnh xám
      final img.Image grayscale = img.grayscale(originalImage);

      // Áp dụng ngưỡng để tách biệt vật thể và nền
      final img.Image binaryImage = img.billboard(
        grayscale,
      );

      // Tìm các vùng kết nối (connected component labeling)
      final regions = _findConnectedComponents(binaryImage);

      // Sắp xếp các vùng theo kích thước
      regions.sort((a, b) => b.area.compareTo(a.area));

      // Vùng lớn nhất là kiện hàng, lớn thứ hai có thể là vật tham chiếu
      if (regions.length < 2) {
        // Nếu không tìm thấy đủ vùng, trả về kích thước ước lượng
        return {
          'width': 0.0,
          'length': 0.0,
          'height': 0.0,
        };
      }

      final packageRegion = regions[0];
      final referenceRegion = regions[1];

      // Tính tỷ lệ pixel/cm từ vật tham chiếu
      final double pixelsPerCM =
          _calculatePixelsPerCMFromRegion(referenceRegion);

      // Tính kích thước thực tế của kiện hàng
      return _calculateDimensionsFromRegion(packageRegion, pixelsPerCM);
    } catch (e) {
      print('Lỗi khi phân đoạn ảnh: $e');
      // Trả về kích thước ước lượng
      return {
        'width': 0.0,
        'length': 0.0,
        'height': 0.0,
      };
    }
  }

  List<ImageRegion> _findConnectedComponents(img.Image binaryImage) {
    final int width = binaryImage.width;
    final int height = binaryImage.height;

    // Mảng đánh dấu nhãn
    List<List<int>> labels =
        List.generate(height, (_) => List.filled(width, 0));

    int currentLabel = 0;
    Map<int, ImageRegion> regions = {};

    // First pass: gán nhãn sơ bộ
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // Kiểm tra pixel trắng (đối tượng)
        if (binaryImage.getPixel(x, y) == 0xFFFFFFFF) {
          // Kiểm tra các pixel lân cận đã có nhãn
          int leftLabel = (x > 0) ? labels[y][x - 1] : 0;
          int topLabel = (y > 0) ? labels[y - 1][x] : 0;

          if (leftLabel == 0 && topLabel == 0) {
            // Tạo nhãn mới
            currentLabel++;
            labels[y][x] = currentLabel;

            // Tạo vùng mới
            regions[currentLabel] = ImageRegion(
              id: currentLabel,
              minX: x,
              minY: y,
              maxX: x,
              maxY: y,
              area: 1,
            );
          } else {
            // Sử dụng nhãn đã có
            int useLabel = max(leftLabel, topLabel);
            labels[y][x] = useLabel;

            // Cập nhật thông tin vùng
            if (regions.containsKey(useLabel)) {
              final region = regions[useLabel]!;
              region.minX = min(region.minX, x);
              region.minY = min(region.minY, y);
              region.maxX = max(region.maxX, x);
              region.maxY = max(region.maxY, y);
              region.area++;
            }
          }
        }
      }
    }

    // Lọc bỏ các vùng quá nhỏ (nhiễu)
    final filteredRegions = regions.values.where((region) {
      return region.area >
          (width * height * 0.01); // Bỏ qua vùng nhỏ hơn 1% ảnh
    }).toList();

    return filteredRegions;
  }

  double _calculatePixelsPerCM(Rect referenceBox) {
    // Tính tỷ lệ pixel/cm dựa trên kích thước đã biết của vật tham chiếu
    final double widthInPixels = referenceBox.width;
    final double heightInPixels = referenceBox.height;

    // Tính tỷ lệ theo chiều rộng và chiều dài
    final double widthRatio =
        widthInPixels / PackageDimensionMeasurement.REFERENCE_WIDTH;
    final double heightRatio =
        heightInPixels / PackageDimensionMeasurement.REFERENCE_HEIGHT;

    // Lấy giá trị trung bình
    return (widthRatio + heightRatio) / 2;
  }

  double _calculatePixelsPerCMFromRegion(ImageRegion region) {
    // Tính tỷ lệ pixel/cm từ vùng của vật tham chiếu
    final double widthInPixels = (region.maxX - region.minX).toDouble();
    final double heightInPixels = (region.maxY - region.minY).toDouble();

    // Tính tỷ lệ theo chiều rộng và chiều dài
    final double widthRatio =
        widthInPixels / PackageDimensionMeasurement.REFERENCE_WIDTH;
    final double heightRatio =
        heightInPixels / PackageDimensionMeasurement.REFERENCE_HEIGHT;

    // Lấy giá trị trung bình
    return (widthRatio + heightRatio) / 2;
  }

  Map<String, double> _calculateDimensions(
      Rect packageBox, double pixelsPerCM) {
    // Tính toán kích thước thực tế từ kích thước pixel và tỷ lệ
    final double width = packageBox.width / pixelsPerCM;
    final double length = packageBox.height / pixelsPerCM;

    // Ước lượng chiều cao
    final double height = min(width, length) * 0.5;

    return {
      'width': double.parse(width.toStringAsFixed(1)),
      'length': double.parse(length.toStringAsFixed(1)),
      'height': double.parse(height.toStringAsFixed(1)),
    };
  }

  Map<String, double> _calculateDimensionsFromRegion(
      ImageRegion packageRegion, double pixelsPerCM) {
    // Tính toán kích thước thực tế từ vùng và tỷ lệ
    final double width =
        (packageRegion.maxX - packageRegion.minX) / pixelsPerCM;
    final double length =
        (packageRegion.maxY - packageRegion.minY) / pixelsPerCM;

    // Ước lượng chiều cao
    final double height = min(width, length) * 0.5;

    return {
      'width': double.parse(width.toStringAsFixed(1)),
      'length': double.parse(length.toStringAsFixed(1)),
      'height': double.parse(height.toStringAsFixed(1)),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          Center(
            child: CameraPreview(_cameraController),
          ),

          // Overlay hiển thị các đối tượng được phát hiện
          if (_detectedObjects.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: ObjectDetectionPainter(
                  detectedObjects: _detectedObjects,
                  objectDimensions: _objectDimensions,
                ),
              ),
            ),

          // Overlay hướng dẫn
          if (_detectedObjects.isEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: MeasurementGuidePainter(),
              ),
            ),

          // Nút chụp ảnh
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: IconButton(
                    onPressed: _isProcessing ? null : _takePicture,
                    icon: Icon(Icons.camera, color: Colors.white, size: 40),
                  ),
                ),
              ],
            ),
          ),

          // Nút hủy
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),

          // Hướng dẫn
          const Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Đặt vật tham chiếu (thẻ ngân hàng) bên cạnh kiện hàng',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Lớp vẽ các đối tượng được phát hiện và hiển thị kích thước
class ObjectDetectionPainter extends CustomPainter {
  final List<DetectedObject> detectedObjects;
  final Map<int, Map<String, double>> objectDimensions;

  ObjectDetectionPainter({
    required this.detectedObjects,
    required this.objectDimensions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ box chính (đối tượng lớn nhất)
    if (detectedObjects.isNotEmpty) {
      final DetectedObject mainObject = detectedObjects[0];
      final Rect boundingBox = mainObject.boundingBox;

      final Paint boxPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      // Vẽ hộp chứa đối tượng chính
      canvas.drawRect(boundingBox, boxPaint);

      // Vẽ kích thước nếu có
      if (objectDimensions.containsKey(0)) {
        final dimensions = objectDimensions[0]!;

        // Chuẩn bị văn bản
        final String dimensionText =
            'W: ${dimensions['width']}cm\nL: ${dimensions['length']}cm\nH: ${dimensions['height']}cm';

        final TextSpan span = TextSpan(
          text: dimensionText,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        );

        final TextPainter textPainter = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();

        // Vẽ nền cho văn bản
        final Paint textBackground = Paint()
          ..color = Colors.black.withOpacity(0.7)
          ..style = PaintingStyle.fill;

        canvas.drawRect(
          Rect.fromLTWH(
            boundingBox.left,
            boundingBox.top - textPainter.height - 5,
            textPainter.width + 10,
            textPainter.height + 5,
          ),
          textBackground,
        );

        // Vẽ văn bản
        textPainter.paint(
          canvas,
          Offset(
              boundingBox.left + 5, boundingBox.top - textPainter.height - 2),
        );
      }

      // Vẽ vật tham chiếu nếu có
      if (detectedObjects.length > 1) {
        final DetectedObject refObject = detectedObjects[1];
        final Paint refPaint = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

        canvas.drawRect(refObject.boundingBox, refPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Vẽ overlay hướng dẫn
class MeasurementGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Vẽ khung hướng dẫn
    final double padding = 40;
    final Rect guideRect = Rect.fromLTWH(
      padding,
      size.height / 2 - (size.width - padding * 2) / 2,
      size.width - padding * 2,
      size.width - padding * 2,
    );

    canvas.drawRect(guideRect, paint);

    // Vẽ đường chéo để định vị
    canvas.drawLine(
      Offset(guideRect.left, guideRect.top),
      Offset(guideRect.right, guideRect.bottom),
      paint,
    );

    canvas.drawLine(
      Offset(guideRect.right, guideRect.top),
      Offset(guideRect.left, guideRect.bottom),
      paint,
    );

    // Vẽ hình vật tham chiếu
    final Rect referenceRect = Rect.fromLTWH(
      guideRect.left + 20,
      guideRect.bottom - 80,
      8.56 * 0.8,
      5.398 * 0.8,
    );

    final Paint referencePaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawRect(referenceRect, referencePaint);

    // Vẽ chữ "Thẻ tham chiếu"
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: "Thẻ tham chiếu",
        style: TextStyle(color: Colors.white, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        referenceRect.left + (referenceRect.width - textPainter.width) / 2,
        referenceRect.top + (referenceRect.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Hàm áp dụng ngưỡng để chuyển ảnh xám thành ảnh nhị phân
img.Image _applyThreshold(img.Image grayscale, int thresholdValue) {
  final img.Image binaryImage = img.Image.from(grayscale);
  for (int y = 0; y < binaryImage.height; y++) {
    for (int x = 0; x < binaryImage.width; x++) {
      final pixel = binaryImage.getPixel(x, y);
      final luminance = img.getLuminance(pixel);
      binaryImage.setPixel(
          x,
          y,
          luminance > thresholdValue
              ? img.ColorRgb8(255, 255, 255)
              : img.ColorRgb8(0, 0, 0));
    }
  }
  return binaryImage;
}

// Lớp lưu trữ thông tin về vùng ảnh
class ImageRegion {
  int id;
  int minX;
  int minY;
  int maxX;
  int maxY;
  int area;

  ImageRegion({
    required this.id,
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
    required this.area,
  });
}

// Lớp mô phỏng đối tượng phát hiện được từ ML Kit
class DetectedObject {
  final Rect boundingBox;
  final List<Label> labels;

  DetectedObject({
    required this.boundingBox,
    required this.labels,
  });
}

class Label {
  final String text;
  final int index;
  final double confidence;

  Label({
    required this.text,
    required this.index,
    required this.confidence,
  });
}
