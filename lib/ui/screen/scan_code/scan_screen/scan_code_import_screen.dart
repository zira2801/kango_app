import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_ml_kit/google_ml_kit.dart' as mlkit;
import 'package:image/image.dart' as img;
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scan_barcode_app/bloc/scan/scan_code/scan_code_import/scan_code_import_bloc.dart';
import 'package:scan_barcode_app/copytessdata.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/models/scan_code/details_package.dart';
import 'package:scan_barcode_app/data/models/scan_code/list_all_surchage_goods.dart';
import 'package:scan_barcode_app/data/models/scan_code/surchage_goods_choosed.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/scan_screen/package_dimension.dart';
import 'package:scan_barcode_app/ui/widgets/scan_screen/result_scan_widget.dart';
import 'package:scan_barcode_app/ui/widgets/scan_screen/scan_error_widget.dart';
import 'package:scan_barcode_app/ui/widgets/scan_screen/scan_overlay.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'dart:math' as math;
import 'package:async/async.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

class ScanCodeImportScreenWithController extends StatefulWidget {
  final String titleScrenn;

  const ScanCodeImportScreenWithController(
      {super.key, required this.titleScrenn});

  @override
  // ignore: library_private_types_in_public_api
  _ScanCodeImportScreenWithControllerState createState() =>
      _ScanCodeImportScreenWithControllerState();
}

class _ScanCodeImportScreenWithControllerState
    extends State<ScanCodeImportScreenWithController>
    with WidgetsBindingObserver {
  BarcodeCapture? barcode;

  late final MobileScannerController controller;
  final codeTextController = TextEditingController();
  final lengthPackageController = TextEditingController();
  final widthPackageController = TextEditingController();
  final heightPackageController = TextEditingController();
  final weightPackageController = TextEditingController();
  final namePackageController = TextEditingController();
  final quantityPackageController = TextEditingController();
  final countScanController = TextEditingController();
  final codeBillController = TextEditingController();
  bool isTorchOn = false;
  String currentCode = '';
  String latestScannedCode = '';
  CameraFacing cameraFacing = CameraFacing.back;
  bool isBottomSheetOpen = false;
  Widget? currentBottomSheet;
  DetailsPackageScanCodeModel? detailsPackageScanCodeModel;
  ListAllSurchageGoodsModel? listAllSurchageGoodsModel;
  List<SurchageGoodsChoosed> listSurchageGoodsChoosed = [];
// Initialize currentListPakage as a list of Item objects
  List<Item> currentListPakage = [];

// Keep track of selected items
  Set<String> selectedItems = {};
  bool isReadyGetDetailsPackage = false;
  bool isReadyGetListSurchageGoods = false;
  bool isGetDetailsPackageSuccess = false;
  bool isScanningWeight = false;
  String selectedUnit = 'kg';
  CameraController? _cameraController;
  mlkit.TextRecognizer _textRecognizer =
      mlkit.GoogleMlKit.vision.textRecognizer();
  bool isConfirmed = false;
  OverlayEntry? overlayEntry;
  late CameraController _dimensionCameraController;
  late List<CameraDescription> _cameras;
  OverlayEntry? _dimensionOverlayEntry;
  Timer? _dimensionTimer;
  bool _isDimensionMeasuring = false;
  CancelableOperation? _processingOperation;
  Timer? _adjustmentTimer;
  bool isProcessing = false;
  Map<String, double> _packageDimensions = {
    'width': 0.0,
    'length': 0.0,
    'height': 0.0
  };
  // Thêm biến theo dõi timer đếm ngược
  // Map<String, int> detectedWeights = {};
  // int minDetectionCount = 3; // Số lần nhận diện giống nhau để xác nhận
  // bool _isProcessingImage = false;

  tfl.Interpreter? _interpreter;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      torchEnabled: false,
      detectionTimeoutMs: 500,
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
    );
    controller.start();
    _textRecognizer = mlkit.GoogleMlKit.vision.textRecognizer();
    WidgetsBinding.instance.addObserver(this);
  }

