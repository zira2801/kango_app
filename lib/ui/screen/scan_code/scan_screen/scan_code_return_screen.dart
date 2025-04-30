import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_barcode_app/bloc/scan/scan_code/scan_code_return/scan_code_return_bloc.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/scan_screen/result_scan_widget.dart';
import 'package:scan_barcode_app/ui/widgets/scan_screen/scan_error_widget.dart';
import 'package:scan_barcode_app/ui/widgets/scan_screen/scan_overlay.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class ScanCodeReturnScreenWithController extends StatefulWidget {
  final String titleScrenn;

  const ScanCodeReturnScreenWithController(
      {super.key, required this.titleScrenn});

  @override
  // ignore: library_private_types_in_public_api
  _ScanCodeReturnScreenWithControllerState createState() =>
      _ScanCodeReturnScreenWithControllerState();
}

class _ScanCodeReturnScreenWithControllerState
    extends State<ScanCodeReturnScreenWithController> {
  BarcodeCapture? barcode;

  late final MobileScannerController controller;
  final codeTextController = TextEditingController();
  final lengthPackageController = TextEditingController();
  final widthPackageController = TextEditingController();
  final heightPackageController = TextEditingController();
  final namePackageController = TextEditingController();
  final quantityPackageController = TextEditingController();

  bool isTorchOn = false;
  String currentCode = '';
  String latestScannedCode = '';
  CameraFacing cameraFacing = CameraFacing.back;
  bool isBottomSheetOpen = false;
  Widget? currentBottomSheet;
  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      torchEnabled: false,
      detectionTimeoutMs: 500,
    );
    controller.start();
  }

  void scanAgain() {
    Navigator.pop(context);
    isBottomSheetOpen = false;
    currentCode = '';
  }

  void onConfirmBarCode(BuildContext context, String orderPickupID) {
    Navigator.pop(context);
    context.read<ScanReturnBloc>().add(
          HanldeScanCodeReturn(
            code: orderPickupID,
          ),
        );
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
            BlocListener<ScanReturnBloc, ScanCodeReturnState>(
                listener: (context, state) {
              if (state is ScanCodeReturnStateSuccess) {
                showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.green,
                    btnOKText: "Xác nhận",
                    typeDialog: "success",
                    eventButtonOKPress: () {},
                    isTwoButton: false);
              } else if (state is ScanCodeReturnStateFailure) {
                showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.red,
                    btnOKText: "Xác nhận",
                    typeDialog: "error",
                    eventButtonOKPress: () {},
                    isTwoButton: false);
              }
            })
          ],
          child: BlocBuilder<ScanReturnBloc, ScanCodeReturnState>(
            builder: (context, state) {
              return Stack(
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

                      if (code.isNotEmpty &&
                          code != '' &&
                          currentCode != code) {
                        setState(() {
                          currentCode = code;
                          codeTextController.text = code;
                        });
                        vibrateScan();
                        if (!isBottomSheetOpen) {
                          // If bottom sheet is not open, open a new one with the latest barcode
                          isBottomSheetOpen = true;
                          controller.stop();
                          currentBottomSheet = ResultScanWidget(
                            context: context,
                            codeTextController: codeTextController,
                            scanAgain: scanAgain,
                            confirmBarCode: () => onConfirmBarCode(
                                context, codeTextController.text),
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
                            controller.start();
                          });
                        } else {
                          // If bottom sheet is open, update its content with the latest barcode
                          if (currentBottomSheet != null) {
                            setState(() {
                              currentBottomSheet = ResultScanWidget(
                                context: context,
                                codeTextController: codeTextController,
                                scanAgain: scanAgain,
                                confirmBarCode: () => onConfirmBarCode(
                                    context, codeTextController.text),
                              );
                            });
                          }
                        }
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
        ));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class Item {
  String name;
  String quantity;
  Item({required this.name, required this.quantity});
}
