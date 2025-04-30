import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:scan_barcode_app/bloc/mawb/list_mawb_bloc.dart';
import 'package:scan_barcode_app/bloc/mawb/list_mawb_event.dart';
import 'package:scan_barcode_app/bloc/mawb/list_mawb_state.dart';
import 'package:scan_barcode_app/bloc/scan/scan_code/details_bag_code/details_bag_code_bloc.dart';
import 'package:scan_barcode_app/bloc/scan/scan_code/scan_bag_code/scan_bag_code_bloc.dart';
import 'package:scan_barcode_app/bloc/scan/scan_code/scan_code_export/scan_code_export_bloc.dart';
import 'package:scan_barcode_app/data/models/mawb/mawb.dart';
import 'package:scan_barcode_app/data/models/scan_code/list_mawb_model.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dropdown/mawb_dropdown.dart';
import 'package:scan_barcode_app/ui/widgets/scan_screen/result_scan_bagCode_widget.dart';
import 'package:scan_barcode_app/ui/widgets/scan_screen/scan_error_widget.dart';
import 'package:scan_barcode_app/ui/widgets/scan_screen/scan_overlay.dart';

import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class ScanBagCodeExportScreenWithController extends StatefulWidget {
  final String titleScrenn;

  const ScanBagCodeExportScreenWithController(
      {super.key, required this.titleScrenn});

  @override
  // ignore: library_private_types_in_public_api
  _ScanBagCodeExportScreenWithControllerState createState() =>
      _ScanBagCodeExportScreenWithControllerState();
}