// Hàm dọn dẹp tất cả tiến trình
  void _cleanupAllProcesses() {
    // 1. Hủy API đang xử lý
    if (_processingOperation != null) {
      _processingOperation!.cancel();
      _processingOperation = null;
    }

    // 2. Hủy timer đếm ngược
    if (_adjustmentTimer != null) {
      _adjustmentTimer!.cancel();
      _adjustmentTimer = null;
    }

    // 3. Xóa overlay nếu đang hiển thị
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }

    // 4. Đóng dialog loading nếu đang hiển thị
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    // 5. Reset trạng thái xử lý
    if (mounted) {
      setState(() {
        isProcessing = false;
      });
    }
  }

  // Future<void> _loadTFLiteModel() async {
  //   try {
  //     _interpreter =
  //         await tfl.Interpreter.fromAsset('assets/yolo/yolov5s-fp16.tflite');
  //     log('Mô hình YOLOv5 đã được tải thành công');
  //   } catch (e) {
  //     log('Lỗi tải mô hình TFLite: $e');
  //   }
  // }

  // List<List<List<double>>> _imageToByteList(img.Image image) {
  //   // Resize ảnh về kích thước 640x640 (hoặc kích thước mà mô hình yêu cầu)
  //   final resizedImage = img.copyResize(image, width: 640, height: 640);

  //   // Tạo tensor [1, 640, 640, 3]
  //   var convertedBytes = List.generate(
  //     1,
  //     (_) => List.generate(
  //       640,
  //       (y) => List.generate(
  //         640 * 3,
  //         (index) {
  //           int x = index ~/ 3;
  //           int channel = index % 3;
  //           var pixel = resizedImage.getPixel(x, y);
  //           if (channel == 0) return pixel.r / 255.0; // Red
  //           if (channel == 1) return pixel.g / 255.0; // Green
  //           return pixel.b / 255.0; // Blue
  //         },
  //       ),
  //     ),
  //   );
  //   return convertedBytes;
  // }

  // Future<List<Map<String, dynamic>>> _runYoloInference(img.Image image) async {
  //   if (_interpreter == null) {
  //     log('Mô hình YOLOv5 chưa được tải');
  //     return [];
  //   }

  //   // Tiền xử lý ảnh
  //   final inputTensor = _imageToByteList(image);

  //   // Chuẩn bị tensor đầu ra
  //   // YOLOv5s thường có đầu ra dạng [1, num_boxes, 5 + num_classes]
  //   // Giả sử mô hình có 80 lớp (COCO dataset) và xuất ra [x, y, w, h, confidence, class_scores]
  //   var outputTensor = List.generate(
  //       1, (_) => List.generate(25200, (_) => List.filled(5 + 80, 0.0)));

  //   // Chạy inference
  //   _interpreter!.run(inputTensor, outputTensor);

  //   // Xử lý đầu ra
  //   final detections =
  //       _processYoloOutput(outputTensor, image.width, image.height);

  //   return detections;
  // }

  // // Process YOLOv5 output to get bounding boxes
  // List<Map<String, dynamic>> _processYoloOutput(
  //     List<dynamic> output, int imageWidth, int imageHeight) {
  //   final List<Map<String, dynamic>> detections = [];

  //   // Giả sử đầu ra là [1, num_boxes, 5 + num_classes]
  //   final numBoxes = output[0].length;
  //   const numClasses = 80; // Điều chỉnh theo mô hình của bạn

  //   for (var i = 0; i < numBoxes; i++) {
  //     final confidence = output[0][i][4];
  //     if (confidence > 0.5) {
  //       // Ngưỡng confidence
  //       final xCenter = output[0][i][0] * imageWidth;
  //       final yCenter = output[0][i][1] * imageHeight;
  //       final width = output[0][i][2] * imageWidth;
  //       final height = output[0][i][3] * imageHeight;

  //       // Tính tọa độ bounding box
  //       final x = xCenter - width / 2;
  //       final y = yCenter - height / 2;

  //       // Tìm lớp có xác suất cao nhất
  //       final classScores = output[0][i].sublist(5, 5 + numClasses);
  //       final classId = classScores.indexOf(classScores.reduce(math.max));

  //       detections.add({
  //         'x': x,
  //         'y': y,
  //         'width': width,
  //         'height': height,
  //         'class': classId,
  //         'confidence': confidence,
  //       });
  //     }
  //   }

  //   // Áp dụng Non-Maximum Suppression (NMS) để lọc các box trùng lặp
  //   return _applyNMS(detections);
  // }

  // List<Map<String, dynamic>> _applyNMS(List<Map<String, dynamic>> detections) {
  //   // TODO: Thêm logic NMS để loại bỏ các box trùng lặp
  //   // Bạn có thể sử dụng thư viện như `non_max_suppression` hoặc tự viết
  //   return detections; // Tạm thời trả về nguyên bản
  // }

  // Future<Map<String, double>> _detectObjectsAndMeasure(String imagePath) async {
  //   try {
  //     // Đọc ảnh
  //     final File file = File(imagePath);
  //     final img.Image? originalImage =
  //         img.decodeImage(await file.readAsBytes());
  //     if (originalImage == null) throw Exception('Không thể đọc ảnh');

  //     // Chạy YOLOv5 để phát hiện đối tượng
  //     final detections = await _runYoloInference(originalImage);

  //     if (detections.isEmpty) {
  //       throw Exception('Không phát hiện được kiện hàng');
  //     }

  //     // Lấy box lớn nhất (giả sử là kiện hàng)
  //     final packageBox = detections.first;
  //     final rect = Rect.fromLTWH(
  //       packageBox['x'],
  //       packageBox['y'],
  //       packageBox['width'],
  //       packageBox['height'],
  //     );

  //     // Tính tỷ lệ pixels/cm (giả sử sử dụng vật tham chiếu hoặc ước lượng)
  //     final double pixelsPerCM = originalImage.width / 30.0; // Ước lượng

  //     return {
  //       'width': double.parse((rect.width / pixelsPerCM).toStringAsFixed(1)),
  //       'length': double.parse((rect.height / pixelsPerCM).toStringAsFixed(1)),
  //       'height': double.parse(
  //           (math.min(rect.width, rect.height) * 0.5 / pixelsPerCM)
  //               .toStringAsFixed(1)),
  //     };
  //   } catch (e) {
  //     print('Lỗi khi phát hiện đối tượng: $e');
  //     return await _fallbackImageSegmentation(imagePath);
  //   }
  // }

  // Future<Map<String, double>> _fallbackImageSegmentation(
  //     String imagePath) async {
  //   try {
  //     // Đọc ảnh
  //     final File file = File(imagePath);
  //     final img.Image? originalImage =
  //         img.decodeImage(await file.readAsBytes());

  //     if (originalImage == null) {
  //       throw Exception('Không thể đọc ảnh');
  //     }

  //     // Chuyển đổi sang ảnh xám
  //     final img.Image grayscale = img.grayscale(originalImage);

  //     // Áp dụng ngưỡng để tách biệt vật thể và nền
  //     final img.Image binaryImage = img.billboard(
  //       grayscale,
  //     );

  //     // Tìm các vùng kết nối (connected component labeling)
  //     final regions = _findConnectedComponents(binaryImage);

  //     // Sắp xếp các vùng theo kích thước
  //     regions.sort((a, b) => b.area.compareTo(a.area));

  //     // Vùng lớn nhất là kiện hàng, lớn thứ hai có thể là vật tham chiếu
  //     if (regions.length < 2) {
  //       // Nếu không tìm thấy đủ vùng, trả về kích thước ước lượng
  //       return {
  //         'width': 0.0,
  //         'length': 0.0,
  //         'height': 0.0,
  //       };
  //     }

  //     final packageRegion = regions[0];
  //     final referenceRegion = regions[1];

  //     // Tính tỷ lệ pixel/cm từ vật tham chiếu
  //     final double pixelsPerCM =
  //         _calculatePixelsPerCMFromRegion(referenceRegion);

  //     // Tính kích thước thực tế của kiện hàng
  //     return _calculateDimensionsFromRegion(packageRegion, pixelsPerCM);
  //   } catch (e) {
  //     print('Lỗi khi phân đoạn ảnh: $e');
  //     // Trả về kích thước ước lượng
  //     return {
  //       'width': 0.0,
  //       'length': 0.0,
  //       'height': 0.0,
  //     };
  //   }
  // }

  // List<ImageRegion> _findConnectedComponents(img.Image binaryImage) {
  //   final int width = binaryImage.width;
  //   final int height = binaryImage.height;

  //   // Mảng đánh dấu nhãn
  //   List<List<int>> labels =
  //       List.generate(height, (_) => List.filled(width, 0));

  //   int currentLabel = 0;
  //   Map<int, ImageRegion> regions = {};

  //   // First pass: gán nhãn sơ bộ
  //   for (int y = 0; y < height; y++) {
  //     for (int x = 0; x < width; x++) {
  //       // Kiểm tra pixel trắng (đối tượng)
  //       if (binaryImage.getPixel(x, y) == 0xFFFFFFFF) {
  //         // Kiểm tra các pixel lân cận đã có nhãn
  //         int leftLabel = (x > 0) ? labels[y][x - 1] : 0;
  //         int topLabel = (y > 0) ? labels[y - 1][x] : 0;

  //         if (leftLabel == 0 && topLabel == 0) {
  //           // Tạo nhãn mới
  //           currentLabel++;
  //           labels[y][x] = currentLabel;

  //           // Tạo vùng mới
  //           regions[currentLabel] = ImageRegion(
  //             id: currentLabel,
  //             minX: x,
  //             minY: y,
  //             maxX: x,
  //             maxY: y,
  //             area: 1,
  //           );
  //         } else {
  //           // Sử dụng nhãn đã có
  //           int useLabel = math.max(leftLabel, topLabel);
  //           labels[y][x] = useLabel;

  //           // Cập nhật thông tin vùng
  //           if (regions.containsKey(useLabel)) {
  //             final region = regions[useLabel]!;
  //             region.minX = math.min(region.minX, x);
  //             region.minY = math.min(region.minY, y);
  //             region.maxX = math.max(region.maxX, x);
  //             region.maxY = math.max(region.maxY, y);
  //             region.area++;
  //           }
  //         }
  //       }
  //     }
  //   }

  //   // Lọc bỏ các vùng quá nhỏ (nhiễu)
  //   final filteredRegions = regions.values.where((region) {
  //     return region.area >
  //         (width * height * 0.01); // Bỏ qua vùng nhỏ hơn 1% ảnh
  //   }).toList();

  //   return filteredRegions;
  // }

  // double _calculatePixelsPerCMFromRegion(ImageRegion region) {
  //   // Tính tỷ lệ pixel/cm từ vùng của vật tham chiếu
  //   final double widthInPixels = (region.maxX - region.minX).toDouble();
  //   final double heightInPixels = (region.maxY - region.minY).toDouble();

  //   // Tính tỷ lệ theo chiều rộng và chiều dài
  //   final double widthRatio =
  //       widthInPixels / PackageDimensionMeasurement.REFERENCE_WIDTH;
  //   final double heightRatio =
  //       heightInPixels / PackageDimensionMeasurement.REFERENCE_HEIGHT;

  //   // Lấy giá trị trung bình
  //   return (widthRatio + heightRatio) / 2;
  // }

  // Map<String, double> _calculateDimensionsFromRegion(
  //     ImageRegion packageRegion, double pixelsPerCM) {
  //   // Tính toán kích thước thực tế từ vùng và tỷ lệ
  //   final double width =
  //       (packageRegion.maxX - packageRegion.minX) / pixelsPerCM;
  //   final double length =
  //       (packageRegion.maxY - packageRegion.minY) / pixelsPerCM;

  //   // Ước lượng chiều cao
  //   final double height = math.min(width, length) * 0.5;

  //   return {
  //     'width': double.parse(width.toStringAsFixed(1)),
  //     'length': double.parse(length.toStringAsFixed(1)),
  //     'height': double.parse(height.toStringAsFixed(1)),
  //   };
  // }

  // Future<Map<String, double>?> _measurePackageDimensions(
  //     CameraController cameraController) async {
  //   try {
  //     final XFile imageFile = await cameraController.takePicture();
  //     return await _detectObjectsAndMeasure(imageFile.path);
  //   } catch (e) {
  //     print('Lỗi đo kích thước: $e');
  //     return null;
  //   }
  // }

  // Tích hợp vào luồng quét mã QR hiện tại
  void onBarcodeDetected(String code) async {
    // Nếu code rỗng, đã được quét trước đó, hoặc đang xử lý, không làm gì cả
    if (code.isEmpty || code == currentCode || isProcessing) {
      debugPrint('QR Scan: Bỏ qua - code rỗng, đã quét hoặc đang xử lý');
      return;
    }

    debugPrint('QR Scan: Phát hiện mã QR - $code');
    setState(() {
      currentCode = code;
      codeTextController.text = code;
      isProcessing = true;
    });

    vibrateScan();

    // Hiển thị dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 20.h),
                  TextApp(
                    text: "Đang xử lý...",
                    fontsize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    bool isOperationCancelled = false;

    // Tạo CancelableOperation
    _processingOperation = CancelableOperation.fromFuture(
      Future.wait([
        Future(() => onGetDetailsPackage(mawbCode: codeTextController.text)),
        Future(() => onGetListSurchageGoods()),
      ]),
      onCancel: () {
        debugPrint('QR Scan: API processing bị hủy');
        isOperationCancelled = true;
      },
    );

    // Xử lý kết quả
    _processingOperation?.value.then((_) {
      // Nếu widget không còn tồn tại hoặc operation đã bị hủy, không làm gì cả
      if (!mounted || isOperationCancelled) {
        debugPrint('QR Scan: Widget không còn tồn tại hoặc bị hủy');
        return;
      }

      // Đóng dialog loading
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        debugPrint('QR Scan: Đóng dialog loading');
      }

      if (isGetDetailsPackageSuccess == true) {
        debugPrint('QR Scan: API thành công, bắt đầu đo kích thước');

        // THAY ĐỔI Ở ĐÂY: Hiển thị overlay để đo kích thước trước
        showDimensionAdjustmentOverlay();
      } else {
        debugPrint('QR Scan: API thất bại, reset trạng thái');
        setState(() {
          isProcessing = false;
          isBottomSheetOpen = false;
          currentCode = '';
        });
      }
    }).catchError((error) {
      // Kiểm tra widget còn tồn tại không và operation chưa bị hủy
      if (!mounted || isOperationCancelled) {
        debugPrint('QR Scan: Widget không còn tồn tại hoặc bị hủy');
        return;
      }

      setState(() {
        isProcessing = false;
      });

      // Đóng dialog
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        debugPrint('QR Scan: Đóng dialog lỗi');
      }

      debugPrint('QR Scan: Lỗi API - $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã xảy ra lỗi: ${error.toString()}")),
      );
    });
  }

  void showDimensionAdjustmentOverlay() {
    debugPrint(
        'Dimension Overlay: Hiển thị overlay điều chỉnh camera cho đo kích thước');

    _dimensionOverlayEntry?.remove();
    _dimensionOverlayEntry = null;

    final bottomPosition = 50.h;
    final horizontalInset = 20.w;

    _dimensionOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: bottomPosition,
        left: horizontalInset,
        right: horizontalInset,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.green.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextApp(
                        text: "Điều chỉnh camera",
                        fontsize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      SizedBox(height: 4.h),
                      TextApp(
                        text:
                            "Vui lòng căn chỉnh camera để đo kích thước kiện hàng",
                        fontsize: 14.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ],
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 5.0, end: 0.0),
                  duration: const Duration(seconds: 5),
                  builder: (context, value, child) {
                    return Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: TextApp(
                          text: value.ceil().toString(),
                          fontsize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_dimensionOverlayEntry!);
    debugPrint('Dimension Overlay: Đã thêm overlay vào giao diện');
    _dimensionTimer?.cancel();
    _dimensionTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) {
        debugPrint('Dimension Overlay: Widget không còn tồn tại, bỏ qua');
        return;
      }

      _dimensionOverlayEntry?.remove();
      _dimensionOverlayEntry = null;
      debugPrint('Dimension Overlay: Đã xóa overlay');

      debugPrint('Dimension Overlay: Bắt đầu đo kích thước');
      _startDimensionMeasurement();
    });
  }

  Future<void> _initializeDimensionCamera() async {
    // Khởi tạo camera
    _cameras = await availableCameras();
    final firstCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );

    _dimensionCameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _dimensionCameraController.initialize();
      debugPrint('Dimension Camera: Đã khởi tạo camera thành công');
    } catch (e) {
      debugPrint('Dimension Camera: Lỗi khởi tạo camera - $e');
    }
  }

  Future<void> _startDimensionMeasurement() async {
    debugPrint('Dimension Measurement: Bắt đầu đo kích thước');
    setState(() {
      _isDimensionMeasuring = true;
    });

    controller.stop(); // Dừng camera quét mã QR
    // Khởi tạo camera cho đo kích thước
    await _initializeDimensionCamera();
    try {
      // Hiển thị dialog loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 20.h),
                  TextApp(
                    text: "Đang đo kích thước...",
                    fontsize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
          );
        },
      );

      // Chụp ảnh
      final XFile picture = await _dimensionCameraController.takePicture();
      debugPrint('Dimension Measurement: Đã chụp ảnh - ${picture.path}');

      // Xử lý ảnh để đo kích thước
      final dimensions = await _processDimensionMeasurement(picture.path);

      // Cập nhật kích thước đã đo
      setState(() {
        _packageDimensions = dimensions;
        // Gán giá trị vào các TextEditingController
        widthPackageController.text =
            dimensions['width']!.toStringAsFixed(1); // D (Chiều rộng)
        lengthPackageController.text =
            dimensions['length']!.toStringAsFixed(1); // R (Chiều dài)
        heightPackageController.text =
            dimensions['height']!.toStringAsFixed(1); // C (Chiều cao)
      });

      // Thông báo kết quả đo
      debugPrint('Dimension Measurement: Kích thước đo được - $dimensions');
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // Đóng dialog loading
      }

      // Hiển thị thông báo kích thước đã đo được
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Kích thước đo được: D${dimensions['width']}cm x R${dimensions['length']}cm x C${dimensions['height']}cm",
          ),
        ),
      );

      // Tiếp tục luồng xử lý - đóng camera đo kích thước và mở overlay quét cân
      await _dimensionCameraController.dispose();

      setState(() {
        _isDimensionMeasuring = false;
      });

      // // Tiếp tục với overlay quét cân
      showCameraAdjustmentOverlay();
    } catch (e) {
      debugPrint('Dimension Measurement: Lỗi - $e');

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // Đóng dialog loading nếu có lỗi
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi đo kích thước: ${e.toString()}")),
      );

      setState(() {
        _isDimensionMeasuring = false;
      });

      // Nếu lỗi vẫn tiếp tục quá trình
      await _dimensionCameraController.dispose();
      showCameraAdjustmentOverlay();
    }
  }

  Future<Map<String, double>> _processDimensionMeasurement(
      String imagePath) async {
    try {
      // Đọc file ảnh
      final File file = File(imagePath);
      final img.Image? originalImage =
          img.decodeImage(await file.readAsBytes());

      if (originalImage == null) {
        throw Exception('Không thể đọc ảnh');
      }

      // Phát hiện văn bản để xác định hướng
      final textRecognizer = mlkit.GoogleMlKit.vision.textRecognizer();
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      bool isTextUpright = false;
      for (TextBlock block in recognizedText.blocks) {
        // Kiểm tra góc xoay của văn bản
        if (block.boundingBox.top < block.boundingBox.bottom) {
          isTextUpright = true; // Văn bản không bị xoay ngược
          break;
        }
      }
      textRecognizer.close();

      // Tách các đối tượng dựa trên màu sắc
      final boxRect = _detectBoxByColor(originalImage);

      if (boxRect != null) {
        final double pixelsPerCM = originalImage.width / 30.0; // Ước lượng

        double dim1 = boxRect.width / pixelsPerCM;
        double dim2 = boxRect.height / pixelsPerCM;
        double dim3 =
            math.min(boxRect.width, boxRect.height) * 0.5 / pixelsPerCM;

        // Nếu văn bản nằm ngang, giả sử dim1 là width, dim2 là length, dim3 là height
        if (isTextUpright) {
          return {
            'length': double.parse(dim2.toStringAsFixed(1)), // Chiều dài
            'width': double.parse(dim1.toStringAsFixed(1)), // Chiều rộng
            'height': double.parse(dim3.toStringAsFixed(1)), // Chiều cao
          };
        } else {
          // Nếu văn bản bị xoay, có thể cần hoán đổi
          return {
            'length': double.parse(dim1.toStringAsFixed(1)), // Chiều dài
            'width': double.parse(dim2.toStringAsFixed(1)), // Chiều rộng
            'height': double.parse(dim3.toStringAsFixed(1)), // Chiều cao
          };
        }
      } else {
        return await _fallbackImageSegmentation(imagePath);
      }
    } catch (e) {
      debugPrint('Dimension Measurement: Lỗi xử lý ảnh - $e');
      return {
        'length': 30.0,
        'width': 20.0,
        'height': 10.0,
      };
    }
  }

  Rect? _detectBoxByColor(img.Image image) {
    // Điều chỉnh ngưỡng màu cho phù hợp với box
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
          minX = math.min(minX, x);
          minY = math.min(minY, y);
          maxX = math.max(maxX, x);
          maxY = math.max(maxY, y);
          foundPixels = true;
          matchedPixelCount++;
        }
      }
    }

    if (foundPixels && matchedPixelCount > minRequiredPixels) {
      // Mở rộng box một chút để đảm bảo bắt đủ toàn bộ hộp
      final int padding = 15; // Tăng padding
      minX = math.max(0, minX - padding);
      minY = math.max(0, minY - padding);
      maxX = math.min(image.width - 1, maxX + padding);
      maxY = math.min(image.height - 1, maxY + padding);

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

      // Phân tích ảnh để xác định kích thước hiện tại
      final int width = originalImage.width;
      final int height = originalImage.height;

      // Nếu không có thuật toán phức tạp, ước lượng kích thước dựa trên tỷ lệ màn hình
      final double screenRatio = width / height;

      // Giả định rằng chiều rộng thực tế của package là khoảng 30cm
      final double estimatedWidth = 30.0;
      final double estimatedLength = estimatedWidth / screenRatio;

      // Chiều cao ước lượng (thường là khoảng 1/2 kích thước ngắn nhất)
      final double estimatedHeight =
          math.min(estimatedWidth, estimatedLength) * 0.5;

      return {
        'width': double.parse(estimatedWidth.toStringAsFixed(1)),
        'length': double.parse(estimatedLength.toStringAsFixed(1)),
        'height': double.parse(estimatedHeight.toStringAsFixed(1)),
      };
    } catch (e) {
      debugPrint('Fallback Measurement: Lỗi - $e');
      // Trả về giá trị mặc định nếu không thể xác định
      return {
        'width': 30.0,
        'length': 20.0,
        'height': 10.0,
      };
    }
  }

  void showCameraAdjustmentOverlay() {
    // Xóa overlay cũ nếu có
    overlayEntry?.remove();
    // Pre-calculate positions and sizes to avoid layout calculations
    final bottomPosition = 50.h;
    final horizontalInset = 20.w;
    // Tạo overlay mới
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50.h,
        left: 20.w,
        right: 20.w,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextApp(
                        text: "Điều chỉnh camera",
                        fontsize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      SizedBox(height: 4.h),
                      TextApp(
                        text: "Vui lòng căn chỉnh camera để quét cân",
                        fontsize: 14.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ],
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 5.0, end: 0.0),
                  duration: const Duration(seconds: 5),
                  builder: (context, value, child) {
                    return Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: TextApp(
                          text: value.ceil().toString(),
                          fontsize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    );
                  },
                  // onEnd: () {
                  //   print("Countdown finished, starting weight capture...");
                  //   setState(() {
                  //     isProcessing = false; // Đảm bảo có thể scan tiếp
                  //   });

                  // },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Hiển thị overlay
    Overlay.of(context).insert(overlayEntry!);

    // LƯU Ý: Dùng một Timer riêng thay vì chỉ dùng Future.delayed
    // để có thể hủy nó nếu cần
    _adjustmentTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;

      overlayEntry?.remove();
      overlayEntry = null;

      _startWeightCapture();
      setState(() {
        isProcessing = false;
      });
      controller.stop();
    });
  }

  void scanAgain() {
    Navigator.pop(context);
    setState(() {
      isBottomSheetOpen = false;
      currentCode = '';
      controller.start();
    });
    // Restart scanning when "scan again" is pressed
  }

  void onConfirmBarCode(BuildContext context, String orderPickupID) {
    // Show loading dialog first
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: 20.h),
                  TextApp(
                    text: "Đang xử lý...",
                    fontsize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Close the original dialog
    Navigator.pop(context);
    currentListPakage.clear();
    selectedItems.clear();

    // Add event to bloc
    context.read<ScanImportBloc>().add(
          HanldeScanCodeImport(
              code: orderPickupID,
              listSurchageGoodsChoosed: listSurchageGoodsChoosed),
        );
  }

  void onGetDetailsPackage({required String mawbCode}) {
    context.read<ScanImportBloc>().add(GetDetailsPackage(mawbCode: mawbCode));
  }

  void onGetListSurchageGoods() {
    context.read<ScanImportBloc>().add(GetListSurchageGoods());
  }

  String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập trọng lượng';
    }

    // Kiểm tra có nhập số không
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Trọng lượng phải là số';
    }

    // Kiểm tra số âm
    if (weight < 0) {
      return 'Trọng lượng không được là số âm';
    }

    return null; // Hợp lệ
  }

  void openDialogSurchageGoodsChoosed({required String mawbCode}) {
    // Tạo key cho form để validation
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    isReadyGetDetailsPackage && isReadyGetListSurchageGoods
        ? showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Dialog(
                  insetPadding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.w),
                  ),
                  surfaceTintColor: Colors.white,
                  backgroundColor: Colors.white,
                  child: Container(
                    width: 1200.w, // Increased width compared to original 800.w
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title Section
                        Column(
                          children: [
                            SizedBox(height: 15.h),
                            TextApp(
                              text: "Mã MAWB: $mawbCode",
                              fontsize: 16.sp,
                            ),
                            Divider()
                          ],
                        ),

                        // Content Section
                        Flexible(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.only(left: 5.w, right: 10.w),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "THÔNG TIN PACKAGE",
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontFamily: "Icomoon",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        Expanded(
                                          child: Divider(
                                            height: 1,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20.w,
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          TextApp(
                                            text: "Mã Bill: ",
                                            fontsize: 16.sp,
                                          ),
                                          TextApp(
                                            text: codeBillController.text,
                                            fontsize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20.w,
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                        child: TextApp(
                                          text:
                                              "Count Scan: ${countScanController.text.isNotEmpty ? countScanController.text : "0"}",
                                          fontsize: 14.sp,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20.w,
                                    ),
                                    Container(
                                      width: 1.sw,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 60.w,
                                            child: TextApp(
                                              text: "Length: ",
                                              fontsize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Expanded(
                                            child: CustomTextFormField(
                                                enabled: true,
                                                controller:
                                                    lengthPackageController,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Nội dung không được để trống';
                                                  }
                                                  // Kiểm tra xem có phải là số hợp lệ không
                                                  if (double.tryParse(value) ==
                                                      null) {
                                                    return 'Vui lòng nhập số hợp lệ';
                                                  }
                                                  return null;
                                                },
                                                hintText: ''),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20.w,
                                    ),
                                    Container(
                                      width: 1.sw,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 60.w,
                                            child: TextApp(
                                              text: "Width: ",
                                              fontsize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Expanded(
                                            child: CustomTextFormField(
                                                enabled: true,
                                                controller:
                                                    widthPackageController,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Nội dung không được để trống';
                                                  }
                                                  // Kiểm tra xem có phải là số hợp lệ không
                                                  if (double.tryParse(value) ==
                                                      null) {
                                                    return 'Vui lòng nhập số hợp lệ';
                                                  }
                                                  return null;
                                                },
                                                hintText: ''),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20.w,
                                    ),
                                    Container(
                                      width: 1.sw,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 60.w,
                                            child: TextApp(
                                              text: "Height: ",
                                              fontsize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Expanded(
                                            child: CustomTextFormField(
                                                enabled: true,
                                                controller:
                                                    heightPackageController,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Nội dung không được để trống';
                                                  }
                                                  // Kiểm tra xem có phải là số hợp lệ không
                                                  if (double.tryParse(value) ==
                                                      null) {
                                                    return 'Vui lòng nhập số hợp lệ';
                                                  }
                                                  return null;
                                                },
                                                hintText: ''),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Container(
                                      width: 1.sw,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 60.w,
                                            child: TextApp(
                                              text: "Weight: ",
                                              fontsize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Expanded(
                                            child: CustomTextFormField(
                                                enabled: true,
                                                controller:
                                                    weightPackageController,
                                                validator: (value) =>
                                                    validateWeight(value),
                                                hintText: 'kg'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "PHÍ PHỤ THU MẶT HÀNG",
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontFamily: "Icomoon",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        Expanded(
                                          child: Divider(
                                            height: 1,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        )
                                      ],
                                    ),
                                    ListView.builder(
                                      key: ValueKey(selectedItems.toString()),
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: currentListPakage.length,
                                      itemBuilder: (context, index) {
                                        // Tạo controller riêng cho từng hàng
                                        TextEditingController
                                            quantityController =
                                            TextEditingController(
                                          text:
                                              currentListPakage[index].quantity,
                                        );
                                        TextEditingController nameController =
                                            TextEditingController(
                                          text: currentListPakage[index].name,
                                        );
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 240.w,
                                              height: 120.h,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  TextApp(
                                                    text: "Mặt hàng ",
                                                    fontsize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  SizedBox(
                                                    height: 10.h,
                                                  ),
                                                  CustomTextFormField(
                                                    readonly: false,
                                                    controller: nameController,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Nội dung không được để trống';
                                                      }
                                                      return null;
                                                    },
                                                    hintText: '',
                                                    suffixIcon:
                                                        Transform.rotate(
                                                      angle: 90 * math.pi / 180,
                                                      child: Icon(
                                                        Icons.chevron_right,
                                                        size: 32.sp,
                                                        color: Colors.black
                                                            .withOpacity(0.5),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      List<String>
                                                          availableItems =
                                                          listAllSurchageGoodsModel!
                                                              .surchageGoods
                                                              .where((item) =>
                                                                  !selectedItems
                                                                      .contains(
                                                                          '${item.surchargeGoodsName}[${item.surchargeGoodsPrice}/${item.surchargeGoodsType}]') ||
                                                                  '${item.surchargeGoodsName}[${item.surchargeGoodsPrice}/${item.surchargeGoodsType}]' ==
                                                                      currentListPakage[
                                                                              index]
                                                                          .name)
                                                              .map((item) =>
                                                                  '${item.surchargeGoodsName}[${item.surchargeGoodsPrice}/${item.surchargeGoodsType}]')
                                                              .toList();

                                                      showMyCustomModalBottomSheet(
                                                        context: context,
                                                        isScroll: true,
                                                        itemCount:
                                                            availableItems
                                                                .length,
                                                        itemBuilder: (context,
                                                            itemIndex) {
                                                          String itemName =
                                                              availableItems[
                                                                  itemIndex];
                                                          bool isSelected =
                                                              selectedItems
                                                                  .contains(
                                                                      itemName);
                                                          return Column(
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left: 20
                                                                            .w),
                                                                child: InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    Navigator.pop(
                                                                        context);
                                                                    setState(
                                                                        () {
                                                                      // Update selected items
                                                                      selectedItems
                                                                          .remove(
                                                                              currentListPakage[index].name);
                                                                      currentListPakage[index]
                                                                              .name =
                                                                          itemName;
                                                                      selectedItems
                                                                          .add(
                                                                              itemName);
                                                                    });
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      SizedBox(
                                                                        width: 1.sw -
                                                                            20.w,
                                                                        child:
                                                                            TextApp(
                                                                          text:
                                                                              itemName,
                                                                          color: isSelected
                                                                              ? Theme.of(context).colorScheme.primary
                                                                              : Colors.black,
                                                                          fontWeight: isSelected
                                                                              ? FontWeight.bold
                                                                              : FontWeight.normal,
                                                                          fontsize:
                                                                              20.sp,
                                                                          isOverFlow:
                                                                              false,
                                                                          softWrap:
                                                                              true,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Divider(
                                                                height: 25.h,
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5.w,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  TextApp(
                                                    text: "Số lượng",
                                                    fontsize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  SizedBox(
                                                    height: 10.h,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 6,
                                                        child:
                                                            CustomTextFormField(
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .fromLTRB(
                                                                      10.w,
                                                                      20.w,
                                                                      0.w,
                                                                      20.w),
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          controller:
                                                              quantityController,
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return 'Nội dung không được để trống';
                                                            }
                                                            if (int.tryParse(
                                                                    value) ==
                                                                null) {
                                                              return 'Vui lòng nhập số nguyên';
                                                            }
                                                            if (int.parse(
                                                                    value) <
                                                                1) {
                                                              return 'Số lượng phải lớn hơn 0';
                                                            }
                                                            return null;
                                                          },
                                                          hintText: '',
                                                          onChange: (value) {
                                                            setState(() {
                                                              currentListPakage[
                                                                          index]
                                                                      .quantity =
                                                                  value;
                                                            });
                                                          },
                                                          textInputAction:
                                                              TextInputAction
                                                                  .done,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5.w,
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              // Remove item from selected items set
                                                              selectedItems.remove(
                                                                  currentListPakage[
                                                                          index]
                                                                      .name);
                                                              currentListPakage
                                                                  .removeAt(
                                                                      index);
                                                            });
                                                          },
                                                          child: Container(
                                                            width: 30.w,
                                                            height: 30.h,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15.r),
                                                              color: Colors.red,
                                                            ),
                                                            child: const Center(
                                                              child: Icon(
                                                                Icons.close,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      height: 30.h,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: ButtonApp(
                                            event: () {
                                              setState(() {
                                                if (listAllSurchageGoodsModel!
                                                        .surchageGoods
                                                        .isNotEmpty &&
                                                    (selectedItems.length <
                                                        listAllSurchageGoodsModel!
                                                            .surchageGoods
                                                            .length)) {
                                                  // Get the first available item that is not selected
                                                  var availableItems =
                                                      listAllSurchageGoodsModel!
                                                          .surchageGoods
                                                          .where((item) =>
                                                              !selectedItems
                                                                  .contains(
                                                                      '${item.surchargeGoodsName}[${item.surchargeGoodsPrice}/${item.surchargeGoodsType}]'))
                                                          .toList();

                                                  if (availableItems
                                                      .isNotEmpty) {
                                                    var firstAvailableItem =
                                                        availableItems.first;
                                                    String newItemName =
                                                        '${firstAvailableItem.surchargeGoodsName}[${firstAvailableItem.surchargeGoodsPrice}/${firstAvailableItem.surchargeGoodsType}]';

                                                    // Add new item to the list
                                                    currentListPakage.add(Item(
                                                      name: newItemName,
                                                      quantity: '1',
                                                    ));
                                                    // Add the new item to selected items
                                                    selectedItems
                                                        .add(newItemName);
                                                  }
                                                }
                                              });
                                            },
                                            fontsize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            text: "Thêm Mặt Hàng",
                                            colorText: Theme.of(context)
                                                .colorScheme
                                                .background,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            outlineColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Actions Section
                        Padding(
                          padding: EdgeInsets.only(
                              left: 15.w, right: 15.w, bottom: 10.w, top: 15.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ButtonApp(
                                event: () {
                                  Navigator.of(context).pop();
                                  currentListPakage.clear();
                                  selectedItems.clear();
                                },
                                fontsize: 14.sp,
                                fontWeight: FontWeight.bold,
                                text: "Huỷ Bỏ",
                                colorText:
                                    Theme.of(context).colorScheme.background,
                                backgroundColor: Colors.grey,
                                outlineColor: Colors.grey,
                              ),
                              ButtonApp(
                                event: () {
                                  // Validate form trước khi xác nhận
                                  if (formKey.currentState!.validate()) {
                                    // Xử lý dữ liệu khi form hợp lệ
                                    listSurchageGoodsChoosed.clear();
                                    for (var packageItem in currentListPakage) {
                                      var item = listAllSurchageGoodsModel!
                                          .surchageGoods
                                          .firstWhere(
                                        (item) =>
                                            '${item.surchargeGoodsName}[${item.surchargeGoodsPrice}/${item.surchargeGoodsType}]' ==
                                            packageItem.name,
                                      );

                                      listSurchageGoodsChoosed.add(
                                        SurchageGoodsChoosed(
                                          surchargeGoodsID:
                                              item.surchargeGoodsId,
                                          count: int.tryParse(
                                                  packageItem.quantity) ??
                                              1,
                                          price: item.surchargeGoodsPrice
                                              .toDouble(),
                                        ),
                                      );
                                    }
                                    log(listSurchageGoodsChoosed.toString());
                                    onConfirmBarCode(
                                        context, codeTextController.text);
                                  }
                                },
                                fontsize: 14.sp,
                                fontWeight: FontWeight.bold,
                                text: "Xác Nhận",
                                colorText:
                                    Theme.of(context).colorScheme.background,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                outlineColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              });
            },
          )
        : showDialog(
            context: navigatorKey.currentContext!,
            builder: (BuildContext context) {
              return ErrorDialog(
                eventConfirm: () {
                  Navigator.pop(context);
                },
              );
            });
  }

  void vibrateScan() {
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        log("User is exiting the screen - cleaning up all processes");
        _cleanupAllProcesses();
        controller.stop();
        return true;
      },
      child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primary,
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.onBackground,
            ),
            backgroundColor: Theme.of(context).colorScheme.background,
            surfaceTintColor: Theme.of(context).colorScheme.background,
            shadowColor: Theme.of(context).colorScheme.background,
            title: Text(
              widget.titleScrenn,
              style: TextStyle(
                fontSize: 20.sp,
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isTorchOn ? Icons.flash_on : Icons.flash_off,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                onPressed: () {
                  setState(() {
                    isTorchOn = !isTorchOn;
                  });
                  controller.toggleTorch();
                },
              ),
              IconButton(
                icon: Icon(
                  cameraFacing == CameraFacing.back
                      ? Icons.camera_front
                      : Icons.camera_rear,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                onPressed: () {
                  setState(() {
                    cameraFacing = cameraFacing == CameraFacing.back
                        ? CameraFacing.front
                        : CameraFacing.back;
                  });
                  controller.switchCamera();
                },
              ),
            ],
          ),
          body: MultiBlocListener(
            listeners: [
              BlocListener<ScanImportBloc, ScanCodeImportState>(
                listener: (context, state) {
                  if (state is ScanCodeImportStateSuccess) {
                    // First dismiss the loading dialog if it's still showing
                    Navigator.of(navigatorKey.currentContext!).pop();
                    showCustomDialogModal(
                      context: navigatorKey.currentContext!,
                      textDesc: state.message,
                      title: "Thông báo",
                      colorButtonOk: Colors.green,
                      btnOKText: "Xác nhận",
                      typeDialog: "success",
                      eventButtonOKPress: () {
                        scanAgain();
                      },
                      isTwoButton: false,
                    );
                  } else if (state is ScanCodeImportStateFailure) {
                    showCustomDialogModal(
                      context: navigatorKey.currentContext!,
                      textDesc: state.message,
                      title: "Thông báo",
                      colorButtonOk: Colors.red,
                      btnOKText: "Xác nhận",
                      typeDialog: "error",
                      eventButtonOKPress: () {},
                      isTwoButton: false,
                    );
                  } else if (state is GetDetailsPackageStateSuccess) {
                    codeBillController.text = state
                        .detailsPackageScanCodeModel.shipment_code
                        .toString();
                    detailsPackageScanCodeModel =
                        state.detailsPackageScanCodeModel;
                    countScanController.text =
                        state.detailsPackageScanCodeModel.count_scan;
                    // lengthPackageController.text = detailsPackageScanCodeModel!
                    //     .package.packageLength
                    //     .toString();
                    // widthPackageController.text = detailsPackageScanCodeModel!
                    //     .package.packageWidth
                    //     .toString();
                    // heightPackageController.text = detailsPackageScanCodeModel!
                    //     .package.packageHeight
                    //     .toString();

                    // Nếu không có số cân từ OCR, sử dụng số cân từ package details
                    if (weightPackageController.text.isEmpty) {
                      weightPackageController.text =
                          detailsPackageScanCodeModel!.package.packageWeight
                              .toString();
                    }
                    isReadyGetDetailsPackage = true;
                    isGetDetailsPackageSuccess = true;

                    // // Thay vì showBottomSheet() ở đây, hiện dialog để chụp ảnh cân
                    // showWeightCaptureDialog();

                    // showBottomSheet();
                  } else if (state is GetDetailsPackageStateFailure) {
                    isReadyGetDetailsPackage = false;
                    isGetDetailsPackageSuccess = false;
                    controller.stop();
                    showDialog(
                      context: navigatorKey.currentContext!,
                      builder: (BuildContext context) {
                        return ErrorDialog(
                          eventConfirm: () {
                            scanAgain();
                          },
                          errorText: state.message,
                        );
                      },
                    );
                  } else if (state is GetListSurchageGoodsStateSuccess) {
                    listAllSurchageGoodsModel = state.listAllSurchageGoodsModel;
                    isReadyGetListSurchageGoods = true;
                  } else if (state is GetListSurchageGoodsStateFailure) {
                    isReadyGetListSurchageGoods = false;
                    showDialog(
                      context: navigatorKey.currentContext!,
                      builder: (BuildContext context) {
                        return ErrorDialog(
                          eventConfirm: () {
                            scanAgain();
                          },
                          errorText: "${state.message}",
                        );
                      },
                    );
                  }
                },
              ),
            ],
            child: BlocBuilder<ScanImportBloc, ScanCodeImportState>(
              builder: (context, state) {
                return Stack(
                  children: [
                    MobileScanner(
                      controller: controller,
                      errorBuilder: (
                        BuildContext context,
                        MobileScannerException error,
                      ) {
                        return ScannerErrorWidget(error: error);
                      },
                      fit: BoxFit.fill,
                      onDetect: (BarcodeCapture barcode) async {
                        final String code =
                            barcode.barcodes.first.rawValue ?? '';

                        if (code.isNotEmpty &&
                            code != '' &&
                            currentCode != code) {
                          onBarcodeDetected(code);
                          vibrateScan();
                        }
                      },
                    ),
                    Center(
                      child: Container(
                        width: 1.sw,
                        height: 1.sh - 600.h,
                        margin: EdgeInsets.all(20.w),
                        child: Lottie.asset('assets/lottie/scan_animation.json',
                            fit: BoxFit.fill),
                      ),
                    ),
                    SizedBox(
                        width: 1.sw,
                        height: 300.h,
                        child: Center(
                          child: TextApp(
                            text: "Đưa mã cần quét vào khung",
                            fontsize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )),
                    const ScannerOverlay()
                  ],
                );
              },
            ),
          )),
    );
  }

  /* void showBottomSheet() {
    if (!isBottomSheetOpen) {
      // If bottom sheet is not open, open a new one
      isBottomSheetOpen = true;
      controller.stop(); // Stop scanning when bottom sheet is shown
      currentBottomSheet = ResultScanWidget(
        context: context,
        codeTextController: codeTextController,
        scanAgain: scanAgain,
        confirmBarCode: () =>
            openDialogSurchageGoodsChoosed(mawbCode: codeTextController.text),
      );
      showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15.r),
            topLeft: Radius.circular(15.r),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        context: context,
        builder: (context) => currentBottomSheet!,
      ).then((_) {
        isBottomSheetOpen = false;
        currentCode = '';
        controller.start(); // Restart scanning when bottom sheet is closed
      });
    }
  }*/

  void showBottomSheet() {
    if (!isBottomSheetOpen) {
      // If bottom sheet is not open, open a new one
      isBottomSheetOpen = true;
      controller.stop(); // Stop scanning when bottom sheet is shown
      currentBottomSheet = ResultScanWidget(
        context: context,
        codeTextController: codeTextController,
        scanAgain: scanAgain,
        confirmBarCode: () {
          openDialogSurchageGoodsChoosed(mawbCode: codeTextController.text);
        },
      );
      showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15.r),
            topLeft: Radius.circular(15.r),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        context: context,
        builder: (context) => currentBottomSheet!,
      ).then((_) {
        isBottomSheetOpen = false;
        currentCode = '';
        controller.start(); // Restart scanning when bottom sheet is closed
      });
    }
  }

// Hàm bắt đầu chụp ảnh cân
  void _startWeightCapture() async {
    try {
      final cameras = await availableCameras();
      log("Danh sách camera: $cameras");

      if (cameras.isEmpty) {
        log("Không tìm thấy camera!");
        return;
      }

      // Chọn camera sau (có chất lượng cao hơn camera trước)
      final CameraDescription selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
          selectedCamera, ResolutionPreset.veryHigh, // Độ phân giải cao nhất
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.yuv420);

      await _cameraController?.initialize();

      // **Tăng chất lượng ảnh bằng cách chỉnh focus và exposure**
      await _cameraController
          ?.setFocusMode(FocusMode.auto); // Chỉnh nét tự động
      // Giới hạn FPS để giảm tiêu thụ pin và tài nguyên
      await _cameraController?.setExposureOffset(0.5); // Tăng độ sáng một chút

      log("Camera đã sẵn sàng!");

      // Tự động chụp ảnh sau khi khởi tạo camera
      _captureWeightImage(context);
    } catch (e) {
      log("Lỗi khởi tạo camera: $e");
      return;
    }
  }

  // 📌 Phân loại màn hình LCD hoặc LED
  double classifyScreenType(img.Image image) {
    int width = image.width;
    int height = image.height;
    int totalPixels = width * height;

    List<int> brightnessValues = [];
    int totalBrightness = 0;
    int darkPixelCount = 0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        img.Pixel pixel = image.getPixel(x, y); // ✅ Lấy Pixel đúng cách

        num r = pixel.getChannel(img.Channel.red);
        num g = pixel.getChannel(img.Channel.green);
        num b = pixel.getChannel(img.Channel.blue);

        // ✅ Tính độ sáng bằng công thức Luminance tiêu chuẩn
        int brightness = ((0.299 * r) + (0.587 * g) + (0.114 * b)).toInt();

        brightnessValues.add(brightness);
        totalBrightness += brightness;
        if (brightness < 80) {
          darkPixelCount++; // Đếm số pixel tối
        }
      }
    }

    // ✅ Tính độ sáng trung bình
    double avgBrightness = totalBrightness / totalPixels;

    // ✅ Tính tỷ lệ pixel tối
    double darkRatio = darkPixelCount / totalPixels;

    log("AvgBrightness: $avgBrightness");
    log("DarkRatio: $darkRatio");

    // 👉 Điều kiện phân loại LED hoặc LCD
    if (avgBrightness < 120 && darkRatio > 0.45) {
      return 1; // LED
    } else {
      return 0; // LCD
    }
  }

// 📌 Tính độ tương phản trung bình của ảnh
  double calculateContrast(img.Image image) {
    int width = image.width;
    int height = image.height;
    int totalPixels = width * height;

    if (totalPixels == 0) return 0; // Tránh lỗi chia 0

    List<int> brightnessValues = [];
    int totalBrightness = 0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        img.Pixel pixel = image.getPixel(x, y); // ✅ Lấy pixel đúng cách

        // ✅ Tính độ sáng (luminance) bằng công thức YIQ
        int brightness =
            (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b).toInt();

        brightnessValues.add(brightness);
        totalBrightness += brightness;
      }
    }

    if (brightnessValues.isEmpty) return 0; // Tránh lỗi khi danh sách rỗng

    double avgBrightness = totalBrightness / totalPixels;

    // ✅ Tính phương sai (variance)
    double variance = brightnessValues
            .map((b) => math.pow(b - avgBrightness, 2))
            .reduce((a, b) => a + b) /
        totalPixels;

    // ✅ Tính độ lệch chuẩn (standard deviation)
    double stdDev = math.sqrt(variance);

    // ✅ Tính tỷ lệ pixel tối
    double darkPixelsRatio =
        brightnessValues.where((b) => b < 100).length / totalPixels;

    log("Độ lệch chuẩn (StdDev): $stdDev");
    log("Độ sáng trung bình (AvgBrightness): $avgBrightness");
    log("Tỷ lệ pixel tối: $darkPixelsRatio");

    return (stdDev > 65 && avgBrightness < 120) ? 1 : 0;
  }

// 📌 Xử lý ảnh LED
//   img.Image processLEDImage(img.Image image) {
//     img.Image grayImage = img.grayscale(image);

//     // 🔹 3. Tăng tương phản
//     img.Image highContrastImage = img.adjustColor(grayImage, contrast: 25.0);

//     // // 🔹 4. Cân chỉnh góc nghiêng ảnh trước khi tiếp tục xử lý
//     // double skewAngle = _detectSkewAngle(highContrastImage);
//     // log(skewAngle.toString());
//     // img.Image correctedImage = (skewAngle.abs() > 1.0)
//     //     ? img.copyRotate(highContrastImage, angle: -skewAngle)
//     //     : highContrastImage;
//     img.Image correctedImage = highContrastImage;

//     // 🔹 5. Làm mịn ảnh để giảm nhiễu nhẹ (giữ giá trị thấp để không mất nét)
//     img.Image denoisedImage = img.gaussianBlur(correctedImage, radius: 7);

//     // 🔹 6. Áp dụng bộ lọc làm rõ nét (Sharpening)
//     img.Image sharpenedImage = _manualSharpen(denoisedImage);

//     // 🔹 7. Đảo ngược màu (tùy trường hợp)
//     return img.invert(sharpenedImage);
//   }

// // 📌 Hàm cân chỉnh góc nghiêng ảnh (Deskewing)
//   // 📌 Hàm phát hiện góc nghiêng của ảnh
//   double _detectSkewAngle(img.Image image) {
//     int leftSum = 0, rightSum = 0, count = 0;

//     for (int y = 0; y < image.height; y++) {
//       if (image.getPixel(0, y).luminance < 128) leftSum += y;
//       if (image.getPixel(image.width - 1, y).luminance < 128) rightSum += y;
//       count++;
//     }

//     double skewAngle =
//         math.atan((rightSum - leftSum) / (count + 1)) * (180 / math.pi);
//     return skewAngle; // Trả về góc nghiêng tính toán
//   }

// // 📌 Hàm tự định nghĩa để làm sắc nét ảnh
//   img.Image _manualSharpen(img.Image image) {
//     img.Image result = img.Image.from(image);

//     List<List<double>> kernel = [
//       [-1, -1, -1],
//       [-1, 9, -1],
//       [-1, -1, -1]
//     ];

//     for (int y = 1; y < image.height - 1; y++) {
//       for (int x = 1; x < image.width - 1; x++) {
//         double redSum = 0;
//         double greenSum = 0;
//         double blueSum = 0;

//         for (int ky = -1; ky <= 1; ky++) {
//           for (int kx = -1; kx <= 1; kx++) {
//             img.Pixel pixel = image.getPixel(x + kx, y + ky);
//             redSum += pixel.r * kernel[ky + 1][kx + 1];
//             greenSum += pixel.g * kernel[ky + 1][kx + 1];
//             blueSum += pixel.b * kernel[ky + 1][kx + 1];
//           }
//         }

//         // Hạn chế nhiễu bằng cách giảm giá trị max của sharpening
//         int newRed = math.max(0, math.min(255, (redSum * 0.8).round()));
//         int newGreen = math.max(0, math.min(255, (greenSum * 0.8).round()));
//         int newBlue = math.max(0, math.min(255, (blueSum * 0.8).round()));

//         result.setPixel(x, y, img.ColorRgb8(newRed, newGreen, newBlue));
//       }
//     }

//     return result;
//   }

  img.Image processLEDImage(img.Image image) {
    logPixel(image, "Original Image");

    // 🔹 Chuyển ảnh sang grayscale
    img.Image grayImage = img.grayscale(image);
    logPixel(grayImage, "Grayscale");

    // 🔹 Phân tích độ sáng trung bình
    double avgBrightness = _calculateBrightness(grayImage);
    log("📌 [Brightness] Avg: $avgBrightness");

    // 🔹 Tự động điều chỉnh độ tương phản
    double contrastLevel = (avgBrightness < 40)
        ? 110.0
        : (avgBrightness < 100)
            ? 80.0
            : 80.0;
    img.Image highContrastImage =
        img.adjustColor(grayImage, contrast: contrastLevel);
    logPixel(highContrastImage, "High Contrast (Contrast=$contrastLevel)");

    // 🔹 Phát hiện và chỉnh góc nghiêng
    double skewAngle = _detectSkewAngle(highContrastImage);
    log("📌 [Skew Detection] Góc nghiêng phát hiện: $skewAngle°");
    img.Image correctedImage = _correctSkewRegion(highContrastImage, skewAngle);
    logPixel(correctedImage, "Corrected Skew");

    // 🔹 Tự động điều chỉnh Gaussian Blur
    int blurRadius = (avgBrightness < 90) ? 12 : 10;
    img.Image denoisedImage =
        img.gaussianBlur(correctedImage, radius: blurRadius);
    logPixel(denoisedImage, "Denoised (Gaussian Blur, radius=$blurRadius)");

    // // 🔹 Làm nổi bật biên (Edge Detection)
    // img.Image edgeEnhanced = _edgeDetection(denoisedImage);
    // logPixel(edgeEnhanced, "Edge Enhanced");

    // 🔹 Làm sắc nét ảnh
    img.Image sharpenedImage = _manualSharpen(denoisedImage);
    logPixel(sharpenedImage, "Sharpened");

    // 🔹 Đảo màu ảnh
    img.Image invertedImage = img.invert(sharpenedImage);
    logPixel(invertedImage, "Inverted");

    return invertedImage;
  }

// 📌 Tính độ sáng trung bình của ảnh
  double _calculateBrightness(img.Image image) {
    double totalBrightness = 0;
    int pixelCount = image.width * image.height;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        totalBrightness += image.getPixel(x, y).luminance;
      }
    }

    return totalBrightness / pixelCount;
  }

// 📌 Phát hiện góc nghiêng của vùng chứa số cân
  double _detectSkewAngle(img.Image image) {
    int leftSum = 0, rightSum = 0, count = 0;
    int validPoints = 0;

    for (int y = image.height ~/ 4; y < (image.height * 3) ~/ 4; y++) {
      num leftLuminance = image.getPixel(10, y).luminance;
      num rightLuminance = image.getPixel(image.width - 10, y).luminance;

      if (leftLuminance < 128) {
        leftSum += y;
        validPoints++;
      }
      if (rightLuminance < 128) {
        rightSum += y;
        validPoints++;
      }
      count++;
    }

    if (validPoints < 10) return 0;

    double skewAngle =
        math.atan((rightSum - leftSum) / (count + 1)) * (180 / math.pi);
    return (skewAngle.abs() > 25) ? 0 : skewAngle;
  }

// 📌 Chỉnh góc nghiêng của vùng số cân
  img.Image _correctSkewRegion(img.Image image, double angle) {
    if (angle.abs() > 1.0) {
      return img.copyRotate(image, angle: -angle);
    }
    return image;
  }

// 📌 Làm sắc nét ảnh
  img.Image _manualSharpen(img.Image image) {
    img.Image result = img.Image.from(image);

    List<List<double>> kernel = [
      [-1, -1, -1],
      [-1, 9, -1],
      [-1, -1, -1]
    ];

    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        double redSum = 0, greenSum = 0, blueSum = 0;

        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            img.Pixel pixel = image.getPixel(x + kx, y + ky);
            redSum += pixel.r * kernel[ky + 1][kx + 1];
            greenSum += pixel.g * kernel[ky + 1][kx + 1];
            blueSum += pixel.b * kernel[ky + 1][kx + 1];
          }
        }

        int newRed = math.max(0, math.min(255, (redSum * 0.8).round()));
        int newGreen = math.max(0, math.min(255, (greenSum * 0.8).round()));
        int newBlue = math.max(0, math.min(255, (blueSum * 0.8).round()));

        result.setPixel(x, y, img.ColorRgb8(newRed, newGreen, newBlue));
      }
    }
    return result;
  }

