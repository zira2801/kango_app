import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:scan_barcode_app/data/models/shipment/details_shipment.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/shipment/custom_container_package_infor.dart';
import 'package:scan_barcode_app/ui/screen/shipment/edit_additional_costs.dart';
import 'package:scan_barcode_app/ui/screen/shipment/edit_company_operating_costs.dart';
import 'package:scan_barcode_app/ui/screen/shipment/package_manager_screen.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/button/status_box.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';

import '../../../data/models/method_pay_character.dart/method_pay_character.dart';

// ignore: must_be_immutable
class PackageInfoWidgetTab1 extends StatefulWidget {
  final ScrollController scrollController;
  final DetailsShipmentModel? detailsShipment;
  final String shipmentCode;
  String? selectedPDFLabelString;
  String? selectedPDFPaymentProofString;
  String? selectedImageFile;
  File? selectedImage;
  List<File> selectedImages = [];
  List<File> selectedPDFLabelFiles = [];
  List<String>? selectedPDFLabelProofStrings = [];
  List<File> selectedPDFLabelProoflFiles = [];
  List<File> selectedPDFPaymentProoflFiles = [];
  List<String> selectedPDFPaymentProofStrings = [];
  final String? userPosition;
  final bool? canUploadLabel;
  final bool? canUploadPayment;
  MethodPayCharater? methodPay = MethodPayCharater.bank;
  PackageInfoWidgetTab1(
      {required this.shipmentCode,
      required this.scrollController,
      required this.detailsShipment,
      required this.selectedPDFLabelString,
      required this.selectedImage,
      required this.methodPay,
      super.key,
      this.userPosition,
      this.canUploadLabel,
      this.canUploadPayment});

  @override
  State<PackageInfoWidgetTab1> createState() => PackageInfoWidgetTab1State();
}

