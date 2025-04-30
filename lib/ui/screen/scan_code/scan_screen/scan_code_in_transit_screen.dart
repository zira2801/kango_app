import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:scan_barcode_app/bloc/mawb/list_mawb_bloc.dart';
import 'package:scan_barcode_app/bloc/mawb/list_mawb_event.dart';
import 'package:scan_barcode_app/bloc/mawb/list_mawb_state.dart';
import 'package:scan_barcode_app/bloc/scan/scan_code/details_bag_code/details_bag_code_bloc.dart';
import 'package:scan_barcode_app/bloc/scan/scan_code/scan_bag_code/scan_bag_code_bloc.dart';
import 'package:scan_barcode_app/bloc/scan/scan_code/scan_code_transit/scan_code_transit_bloc.dart';
import 'package:scan_barcode_app/data/models/mawb/mawb.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/dropdown/mawb_dropdown.dart';
import 'package:scan_barcode_app/ui/widgets/scan_screen/result_scan_bagCode_widget.dart';
import 'package:scan_barcode_app/ui/widgets/scan_screen/result_scan_widget.dart';
import 'package:scan_barcode_app/ui/widgets/scan_screen/scan_error_widget.dart';
import 'package:scan_barcode_app/ui/widgets/scan_screen/scan_overlay.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class ScanCodeInTransitScreenWithController extends StatefulWidget {
  final String titleScreen;

  const ScanCodeInTransitScreenWithController({
    super.key,
    required this.titleScreen,
  });

  @override
  _ScanCodeInTransitScreenWithControllerState createState() =>
      _ScanCodeInTransitScreenWithControllerState();
}