// 📌 Ghi log thông tin pixel trung tâm để theo dõi từng bước xử lý
  void logPixel(img.Image image, String step) {
    int centerX = image.width ~/ 2;
    int centerY = image.height ~/ 2;
    img.Pixel pixel = image.getPixel(centerX, centerY);

    log("📌 [$step] Pixel trung tâm: R=${pixel.r}, G=${pixel.g}, B=${pixel.b}, Luminance=${pixel.luminance}");
  }

// 📌 Xử lý ảnh LCD
  img.Image process7SegmentImage(img.Image image) {
    // // 🔹 1. Chuyển về grayscale để loại bỏ màu sắc
    // img.Image grayImage = img.grayscale(image);

    // // 🔹 2. Tăng cường cạnh bằng bộ lọc Sobel
    // img.Image edgeImage = img.sobel(grayImage);

    // // 🔹 3. Dùng Adaptive Threshold để làm rõ số
    // img.Image thresholdedImage = applyLocalThresholdFast(edgeImage, 128, 10);

    // // 🔹 4. Phát hiện góc nghiêng và xoay chỉnh ảnh
    // double skewAngle = _detect7SegmentSkewAngle(thresholdedImage);
    // img.Image correctedImage = (skewAngle.abs() > 1.5)
    //     ? img.copyRotate(thresholdedImage, angle: -skewAngle)
    //     : thresholdedImage;

    // // 🔹 5. Lọc nhiễu bằng Morphology (giữ nét số)
    // img.Image denoisedImage = img.gaussianBlur(correctedImage, radius: 10);

    // // 🔹 6. Làm sắc nét để tăng độ rõ của số
    // img.Image sharpenedImage = _sharpen7Segment(denoisedImage);

    // return sharpenedImage;

    // 🔹 1. Chuyển ảnh sang grayscale để cân bằng tất cả màu chữ
    img.Image grayImage = img.grayscale(image);

    // 🔹 2. Tăng tương phản
    img.Image highContrastImage = img.adjustColor(grayImage, contrast: 20.0);

    // 🔹 3. Cân chỉnh góc nghiêng ảnh trước khi tiếp tục xử lý
    // double skewAngle = _detectSkewAngle(highContrastImage);
    // log(skewAngle.toString());
    // img.Image correctedImage = (skewAngle.abs() > 2.0)
    //     ? img.copyRotate(highContrastImage, angle: -skewAngle)
    //     : highContrastImage;
    img.Image correctedImage = highContrastImage;

    // 🔹 4. Làm mịn ảnh để giảm nhiễu nhẹ (giữ giá trị thấp để không mất nét)
    img.Image denoisedImage = img.gaussianBlur(correctedImage, radius: 10);

    // 🔹 5. Áp dụng bộ lọc làm rõ nét (Sharpening)
    img.Image sharpenedImage = _manualSharpen(denoisedImage);

    // 🔹 6. Đảo ngược màu (tùy trường hợp)
    return img.invert(sharpenedImage);
  }

  img.Image applyLocalThresholdFast(
      img.Image image, int blockSize, int offset) {
    int w = image.width;
    int h = image.height;
    img.Image thresholded = img.Image.from(image);

    // 🔥 **Tạo Integral Image để tính tổng nhanh**
    List<List<int>> integral = List.generate(h, (_) => List.filled(w, 0));

    for (int y = 0; y < h; y++) {
      int rowSum = 0;
      for (int x = 0; x < w; x++) {
        rowSum += img.getLuminance(image.getPixel(x, y)).toInt();
        integral[y][x] = rowSum + (y > 0 ? integral[y - 1][x] : 0);
      }
    }

    // 🔥 **Áp dụng Adaptive Threshold bằng Integral Image**
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        int x1 = (x - blockSize ~/ 2).clamp(0, w - 1);
        int y1 = (y - blockSize ~/ 2).clamp(0, h - 1);
        int x2 = (x + blockSize ~/ 2).clamp(0, w - 1);
        int y2 = (y + blockSize ~/ 2).clamp(0, h - 1);

        int area = (x2 - x1 + 1) * (y2 - y1 + 1);
        int sum = integral[y2][x2] -
            (y1 > 0 ? integral[y1 - 1][x2] : 0) -
            (x1 > 0 ? integral[y2][x1 - 1] : 0) +
            (x1 > 0 && y1 > 0 ? integral[y1 - 1][x1 - 1] : 0);

        int avgBrightness = sum ~/ area;
        int threshold = avgBrightness - offset;
        int pixelBrightness = img.getLuminance(image.getPixel(x, y)).toInt();

        if (pixelBrightness > threshold) {
          thresholded.setPixel(x, y, img.ColorInt8.rgb(255, 255, 255)); // Trắng
        } else {
          thresholded.setPixel(x, y, img.ColorInt8.rgb(0, 0, 0)); // Đen
        }
      }
    }
    return thresholded;
  }