class PackageInfoWidgetTab1State extends State<PackageInfoWidgetTab1> {
  final urbanMoneyController = TextEditingController();
  final urbanQuantityController = TextEditingController();
  final suburbanMoneyController = TextEditingController();
  final suburanQuantityController = TextEditingController();
  int currentMethodPay = 1;
  FToast fToast = FToast();
  String? localPath;
  bool isLoadingCreateLabel = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  _showToast({required String mess, required Color color, required Icon icon}) {
    Widget toast = Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.r),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(
            width: 10.w,
          ),
          TextApp(
            text: mess,
            fontsize: 14.sp,
            color: Colors.white,
          ),
        ],
      ),
    );

    // Custom Toast Position
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
      positionedToastBuilder: (context, child, gravity) {
        return Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 80.h),
                  child: child,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void handleUpdatePaymentProofShipment() async {
    try {
      List<String> fileBase64List = [];
      List<String> fileExtensions = [];

      // Handle image files
      for (File imageFile in widget.selectedImages) {
        try {
          Uint8List imageBytes = await imageFile.readAsBytes();

          // Check file size (5MB limit)
          if (imageBytes.length > 5 * 1024 * 1024) {
            _showToast(
                mess: "Image size must be less than 5MB: ${imageFile.path}",
                color: Colors.red,
                icon: const Icon(Icons.cancel, color: Colors.white));
            continue;
          }

          fileBase64List.add(base64Encode(imageBytes));
          fileExtensions.add('jpg');
        } catch (e) {
          log("Error reading image file: $e");
          _showToast(
              mess: "Error processing image file",
              color: Colors.red,
              icon: const Icon(Icons.cancel, color: Colors.white));
          continue;
        }
      }

      // Handle PDF files
      for (File pdfFile in widget.selectedPDFPaymentProoflFiles) {
        try {
          Uint8List pdfBytes = await pdfFile.readAsBytes();

          // Check file size (5MB limit)
          if (pdfBytes.length > 5 * 1024 * 1024) {
            _showToast(
                mess: "Kích thước file PDF phải ít hơn 5MB: ${pdfFile.path}",
                color: Colors.red,
                icon: const Icon(Icons.cancel, color: Colors.white));
            continue;
          }

          fileBase64List.add(base64Encode(pdfBytes));
          fileExtensions.add('pdf');
        } catch (e) {
          log("Error reading PDF file: $e");
          _showToast(
              mess: "Error processing PDF file",
              color: Colors.red,
              icon: const Icon(Icons.cancel, color: Colors.white));
          continue;
        }
      }

      // Validate files were processed successfully
      if (fileBase64List.isEmpty) {
        log("Không tìm thấy file upload");
      }

      // Prepare request body
      final requestBody = {
        'shipment_code': widget.shipmentCode,
        'file_method': fileBase64List,
        'file_extension': fileExtensions,
        'shipment_payment_method': currentMethodPay,
      };

      // Make API call
      final response = await http.post(
        Uri.parse('$baseUrl$updatePaymentProofShipment'),
        headers: {
          ...ApiUtils.getHeaders(isNeedToken: true),
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);

      // Extract message
      String messRes;
      if (data['message'] is Map) {
        messRes = data['message']['text']?.toString() ?? 'Unknown error';
      } else {
        messRes = data['message']?.toString() ?? 'Unknown error';
      }

      if (data['status'] == 200) {
        _showToast(
            mess: messRes,
            color: Colors.green,
            icon: const Icon(Icons.check, color: Colors.white));
        await Future.delayed(Duration(milliseconds: 500), () {
          Navigator.pop(context);
        });
      } else {
        _showToast(
            mess: messRes,
            color: Colors.red,
            icon: const Icon(Icons.cancel, color: Colors.white));
      }
    } catch (error) {
      log("handleUpdatePaymentProofShipment encountered error: $error");
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

  void handleUpdateLabel(
      {required List<File> selectedPDFFile,
      required String? selectedPDFString}) async {
    List<String> fileBase64List = [];
    List<String> fileExtensions = [];
    if (selectedPDFFile != null) {
      for (File pdfFile in widget.selectedPDFPaymentProoflFiles) {
        try {
          Uint8List pdfBytes = await pdfFile.readAsBytes();

          // Check file size (5MB limit)
          if (pdfBytes.length > 5 * 1024 * 1024) {
            _showToast(
                mess: "Kích thước file PDF phải ít hơn 5MB: ${pdfFile.path}",
                color: Colors.red,
                icon: const Icon(Icons.cancel, color: Colors.white));
            continue;
          }

          fileBase64List.add(base64Encode(pdfBytes));
          fileExtensions.add('pdf');
        } catch (e) {
          log("Error reading PDF file: $e");
          _showToast(
              mess: "Error processing PDF file",
              color: Colors.red,
              icon: const Icon(Icons.cancel, color: Colors.white));
          continue;
        }
      }
    }

    final response = await http.post(
      Uri.parse('$baseUrl$updateLableShipment'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'shipment_code': widget.shipmentCode,
        'file_label': fileBase64List,
      }),
    );
    final data = jsonDecode(response.body);
    var mess = data['message'];
    var messRes = mess['text'];

    try {
      if (data['status'] == 200) {
        log("handleUpdateLabel OKOK");
        _showToast(
            mess: messRes,
            color: Colors.green,
            icon: const Icon(
              Icons.check,
              color: Colors.white,
            ));
        await Future.delayed(Duration(milliseconds: 500), () {
          Navigator.pop(context);
        });
      } else {
        log("handleUpdateLabel ERROR 1: " + messRes);
        _showToast(
            mess: messRes,
            color: Colors.red,
            icon: const Icon(
              Icons.cancel,
              color: Colors.white,
            ));
      }
    } catch (error) {
      log("handleUpdateLabel ERROR $error 2");
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

  void handleCallAgainCreateLable({
    required int shipmentID,
  }) async {
    setState(() {
      isLoadingCreateLabel = true;
    });
    final response = await http.post(
      Uri.parse('$baseUrl$createLabel'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'is_api': true,
        'shipment_id': shipmentID,
      }),
    );
    final data = jsonDecode(response.body);

    var mess = data['message'];
    var messRes = mess['text'];
    try {
      if (data['status'] == 200) {
        log("handleUpdateLabel OKOK");
        setState(() {
          isLoadingCreateLabel = false;
        });
        _showToast(
            mess: messRes,
            color: Colors.green,
            icon: const Icon(
              Icons.check,
              color: Colors.white,
            ));
      } else {
        log("handleUpdateLabel ERROR 1");
        setState(() {
          isLoadingCreateLabel = false;
        });
        _showToast(
            mess: messRes,
            color: Colors.red,
            icon: const Icon(
              Icons.cancel,
              color: Colors.white,
            ));
      }
    } catch (error) {
      log("handleUpdateLabel ERROR $error 2");
      setState(() {
        isLoadingCreateLabel = false;
      });
      _showToast(
          mess: error.toString(),
          color: Colors.red,
          icon: const Icon(
            Icons.cancel,
            color: Colors.white,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool? isShipper = StorageUtils.instance.getBool(key: 'is_shipper');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
            child: ListView(
          padding: EdgeInsets.all(10.w),
          controller: widget.scrollController,
          children: [
            CustomContainerPakageInfor(
              title: "Thông tin người gửi",
              content: Column(
                children: [
                  Row(
                    children: [
                      TextApp(
                        text: '- Công ty :',
                        fontWeight: FontWeight.bold,
                        fontsize: 14.sp,
                        textAlign: TextAlign.center,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                        child: TextApp(
                          isOverFlow: false,
                          softWrap: true,
                          text: widget.detailsShipment?.shipment
                                  .senderCompanyName ??
                              '',
                          fontsize: 14.sp,
                          textAlign: TextAlign.left,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      TextApp(
                        text: '- Tên người gửi :',
                        fontWeight: FontWeight.bold,
                        fontsize: 14.sp,
                        textAlign: TextAlign.center,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                        child: TextApp(
                          isOverFlow: false,
                          softWrap: true,
                          text: widget.detailsShipment?.shipment
                                  .senderContactName ??
                              '',
                          fontsize: 14.sp,
                          textAlign: TextAlign.left,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      TextApp(
                        text: '- Số Điện Thoại :',
                        fontWeight: FontWeight.bold,
                        fontsize: 14.sp,
                        textAlign: TextAlign.center,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                        child: TextApp(
                          isOverFlow: false,
                          softWrap: true,
                          text: widget
                                  .detailsShipment?.shipment.senderTelephone ??
                              '',
                          fontsize: 14.sp,
                          textAlign: TextAlign.left,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            CustomContainerPakageInfor(
              title: "Thông tin dịch vụ",
              content: Column(
                children: [
                  Row(
                    children: [
                      TextApp(
                        text: '- Dịch vụ :',
                        fontWeight: FontWeight.bold,
                        fontsize: 14.sp,
                        textAlign: TextAlign.center,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                        child: TextApp(
                          isOverFlow: false,
                          softWrap: true,
                          text: widget.detailsShipment?.shipment.service
                                  .serviceName ??
                              'Dịch vụ vẩn chuyển Kango',
                          fontsize: 14.sp,
                          textAlign: TextAlign.left,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      TextApp(
                        text: '- Loại dịch vụ :',
                        fontWeight: FontWeight.bold,
                        fontsize: 14.sp,
                        textAlign: TextAlign.center,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                        child: TextApp(
                          isOverFlow: false,
                          softWrap: true,
                          text: widget.detailsShipment?.shipment.service
                                      .promotionFlg ==
                                  2
                              ? "Dịch vụ Epacket"
                              : "Dịch vụ thường",
                          fontsize: 14.sp,
                          textAlign: TextAlign.left,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  widget.detailsShipment?.shipment.service.promotionFlg == 2
                      ? Column(
                          children: [
                            Row(
                              children: [
                                TextApp(
                                  text: '- Khởi tạo label: ',
                                  fontWeight: FontWeight.bold,
                                  fontsize: 14.sp,
                                  textAlign: TextAlign.center,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                TextApp(
                                  isOverFlow: false,
                                  softWrap: true,
                                  text: widget.detailsShipment?.shipment
                                              .shipmentCheckCreateLabel ==
                                          1
                                      ? "Thành công"
                                      : "Thất bại",
                                  fontsize: 14.sp,
                                  textAlign: TextAlign.center,
                                  color: widget.detailsShipment?.shipment
                                              .shipmentCheckCreateLabel ==
                                          1
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                widget.detailsShipment?.shipment
                                            .shipmentCheckCreateLabel ==
                                        0
                                    ? InkWell(
                                        onTap: () {
                                          isLoadingCreateLabel
                                              ? null
                                              : handleCallAgainCreateLable(
                                                  shipmentID: widget
                                                      .detailsShipment!
                                                      .shipment
                                                      .shipmentId);
                                        },
                                        child: isLoadingCreateLabel
                                            ? SizedBox(
                                                width: 60.w,
                                                height: 60.w,
                                                child: Lottie.asset(
                                                    'assets/lottie/loading_kango.json'),
                                              )
                                            : Icon(
                                                Icons.replay_circle_filled,
                                                size: 32.sp,
                                                color: Colors.green,
                                              ),
                                      )
                                    : Container()
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                          ],
                        )
                      : Container(),
                  Row(
                    children: [
                      TextApp(
                        text: '- Brand :',
                        fontWeight: FontWeight.bold,
                        fontsize: 14.sp,
                        textAlign: TextAlign.center,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      TextApp(
                        isOverFlow: false,
                        softWrap: true,
                        text: widget
                                .detailsShipment?.shipment.branch.branchName ??
                            '',
                        fontsize: 14.sp,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  // Row(
                  //   children: [
                  //     TextApp(
                  //       text: "- Status :",
                  //       fontWeight: FontWeight.bold,
                  //       fontsize: 14.sp,
                  //     ),
                  //     SizedBox(
                  //       width: 10.w,
                  //     ),
                  //     SizedBox(
                  //         // width: 150.w,
                  //         height: 25.h,
                  //         child: StatusBox(
                  //           icon: Icon(
                  //             Icons.history,
                  //             color: Colors.white,
                  //             size: 14.sp,
                  //           ),
                  //           textStatus: widget.detailsShipment!.shipment
                  //                       .shipmentStatus ==
                  //                   0
                  //               ? "Create Bill"
                  //               : widget.detailsShipment!.shipment
                  //                           .shipmentStatus ==
                  //                       1
                  //                   ? "Imported"
                  //                   : widget.detailsShipment!.shipment
                  //                               .shipmentStatus ==
                  //                           2
                  //                       ? "Exported"
                  //                       : "Returned",
                  //           colorBoxStatus: Colors.grey,
                  //         )),
                  //   ],
                  // ),
                  // SizedBox(
                  //   height: 10.h,
                  // ),
                  Row(
                    children: [
                      TextApp(
                        text: '- Dịch vụ chữ ký người nhận :',
                        fontWeight: FontWeight.bold,
                        fontsize: 14.sp,
                        textAlign: TextAlign.center,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      TextApp(
                        isOverFlow: false,
                        softWrap: true,
                        text: widget.detailsShipment?.shipment
                                    .shipmentSignatureFlg ==
                                0
                            ? 'Không'
                            : 'Có',
                        fontsize: 14.sp,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            CustomContainerPakageInfor(
              title: "Thông tin người nhận",
              content: Column(
                children: [
                  Row(
                    children: [
                      TextApp(
                        text: '- Công ty :',
                        fontWeight: FontWeight.bold,
                        fontsize: 14.sp,
                        textAlign: TextAlign.center,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                        child: TextApp(
                          isOverFlow: false,
                          softWrap: true,
                          text: widget.detailsShipment?.shipment
                                  .receiverCompanyName ??
                              '',
                          fontsize: 14.sp,
                          textAlign: TextAlign.left,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      TextApp(
                        text: '- Tên người nhận: :',
                        fontWeight: FontWeight.bold,
                        fontsize: 14.sp,
                        textAlign: TextAlign.center,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                        child: TextApp(
                          isOverFlow: false,
                          softWrap: true,
                          text: widget.detailsShipment?.shipment
                                  .receiverContactName ??
                              '',
                          fontsize: 14.sp,
                          textAlign: TextAlign.left,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      TextApp(
                        text: '- Số Điện Thoại :',
                        fontWeight: FontWeight.bold,
                        fontsize: 14.sp,
                        textAlign: TextAlign.center,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      TextApp(
                        isOverFlow: false,
                        softWrap: true,
                        text: widget
                                .detailsShipment?.shipment.receiverTelephone ??
                            '',
                        fontsize: 14.sp,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      TextApp(
                        text: '- Địa chỉ :',
                        fontWeight: FontWeight.bold,
                        fontsize: 14.sp,
                        textAlign: TextAlign.center,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                        child: TextApp(
                          isOverFlow: false,
                          softWrap: true,
                          text: widget
                                  .detailsShipment?.shipment.receiverAddress1 ??
                              '',
                          fontsize: 14.sp,
                          textAlign: TextAlign.left,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      TextApp(
                        text: '- Thành phố :',
                        fontWeight: FontWeight.bold,
                        fontsize: 14.sp,
                        textAlign: TextAlign.center,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                        child: TextApp(
                          isOverFlow: false,
                          softWrap: true,
                          text: widget.detailsShipment?.shipment.city!.cityName
                                  .toString() ??
                              '',
                          fontsize: 14.sp,
                          textAlign: TextAlign.left,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      TextApp(
                        text: '- Post code :',
                        fontWeight: FontWeight.bold,
                        fontsize: 14.sp,
                        textAlign: TextAlign.center,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                        child: TextApp(
                          isOverFlow: false,
                          softWrap: true,
                          text: widget
                                  .detailsShipment?.shipment.receiverPostalCode
                                  .toString() ??
                              '',
                          fontsize: 14.sp,
                          textAlign: TextAlign.left,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      TextApp(
                        text: '- Khu vực :',
                        fontWeight: FontWeight.bold,
                        fontsize: 14.sp,
                        textAlign: TextAlign.center,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                        child: TextApp(
                          isOverFlow: false,
                          softWrap: true,
                          text: widget
                                  .detailsShipment?.shipment.receiverStateName
                                  .toString() ??
                              '',
                          fontsize: 14.sp,
                          textAlign: TextAlign.left,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      TextApp(
                        text: '- Quốc gia :',
                        fontWeight: FontWeight.bold,
                        fontsize: 14.sp,
                        textAlign: TextAlign.center,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                        child: TextApp(
                          isOverFlow: false,
                          softWrap: true,
                          text: widget
                                  .detailsShipment?.shipment.country.countryName
                                  .toString() ??
                              '',
                          fontsize: 14.sp,
                          textAlign: TextAlign.left,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            CustomContainerPakageInfor(
              title: "Thông tin thanh toán",
              content: Column(
                children: [
                  widget.canUploadLabel == true
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                TextApp(
                                  text: " Upload file Label",
                                  fontsize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                          ],
                        )
                      : Container(),
                  isShipper!
                      ? Container()
                      : Column(
                          children: [
                            widget.canUploadLabel == false &&
                                    (widget.userPosition != 'ops_leader' ||
                                        widget.userPosition != 'ops_pickup')
                                ? Container()
                                : widget.detailsShipment!.shipment
                                            .shipmentFileLabel ==
                                        null
                                    ? widget.selectedPDFLabelProoflFiles.isEmpty
                                        ? DottedBorder(
                                            dashPattern: const [3, 1, 0, 2],
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            strokeWidth: 1.5,
                                            padding: const EdgeInsets.all(3),
                                            child: SizedBox(
                                              width: 1.sw,
                                              height: 200.h,
                                              child: Center(
                                                  child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      FilePickerResult? result =
                                                          await FilePicker
                                                              .platform
                                                              .pickFiles(
                                                        type: FileType.custom,
                                                        allowedExtensions: [
                                                          'pdf'
                                                        ],
                                                        allowMultiple: true,
                                                      );

                                                      if (result != null) {
                                                        setState(() {
                                                          for (var file
                                                              in result.files) {
                                                            widget
                                                                .selectedPDFLabelProoflFiles
                                                                .add(File(file
                                                                    .path!));
                                                            widget
                                                                .selectedPDFLabelProofStrings!
                                                                .add(file.name);
                                                          }
                                                        });
                                                      } else {
                                                        // User canceled the picker
                                                      }
                                                    },
                                                    child: Container(
                                                        width: 120.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.r),
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                        child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.w),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .upload_file,
                                                                  size: 24.sp,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                SizedBox(
                                                                  width: 5.w,
                                                                ),
                                                                TextApp(
                                                                  fontsize:
                                                                      14.sp,
                                                                  text:
                                                                      "Upload file",
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ],
                                                            ))),
                                                  ),
                                                  SizedBox(
                                                    height: 10.h,
                                                  ),
                                                  TextApp(
                                                    text:
                                                        "* Chỉ chấp nhận file PDF",
                                                    color: Colors.red,
                                                    fontsize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                  )
                                                ],
                                              )),
                                            ),
                                          )
                                        : Column(
                                            children: [
                                              ...widget
                                                  .selectedPDFLabelProoflFiles
                                                  .asMap()
                                                  .entries
                                                  .map((entry) {
                                                int idx = entry.key;
                                                File file = entry.value;
                                                return Container(
                                                    width: 1.sw,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.r),
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.5),
                                                          spreadRadius: 2,
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                              0, 3),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10.w),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                width: 50.w,
                                                                height: 50.w,
                                                                child: Image.asset(
                                                                    "assets/images/pdf_icon.png"),
                                                              ),
                                                              SizedBox(
                                                                  width: 10.w),
                                                              Expanded(
                                                                  child: Column(
                                                                children: [
                                                                  Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      TextApp(
                                                                        text: widget
                                                                            .selectedPDFLabelProofStrings![idx],
                                                                        color: Colors
                                                                            .black,
                                                                        fontsize:
                                                                            14.sp,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Container(
                                                                    height:
                                                                        10.h,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.r),
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .primary,
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      TextApp(
                                                                        text:
                                                                            "100%",
                                                                        color: Colors
                                                                            .black,
                                                                        fontsize:
                                                                            14.sp,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              )),
                                                            ],
                                                          ),
                                                        ),
                                                        Positioned(
                                                            right: 3,
                                                            top: 3,
                                                            child: InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  widget
                                                                      .selectedPDFLabelProoflFiles
                                                                      .removeAt(
                                                                          idx);
                                                                  widget
                                                                      .selectedPDFLabelProofStrings!
                                                                      .removeAt(
                                                                          idx);
                                                                });
                                                              },
                                                              child: Icon(
                                                                Icons.close,
                                                                color: Colors
                                                                    .black,
                                                                size: 20.sp,
                                                              ),
                                                            ))
                                                      ],
                                                    ));
                                              }),
                                              SizedBox(height: 10.h),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      FilePickerResult? result =
                                                          await FilePicker
                                                              .platform
                                                              .pickFiles(
                                                        type: FileType.custom,
                                                        allowedExtensions: [
                                                          'pdf'
                                                        ],
                                                        allowMultiple: true,
                                                      );

                                                      if (result != null) {
                                                        setState(() {
                                                          for (var file
                                                              in result.files) {
                                                            widget
                                                                .selectedPDFLabelProoflFiles
                                                                .add(File(file
                                                                    .path!));
                                                            widget
                                                                .selectedPDFLabelProofStrings!
                                                                .add(file.name);
                                                          }
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                        width: 120.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.r),
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.w),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .upload_file,
                                                                size: 24.sp,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              SizedBox(
                                                                  width: 5.w),
                                                              TextApp(
                                                                fontsize: 14.sp,
                                                                text:
                                                                    "Thêm PDF",
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ],
                                                          ),
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                    : Column(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: 80.h,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10.w),
                                                color: const Color.fromRGBO(
                                                    255, 250, 235, 1)),
                                            child: Center(
                                              child: TextApp(
                                                color: const Color.fromRGBO(
                                                    207, 162, 14, 1),
                                                text: "Đang chờ duyệt",
                                                fontsize: 18.w,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10.h),
                                          ButtonApp(
                                            icon: Icons.remove_red_eye_sharp,
                                            iconSize: 18.sp,
                                            text: 'Hiển thị',
                                            fontsize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            colorText: Theme.of(context)
                                                .colorScheme
                                                .background,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            outlineColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            event: () async {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      clipBehavior: Clip
                                                          .antiAliasWithSaveLayer,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.w),
                                                      ),
                                                      actionsPadding:
                                                          EdgeInsets.zero,
                                                      contentPadding:
                                                          EdgeInsets.all(10.w),
                                                      titlePadding:
                                                          EdgeInsets.all(15.w),
                                                      surfaceTintColor:
                                                          Colors.white,
                                                      backgroundColor:
                                                          Colors.white,
                                                      title: const Text(
                                                          'Bằng chứng thanh toán (PDF)'),
                                                      content: Container(
                                                        width: double.maxFinite,
                                                        height: 400,
                                                        child:
                                                            PDF().cachedFromUrl(
                                                          httpImage +
                                                              widget
                                                                  .detailsShipment
                                                                  ?.shipment
                                                                  .shipmentFileLabel,
                                                          placeholder:
                                                              (progress) => Center(
                                                                  child: Text(
                                                                      '$progress %')),
                                                          errorWidget:
                                                              (error) => Center(
                                                                  child: Text(error
                                                                      .toString())),
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: TextApp(
                                                            text: 'Đóng',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontsize: 16.sp,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary,
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            },
                                          )
                                        ],
                                      ),
                            SizedBox(
                              height: 10.h,
                            ),
                            SizedBox(
                              width: 1.sw,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  isShipper!
                                      ? Container()
                                      : widget.canUploadLabel == true
                                          ? ButtonApp(
                                              icon: Icons.edit,
                                              iconSize: 18.sp,
                                              text: 'Cập nhật',
                                              fontsize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              colorText: Theme.of(context)
                                                  .colorScheme
                                                  .background,
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              outlineColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              event: () {
                                                if (widget
                                                    .selectedPDFLabelProoflFiles
                                                    .isNotEmpty) {
                                                  handleUpdateLabel(
                                                      selectedPDFFile: widget
                                                          .selectedPDFLabelFiles,
                                                      selectedPDFString: widget
                                                          .selectedPDFLabelString);
                                                } else {
                                                  showCustomDialogModal(
                                                      context: navigatorKey
                                                          .currentContext!,
                                                      textDesc:
                                                          "Chọn ít nhất một ảnh để cập nhật!",
                                                      title: "Thông báo",
                                                      colorButtonOk:
                                                          Colors.blue,
                                                      btnOKText: "Xác nhận",
                                                      typeDialog: "info",
                                                      eventButtonOKPress: () {},
                                                      isTwoButton: false);
                                                }
                                              },
                                            )
                                          : Container()
                                ],
                              ),
                            ),
                          ],
                        ),
                  SizedBox(
                    height: 10.h,
                  ),
                  widget.canUploadPayment == true
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                TextApp(
                                  text: " Bằng chứng thanh toán",
                                  fontsize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                          ],
                        )
                      : Container(),
                  isShipper
                      ? Container()
                      : widget.canUploadPayment == false
                          ? Container()
                          : widget.detailsShipment!.shipment
                                      .shipmentFileProofOfPayment ==
                                  null
                              ? Column(
                                  children: [
                                    (widget.selectedImages.isEmpty &&
                                            widget.selectedPDFPaymentProoflFiles
                                                .isEmpty)
                                        ? DottedBorder(
                                            dashPattern: const [3, 1, 0, 2],
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            strokeWidth: 1.5,
                                            padding: const EdgeInsets.all(3),
                                            child: SizedBox(
                                              width: 1.sw,
                                              height: 200.h,
                                              child: Center(
                                                  child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      final returnedImages =
                                                          await ImagePicker()
                                                              .pickMultiImage();
                                                      if (returnedImages ==
                                                          null) return;
                                                      setState(() {
                                                        widget.selectedImages
                                                            .addAll(returnedImages
                                                                .map((image) =>
                                                                    File(image
                                                                        .path)));
                                                      });
                                                    },
                                                    child: Container(
                                                        width: 120.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.r),
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                        child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.w),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .collections,
                                                                  size: 24.sp,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                SizedBox(
                                                                    width: 5.w),
                                                                TextApp(
                                                                  fontsize:
                                                                      14.sp,
                                                                  text:
                                                                      "Chọn ảnh",
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ],
                                                            ))),
                                                  ),
                                                  SizedBox(height: 10.h),
                                                  InkWell(
                                                    onTap: () async {
                                                      FilePickerResult? result =
                                                          await FilePicker
                                                              .platform
                                                              .pickFiles(
                                                        type: FileType.custom,
                                                        allowedExtensions: [
                                                          'pdf'
                                                        ],
                                                        allowMultiple: true,
                                                      );

                                                      if (result != null) {
                                                        setState(() {
                                                          for (var file
                                                              in result.files) {
                                                            widget
                                                                .selectedPDFPaymentProoflFiles
                                                                .add(File(file
                                                                    .path!));
                                                            widget
                                                                .selectedPDFPaymentProofStrings
                                                                .add(file.name);
                                                          }
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                        width: 120.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.r),
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.w),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .upload_file,
                                                                size: 24.sp,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              SizedBox(
                                                                  width: 5.w),
                                                              TextApp(
                                                                fontsize: 14.sp,
                                                                text:
                                                                    "Upload file",
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ],
                                                          ),
                                                        )),
                                                  ),
                                                  SizedBox(height: 10.h),
                                                  TextApp(
                                                    text:
                                                        "* Hình ảnh, file PDF",
                                                    color: Colors.red,
                                                    fontsize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                  )
                                                ],
                                              )),
                                            ),
                                          )
                                        : Column(
                                            children: [
                                              ...widget.selectedImages
                                                  .map((image) => Stack(
                                                        children: [
                                                          SizedBox(
                                                              width: 1.sw,
                                                              height: 250.w,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.r),
                                                                child:
                                                                    Image.file(
                                                                  image,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              )),
                                                          Positioned(
                                                            top: 5.w,
                                                            right: 5.w,
                                                            child: InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  widget
                                                                      .selectedImages
                                                                      .remove(
                                                                          image);
                                                                });
                                                              },
                                                              child: Container(
                                                                width: 30,
                                                                height: 30,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15),
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.8),
                                                                ),
                                                                child: Center(
                                                                    child: Icon(
                                                                  Icons.close,
                                                                  size: 20.sp,
                                                                  color: Colors
                                                                      .black,
                                                                )),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                              ...widget
                                                  .selectedPDFPaymentProoflFiles
                                                  .asMap()
                                                  .entries
                                                  .map((entry) {
                                                int idx = entry.key;
                                                File file = entry.value;
                                                return Container(
                                                    width: 1.sw,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.r),
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.5),
                                                          spreadRadius: 2,
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                              0, 3),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10.w),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                width: 50.w,
                                                                height: 50.w,
                                                                child: Image.asset(
                                                                    "assets/images/pdf_icon.png"),
                                                              ),
                                                              SizedBox(
                                                                  width: 10.w),
                                                              Expanded(
                                                                  child: Column(
                                                                children: [
                                                                  Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      TextApp(
                                                                        text: widget
                                                                            .selectedPDFPaymentProofStrings[idx],
                                                                        color: Colors
                                                                            .black,
                                                                        fontsize:
                                                                            14.sp,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Container(
                                                                    height:
                                                                        10.h,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.r),
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .primary,
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      TextApp(
                                                                        text:
                                                                            "100%",
                                                                        color: Colors
                                                                            .black,
                                                                        fontsize:
                                                                            14.sp,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              )),
                                                            ],
                                                          ),
                                                        ),
                                                        Positioned(
                                                            right: 3,
                                                            top: 3,
                                                            child: InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  widget
                                                                      .selectedPDFPaymentProoflFiles
                                                                      .removeAt(
                                                                          idx);
                                                                  widget
                                                                      .selectedPDFPaymentProofStrings
                                                                      .removeAt(
                                                                          idx);
                                                                });
                                                              },
                                                              child: Icon(
                                                                Icons.close,
                                                                color: Colors
                                                                    .black,
                                                                size: 20.sp,
                                                              ),
                                                            ))
                                                      ],
                                                    ));
                                              }),
                                              SizedBox(height: 10.h),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      final returnedImages =
                                                          await ImagePicker()
                                                              .pickMultiImage();
                                                      if (returnedImages ==
                                                          null) return;
                                                      setState(() {
                                                        widget.selectedImages
                                                            .addAll(returnedImages
                                                                .map((image) =>
                                                                    File(image
                                                                        .path)));
                                                      });
                                                    },
                                                    child: Container(
                                                        width: 120.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.r),
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                        child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.w),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .collections,
                                                                  size: 24.sp,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                SizedBox(
                                                                    width: 5.w),
                                                                TextApp(
                                                                  fontsize:
                                                                      14.sp,
                                                                  text:
                                                                      "Thêm ảnh",
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ],
                                                            ))),
                                                  ),
                                                  SizedBox(width: 10.w),
                                                  InkWell(
                                                    onTap: () async {
                                                      FilePickerResult? result =
                                                          await FilePicker
                                                              .platform
                                                              .pickFiles(
                                                        type: FileType.custom,
                                                        allowedExtensions: [
                                                          'pdf'
                                                        ],
                                                        allowMultiple: true,
                                                      );

                                                      if (result != null) {
                                                        setState(() {
                                                          for (var file
                                                              in result.files) {
                                                            widget
                                                                .selectedPDFPaymentProoflFiles
                                                                .add(File(file
                                                                    .path!));
                                                            widget
                                                                .selectedPDFPaymentProofStrings
                                                                .add(file.name);
                                                          }
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                        width: 120.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.r),
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.w),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .upload_file,
                                                                size: 24.sp,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              SizedBox(
                                                                  width: 5.w),
                                                              TextApp(
                                                                fontsize: 14.sp,
                                                                text:
                                                                    "Thêm PDF",
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ],
                                                          ),
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Row(
                                      children: [
                                        TextApp(
                                          text: 'Phương thức thanh toán: ',
                                          fontWeight: FontWeight.bold,
                                          fontsize: 14.sp,
                                          textAlign: TextAlign.center,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                    Wrap(
                                      spacing:
                                          8.0, // Khoảng cách ngang giữa các phần tử
                                      alignment: WrapAlignment
                                          .center, // Căn giữa các phần tử
                                      children: <Widget>[
                                        ListTile(
                                          title: TextApp(
                                            text: 'Ngân hàng',
                                            fontsize: 14.sp,
                                          ),
                                          leading: Radio<int>(
                                            value: 1,
                                            groupValue: currentMethodPay,
                                            onChanged: (int? value) {
                                              setState(() {
                                                currentMethodPay = value!;
                                              });
                                            },
                                          ),
                                        ),
                                        ListTile(
                                          title: TextApp(
                                            text: 'Tiền mặt',
                                            fontsize: 14.sp,
                                          ),
                                          leading: Radio<int>(
                                            value: 2,
                                            groupValue: currentMethodPay,
                                            onChanged: (int? value) {
                                              setState(() {
                                                currentMethodPay = value!;
                                              });
                                            },
                                          ),
                                        ),
                                        ListTile(
                                          title: TextApp(
                                            text: 'Tiền mặt & ngân hàng',
                                            fontsize: 14.sp,
                                          ),
                                          leading: Radio<int>(
                                            value: 3,
                                            groupValue: currentMethodPay,
                                            onChanged: (int? value) {
                                              setState(() {
                                                currentMethodPay = value!;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15.h,
                                    ),
                                    SizedBox(
                                      width: 1.sw,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          isShipper &&
                                                  (widget.userPosition ==
                                                          'ops_leader' ||
                                                      widget.userPosition ==
                                                          'ops_pickup')
                                              ? Container()
                                              : ButtonApp(
                                                  icon: Icons.edit,
                                                  iconSize: 18.sp,
                                                  text: 'Cập nhật',
                                                  fontsize: 14.sp,
                                                  fontWeight: FontWeight.bold,
                                                  colorText: Theme.of(context)
                                                      .colorScheme
                                                      .background,
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                  outlineColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                  event: () {
                                                    if (widget.selectedImages
                                                            .isNotEmpty ||
                                                        widget
                                                            .selectedPDFPaymentProoflFiles
                                                            .isNotEmpty) {
                                                      handleUpdatePaymentProofShipment();
                                                    } else {
                                                      showCustomDialogModal(
                                                          context: navigatorKey
                                                              .currentContext!,
                                                          textDesc:
                                                              "Chọn ít nhất một ảnh hoặc file PDF để cập nhật!",
                                                          title: "Thông báo",
                                                          colorButtonOk:
                                                              Colors.blue,
                                                          btnOKText: "Xác nhận",
                                                          typeDialog: "info",
                                                          eventButtonOKPress:
                                                              () {},
                                                          isTwoButton: false);
                                                    }
                                                  },
                                                )
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 80.h,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.w),
                                          color: const Color.fromRGBO(
                                              255, 250, 235, 1)),
                                      child: Center(
                                        child: TextApp(
                                          color: const Color.fromRGBO(
                                              207, 162, 14, 1),
                                          text: "Đang chờ duyệt",
                                          fontsize: 18.w,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    ButtonApp(
                                      icon: Icons.remove_red_eye_sharp,
                                      iconSize: 18.sp,
                                      text: 'Hiển thị',
                                      fontsize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      outlineColor:
                                          Theme.of(context).colorScheme.primary,
                                      event: () async {
                                        String rawJson = widget
                                                .detailsShipment
                                                ?.shipment
                                                .shipmentFileProofOfPayment ??
                                            "[]";
                                        List<dynamic> paths =
                                            jsonDecode(rawJson);

                                        // Phân loại files thành ảnh và PDF
                                        List<String> imagePaths = [];
                                        List<String> pdfPaths = [];

                                        for (String path in paths) {
                                          if (path
                                                  .toLowerCase()
                                                  .contains('png') ||
                                              path
                                                  .toLowerCase()
                                                  .contains('jpg')) {
                                            imagePaths.add(path);
                                          } else if (path
                                              .toLowerCase()
                                              .contains('pdf')) {
                                            pdfPaths.add(path);
                                          }
                                        }

                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                clipBehavior:
                                                    Clip.antiAliasWithSaveLayer,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.w),
                                                ),
                                                actionsPadding: EdgeInsets.zero,
                                                contentPadding:
                                                    EdgeInsets.all(10.w),
                                                titlePadding:
                                                    EdgeInsets.all(15.w),
                                                surfaceTintColor: Colors.white,
                                                backgroundColor: Colors.white,
                                                title: Text(imagePaths
                                                            .isNotEmpty &&
                                                        pdfPaths.isNotEmpty
                                                    ? 'Bằng chứng thanh toán (Hình ảnh & PDF)'
                                                    : imagePaths.isNotEmpty
                                                        ? 'Bằng chứng thanh toán (Hình ảnh)'
                                                        : 'Bằng chứng thanh toán (PDF)'),
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      // Hiển thị ảnh
                                                      if (imagePaths
                                                          .isNotEmpty) ...[
                                                        ...imagePaths
                                                            .map(
                                                                (path) =>
                                                                    Column(
                                                                      children: [
                                                                        Container(
                                                                          constraints:
                                                                              BoxConstraints(maxHeight: 300.h),
                                                                          child:
                                                                              CachedNetworkImage(
                                                                            fit:
                                                                                BoxFit.contain,
                                                                            imageUrl:
                                                                                httpImage + path,
                                                                            placeholder: (context, url) =>
                                                                                SizedBox(
                                                                              height: 20.w,
                                                                              width: 20.w,
                                                                              child: const Center(child: CircularProgressIndicator()),
                                                                            ),
                                                                            errorWidget: (context, url, error) =>
                                                                                const Icon(Icons.error),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                10.h),
                                                                      ],
                                                                    ))
                                                            .toList(),
                                                      ],

                                                      // Hiển thị PDF
                                                      if (pdfPaths
                                                          .isNotEmpty) ...[
                                                        ...pdfPaths
                                                            .map(
                                                                (path) =>
                                                                    Column(
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              double.maxFinite,
                                                                          height:
                                                                              400,
                                                                          child:
                                                                              PDF().cachedFromUrl(
                                                                            httpImage +
                                                                                path,
                                                                            placeholder: (progress) =>
                                                                                Center(child: Text('$progress %')),
                                                                            errorWidget: (error) =>
                                                                                Center(child: Text(error.toString())),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                10.h),
                                                                      ],
                                                                    ))
                                                            .toList(),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: TextApp(
                                                      text: 'Đóng',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontsize: 16.sp,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                    )
                                  ],
                                ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      TextApp(
                        text: '- Tên hàng: ',
                        fontWeight: FontWeight.bold,
                        fontsize: 14.sp,
                        textAlign: TextAlign.center,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Flexible(
                        child: TextApp(
                          isOverFlow: false,
                          softWrap: true,
                          text: widget.detailsShipment?.shipment
                                  .shipmentGoodsName ??
                              '',
                          fontsize: 14.sp,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      TextApp(
                        text: '- Export as: ',
                        fontWeight: FontWeight.bold,
                        fontsize: 14.sp,
                        textAlign: TextAlign.center,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Flexible(
                        child: TextApp(
                          isOverFlow: false,
                          softWrap: true,
                          text: widget.detailsShipment?.shipment
                                      .shipmentExportAs ==
                                  1
                              ? "Sample"
                              : "Gift (no commercial value)",
                          fontsize: 14.sp,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      TextApp(
                        text: '- Trạng thái thanh toán: ',
                        fontWeight: FontWeight.bold,
                        fontsize: 14.sp,
                        textAlign: TextAlign.center,
                        color: Colors.black,
                      ),
                      Flexible(
                        child: TextApp(
                          isOverFlow: false,
                          softWrap: true,
                          text: getTextShipmentStatus(),
                          fontsize: 14.sp,
                          color: Colors.red,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      TextApp(
                        text: '- Phương thức thanh toán: ',
                        fontWeight: FontWeight.bold,
                        fontsize: 14.sp,
                        textAlign: TextAlign.center,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Flexible(
                        child: TextApp(
                          isOverFlow: false,
                          softWrap: true,
                          text: getTextShipmentPayBy(),
                          fontsize: 14.sp,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            widget.userPosition == 'fwd'
                ? Container()
                : CustomContainerPakageInfor(
                    title: "Chi phí phụ thu khách",
                    content: Column(
                      children: [
                        Row(
                          children: [
                            TextApp(
                              text: '- Cước nội địa : ',
                              fontWeight: FontWeight.bold,
                              fontsize: 14.sp,
                              textAlign: TextAlign.center,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            TextApp(
                              isOverFlow: false,
                              softWrap: true,
                              text:
                                  "${MoneyFormatter(amount: (widget.detailsShipment?.shipment.shipmentDomesticCharges ?? 0).toDouble()).output.withoutFractionDigits.toString()} đ",
                              fontsize: 14.sp,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          children: [
                            TextApp(
                              text: '- Cước phụ thu : ',
                              fontWeight: FontWeight.bold,
                              fontsize: 14.sp,
                              textAlign: TextAlign.center,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            TextApp(
                              isOverFlow: false,
                              softWrap: true,
                              text:
                                  "${MoneyFormatter(amount: (widget.detailsShipment?.shipment.shipmentAmountSurcharge ?? 0).toDouble()).output.withoutFractionDigits.toString()} đ",
                              fontsize: 14.sp,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          children: [
                            TextApp(
                              text: '- Cước thu hộ : ',
                              fontWeight: FontWeight.bold,
                              fontsize: 14.sp,
                              textAlign: TextAlign.center,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            TextApp(
                              isOverFlow: false,
                              softWrap: true,
                              text:
                                  "${MoneyFormatter(amount: (widget.detailsShipment?.shipment.shipmentCollectionFee ?? 0).toDouble()).output.withoutFractionDigits.toString()} đ",
                              fontsize: 14.sp,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          children: [
                            TextApp(
                              text: '- Cước phí bảo hiểm : ',
                              fontWeight: FontWeight.bold,
                              fontsize: 14.sp,
                              textAlign: TextAlign.center,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            TextApp(
                              isOverFlow: false,
                              softWrap: true,
                              text:
                                  "${MoneyFormatter(amount: (widget.detailsShipment?.shipment.shipmentAmountInsurance ?? 0).toDouble()).output.withoutFractionDigits.toString()} đ",
                              fontsize: 14.sp,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          children: [
                            TextApp(
                              text: '- Giá cước VAT : ',
                              fontWeight: FontWeight.bold,
                              fontsize: 14.sp,
                              textAlign: TextAlign.center,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            TextApp(
                              isOverFlow: false,
                              softWrap: true,
                              text:
                                  "${MoneyFormatter(amount: (widget.detailsShipment?.shipment.shipmentAmountVat ?? 0).toDouble()).output.withoutFractionDigits.toString()} đ",
                              fontsize: 14.sp,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          children: [
                            TextApp(
                              text: '- Cước gốc : ',
                              fontWeight: FontWeight.bold,
                              fontsize: 14.sp,
                              textAlign: TextAlign.center,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            TextApp(
                              isOverFlow: false,
                              softWrap: true,
                              text:
                                  "${MoneyFormatter(amount: (widget.detailsShipment?.shipment.shipmentAmountOriginal ?? 0).toDouble()).output.withoutFractionDigits.toString()} đ",
                              fontsize: 14.sp,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Divider(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Row(
                          children: [
                            TextApp(
                              text: 'Giá trị bảo hiểm : ',
                              fontWeight: FontWeight.bold,
                              fontsize: 14.sp,
                              textAlign: TextAlign.center,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            TextApp(
                              isOverFlow: false,
                              softWrap: true,
                              text:
                                  "${MoneyFormatter(amount: (widget.detailsShipment?.shipment.shipmentAmountInsuranceValue ?? 0).toDouble()).output.withoutFractionDigits.toString()} đ",
                              fontsize: 14.sp,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          children: [
                            TextApp(
                              text: 'Tổng cước thu khách : ',
                              fontWeight: FontWeight.bold,
                              fontsize: 14.sp,
                              textAlign: TextAlign.center,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            TextApp(
                              isOverFlow: false,
                              softWrap: true,
                              text:
                                  "${MoneyFormatter(amount: (widget.detailsShipment?.shipment.shipmentAmountTotalCustomer ?? 0).toDouble()).output.withoutFractionDigits.toString()} đ",
                              fontsize: 14.sp,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          children: [
                            TextApp(
                              text: 'Lợi nhuận thực tế : ',
                              fontWeight: FontWeight.bold,
                              fontsize: 14.sp,
                              textAlign: TextAlign.center,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            TextApp(
                              isOverFlow: false,
                              softWrap: true,
                              text:
                                  "${MoneyFormatter(amount: (widget.detailsShipment?.shipment.shipmentAmountProfit ?? 0).toDouble()).output.withoutFractionDigits.toString()} đ",
                              fontsize: 14.sp,
                              textAlign: TextAlign.center,
                              fontWeight: FontWeight.bold,
                              color: widget.detailsShipment!.shipment
                                          .shipmentAmountProfit <=
                                      0
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        isShipper
                            ? Container()
                            : widget.userPosition == 'sale'
                                ? Container()
                                : Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ButtonApp(
                                        icon: Icons.edit,
                                        iconSize: 16.sp,
                                        text: 'Sửa chi phí',
                                        fontsize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        colorText: Theme.of(context)
                                            .colorScheme
                                            .background,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        outlineColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        event: () async {
                                          // await Future.delayed(
                                          //     Duration(milliseconds: 500), () {
                                          //   Navigator.pop(context);
                                          // });
                                          showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topRight:
                                                      Radius.circular(15.r),
                                                  topLeft:
                                                      Radius.circular(15.r),
                                                ),
                                              ),
                                              clipBehavior:
                                                  Clip.antiAliasWithSaveLayer,
                                              builder: (context) {
                                                return EditAdditionalCosts(
                                                  shipmentCode:
                                                      widget.shipmentCode,
                                                  detailsShipment:
                                                      widget.detailsShipment,
                                                );
                                              });
                                        },
                                      )
                                    ],
                                  )
                      ],
                    ),
                  ),
            SizedBox(
              height: 15.h,
            ),
            widget.userPosition == 'fwd'
                ? Container()
                : CustomContainerPakageInfor(
                    title: "Chi phí vận hành công ty",
                    content: ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: widget.detailsShipment?.shipment
                            .shipmentOperatingCosts.length,
                        itemBuilder: (context, index) {
                          var shipmentOperatingCostsData = widget
                              .detailsShipment
                              ?.shipment
                              .shipmentOperatingCosts[index];
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      TextApp(
                                        text:
                                            '${shipmentOperatingCostsData?.operatingCostName} : ',
                                        fontWeight: FontWeight.bold,
                                        fontsize: 14.sp,
                                        textAlign: TextAlign.center,
                                        color: Colors.black,
                                      ),
                                      SizedBox(
                                        width: 10.w,
                                      ),
                                      TextApp(
                                        isOverFlow: false,
                                        softWrap: true,
                                        text:
                                            "${MoneyFormatter(amount: (shipmentOperatingCostsData?.shipmentOperatingCostAmount ?? 0).toDouble()).output.withoutFractionDigits.toString()} đ",
                                        fontsize: 14.sp,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  TextApp(
                                    isOverFlow: false,
                                    softWrap: true,
                                    text:
                                        'SL : ${shipmentOperatingCostsData?.shipmentOperatingCostQuantity}',
                                    fontsize: 14.sp,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                            ],
                          );
                        }),
                    expandContent: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: isShipper
                          ? Container()
                          : widget.userPosition == 'sale'
                              ? Container()
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ButtonApp(
                                      icon: Icons.edit,
                                      iconSize: 16.sp,
                                      text: 'Sửa chi phí',
                                      fontsize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      outlineColor:
                                          Theme.of(context).colorScheme.primary,
                                      event: () async {
                                        // await Future.delayed(Duration(milliseconds: 500),
                                        //     () {
                                        //   Navigator.pop(context);
                                        // });
                                        showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(15.r),
                                                topLeft: Radius.circular(15.r),
                                              ),
                                            ),
                                            clipBehavior:
                                                Clip.antiAliasWithSaveLayer,
                                            builder: (context) {
                                              return EditCompanyOperatingCosts(
                                                shipmentCode:
                                                    widget.shipmentCode,
                                              );
                                            });
                                      },
                                    )
                                  ],
                                ),
                    ),
                  ),
            SizedBox(
              height: 30.h,
            ),
          ],
        ))
      ],
    );
  }

  String getTextShipmentPayBy() {
    if (widget.detailsShipment!.shipment.shipmentPaidBy == 0) {
      return " Thanh toán sau ";
    } else {
      return " Thanh toán nợ (Dùng hạn mức) ";
    }
  }

  String getTextShipmentStatus() {
    if (widget.detailsShipment!.shipment.shipmentPaymentStatus == 0) {
      return " Chưa thanh toán ";
    } else {
      return " Đã thanh toán ";
    }
  }
}
