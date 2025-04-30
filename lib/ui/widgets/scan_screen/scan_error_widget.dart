import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:url_launcher/url_launcher.dart';

class ScannerErrorWidget extends StatelessWidget {
  const ScannerErrorWidget({super.key, required this.error});

  final MobileScannerException error;

  Future<void> openAppSettings() async {
    const String settingsUrl = 'app-settings:';
    if (await canLaunchUrl(Uri.parse(settingsUrl))) {
      await launchUrl(Uri.parse(settingsUrl));
    } else {
      print('Could not open settings.');
    }
  }

  @override
  Widget build(BuildContext context) {
    String errorMessage;

    switch (error.errorCode) {
      case MobileScannerErrorCode.controllerUninitialized:
        errorMessage = 'Máy ảnh của bạn không hoạt động';
        break;
      case MobileScannerErrorCode.permissionDenied:
        errorMessage =
            'Chưa cấp quyền truy cập máy ảnh cho ứng dụng. \nVui lòng vào phần cài đặt để cấp quyền cho ứng dụng !';

        break;
      default:
        errorMessage = 'Đang đợi cấp quyền sử dụng máy ảnh';
        break;
    }

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Icon(
                Icons.error,
                color: Colors.white,
                size: 30.sp,
              ),
            ),
            TextApp(
              textAlign: TextAlign.center,
              text: errorMessage,
              color: Colors.white,
              isOverFlow: false,
              softWrap: true,
              fontsize: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}