// ✅ Hàm tính độ sáng trung bình của ảnh
  double getAverageBrightness(img.Image image) {
    int totalBrightness = 0;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        img.Pixel pixel = image.getPixelSafe(x, y);
        int brightness = img.getLuminance(pixel).toInt();
        totalBrightness += brightness;
      }
    }
    return totalBrightness / (image.width * image.height);
  }

// 📌 Tiền xử lý ảnh
  Future<String> preprocessImage(String imagePath) async {
    // Bỏ qua việc tạo isolate cho ảnh nhỏ
    final File imageFile = File(imagePath);
    final int fileSize = await imageFile.length();

    // // Với file nhỏ, xử lý trực tiếp không cần isolate
    // if (fileSize < 1 * 1024 * 1024) {
    // 1MB
    return _imageProcessingLight(imagePath);
    // }

    // // Với file lớn, sử dụng isolate
    // final ReceivePort receivePort = ReceivePort();
    // await Isolate.spawn(
    //     _imageProcessingIsolate, [imagePath, receivePort.sendPort]);
    // return await receivePort.first;
  }

// Phiên bản nhẹ hơn cho xử lý ảnh

// Nhận diện văn bản từ ảnh sau khi tiền xử lý
  Future<String?> recognizeText(String imagePath) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await textRecognizer.processImage(inputImage);
    textRecognizer.close();

    if (recognizedText.text.isEmpty) {
      final textRecognizerRetry =
          TextRecognizer(script: TextRecognitionScript.latin);
      final retryResult = await textRecognizerRetry.processImage(inputImage);
      textRecognizerRetry.close();
      return retryResult.text;
    }
    return recognizedText.text;
  }

  Future<String?> recognizeTextWithGoogleVision(String imagePath) async {
    const url =
        "https://vision.googleapis.com/v1/images:annotate?key=$googleVisionApi";

    final bytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(bytes);

    final requestBody = jsonEncode({
      "requests": [
        {
          "image": {"content": base64Image},
          "features": [
            {"type": "TEXT_DETECTION", "maxResults": 1}
          ]
        }
      ]
    });

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: requestBody,
          )
          .timeout(const Duration(seconds: 5));

      switch (response.statusCode) {
        case 200:
          log("✅ Google Vision API: Thành công");
          final jsonResponse = jsonDecode(response.body);
          final textAnnotations =
              jsonResponse["responses"][0]["textAnnotations"];
          if (textAnnotations != null && textAnnotations.isNotEmpty) {
            return textAnnotations[0]["description"];
          }
          return ""; // Không có văn bản nào được nhận diện

        case 400:
          log("❌ Google Vision API Error 400: Bad Request (Có thể do request bị sai format)");
          break;

        case 401:
          log("❌ Google Vision API Error 401: Unauthorized (Sai API Key hoặc không có quyền truy cập)");
          break;

        case 403:
          log("❌ Google Vision API Error 403: Forbidden (Dịch vụ có thể bị khóa hoặc quota API bị giới hạn)");
          break;

        case 404:
          log("❌ Google Vision API Error 404: Not Found (URL API có thể sai)");
          break;

        case 413:
          log("❌ Google Vision API Error 413: Payload Too Large (Ảnh quá lớn để xử lý)");
          break;

        case 429:
          log("❌ Google Vision API Error 429: Quota Hết (Chuyển sang nhận diện offline)");
          return await recognizeText(imagePath);

        case 500:
          log("❌ Google Vision API Error 500: Internal Server Error (Lỗi từ phía Google)");
          break;

        case 503:
          log("❌ Google Vision API Error 503: Service Unavailable (Dịch vụ Google đang bị gián đoạn)");
          break;

        default:
          log("❌ Google Vision API Error ${response.statusCode}: ${response.body}");
          break;
      }
    } catch (e) {
      log("❌ Google Vision API Exception: $e");
    }

    return "";
  }

  // Future<String> recognizeNumbers(File imageFile) async {
  //   String text = await FlutterTesseractOcr.extractText(imageFile.path,
  //       language: "eng",
  //       args: {
  //         "preserve_interword_spaces": "1",
  //       });

  //   log("OCR Output: $text"); // Debug dữ liệu nhận diện được
  //   return text.replaceAll(RegExp(r'[^0-9.]'), '');
  // }

  Future<String?> recognizeTextMultipleWays(String imagePath) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      // // Chạy OCR bằng Tesseract
      // String? tesseractResult = await recognizeNumbers(File(imagePath));
      // log("Kết quả OCR từ Tesseract: $tesseractResult");
      // if (tesseractResult != null && tesseractResult.isNotEmpty) {
      //   log("Tesseract hoạt động bình thường.");
      //   return tesseractResult; // Nếu có kết quả từ Tesseract, return ngay
      // } else {
      //   log("Tesseract không nhận diện được hoặc trả về rỗng.");
      // }

      // Lấy đường dẫn đến các phiên bản ảnh đã xử lý
      final tempDir = await getTemporaryDirectory();
      String originalPath = '${tempDir.path}/original_image.jpg';
      String processedPath = '${tempDir.path}/processed_image.jpg';
      String thresholdPath = '${tempDir.path}/threshold_image.jpg';
      String invertedPath = '${tempDir.path}/inverted_image.jpg';

      // Danh sách các đường dẫn ảnh cần thử
      List<String> imagePaths = [
        processedPath, // Ưu tiên ảnh đã xử lý
        thresholdPath, // Thử ảnh áp dụng threshold
        invertedPath, // Thử ảnh đảo màu
        originalPath, // Ảnh gốc
        imagePath // Ảnh ban đầu
      ];

      List<String> results = [];

      // Chạy OCR bằng ML Kit trên tất cả các phiên bản ảnh
      for (String path in imagePaths) {
        if (File(path).existsSync()) {
          final inputImage = InputImage.fromFilePath(path);
          final recognizedText = await textRecognizer.processImage(inputImage);
          log("Text : ${recognizedText.text} ");
          if (recognizedText.text.isNotEmpty) {
            results.add(recognizedText.text);
          }
        }
      }

      // Đóng recognizer sau khi sử dụng
      textRecognizer.close();

      // Tổng hợp và chọn kết quả tốt nhất từ ML Kit
      if (results.isNotEmpty) {
        // Nếu có kết quả chứa số và dấu chấm thập phân, ưu tiên nó
        for (String result in results) {
          if (result.contains('.') && RegExp(r'\d').hasMatch(result)) {
            log("Kết quả từ ML Kit: $result");
            return result;
          }
        }
        return results
            .first; // Trả về kết quả đầu tiên nếu không có số thập phân
      }

      return ''; // Trả về rỗng nếu không có kết quả nào
    } catch (e) {
      textRecognizer.close();
      log("Lỗi nhận dạng văn bản: $e");
      return null;
    }
  }