class _ScanBagCodeExportScreenWithControllerState
    extends State<ScanBagCodeExportScreenWithController>
    with WidgetsBindingObserver {
  BarcodeCapture? barcode;

  MobileScannerController? controller;
  final codeTextController = TextEditingController();
  final codeMAWBTextController = TextEditingController();
  List<ShipmentsTracktry>? shipmentTracktry;
  bool isTorchOn = false;
  String currentCode = '';
  String latestScannedCode = '';
  String? bagCodeResponse;
  CameraFacing cameraFacing = CameraFacing.back;
  bool isBottomSheetOpen = false;
  Widget? currentBottomSheet;
  final ImagePicker picker = ImagePicker();
  List<File> selectedImages = [];
  String? selectedImageString;
  int? smTracktryIDParam;
  String? selectedAwbCode;
  List<ShipmentTracktry> shipments = [];
  int? selectedSmTracktryId;
  ShipmentTracktry? selectedShipment;
  bool isScanExport = false;
  int? selectedImageIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    context
        .read<MAWBListBloc>()
        .add(const FetchMAWBList(keywords: null, trackingStatus: null));
  }

  void _initializeCamera() {
    controller = MobileScannerController(
      torchEnabled: false,
      detectionTimeoutMs: 500,
    );
    controller?.start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    codeTextController.dispose();
    codeMAWBTextController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    } else if (state == AppLifecycleState.paused) {
      controller?.stop();
    }
  }

  // Cập nhật hàm deleteImage để xóa một ảnh cụ thể
  Future<void> deleteImage(int index) async {
    if (index >= 0 && index < selectedImages.length) {
      setState(() {
        selectedImages.removeAt(index);
      });
    }
  }

  // Cập nhật hàm pickImage để chọn nhiều ảnh
  Future<void> pickImage() async {
    final List<XFile>? returnedImages = await ImagePicker().pickMultiImage();
    if (returnedImages == null) return;
    setState(() {
      selectedImages.addAll(returnedImages.map((image) => File(image.path)));
    });
  }

  // Cập nhật hàm captureImage
  Future<void> captureMultipleImages() async {
    List<File> tempImages = [];

    for (int i = 0; i < 5; i++) {
      // Chụp tối đa 5 ảnh (có thể thay đổi)
      final XFile? capturedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (capturedImage != null) {
        tempImages.add(File(capturedImage.path));
      } else {
        break; // Dừng khi người dùng hủy
      }
    }

    setState(() {
      selectedImages.addAll(tempImages);
    });
  }

  void clearImages() {
    setState(() {
      selectedImages.clear();
      selectedImageString = null;
      selectedImageIndex = null;
    });
  }

  void scanAgain() {
    clearImages();
    Navigator.pop(context);
    isBottomSheetOpen = false;
    currentCode = '';
  }

  void onScanBagCode({
    required BuildContext context,
    required String bagCode,
    required int smTracktryID,
    required bool isscanexport,
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
      isScanExport = isscanexport;
    });
    Navigator.pop(context);
    context.read<ScanBagCodeBloc>().add(
          HanldeScanBagCode(
            bagCode: bagCode,
            smTracktryID: selectedSmTracktryId!,
          ),
        );
  }

  void onScanGetDetailsBagCode({
    required BuildContext context,
    required String bagCode,
    required int smTracktryID,
    required String code,
    required bool isscanexport,
  }) {
    setState(() {
      smTracktryIDParam = smTracktryID;
      isScanExport = isscanexport;
    });
    Navigator.pop(context);
    context.read<DetailsBagCodeBloc>().add(
          HanldeDetailsBagCode(
              bagCode: bagCode,
              smTracktryID: smTracktryID,
              code: code,
              status: 2),
        );
  }

  void vibrateScan() {
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.vibrate();
    }
  }

  Future<void> onUpdateExportScan({
    required BuildContext context,
    required String bagCode,
    required String packageImage,
    required int smTracktryID,
    required String code,
  }) async {
    Navigator.pop(context);
    context.read<ScanExportBloc>().add(
          HanldeScanCodeExport(
              code: code,
              bagCode: bagCode,
              smTracktryID: smTracktryID,
              packageImage: packageImage),
        );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isBottomSheetOpen) {
          setState(() {
            selectedImages = [];
            selectedImageString = null;
            selectedImageIndex = null;
          });
        }
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
                  controller?.toggleTorch();
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
                  controller?.switchCamera();
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
                    clearImages();
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
                        text: "Tiếp tục quét mã xuất hàng",
                        color: Colors.white),
                    position: MotionToastPosition.top,
                    animationType: AnimationType.fromTop,
                  ).show(context);
                } else if (state is ScanBagCodeStateFailure) {
                  setState(() {
                    isScanExport = false;
                  });
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
                  setState(() {
                    currentCode = '';
                    isBottomSheetOpen = false;
                  });
                  controller?.start();
                }
              }),
              BlocListener<ScanExportBloc, ScanCodeExportState>(
                  listener: (context, state) {
                if (state is ScanCodeExportStateSuccess) {
                  MotionToast(
                    primaryColor: Colors.green,
                    secondaryColor: Theme.of(context).colorScheme.primary,
                    icon: Icons.check_circle,
                    title: TextApp(
                      text: "Thành công",
                      color: Colors.white,
                    ),
                    description:
                        TextApp(text: "${state.message}", color: Colors.white),
                    position: MotionToastPosition.top,
                    animationType: AnimationType.fromTop,
                  ).show(context);
                } else if (state is ScanCodeExportStateFailure) {
                  MotionToast(
                    primaryColor: Colors.black,
                    secondaryColor: Colors.red,
                    icon: Icons.check_circle,
                    title: TextApp(text: "Thất bại", color: Colors.white),
                    description:
                        TextApp(text: "${state.message}", color: Colors.white),
                    position: MotionToastPosition.top,
                    animationType: AnimationType.fromTop,
                  ).show(context);
                }
              }),
              BlocListener<DetailsBagCodeBloc, DetailsBagCodeState>(
                listener: (context, state) {
                  if (state is DetailsBagCodeStateSuccess) {
                    showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15.r),
                          topLeft: Radius.circular(15.r),
                        ),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return StatefulBuilder(builder:
                            (BuildContext context, StateSetter setModalState) {
                          return DraggableScrollableSheet(
                            maxChildSize: 0.8,
                            expand: false,
                            builder: (BuildContext context,
                                ScrollController scrollController) {
                              return Container(
                                color: Colors.white,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 50.w,
                                      height: 5.h,
                                      margin: EdgeInsets.only(
                                          top: 15.w, bottom: 15.w),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Container(
                                      width: 1.sw,
                                      padding: EdgeInsets.all(15.w),
                                      child: TextApp(
                                        text: "Cập nhật package",
                                        color: Colors.black,
                                        fontsize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Divider(),
                                    Expanded(
                                      child: ListView(
                                        padding: EdgeInsets.all(15.w),
                                        controller: scrollController,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: SizedBox(
                                              child: TextApp(
                                                text:
                                                    "Count Scan: ${state.scanDetailsBagCodeModel.data.count_scan}",
                                                fontsize: 18.sp,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Row(
                                            children: [
                                              TextApp(
                                                text: "Package: ",
                                                color: Colors.black,
                                                fontsize: 20.sp,
                                              ),
                                              TextApp(
                                                text: state
                                                    .scanDetailsBagCodeModel
                                                    .data
                                                    .packageCode,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontsize: 20.sp,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Row(
                                            children: [
                                              TextApp(
                                                text: "Bag code: ",
                                                color: Colors.black,
                                                fontsize: 20.sp,
                                              ),
                                              TextApp(
                                                text:
                                                    "${state.scanDetailsBagCodeModel.data.bagCode}",
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontsize: 20.sp,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Container(
                                            width: 1.sw,
                                            child: TextApp(
                                              text: "Thông tin kiện hàng",
                                              color: Colors.black,
                                              fontsize: 20.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Container(
                                            width: 1.sw,
                                            child: TextApp(
                                              text:
                                                  "- Kích thước: ${state.scanDetailsBagCodeModel.data.size}",
                                              color: Colors.black,
                                              fontsize: 18.sp,
                                            ),
                                          ),
                                          Container(
                                            width: 1.sw,
                                            child: TextApp(
                                              text:
                                                  "- Cân nặng: ${state.scanDetailsBagCodeModel.data.weight}",
                                              color: Colors.black,
                                              fontsize: 18.sp,
                                            ),
                                          ),
                                          Container(
                                            width: 1.sw,
                                            child: TextApp(
                                              text:
                                                  "- MAWB xuất hàng: ${state.scanDetailsBagCodeModel.data.awbCode}",
                                              color: Colors.black,
                                              fontsize: 18.sp,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Container(
                                            width: 1.sw,
                                            child: TextApp(
                                              text: "Update hình ảnh kiện hàng",
                                              color: Colors.black,
                                              fontsize: 20.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          selectedImages.isEmpty
                                              ? Container(
                                                  padding: EdgeInsets.all(10.w),
                                                  child: DottedBorder(
                                                    dashPattern: const [
                                                      3,
                                                      1,
                                                      0,
                                                      2
                                                    ],
                                                    color: Colors.black
                                                        .withOpacity(0.6),
                                                    strokeWidth: 1.5,
                                                    padding:
                                                        const EdgeInsets.all(3),
                                                    child: SizedBox(
                                                      width: 1.sw,
                                                      height: 200.h,
                                                      child: Center(
                                                          child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () async {
                                                              await pickImage();
                                                              setModalState(
                                                                  () {});
                                                            },
                                                            child: Container(
                                                                width: 120.w,
                                                                // height: 50.h,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5.r),
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary,
                                                                ),
                                                                child: Padding(
                                                                    padding: EdgeInsets
                                                                        .all(8
                                                                            .w),
                                                                    child: Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .collections,
                                                                          size:
                                                                              24.sp,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              5.w,
                                                                        ),
                                                                        TextApp(
                                                                          fontsize:
                                                                              14.sp,
                                                                          text:
                                                                              "Chọn ảnh",
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ],
                                                                    ))),
                                                          ),
                                                          SizedBox(
                                                            height: 10.h,
                                                          ),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              await captureMultipleImages();
                                                              setModalState(
                                                                  () {});
                                                            },
                                                            child: Container(
                                                                width: 120.w,
                                                                // height: 50.h,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5.r),
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary,
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(8
                                                                              .w),
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .camera,
                                                                        size: 24
                                                                            .sp,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            5.w,
                                                                      ),
                                                                      TextApp(
                                                                        fontsize:
                                                                            14.sp,
                                                                        text:
                                                                            "Chụp ảnh",
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )),
                                                          ),
                                                        ],
                                                      )),
                                                    ),
                                                  ),
                                                )
                                              : Column(
                                                  children: [
                                                    Container(
                                                      height: 250.h,
                                                      child: ListView.builder(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemCount: selectedImages
                                                                .length +
                                                            1, // +1 cho nút thêm ảnh
                                                        itemBuilder:
                                                            (context, index) {
                                                          if (index ==
                                                              selectedImages
                                                                  .length) {
                                                            // Nút thêm ảnh mới
                                                            return Container(
                                                              width: 250.w,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          10.w),
                                                              child:
                                                                  DottedBorder(
                                                                dashPattern: const [
                                                                  3,
                                                                  1,
                                                                  0,
                                                                  2
                                                                ],
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.6),
                                                                strokeWidth:
                                                                    1.5,
                                                                child: Center(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      IconButton(
                                                                        onPressed:
                                                                            () async {
                                                                          await pickImage();
                                                                          setModalState(
                                                                              () {});
                                                                        },
                                                                        icon: Icon(
                                                                            Icons
                                                                                .add_photo_alternate,
                                                                            color:
                                                                                Theme.of(context).colorScheme.primary),
                                                                      ),
                                                                      TextApp(
                                                                        text:
                                                                            "Thêm ảnh",
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .primary,
                                                                        fontsize:
                                                                            14.sp,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                          return Stack(
                                                            children: [
                                                              Container(
                                                                width: 250.w,
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        right: 10
                                                                            .w),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.r),
                                                                  child: Image
                                                                      .file(
                                                                    selectedImages[
                                                                        index],
                                                                    fit: BoxFit
                                                                        .contain,
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                top: 5.w,
                                                                right: 15.w,
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    if (index <
                                                                        selectedImages
                                                                            .length) {
                                                                      deleteImage(
                                                                          index);
                                                                      setModalState(
                                                                          () {});
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 30,
                                                                    height: 30,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              15),
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              0.8),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .close,
                                                                        size: 20
                                                                            .sp,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          ButtonApp(
                                              event: () async {
                                                if (selectedImages.isNotEmpty) {
                                                  List<String> base64Images =
                                                      [];
                                                  for (var image
                                                      in selectedImages) {
                                                    Uint8List imageBytes =
                                                        await image
                                                            .readAsBytes();
                                                    String base64string =
                                                        base64Encode(
                                                            imageBytes);
                                                    base64Images
                                                        .add(base64string);
                                                  }
                                                  selectedImageString = jsonEncode(
                                                      base64Images); // Convert list to JSON string

                                                  await onUpdateExportScan(
                                                      context: context,
                                                      bagCode: state
                                                          .scanDetailsBagCodeModel
                                                          .data
                                                          .bagCode,
                                                      packageImage:
                                                          selectedImageString!,
                                                      smTracktryID:
                                                          smTracktryIDParam!,
                                                      code: state
                                                          .scanDetailsBagCodeModel
                                                          .data
                                                          .packageCode);
                                                } else {
                                                  return MotionToast(
                                                    primaryColor: Colors.black,
                                                    secondaryColor: Colors.red,
                                                    icon: Icons.check_circle,
                                                    title: TextApp(
                                                      text: "Thất bại",
                                                      color: Colors.white,
                                                    ),
                                                    description: TextApp(
                                                        text:
                                                            "Vui lòng cập nhật hình ảnh",
                                                        color: Colors.white),
                                                    position:
                                                        MotionToastPosition.top,
                                                    animationType:
                                                        AnimationType.fromTop,
                                                  ).show(context);
                                                }
                                              },
                                              text: "Cập nhật",
                                              colorText: Colors.white,
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.bold,
                                              outlineColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        });
                      },
                    ).then((_) {
                      setState(() {
                        clearImages();
                      });
                    });
                  } else if (state is DetailsBagCodeStateFailure) {
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
                  }
                },
              )
            ],
            child: Column(
              children: [
                isScanExport == false
                    ? Container(
                        color: Theme.of(context).colorScheme.background,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
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
                  child: BlocBuilder<ScanBagCodeBloc, ScanBagCodeState>(
                    builder: (context, state) {
                      return Stack(
                        children: [
                          if (controller != null)
                            MobileScanner(
                              controller: controller!,
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
                                    currentCode != code) {
                                  setState(() {
                                    currentCode = code;
                                    codeTextController.text = code;
                                  });
                                  vibrateScan();

                                  if (!isBottomSheetOpen) {
                                    isBottomSheetOpen = true;
                                    controller?.stop();
                                    currentBottomSheet =
                                        ResultScanBagCodeWidget(
                                      context: context,
                                      codeTextController: codeTextController,
                                      scanAgain: scanAgain,
                                      confirmBarCode: ({
                                        required BuildContext context,
                                        required String orderPickupID,
                                        required int smTracktryID,
                                      }) {
                                        bagCodeResponse == null
                                            ? onScanBagCode(
                                                context: context,
                                                bagCode:
                                                    codeTextController.text,
                                                smTracktryID:
                                                    selectedSmTracktryId ?? 0,
                                                isscanexport: true)
                                            : onScanGetDetailsBagCode(
                                                context: context,
                                                bagCode: bagCodeResponse!,
                                                smTracktryID:
                                                    selectedSmTracktryId ?? 0,
                                                code: code,
                                                isscanexport: true);
                                      },
                                      onSelectedID: (id) {
                                        Navigator.pop(context,
                                            id); // Pass the selected ID back
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
                                        currentBottomSheet =
                                            ResultScanBagCodeWidget(
                                          context: context,
                                          codeTextController:
                                              codeTextController,
                                          scanAgain: scanAgain,
                                          confirmBarCode: ({
                                            required BuildContext context,
                                            required String orderPickupID,
                                            required int smTracktryID,
                                          }) {
                                            bagCodeResponse == null
                                                ? onScanBagCode(
                                                    context: context,
                                                    bagCode:
                                                        codeTextController.text,
                                                    smTracktryID:
                                                        selectedSmTracktryId ??
                                                            0,
                                                    isscanexport: true)
                                                : onScanGetDetailsBagCode(
                                                    context: context,
                                                    bagCode: bagCodeResponse!,
                                                    smTracktryID:
                                                        selectedSmTracktryId ??
                                                            0,
                                                    code: code,
                                                    isscanexport: true);
                                          },
                                          onSelectedID: (id) {
                                            Navigator.pop(context,
                                                id); // Pass the selected ID back
                                          },
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
                              child: Lottie.asset(
                                  'assets/lottie/scan_animation.json',
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
                ),
              ],
            ),
          )),
    );
  }
}