class _ScanCodeInTransitScreenWithControllerState
    extends State<ScanCodeInTransitScreenWithController> {
  late final MobileScannerController controller;
  final TextEditingController codeTextController = TextEditingController();
  bool isTorchOn = false;
  String currentCode = '';
  CameraFacing cameraFacing = CameraFacing.back;
  bool isBottomSheetOpen = false;
  Widget? currentBottomSheet;
  bool isGetDetailsPackageSuccess = false;
  int? selectedSmTracktryId;
  String? bagCodeResponse;
  List<ShipmentTracktry> shipments = [];
  ShipmentTracktry? selectedShipment;
  String? selectedAwbCode;
  int? smTracktryIDParam;
  bool isScanInTransit = false;
  bool hasConfirmed = false;
  bool hasProcessedDetails = false;

  bool isProcessingDetails = false;
  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      torchEnabled: false,
      detectionTimeoutMs: 500,
    );
    controller.start();
    context
        .read<MAWBListBloc>()
        .add(const FetchMAWBList(keywords: null, trackingStatus: null));
  }

  void vibrateScan() {
    HapticFeedback.vibrate();
  }

  void onGetDetailsPackage(
      {required BuildContext context,
      required String bagCode,
      required int smTracktryID,
      required bool isscanintransit,
      required String code}) {
    if (selectedSmTracktryId == null) {
      MotionToast(
        primaryColor: Colors.black,
        secondaryColor: Colors.red,
        icon: Icons.error,
        title: TextApp(text: "Có lỗi xảy ra!", color: Colors.white),
        description: TextApp(text: "Bạn chưa chọn MAWB", color: Colors.white),
        position: MotionToastPosition.top,
        animationType: AnimationType.fromTop,
      ).show(context);
      return;
    }

    // Thêm check này để tránh xử lý trùng lặp
    if (isProcessingDetails) return;

    setState(() {
      smTracktryIDParam = smTracktryID;
      isScanInTransit = isscanintransit;
      isProcessingDetails = true; // Đánh dấu đang xử lý
    });

    Navigator.pop(context); // Đóng bottom sheet hiện tại

    context.read<DetailsBagCodeBloc>().add(
          HanldeDetailsBagCode(
              bagCode: bagCode,
              smTracktryID: smTracktryID,
              code: code,
              status: 5),
        );
  }

  void scanAgain() {
    Navigator.pop(context);
    hasConfirmed = false;
    isBottomSheetOpen = false;
    currentCode = '';
  }

  void onBarcodeDetected(String code) {
    setState(() {
      currentCode = code;
      codeTextController.text = code;
    });
    vibrateScan();
  }

  void onScanBagCode({
    required BuildContext context,
    required String bagCode,
    required int smTracktryID,
    required bool isscanintransit,
  }) {
    if (selectedSmTracktryId == null) {
      MotionToast(
        primaryColor: Colors.black,
        secondaryColor: Colors.red,
        icon: Icons.error,
        title: TextApp(text: "Có lỗi xảy ra!", color: Colors.white),
        description: TextApp(text: "Bạn chưa chọn MAWB", color: Colors.white),
        position: MotionToastPosition.top,
        animationType: AnimationType.fromTop,
      ).show(context);
      return;
    }

    setState(() {
      smTracktryIDParam = smTracktryID;
      isScanInTransit = isscanintransit;
    });
    Navigator.pop(context);
    context.read<ScanBagCodeBloc>().add(
          HanldeScanBagCode(
            bagCode: bagCode,
            smTracktryID: selectedSmTracktryId!,
          ),
        );
  }

  Future<void> onConfirmBarCode({
    required BuildContext context,
    required String bagCode,
    required int smTracktryID,
    required String code,
  }) async {
    setState(() {
      hasConfirmed = true; // Đánh dấu đã confirm
      isBottomSheetOpen = false; // Đặt false trước khi đóng bottom sheet
    });
    Navigator.pop(context);
    context.read<ScanInTransitBloc>().add(
          PerformInTransitScanEvent(
            code: code,
            bagCode: bagCode,
            smTracktryID: smTracktryID,
          ),
        );
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
          widget.titleScreen,
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
          BlocListener<ScanBagCodeBloc, ScanBagCodeState>(
              listener: (context, state) {
            if (state is ScanBagCodeStateSuccess) {
              setState(() {
                bagCodeResponse = state.scanBagCodeModel!.data.bagCode;
                controller.stop();
              });
              MotionToast(
                primaryColor: Colors.green,
                secondaryColor: Theme.of(context).colorScheme.primary,
                icon: Icons.check_circle,
                title: TextApp(
                  text: "Thành công",
                  color: Colors.white,
                ),
                description: TextApp(
                    text: "Tiếp tục quét mã vận chuyển", color: Colors.white),
                position: MotionToastPosition.top,
                animationType: AnimationType.fromTop,
              ).show(context);
              controller.start();
            } else if (state is ScanBagCodeStateFailure) {
              setState(() {
                isScanInTransit = false;
              });
              MotionToast(
                primaryColor: Colors.black,
                secondaryColor: Colors.red,
                icon: Icons.check_circle,
                title: TextApp(text: "Thất bại", color: Colors.white),
                description: TextApp(text: state.message, color: Colors.white),
                position: MotionToastPosition.top,
                animationType: AnimationType.fromTop,
              ).show(context);
              setState(() async {
                currentCode = '';
                isBottomSheetOpen = false;
              });
              controller?.start();
            }
          }),
          BlocListener<ScanInTransitBloc, InTransitScanState>(
            listener: (context, state) {
              if (state is InTransitScanStateSuccess) {
                setState(() {
                  hasConfirmed = false;
                });
                showCustomDialogModal(
                  context: navigatorKey.currentContext!,
                  textDesc: state.message,
                  title: "Thông báo",
                  colorButtonOk: Colors.green,
                  btnOKText: "Xác nhận",
                  typeDialog: "success",
                  eventButtonOKPress: () {
                    controller.start();
                  },
                  isTwoButton: false,
                );
              } else if (state is InTransitScanStateFailure) {
                setState(() {
                  hasConfirmed = false;
                });
                showCustomDialogModal(
                  context: navigatorKey.currentContext!,
                  textDesc: state.message,
                  title: "Thông báo",
                  colorButtonOk: Colors.red,
                  btnOKText: "Xác nhận",
                  typeDialog: "error",
                  eventButtonOKPress: () {
                    controller.start();
                  },
                  isTwoButton: false,
                );
              }
            },
          ),
          BlocListener<DetailsBagCodeBloc, DetailsBagCodeState>(
            listener: (context, state) {
              if (state is DetailsBagCodeStateSuccess) {
                // Show success notification first
                onConfirmBarCode(
                  context: context,
                  bagCode: state.scanDetailsBagCodeModel.data.bagCode,
                  smTracktryID: smTracktryIDParam!,
                  code: state.scanDetailsBagCodeModel.data.packageCode,
                );
              } else if (state is DetailsBagCodeStateFailure) {
                // Existing error handling
                MotionToast(
                  primaryColor: Colors.black,
                  secondaryColor: Colors.red,
                  icon: Icons.check_circle,
                  title: TextApp(text: "Thất bại", color: Colors.white),
                  description:
                      TextApp(text: state.message, color: Colors.white),
                  position: MotionToastPosition.top,
                  animationType: AnimationType.fromTop,
                ).show(context);
                if (isBottomSheetOpen) {
                  Navigator.pop(context);
                }
              }
            },
          )
        ],
        child: Column(
          children: [
            isScanInTransit == false
                ? Container(
                    color: Theme.of(context).colorScheme.background,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: BlocBuilder<MAWBListBloc, MAWBListState>(
                      builder: (context, state) {
                        if (state is MAWBListSuccess) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chọn MAWB',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              CustomMAWBDropdown(
                                value: selectedShipment,
                                items: state.data
                                    .cast<ShipmentTracktry>()
                                    .toList(),
                                onChanged: (ShipmentTracktry? newValue) {
                                  setState(() {
                                    selectedShipment = newValue;
                                    selectedAwbCode = newValue?.awbCode;
                                    selectedSmTracktryId =
                                        newValue?.smTracktryId;
                                  });
                                },
                              ),
                            ],
                          );
                        } else if (state is MAWBListLoading) {
                          return Center(
                            child: SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          );
                        } else if (state is MAWBListFailure) {
                          return Center(
                            child: TextButton.icon(
                              onPressed: () {
                                context.read<MAWBListBloc>().add(
                                      const FetchMAWBList(
                                        keywords: '',
                                        trackingStatus: '',
                                      ),
                                    );
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tải lại'),
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  )
                : Container(),
            Expanded(
              child: Stack(
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
                        final String code =
                            barcode.barcodes.first.rawValue ?? '';

                        if (code.isNotEmpty &&
                            code != '' &&
                            currentCode != code &&
                            !isBottomSheetOpen) {
                          onBarcodeDetected(code);
                          vibrateScan();
                          controller.stop();
                          showBagCodeBottomSheet(code);
                        }
                      }),
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
                    ),
                  ),
                  const ScannerOverlay()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showBagCodeBottomSheet(String code) {
    if (!isBottomSheetOpen) {
      isBottomSheetOpen = true;
      controller?.stop();
      setState(() {
        hasConfirmed = false; // Reset confirmation state
      });
      currentBottomSheet = ResultScanBagCodeWidget(
        context: context,
        codeTextController: codeTextController,
        scanAgain: scanAgain,
        confirmBarCode: ({
          required BuildContext context,
          required String orderPickupID,
          required int smTracktryID,
        }) {
          if (bagCodeResponse == null) {
            onScanBagCode(
                context: context,
                bagCode: codeTextController.text,
                smTracktryID: selectedSmTracktryId ?? 0,
                isscanintransit: true);
          } else {
            // Thay vì gọi onGetDetailsPackage, gọi trực tiếp event
            setState(() {
              hasProcessedDetails = true;
            });
            context.read<DetailsBagCodeBloc>().add(
                  HanldeDetailsBagCode(
                      bagCode: bagCodeResponse!,
                      smTracktryID: selectedSmTracktryId ?? 0,
                      code: code,
                      status: 5),
                );
          }
        },
        onSelectedID: (id) {
          Navigator.pop(context, id); // Pass the selected ID back
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
        controller?.start();
      });
    } else {
      // If bottom sheet is open, update its content with the latest barcode
      if (currentBottomSheet != null) {
        setState(() {
          currentBottomSheet = ResultScanBagCodeWidget(
            context: context,
            codeTextController: codeTextController,
            scanAgain: scanAgain,
            confirmBarCode: ({
              required BuildContext context,
              required String orderPickupID,
              required int smTracktryID,
            }) {
              if (bagCodeResponse == null) {
                onScanBagCode(
                    context: context,
                    bagCode: codeTextController.text,
                    smTracktryID: selectedSmTracktryId ?? 0,
                    isscanintransit: true);
              } else {
                // Thay vì gọi onGetDetailsPackage, gọi trực tiếp event
                context.read<DetailsBagCodeBloc>().add(
                      HanldeDetailsBagCode(
                          bagCode: bagCodeResponse!,
                          smTracktryID: selectedSmTracktryId ?? 0,
                          code: code,
                          status: 5),
                    );

                // Không cần pop bottom sheet ở đây
              }
            },
            onSelectedID: (id) {
              Navigator.pop(context, id); // Pass the selected ID back
            },
          );
        });
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    codeTextController.dispose();
    super.dispose();
  }
}