// Hàm chụp và xử lý ảnh cân
  /*void _captureWeightImage(BuildContext context) async {
    try {
      if (_cameraController?.value.isInitialized != true) {
        return;
      }

      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await Future.delayed(Duration(milliseconds: 300));

      // Chụp ảnh
      final XFile? file = await _cameraController?.takePicture();
      if (file == null) {
        Navigator.pop(context);
        return;
      }

      // Xử lý ảnh để làm rõ số LED
      File processedImage = await preprocessImage(file.path);

      // Nhận diện số từ ảnh đã xử lý - sử dụng phương pháp nâng cao
      final recognizedText =
          await recognizeTextMultipleWays(processedImage.path);
      log('Văn bản được phát hiện: "${recognizedText}"');

      Navigator.pop(context);

      // Trích xuất số từ văn bản OCR
      double? detectedWeight =
          _extractDigitalScaleWeight(recognizedText.toString(), file.path);

      if (detectedWeight != null) {
        setState(() {
          // Sử dụng định dạng mới để hiển thị số cân
          weightPackageController.text = formatWeight(detectedWeight);
        });
        // Hiển thị kết quả sau khi nhận diện số cân
        showBottomSheet();
      } else {
        _showManualWeightInputDialog();
      }
    } catch (e) {
      log("Error capturing weight image: $e");
      Navigator.pop(context);
      _showManualWeightInputDialog();
    }
  }*/

  void _captureWeightImage(BuildContext context) async {
    try {
      if (_cameraController?.value.isInitialized != true) {
        return;
      }

      // Hiển thị loading trước khi chụp ảnh
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ),
        );
      }

      // Chụp ảnh
      final XFile? file = await _cameraController?.takePicture();

      // Giải phóng camera ngay lập tức
      Future.microtask(() {
        _cameraController?.dispose();
        _cameraController = null;
      });

      if (file == null) {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        return;
      }

      final processedImagePath = await preprocessImage(file.path);
      final recognizedText =
          await recognizeTextWithGoogleVision(processedImagePath);
      log('Văn bản được phát hiện: "$recognizedText"');

      if (!mounted) return;

      // Đóng loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Trích xuất số cân nặng từ văn bản
      String detectedWeight =
          _extractDigitalScaleWeight(recognizedText ?? "", file.path);

      if (detectedWeight.isNotEmpty) {
        setState(() {
          weightPackageController.text = formatWeight(detectedWeight);
        });
      } else {
        weightPackageController.text =
            detailsPackageScanCodeModel?.package.packageWeight.toString() ?? "";
      }

      showBottomSheet();
    } catch (e) {
      log("Error capturing weight image: $e");
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

// Tối ưu hóa các regex để giảm số lần xử lý
  final RegExp _nonNumericRegex = RegExp(r'[^0-9.]');
  final RegExp _trailingDotRegex = RegExp(r'\.$');
  final RegExp _leadingZerosRegex = RegExp(r'^0+');
  final RegExp _multipleSpacesRegex = RegExp(r'\s+');

// Các regex cho _cleanupOcrText
  final RegExp _zeroCharsRegex = RegExp(r'[OoQDUa]');
  final RegExp _oneCharsRegex = RegExp(r'[IlT]');
  String _extractDigitalScaleWeight(String text, String path) {
    log('Original text: "$text"');

    // Handle null or empty input
    if (text == "null" || text.isEmpty) {
      return ""; // Return two spaces
    }

    // 🔹 Bước 1: Làm sạch văn bản OCR
    String cleanedText = _cleanupOcrText(text, true);
    log('Cleaned OCR text: "$cleanedText"');

    // 🔹 Bước 2: Phân tích và tìm giá trị cân thực
    String extractedWeight = _findActualWeightValue(cleanedText);
    log('Extracted weight: "$extractedWeight"');

    return extractedWeight;
  }

  String _findActualWeightValue(String text) {
    // Handle null or empty input
    if (text == "null" || text.isEmpty) {
      return ""; // Return two spaces
    }
    // Loại bỏ tất cả ký tự không phải số và dấu chấm
    String numericOnly = text.replaceAll(RegExp(r'[^0-9.]'), '');
    log('Số sau khi lọc: "$numericOnly"');

    // TRƯỜNG HỢP 0: Đã định dạng đúng X.XX hoặc XX.XX hoặc XXX.XX
    // Ưu tiên tìm mẫu chuẩn X.XX hoặc XX.XX hoặc XXX.XX với hai chữ số phần thập phân
    RegExp standardWeightPattern = RegExp(r'(\d{1,3})\.(\d{2})');
    Match? standardMatch = standardWeightPattern.firstMatch(text);
    if (standardMatch != null) {
      return standardMatch.group(0) ?? "";
    }
// CẢI TIẾN: Phân tích và đặt dấu chấm thập phân dựa vào hình dạng của số
    // Trường hợp 3 chữ số: XYZ -> X.YZ
    if (numericOnly.length == 3) {
      // Với số bắt đầu bằng 0 (như 070), luôn định dạng thành 0.YZ
      if (numericOnly.startsWith('0')) {
        return "${numericOnly[0]}.${numericOnly.substring(1)}"; // 070 -> 0.70
      }

      // Với các số khác (như 123, 680), cũng định dạng thành X.YZ
      return "${numericOnly[0]}.${numericOnly.substring(1)}"; // 680 -> 6.80
    }

    // Trường hợp 4 chữ số: WXYZ -> WX.YZ
    if (numericOnly.length == 4) {
      // Nếu bắt đầu với 00 (như 0070), định dạng thành 0.70
      if (numericOnly.startsWith("00")) {
        return "0.${numericOnly.substring(2)}";
      }
      // Các trường hợp khác (như 1234), định dạng thành 12.34
      return "${numericOnly.substring(0, 2)}.${numericOnly.substring(2)}";
    }

    // Trường hợp 2 chữ số: XY -> X.Y0
    if (numericOnly.length == 2) {
      return "${numericOnly[0]}.${numericOnly[1]}0"; // 56 -> 5.60
    }

    // Trường hợp 1 chữ số: X -> X.00
    if (numericOnly.length == 1) {
      return "$numericOnly.00";
    }
    // TRƯỜNG HỢP 8: Xử lý trường hợp số có prefix phổ biến 884, 88, 8, 88888 + số cân thực
    if (numericOnly.length >= 5) {
      // Kiểm tra các tiền tố phổ biến
      if (numericOnly.startsWith('884') ||
          numericOnly.startsWith('88') ||
          numericOnly.startsWith('8888') ||
          numericOnly.startsWith('888')) {
        // Xử lý tách số cân từ 884XXX, 88XXX, 8888XXX, 888XXX
        String realValue = "";
        if (numericOnly.startsWith('884') && numericOnly.length >= 5) {
          realValue = numericOnly.substring(3); // Bỏ qua "884"
        } else if (numericOnly.startsWith('8888') && numericOnly.length >= 6) {
          realValue = numericOnly.substring(4); // Bỏ qua "8888"
        } else if (numericOnly.startsWith('888') && numericOnly.length >= 5) {
          realValue = numericOnly.substring(3); // Bỏ qua "888"
        } else if (numericOnly.startsWith('88') && numericOnly.length >= 4) {
          realValue = numericOnly.substring(2); // Bỏ qua "88"
        }

        // Nếu phần còn lại có 3 chữ số, định dạng thành X.XX
        if (realValue.length == 3) {
          return "${realValue[0]}.${realValue.substring(1)}";
        }
        // Nếu phần còn lại có 4 chữ số, định dạng thành XX.XX
        else if (realValue.length == 4) {
          return "${realValue.substring(0, 2)}.${realValue.substring(2)}";
        }
        // Các trường hợp khác, thử áp dụng logic dựa vào độ dài
        else if (realValue.length > 0) {
          return _formatNumericWeight(realValue);
        }
      }
    }

    // TRƯỜNG HỢP MỚI: Xử lý số 3 chữ số có thể là X.XX (như 680 -> 6.80)
    if (numericOnly.length == 3) {
      // Kiểm tra giá trị - nếu nhỏ hơn 100, có thể là một số nguyên
      // Nếu >= 100, có thể đó là giá trị thập phân X.XX
      int value = int.tryParse(numericOnly) ?? 0;
      if (value < 10 || (value >= 100 && value < 1000)) {
        return "${numericOnly[0]}.${numericOnly.substring(1)}";
      } else {
        return "$numericOnly.00";
      }
    }

    // TRƯỜNG HỢP 1: Xử lý các giá trị như 888.00, 88.50, 000.00
    RegExp repeatingDigitsPattern = RegExp(r'([8]{3}|[0]{3}|[9]{3})\.(\d{2})');
    Match? repeatingMatch = repeatingDigitsPattern.firstMatch(text);
    if (repeatingMatch != null) {
      // Kiểm tra nếu giá trị sau dấu chấm khác 0, thì đây có thể là giá trị thực
      String decimalPart = repeatingMatch.group(2) ?? "00";
      if (decimalPart != "00") {
        return repeatingMatch.group(0) ?? "";
      }
      // Nếu cả phần nguyên và phần thập phân đều là các số lặp lại (888.00),
      // đây có thể là giá trị thực, nên vẫn trả về
      return repeatingMatch.group(0) ?? "";
    }

    // TRƯỜNG HỢP 2: Chuỗi có dạng 888XXX - phân đoạn segment (888) + giá trị thực (XXX)
    if (numericOnly.length >= 6) {
      // Kiểm tra nếu có mẫu segment phổ biến ở đầu (888, 8888, 000, 0000, 999)
      RegExp segmentPattern =
          RegExp(r'(888|000|999|8{3,4}|0{3,4}|9{3,4})(\d+)');
      Match? segMatch = segmentPattern.firstMatch(numericOnly);

      if (segMatch != null && segMatch.groupCount >= 2) {
        String realValue = segMatch.group(2) ?? "";
        if (realValue.isNotEmpty) {
          // Nếu giá trị thực là 3-4 chữ số, định dạng thành X.XX hoặc XX.XX
          if (realValue.length == 3) {
            return "${realValue[0]}.${realValue.substring(1)}";
          } else if (realValue.length == 4) {
            return "${realValue.substring(0, 2)}.${realValue.substring(2)}";
          } else if (realValue.length >= 5) {
            // Xử lý trường hợp có thêm ký tự thừa (như 67001 cho 6.70)
            return "${realValue.substring(0, realValue.length - 4)}.${realValue.substring(realValue.length - 4, realValue.length - 2)}";
          }
          return realValue;
        }
      }
    }

    // TRƯỜNG HỢP 3: Nếu có 3-4 chữ số cuối giống nhau (segment), chỉ lấy phần đầu
    if (numericOnly.length >= 5) {
      String lastDigits = numericOnly.substring(numericOnly.length - 4);
      if (RegExp(r'(.)\1{3}').hasMatch(lastDigits)) {
        // 4 chữ số cuối giống nhau
        String value = numericOnly.substring(0, numericOnly.length - 4);
        if (value.length >= 3) {
          return _formatNumericWeight(value);
        }
      }

      // Kiểm tra 3 chữ số cuối
      lastDigits = numericOnly.substring(numericOnly.length - 3);
      if (RegExp(r'(.)\1{2}').hasMatch(lastDigits)) {
        // 3 chữ số cuối giống nhau
        String value = numericOnly.substring(0, numericOnly.length - 3);
        if (value.length >= 3) {
          return _formatNumericWeight(value);
        }
      }
    }

    // TRƯỜNG HỢP 4: Xử lý các mẫu cụ thể từ các loại cân phổ biến
    // 388XXXX -> trích xuất X.XX
    RegExp specificPattern = RegExp(r'388(\d)(\d)(\d)');
    Match? specificMatch = specificPattern.firstMatch(numericOnly);
    if (specificMatch != null && specificMatch.groupCount >= 3) {
      return "${specificMatch.group(1)}.${specificMatch.group(2)}${specificMatch.group(3)}";
    }

    // Mẫu NET XX.XX kg hoặc NET X.XX kg
    RegExp netPattern =
        RegExp(r'NET\s*(\d{1,2})\.(\d{2})', caseSensitive: false);
    Match? netMatch = netPattern.firstMatch(text);
    if (netMatch != null) {
      return netMatch
              .group(0)
              ?.replaceAll(RegExp(r'NET\s*', caseSensitive: false), '') ??
          "";
    }

    // TRƯỜNG HỢP 5: Xử lý trường hợp đặc biệt: 00X.YZ hoặc 0XX.YZ (00 hoặc 0 là phần thừa)
    if (numericOnly.startsWith('00') && numericOnly.length >= 5) {
      return numericOnly.substring(2);
    } else if (numericOnly.startsWith('0') &&
        numericOnly.length >= 4 &&
        !numericOnly.startsWith('0.')) {
      return numericOnly.substring(1);
    }

    // TRƯỜNG HỢP 6: Nếu là chuỗi quá dài, dùng heuristic để tìm giá trị giữa
    if (numericOnly.length >= 7) {
      // Tìm X.YZ ở giữa chuỗi
      int midStart = (numericOnly.length ~/ 2) - 1;
      String midSection = numericOnly.substring(midStart, midStart + 3);
      if (midSection.length == 3) {
        return "${midSection[0]}.${midSection.substring(1)}";
      }
    }

    // TRƯỜNG HỢP 9: Xử lý các trường hợp đặc biệt có tiền tố từ các loại cân phổ biến
    if (numericOnly.length >= 5) {
      // Kiểm tra các số có tiền tố đặc biệt + 3 chữ số cuối
      final lastThreeDigits = numericOnly.substring(numericOnly.length - 3);
      int lastThreeValue = int.tryParse(lastThreeDigits) ?? 0;

      // Nếu 3 chữ số cuối nằm trong khoảng 100-999, có thể là X.YY
      if (lastThreeValue >= 100 && lastThreeValue < 1000) {
        return "${lastThreeDigits[0]}.${lastThreeDigits.substring(1)}";
      }
    }

    // TRƯỜNG HỢP 7: Xử lý chuỗi ngắn phổ biến
    // Xử lý trường hợp 2-3 chữ số có thể là X.X, X.XX, XX.X, XX.XX
    if (numericOnly.length == 2) {
      int value = int.tryParse(numericOnly) ?? 0;
      if (value < 10) {
        return "$numericOnly.00";
      } else {
        return "${numericOnly[0]}.${numericOnly[1]}0"; // Ví dụ: 56 -> 5.60
      }
    } else if (numericOnly.length == 3) {
      int value = int.tryParse(numericOnly) ?? 0;
      if (value < 10) {
        return "$numericOnly.00";
      } else if (value >= 100 && value < 1000) {
        return "${numericOnly[0]}.${numericOnly.substring(1)}"; // Ví dụ: 680 -> 6.80
      } else {
        return "${numericOnly.substring(0, 2)}.${numericOnly[2]}0"; // Ví dụ: 856 -> 85.60
      }
    } else if (numericOnly.length == 4) {
      int value = int.tryParse(numericOnly) ?? 0;
      if (value < 100) {
        return "${numericOnly.substring(0, 2)}.${numericOnly.substring(2)}"; // Ví dụ: 0680 -> 06.80
      } else if (value >= 1000) {
        return "${numericOnly.substring(0, 2)}.${numericOnly.substring(2)}"; // Ví dụ: 1750 -> 17.50
      } else {
        return "${numericOnly.substring(0, 2)}.${numericOnly.substring(2)}";
      }
    } else if (numericOnly.length == 6) {
      // Trường hợp đặc biệt cho số 6 chữ số - lấy 3 chữ số cuối và định dạng X.XX
      String lastThree = numericOnly.substring(numericOnly.length - 3);
      if (int.tryParse(lastThree) != null) {
        return "${lastThree[0]}.${lastThree.substring(1)}";
      }
    }

    // Cuối cùng, dùng định dạng mặc định dựa trên độ dài
    return _formatNumericWeight(numericOnly);
  }

  String _formatNumericWeight(String numericText) {
    if (numericText.isEmpty) return "0.00";

    // Nếu đã có dấu chấm và ít nhất 2 chữ số sau dấu chấm, giữ nguyên
    if (numericText.contains('.')) {
      RegExp decimalPattern = RegExp(r'(\d+)\.(\d{2,})');
      Match? match = decimalPattern.firstMatch(numericText);
      if (match != null) {
        String wholePart = match.group(1) ?? "";
        String decimalPart = match.group(2) ?? "";
        // Đảm bảo phần thập phân chỉ có 2 chữ số
        if (decimalPart.length > 2) {
          decimalPart = decimalPart.substring(0, 2);
        }
        return "$wholePart.$decimalPart";
      }

      // Trường hợp thiếu chữ số thập phân
      RegExp shortDecimalPattern = RegExp(r'(\d+)\.(\d?)');
      Match? shortMatch = shortDecimalPattern.firstMatch(numericText);
      if (shortMatch != null) {
        String wholePart = shortMatch.group(1) ?? "";
        String decimalPart = shortMatch.group(2) ?? "";
        // Thêm 0 nếu cần để có 2 chữ số sau dấu chấm
        if (decimalPart.isEmpty) {
          decimalPart = "00";
        } else if (decimalPart.length == 1) {
          decimalPart = decimalPart + "0";
        }
        return "$wholePart.$decimalPart";
      }
    }

    switch (numericText.length) {
      case 0:
        return "";
      case 1:
        return "$numericText.00"; // 1 chữ số: 1 -> 1.00
      case 2:
        int value = int.tryParse(numericText) ?? 0;
        if (value < 10) {
          return "$numericText.00"; // 2 chữ số nhỏ: 01 -> 01.00
        } else {
          return "${numericText[0]}.${numericText[1]}0"; // 2 chữ số: 12 -> 1.20
        }
      case 3:
        int value = int.tryParse(numericText) ?? 0;
        if (value < 10) {
          return "$numericText.00"; // 3 chữ số nhỏ: 001 -> 001.00 (ít xảy ra)
        } else if (value >= 100 && value < 1000) {
          return "${numericText[0]}.${numericText.substring(1)}"; // 680 -> 6.80
        } else {
          return "${numericText.substring(0, 2)}.${numericText[2]}0"; // 85 -> 85.0
        }
      case 4:
        return "${numericText.substring(0, 2)}.${numericText.substring(2)}"; // 1234 -> 12.34
      case 5:
        // Với 5 chữ số, kiểm tra nếu 3 chữ số cuối có thể là một số cân
        String lastThreeDigits = numericText.substring(numericText.length - 3);
        if (int.tryParse(lastThreeDigits) != null &&
            int.parse(lastThreeDigits) >= 100) {
          return "${lastThreeDigits[0]}.${lastThreeDigits.substring(1)}"; // Ví dụ: 88670 -> 6.70
        }
        // Mặc định, làm theo quy tắc chung của cân điện tử
        return "${numericText.substring(0, 3)}.${numericText.substring(3)}"; // 12345 -> 123.45
      case 6:
        // Ưu tiên giải pháp lấy 3 chữ số cuối cho trường hợp 884680 -> 6.80
        String lastThreeDigits = numericText.substring(numericText.length - 3);
        if (int.tryParse(lastThreeDigits) != null &&
            int.parse(lastThreeDigits) >= 100) {
          return "${lastThreeDigits[0]}.${lastThreeDigits.substring(1)}"; // Ví dụ: 884680 -> 6.80
        }

        // Với trường hợp cụ thể như 3886.70
        if (numericText.startsWith('388')) {
          return "${numericText.substring(3, 4)}.${numericText.substring(4, 6)}"; // 388670 -> 6.70
        } else {
          // Các trường hợp khác: kiểm tra mẫu lặp lại ở đầu
          if (numericText.startsWith('000') ||
              numericText.startsWith('888') ||
              numericText.startsWith('999')) {
            return "${numericText.substring(3, 4)}.${numericText.substring(4, 6)}";
          }
          // Mặc định: lấy 3 chữ số đầu + 2 chữ số cuối
          return "${numericText.substring(0, 3)}.${numericText.substring(4, 6)}";
        }
      case 7:
        // Ưu tiên lấy 3 chữ số cuối nếu có thể là số cân
        String lastThreeDigits = numericText.substring(numericText.length - 3);
        if (int.tryParse(lastThreeDigits) != null &&
            int.parse(lastThreeDigits) >= 100) {
          return "${lastThreeDigits[0]}.${lastThreeDigits.substring(1)}"; // Ví dụ: 8884680 -> 6.80
        }

        // Với trường hợp đặc biệt như 3886701
        if (numericText.startsWith('388')) {
          return "${numericText.substring(3, 4)}.${numericText.substring(4, 6)}"; // 3886701 -> 6.70
        } else {
          // Các trường hợp khác, xem xét các mẫu phổ biến ở đầu
          if (numericText.startsWith('000') ||
              numericText.startsWith('888') ||
              numericText.startsWith('999')) {
            return "${numericText.substring(3, 5)}.${numericText.substring(5, 7)}";
          }
          // Mặc định: cố gắng trích xuất từ giữa
          int mid = numericText.length ~/ 2 - 1;
          return "${numericText.substring(mid, mid + 1)}.${numericText.substring(mid + 1, mid + 3)}";
        }
      default:
        // Ưu tiên lấy 3 chữ số cuối cho tất cả các trường hợp dài khác
        String lastThreeDigits = numericText.substring(numericText.length - 3);
        if (int.tryParse(lastThreeDigits) != null &&
            int.parse(lastThreeDigits) >= 100) {
          return "${lastThreeDigits[0]}.${lastThreeDigits.substring(1)}"; // Ví dụ: 12884680 -> 6.80
        }

        // Trường hợp khác, thử lấy 1 chữ số + 2 chữ số từ giữa
        int mid = numericText.length ~/ 2 - 1;
        return "${numericText.substring(mid, mid + 1)}.${numericText.substring(mid + 1, mid + 3)}";
    }
  }

  // Làm sạch văn bản OCR
  String _cleanupOcrText(String text, bool preserveDecimal) {
    // Kiểm tra nhanh cho độ dài văn bản
    if (text.isEmpty) return '';

    // Cache kết quả kiểm tra cân CAS để tránh kiểm tra nhiều lần
    final bool isCasScale = text.contains('CAS') || text.contains('cas');

    // Xử lý nhanh cho chuỗi ngắn
    if (text.length < 20) {
      // Thay thế các ký tự thông dụng bằng một lần thay thế
      String cleaned = text
          .replaceAll(_zeroCharsRegex, '0')
          .replaceAll(_oneCharsRegex, '1')
          .replaceAll('S', '5')
          .replaceAll('L', '7')
          .replaceAll('Z', '2')
          .replaceAll('z', '2')
          .replaceAll('G', '6')
          .replaceAll('A', '4')
          .replaceAll('s', '5');

      // Xử lý đơn vị đo đặc biệt
      cleaned = cleaned
          .replaceAll('CM', 'g')
          .replaceAll('cm', 'g')
          .replaceAll(' C ', ' g ');
      return cleaned.trim();
    }

    // Xử lý cho chuỗi dài bằng cách nhóm các thay thế lại
    String cleaned = text;

    // Thực hiện các thay thế bằng regex đã cache
    cleaned = cleaned.replaceAll(_zeroCharsRegex, '0');
    cleaned = cleaned.replaceAll(_oneCharsRegex, '1');

    // Thực hiện các thay thế phổ biến khác
    cleaned = cleaned
        .replaceAll('S', '5')
        .replaceAll('s', '5')
        .replaceAll('&', '8')
        .replaceAll('D', '0')
        .replaceAll('B', '8')
        .replaceAll('L', '7')
        .replaceAll('P', '2')
        .replaceAll('Z', '2')
        .replaceAll('z', '2')
        .replaceAll('G', '6')
        .replaceAll('A', '4');

    // Xử lý các lỗi nhận dạng trên cân điện tử
    cleaned = cleaned
        .replaceAll('CM', 'g')
        .replaceAll('cm', 'g')
        .replaceAll(' C ', ' g ');

    // Xử lý trường hợp đặc biệt cho cân CAS
    if (isCasScale) {
      cleaned = cleaned
          .replaceAll('OANG', '0500')
          .replaceAll('04NG', '0500')
          .replaceAll('a500', '0500');
    }

    // Loại bỏ khoảng trắng thừa bằng regex đã cache
    cleaned = cleaned.replaceAll(_multipleSpacesRegex, ' ').trim();

    return cleaned;
  }

// Tiền biên dịch các regex để tăng hiệu suất
  final RegExp _numbersRegex = RegExp(r'\d+\.?\d*');

// Hàm mới để định dạng số cân
  String formatWeight(String input) {
    // Chỉ giữ lại các ký tự số và dấu chấm
    final String cleaned = input.replaceAll(RegExp(r'[^\d.]'), '');

    if (cleaned.isEmpty) return "0";
    if (cleaned.contains('.')) return cleaned;

    final int length = cleaned.length;

    // Sử dụng cách tiếp cận đơn giản hơn cho phổ biến các trường hợp
    if (length <= 3) return cleaned;
    if (length == 4) {
      return "${cleaned.substring(0, 3)}.${cleaned.substring(3)}";
    }
    if (length == 5) {
      return "${cleaned.substring(0, 3)}.${cleaned.substring(3)}";
    }

    // Mặc định
    return "${cleaned.substring(0, length - 2)}.${cleaned.substring(length - 2)}";
  }

  @override
  void dispose() {
    controller.dispose();
    _cameraController?.dispose();
    _textRecognizer.close();
    _cleanupAllProcesses();
    _interpreter?.close();
    _adjustmentTimer?.cancel();
    _dimensionTimer?.cancel();
    _processingOperation?.cancel();
    overlayEntry?.remove();
    _dimensionOverlayEntry?.remove();
    codeTextController.dispose();
    super.dispose();
  }
}

