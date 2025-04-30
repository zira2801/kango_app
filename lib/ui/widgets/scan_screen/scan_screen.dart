import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';

class BarcodeScannerWithController extends StatefulWidget {
  final String titleScrenn;

  const BarcodeScannerWithController({super.key, required this.titleScrenn});

  @override
  // ignore: library_private_types_in_public_api
  _BarcodeScannerWithControllerState createState() =>
      _BarcodeScannerWithControllerState();
}

class _BarcodeScannerWithControllerState
    extends State<BarcodeScannerWithController> {
  BarcodeCapture? barcode;

  late final MobileScannerController controller;
  final codeTextController = TextEditingController();

  bool isTorchOn = false;
  String currentCode = '';
  String latestScannedCode = '';
  CameraFacing cameraFacing = CameraFacing.back;
  bool isBottomSheetOpen = false;
  Widget? currentBottomSheet;
  // Completer<void>? _bottomSheetCompleter;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      torchEnabled: false,
      // detectionSpeed: DetectionSpeed.noDuplicates,
      detectionTimeoutMs: 500,
    );
    controller.start();
  }

  void scanAgain() {
    Navigator.pop(context);
    isBottomSheetOpen = false;
    currentCode = '';
  }

  Future<void> updateStatusPackage({required String code}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$updateScanStatus'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'code': code,
        'status': 1,
      }),
    );
    final data = jsonDecode(response.body);
    var mess = data['message'];
    try {
      if (data['status'] == 200) {
        showCustomDialogModal(
            context: navigatorKey.currentContext!,
            textDesc: mess['text'],
            title: "Thông báo",
            colorButtonOk: Colors.green,
            btnOKText: "Xác nhận",
            typeDialog: "success",
            eventButtonOKPress: () {},
            isTwoButton: false);
      } else if (data['status'] == 404) {
        showCustomDialogModal(
            context: navigatorKey.currentContext!,
            textDesc: mess['text'],
            title: "Thông báo",
            colorButtonOk: Colors.red,
            btnOKText: "Xác nhận",
            typeDialog: "error",
            eventButtonOKPress: () {},
            isTwoButton: false);
      } else {
        log("ERROR getListBank 1");

        showDialog(
            context: navigatorKey.currentContext!,
            builder: (BuildContext context) {
              return ErrorDialog(
                eventConfirm: () {
                  Navigator.pop(context);
                },
              );
            });
      }
    } catch (error) {
      log("ERROR getListBank $error");
      if (error is http.ClientException) {
        showDialog(
            context: navigatorKey.currentContext!,
            builder: (BuildContext context) {
              return ErrorDialog(
                eventConfirm: () {
                  Navigator.pop(context);
                },
                errorText: "Không thể kết nối đến máy chủ",
              );
            });
      } else {
        showDialog(
            context: navigatorKey.currentContext!,
            builder: (BuildContext context) {
              return ErrorDialog(
                eventConfirm: () {
                  Navigator.pop(context);
                },
              );
            });
      }
    }
  }

  void confirmBarcode(BuildContext context, String code) {
    Navigator.pop(context);
    updateStatusPackage(code: code);
    // Navigator.pop(context);
    // controller.stop();
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) =>
    //           DetailsScanedCode(barCodeScanned: codeTextController.text)),
    // ).then((_) {
    //   controller.start();
    // });
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          widget.titleScrenn,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
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
              color: Colors.white,
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
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            errorBuilder: (
              BuildContext context,
              MobileScannerException error,
              Widget? child,
            ) {
              return ScannerErrorWidget(error: error);
            },
            fit: BoxFit.fill,
            onDetect: (BarcodeCapture barcode) async {
              final String code = barcode.barcodes.first.rawValue ?? '';

              if (code.isNotEmpty && code != '' && currentCode != code) {
                setState(() {
                  currentCode = code;
                  codeTextController.text = code;
                });
                vibrateScan();
                if (!isBottomSheetOpen) {
                  // If bottom sheet is not open, open a new one with the latest barcode
                  isBottomSheetOpen = true;
                  currentBottomSheet = _buildBottomSheet(
                      context,
                      codeTextController,
                      scanAgain,
                      () => confirmBarcode(context, codeTextController.text));
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
                  });
                } else {
                  // If bottom sheet is open, update its content with the latest barcode
                  if (currentBottomSheet != null) {
                    setState(() {
                      currentBottomSheet = _buildBottomSheet(
                          context,
                          codeTextController,
                          scanAgain,
                          () =>
                              confirmBarcode(context, codeTextController.text));
                    });
                  }
                }

                // isBottomSheetOpen = true;
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
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

Widget _buildBottomSheet(
    BuildContext context,
    TextEditingController codeTextController,
    Function scanAgain,
    Function confirmBarCode) {
  return SingleChildScrollView(
    child: Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 1.sw,
              height: 250.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15.r),
                    topLeft: Radius.circular(15.r)),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    width: 60.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: Colors.grey.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  TextApp(
                    text: "Mã đã quét",
                    fontsize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.w, right: 20.w),
                    child: Center(
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        enabled: false,
                        textAlign: TextAlign.center,
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        controller: codeTextController,
                        decoration: InputDecoration(
                            fillColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.8),
                            filled: true,
                            hintText: '',
                            labelStyle:
                                TextStyle(color: Colors.white, fontSize: 14.sp),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2.0),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2.0),
                              borderRadius: BorderRadius.all(
                                  Radius.elliptical(10.r, 10.r)),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2.0),
                              borderRadius: BorderRadius.all(
                                  Radius.elliptical(10.r, 10.r)),
                            ),
                            contentPadding: EdgeInsets.all(20.w)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.w, right: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ButtonApp(
                            event: () {
                              scanAgain();
                            },
                            text: "Quét lại",
                            colorText: Theme.of(context).colorScheme.primary,
                            backgroundColor: Colors.white,
                            outlineColor: Theme.of(context).colorScheme.primary,
                            line: 2,
                          ),
                        ),
                        SizedBox(
                          width: 25.w,
                        ),
                        Expanded(
                          child: ButtonApp(
                            event: () {
                              confirmBarCode();
                            },
                            text: "Xác nhận",
                            colorText: Theme.of(context).colorScheme.primary,
                            backgroundColor: Colors.white,
                            outlineColor: Theme.of(context).colorScheme.primary,
                            line: 2,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ))
        ],
      ),
    ),
  );
}

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