class Item {
  String name;
  String quantity;
  Item({required this.name, required this.quantity});
}

// Future<String> _processImage(String imagePath) async {
//   final ReceivePort receivePort = ReceivePort();
//   await Isolate.spawn(
//       _imageProcessingIsolate, [imagePath, receivePort.sendPort]);
//   return await receivePort.first;
// }

void _imageProcessingIsolate(List<dynamic> args) {
  String imagePath = args[0];
  SendPort sendPort = args[1];

  // 1. Use try-catch for better error handling
  try {
    final File imageFile = File(imagePath);
    final Uint8List imageBytes = imageFile.readAsBytesSync();

    // 2. Check file size first and avoid processing very large images
    if (imageBytes.length > 10 * 1024 * 1024) {
      // 10MB limit
      // Downsample larger files first before full processing
      img.Image? tempImage = img.decodeImage(imageBytes);
      if (tempImage != null &&
          (tempImage.width > 1000 || tempImage.height > 1000)) {
        double scale = 1000 / math.max(tempImage.width, tempImage.height);
        tempImage = img.copyResize(tempImage,
            width: (tempImage.width * scale).toInt(),
            height: (tempImage.height * scale).toInt(),
            interpolation:
                img.Interpolation.nearest); // 3. Use nearest for speed
        Uint8List downsampledBytes = img.encodePng(tempImage, level: 0);
        tempImage = null; // Free memory
        tempImage = img.decodeImage(downsampledBytes);
      }
    }

    // 4. Use more efficient decoding options
    final img.Image? originalImage =
        img.decodeImage(imageBytes); // Only decode what we need

    if (originalImage == null) {
      sendPort.send(imagePath);
      return;
    }

    // 5. More aggressive downsizing for processing speed
    double resizeFactor = originalImage.width > 1000 ? 0.2 : 0.3;

    // 6. Use more efficient resize method
    img.Image resizedImage = img.copyResize(originalImage,
        width: (originalImage.width * resizeFactor).toInt(),
        height: (originalImage.height * resizeFactor).toInt(),
        interpolation: img.Interpolation.nearest // Faster than linear
        );

    // 7. Release original image memory
    // originalImage = null; // Free memory - uncommenting causes compile error but is a good practice

    // 8. Combine operations where possible
    img.Image processedImage =
        img.adjustColor(img.grayscale(resizedImage), contrast: 90.0);

    // 9. Release resized image memory
    // resizedImage = null; // Free memory

    // 10. Lower blur radius for speed if results are acceptable
    processedImage = img.gaussianBlur(processedImage, radius: 3);
    processedImage = img.invert(processedImage);

    // 11. Use memory efficiently by not creating new variables

    // 12. Use faster PNG compression
    final Directory tempDir = Directory.systemTemp;
    final String processedPath =
        '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.png';
    final File processedFile = File(processedPath);

    // 13. Use level 0 compression (fastest)
    processedFile.writeAsBytesSync(img.encodePng(processedImage, level: 0));

    sendPort.send(processedPath);
  } catch (e) {
    print('Error processing image: $e');
    sendPort.send(imagePath); // Return original path on error
  }
}

String _imageProcessingLight(String imagePath) {
  try {
    final File imageFile = File(imagePath);
    final Uint8List imageBytes = imageFile.readAsBytesSync();

    // Đọc ảnh với kích thước giảm
    final img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) return imagePath;

    // Resize thấp hơn và chỉ áp dụng các bộ lọc quan trọng nhất
    double resizeFactor = 0.2; // Giảm kích thước nhiều hơn
    img.Image processedImage = img.copyResize(originalImage,
        width: (originalImage.width * resizeFactor).toInt(),
        height: (originalImage.height * resizeFactor).toInt(),
        interpolation: img.Interpolation.nearest);

    // Chỉ áp dụng grayscale và tăng độ tương phản
    processedImage =
        img.adjustColor(img.grayscale(processedImage), contrast: 100.0);

    // Lưu với định dạng JPG thay vì PNG cho tốc độ
    final Directory tempDir = Directory.systemTemp;
    final String processedPath =
        '${tempDir.path}/proc_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File processedFile = File(processedPath);
    processedFile.writeAsBytesSync(img.encodeJpg(processedImage, quality: 100));

    // Xóa ảnh gốc sau khi xử lý
    try {
      if (imagePath != processedPath) {
        imageFile.deleteSync();
      }
    } catch (e) {
      print('Error deleting original image: $e');
    }

    return processedPath;
  } catch (e) {
    print('Error in light processing: $e');
    return imagePath;
  }
}
