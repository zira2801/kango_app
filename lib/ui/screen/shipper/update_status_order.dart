import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:scan_barcode_app/bloc/shipper/choose_branch_return.dart/choose_branch_return_bloc.dart';
import 'package:scan_barcode_app/bloc/shipper/shipper_finish/shipper_finish_bloc.dart';
import 'package:scan_barcode_app/bloc/shipper/shipper_list_order/shipper_list_order_screen_bloc.dart';
import 'package:scan_barcode_app/bloc/shipper/update_status_order_shipper/update_status_order_shipper_bloc.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/models/order_pickup/details_order_pick_up.dart';
import 'package:scan_barcode_app/data/models/utils/list_branchs_model.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/ui/screen/driver/driver_list_order.dart';
import 'package:scan_barcode_app/ui/theme/theme.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';

class UpdateStatusOrderShipper extends StatefulWidget {
  final DetailsOrderPickUpModel? detailsOrderPickUp;
  const UpdateStatusOrderShipper({required this.detailsOrderPickUp, super.key});

  @override
  State<UpdateStatusOrderShipper> createState() =>
      _UpdateStatusOrderShipperState();
}

class _UpdateStatusOrderShipperState extends State<UpdateStatusOrderShipper> {
  final _formUpdateOrderPickUpShipper = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {};
  final ImagePicker picker = ImagePicker();
  BranchResponse? branchResponse;
  String query = '';
  LatLng currentBranchSelected = LatLng(0, 0);
  bool isLoadingButton = false;
  List<String> listStatus = [
    "Đang chờ duyệt", //0
    "Đang chờ xác nhận", //1
    "Đã xác nhận", //2
    "Đang đi lấy", //3
    "Đã lấy", //4
    "Đã pickup", //5
    "Đã huỷ" //6
  ];
  List<IconData> iconStatus = [
    Icons.history,
    Icons.info,
    Icons.check_circle,
    Icons.delivery_dining,
    Icons.get_app,
    Icons.check,
    Icons.cancel,
  ];
  File? selectedImage;
  String? selectedImageString;
  int? editStatusIndex;
  void initializeControllers(List<String> keys) {
    for (var key in keys) {
      controllers[key] = TextEditingController();
    }
  }

  Future<void> deleteImage() async {
    setState(() {
      selectedImage = null;
    });
  }

  Future<void> deleteExistImage() async {
    setState(() {
      widget.detailsOrderPickUp!.data.orderPickupImage = null;
    });
  } // xoá ảnh nếu đã có từ data trả về

  Future<void> pickImage() async {
    final returndImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returndImage == null) return;
    setState(() {
      selectedImage = File(returndImage.path);
    });
  }

  Future<String> convertImageUrlToBase64(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return base64Encode(response.bodyBytes);
      } else {
        throw Exception("Không thể tải ảnh từ URL: $imageUrl");
      }
    } catch (e) {
      print("❌ Lỗi khi tải ảnh từ URL: $e");
      return "";
    }
  }

  void updateDialogState(File? newImage, StateSetter setState) {
    setState(() {
      selectedImage = newImage;
    });
  }

  void captureImage(StateSetter setState) async {
    try {
      final XFile? capturedImage = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (capturedImage != null) {
        updateDialogState(File(capturedImage.path), setState);
      }
    } catch (e) {
      print('Camera error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể chụp ảnh. Vui lòng thử lại.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  DateTime dateTime = DateTime(2022, 12, 24, 5, 30);

  Future<DateTime?> pickMaterialDate() => showDatePicker(
        helpText: "Chọn ngày",
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year - 2),
        lastDate: DateTime(DateTime.now().year + 2),
        builder: (context, child) {
          return Theme(
            data: ThemeData.from(colorScheme: lightColorScheme),
            child: child!,
          );
        },
      );

  Future<TimeOfDay?> pickMaterialTime() => showTimePicker(
        helpText: "Chọn thời gian",
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.from(colorScheme: lightColorScheme),
            child: child!,
          );
        },
      );

  Future<DateTime?> pickCupertinoDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();

    await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15.r),
          topLeft: Radius.circular(15.r),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          color: Colors.white,
          child: SizedBox(
            height: 300.h,
            child: Column(
              children: [
                Container(
                  width: 1.sw,
                  height: 50.h,
                  color: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.only(left: 20.w, right: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: TextApp(
                          text: "Huỷ",
                          fontsize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop(selectedDate);
                        },
                        child: TextApp(
                          text: "Xác nhận",
                          fontsize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: DateTime.now(),
                    minimumDate: DateTime(DateTime.now().year - 2),
                    maximumDate: DateTime(DateTime.now().year + 2),
                    onDateTimeChanged: (DateTime newDate) {
                      selectedDate = newDate;
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );

    return selectedDate;
  }

  Future<TimeOfDay?> pickCupertinoTime(BuildContext context) async {
    TimeOfDay selectedTime = TimeOfDay.now();

    await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15.r),
          topLeft: Radius.circular(15.r),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          color: Colors.white,
          child: SizedBox(
            height: 300.h,
            child: Column(
              children: [
                Container(
                  width: 1.sw,
                  height: 50.h,
                  color: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.only(left: 20.w, right: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: TextApp(
                          text: "Huỷ",
                          fontsize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: TextApp(
                          text: "Xác nhận",
                          fontsize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: DateTime.now(),
                    onDateTimeChanged: (DateTime newDate) {
                      selectedTime =
                          TimeOfDay(hour: newDate.hour, minute: newDate.minute);
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );

    return selectedTime;
  }

  Future<void> pickDateAndTime() async {
    DateTime? date;
    TimeOfDay? time;
    final now = DateTime.now();

    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        date = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: DateTime(now.year - 1), // Cho phép chọn từ năm trước
          lastDate: DateTime(now.year + 1),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Theme.of(context).primaryColor,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
                dialogBackgroundColor: Colors.white,
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );

        // Bỏ kiểm tra date trong quá khứ
        if (date == null) return; // Chỉ kiểm tra null khi người dùng hủy

        time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: Colors.white,
                  hourMinuteTextColor: Theme.of(context).primaryColor,
                  dayPeriodTextColor: Theme.of(context).primaryColor,
                  dialHandColor: Theme.of(context).primaryColor,
                  dialBackgroundColor: Colors.grey.shade200,
                ),
              ),
              child: child!,
            );
          },
        );
        break;

      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        DateTime? selectedDateTime;
        await showCupertinoModalPopup(
          context: context,
          builder: (context) => Container(
            height: 300,
            color: CupertinoColors.systemBackground,
            child: Column(
              children: [
                Container(
                  height: 40,
                  color: Colors.grey.shade200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        child: const Text('Hủy'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      CupertinoButton(
                        child: const Text('Xong'),
                        onPressed: () {
                          if (selectedDateTime != null) {
                            date = selectedDateTime;
                            time = TimeOfDay(
                              hour: selectedDateTime!.hour,
                              minute: selectedDateTime!.minute,
                            );
                          }
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    initialDateTime: now,
                    minimumDate:
                        DateTime(now.year - 1), // Cho phép chọn từ năm trước
                    maximumDate: DateTime(now.year + 1),
                    mode: CupertinoDatePickerMode.dateAndTime,
                    use24hFormat: true, // Sử dụng định dạng 24h
                    onDateTimeChanged: (DateTime newDateTime) {
                      selectedDateTime = newDateTime;
                    },
                  ),
                ),
              ],
            ),
          ),
        );

        if (date == null || time == null) {
          // Chỉ hiển thị cảnh báo khi không chọn gì (tức là hủy)
          _showErrorDialog(
              title: 'Chưa hoàn tất',
              message: 'Vui lòng chọn thời gian để tiếp tục',
              type: 'warning');
          return;
        }
        break;
    }

    // Không cần kiểm tra thời gian trong quá khứ nữa
    final newDateTime = DateTime(
      date!.year,
      date!.month,
      date!.day,
      time!.hour,
      time!.minute,
    );

    setState(() {
      controllers['datePickUp']!.text =
          DateFormat('yyyy-MM-dd HH:mm').format(newDateTime);
    });
  }

  void _showErrorDialog({
    required String title,
    required String message,
    required String type,
  }) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                'Đồng ý',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                type == 'error'
                    ? Icons.error_outline
                    : Icons.warning_amber_rounded,
                color: type == 'error' ? Colors.red : Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Đồng ý',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  String formatDateTime(String dateTime) {
    // Implement your date formatting logic here
    final DateTime dt = DateTime.parse(dateTime);
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
    return formatter.format(dt);
  }

  Future<void> autoFillData() async {
    setState(() {
      controllers['datePickUp']!.text = formatDateTime(
          widget.detailsOrderPickUp!.data.orderPickupDateTime.toString());
      controllers['note']!.text =
          widget.detailsOrderPickUp!.data.orderPickupNote ?? '';
      controllers['status']!.text =
          listStatus[widget.detailsOrderPickUp!.data.orderPickupStatus];
      editStatusIndex = widget.detailsOrderPickUp!.data.orderPickupStatus;
    });
  }

  Future<void> getBranchKango() async {
    String? branchResponseJson =
        StorageUtils.instance.getString(key: 'branch_response');
    if (branchResponseJson != null) {
      branchResponse = BranchResponse.fromJson(jsonDecode(branchResponseJson));
    }
  }

  Future<void> _showDialogChooseBranchToComeBack() async {
    showDialog(
      barrierDismissible: false,
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        String? _selectedOption;

        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          title: TextApp(
            text: 'Chọn chi nhánh',
            fontsize: 16.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    shrinkWrap:
                        true, // Ensures the ListView doesn't take infinite height
                    itemCount: branchResponse!.branchs.length,
                    itemBuilder: (context, index) {
                      final branch = branchResponse!.branchs[index];
                      return ListTile(
                        title: TextApp(
                          text: branch.branchDescription,
                          fontsize: 14.sp,
                          color: Colors.black,
                          maxLines: 3,
                        ),
                        leading: Radio<String>(
                          value: branch.branchId.toString(),
                          groupValue: _selectedOption,
                          onChanged: (value) {
                            setState(() {
                              _selectedOption = value;
                              currentBranchSelected = LatLng(
                                  double.parse(branch.branchLatitude!),
                                  double.parse(branch.branchLongitude!));
                            });
                          },
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            ButtonApp(
              event: () {
                // context.read<ChooseBranchReturnBloc>().add(
                //     DialogSelectionEvent(
                //         _selectedOption == 'branchHCMAdrees'
                //             ? branchHCMLocation
                //             : _selectedOption == 'branchDNAdrees'
                //                 ? branchDNLocation
                //                 : branchHNLocation));
                context
                    .read<ChooseBranchReturnBloc>()
                    .add(DialogSelectionEvent(currentBranchSelected));
                Navigator.of(context).pop();
              },
              text: 'OK',
              colorText: Colors.white,
              backgroundColor: Theme.of(context).colorScheme.primary,
              outlineColor: Theme.of(context).colorScheme.primary,
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getBranchKango();
    initializeControllers(['datePickUp', 'note', 'status', 'cancle_reason']);
    autoFillData();
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  Future<void> onHandleUpdateOrderPickUp({
    required int? orderPickUpID,
    required int orderPickUpType,
    required int branchIDEdit,
    required int? fwd,
    required String orderPickUpTime,
    required String orderPickUpAWB,
    required String orderPickUpGrossWeight,
    required String orderPickUpNumberPackage,
    required String orderPickUpPhone,
    required String orderPickUpAdrees,
    required String? orderPickUpNote,
    required String? orderPickupName,
    required int? orderPickUpStatus,
    required double longitude,
    required double latitude,
    required String? orderPickupCancelDes,
  }) async {
    mounted
        ? setState(() {
            isLoadingButton = true;
          })
        : null;
    //Kiểm tra trạng thái 6 (Hủy bỏ)
    if (editStatusIndex == 6 &&
        (orderPickupCancelDes == null || orderPickupCancelDes == '')) {
      showCustomDialogModal(
        context: navigatorKey.currentContext!,
        textDesc: "Nguyên nhân hủy không được để trống",
        title: "Thông báo lỗi",
        colorButtonOk: Colors.red,
        btnOKText: "Xác nhận",
        typeDialog: "error",
        eventButtonOKPress: () {
          Future.delayed(const Duration(microseconds: 800), () {
            setState(() {
              isLoadingButton = false;
            });
          });
        },
        onDismissCallback: () => setState(() {
          isLoadingButton = false;
        }),
        isTwoButton: false,
      );
      return; // Dừng lại nếu không có ảnh
    }
    // Kiểm tra trạng thái 3 hoặc 4 và ảnh không được trống
    if ((editStatusIndex == 4 || editStatusIndex == 5) &&
        selectedImage == null &&
        (widget.detailsOrderPickUp?.data.orderPickupImage == null ||
            widget.detailsOrderPickUp?.data.orderPickupImage == '')) {
      showCustomDialogModal(
        context: navigatorKey.currentContext!,
        textDesc: "Hình ảnh không được để trống",
        title: "Thông báo lỗi",
        colorButtonOk: Colors.red,
        btnOKText: "Xác nhận",
        typeDialog: "error",
        eventButtonOKPress: () {
          Future.delayed(const Duration(microseconds: 800), () {
            setState(() {
              isLoadingButton = false;
            });
          });
        },
        onDismissCallback: () => setState(() {
          isLoadingButton = false;
        }),
        isTwoButton: false,
      );
      return; // Dừng lại nếu không có ảnh
    }
    // Xử lý ảnh dựa theo trạng thái
    if (selectedImage != null) {
      // Nếu có chọn ảnh mới thì dùng ảnh mới
      Uint8List imageBytes = await selectedImage!.readAsBytes();
      selectedImageString = base64Encode(imageBytes);
    } else if (widget.detailsOrderPickUp?.data.orderPickupImage != null &&
        widget.detailsOrderPickUp?.data.orderPickupImage != '') {
      // Nếu có ảnh URL nhưng không có ảnh mới, tải ảnh về trước khi encode Base64
      String imageUrl =
          httpImage + widget.detailsOrderPickUp!.data.orderPickupImage!;
      try {
        selectedImageString = await convertImageUrlToBase64(imageUrl);
        if (selectedImageString == null || selectedImageString!.isEmpty) {
          throw Exception("Lỗi chuyển đổi ảnh từ URL sang Base64.");
        }
      } catch (e) {
        print("❌ Lỗi khi tải ảnh từ URL: $e");
        selectedImageString = ""; // Đặt chuỗi rỗng để tránh lỗi khi gửi API
      }
    }

    context.read<UpdateStatusOrderPickupShipperBloc>().add(
          HanldeUpdateStatusOrderPickupShipper(
              orderPickUpID: orderPickUpID,
              orderPickUpType: orderPickUpType,
              branchIDEdit: branchIDEdit,
              fwd: fwd,
              orderPickUpTime: orderPickUpTime,
              orderPickUpAWB: orderPickUpAWB,
              orderPickUpGrossWeight: orderPickUpGrossWeight,
              orderPickUpNumberPackage: orderPickUpNumberPackage,
              orderPickUpPhone: orderPickUpPhone,
              orderPickUpAdrees: orderPickUpAdrees,
              orderPickUpNote: orderPickUpNote,
              orderPickUpStatus: orderPickUpStatus,
              orderPickUpImage: selectedImageString,
              orderPickupName: orderPickupName,
              longitude: longitude,
              latitude: latitude,
              orderPickupCancelDes: orderPickupCancelDes),
        );
  }

  Future<void> shipperFinish() async {
    context.read<ShipperFinishBloc>().add(HanldeShipperFinish(
        shipperLongitude: widget.detailsOrderPickUp!.data.longitude,
        shipperLatitude: widget.detailsOrderPickUp!.data.latitude,
        shipperLocation:
            widget.detailsOrderPickUp!.data.orderPickupAddress.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.8,
        expand: false,
        builder:
            (BuildContext context, ScrollController scrollControllerFilter) {
          return Container(
            color: Colors.white,
            child: Column(
              children: [
                Expanded(
                    child: MultiBlocListener(
                        listeners: [
                      BlocListener<UpdateStatusOrderPickupShipperBloc,
                              UpdateStatusOrderPickupShipperState>(
                          listener: (context, state) async {
                        if (state is UpdateStatusOrderPickupShipperSuccess) {
                          if (mounted) {
                            setState(() {
                              isLoadingButton = false;
                            });
                          }

                          final int? userID =
                              StorageUtils.instance.getInt(key: 'user_ID');

                          // Tải lại dữ liệu
                          BlocProvider.of<GetShipperListOrderScreenBloc>(
                                  context)
                              .add(FetchListOrderPickupShipper(
                            status: null,
                            startDate: null,
                            endDate: null,
                            branchId: null,
                            keywords: query,
                            pickupShipStatus: 1,
                            shipperId: userID,
                          ));
                          Navigator.popUntil(
                            context,
                            (route) => route.isFirst,
                          );
                          // Hiển thị thông báo thành công
                          showCustomDialogModal(
                              isCanCloseWhenTouchOutside: false,
                              context: navigatorKey
                                  .currentContext!, // ✅ Đảm bảo context hợp lệ
                              textDesc: "Cập nhật thành công!",
                              title: "Thông báo",
                              colorButtonOk: Colors.green,
                              btnOKText: "Xác nhận",
                              typeDialog: "success",
                              eventButtonOKPress: () async {});
                        } else if (state
                            is UpdateStatusOrderPickupShipperFailure) {
                          showCustomDialogModal(
                              context: navigatorKey.currentContext!,
                              textDesc: state.errorText ?? "Đã có lỗi xảy ra",
                              title: "Thông báo",
                              colorButtonOk: Colors.red,
                              btnOKText: "Xác nhận",
                              typeDialog: "error",
                              eventButtonOKPress: () {},
                              isTwoButton: false);
                          // log("SAI r");
                        }
                      }),
                    ],
                        child: BlocBuilder<UpdateStatusOrderPickupShipperBloc,
                                UpdateStatusOrderPickupShipperState>(
                            builder: (context, state) {
                          return SingleChildScrollView(
                            controller: scrollControllerFilter,
                            physics: const BouncingScrollPhysics(),
                            child: Form(
                                key: _formUpdateOrderPickUpShipper,
                                child: Padding(
                                  padding: EdgeInsets.all(15.h),
                                  child: Column(
                                    children: [
                                      TextApp(
                                        text: "Lên Lịch PickUp cho KANGO",
                                        color: const Color.fromRGBO(
                                            52, 71, 103, 1),
                                        fontFamily: "OpenSans",
                                        fontWeight: FontWeight.bold,
                                        fontsize: 20.sp,
                                      ),
                                      SizedBox(
                                        height: 20.h,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          widget.detailsOrderPickUp?.data
                                                      .orderPickupId !=
                                                  null
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    TextApp(
                                                      text: " Trạng thái",
                                                      fontsize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                    SizedBox(
                                                      height: 10.h,
                                                    ),
                                                    SizedBox(
                                                      width: 1.sw,
                                                      // height: 40.w,
                                                      child:
                                                          CustomTextFormField(
                                                        readonly: true,
                                                        controller: controllers[
                                                            'status']!,
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
                                                          angle: 90 *
                                                              math.pi /
                                                              180,
                                                          child: Icon(
                                                            Icons.chevron_right,
                                                            size: 32.sp,
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.5),
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          showMyCustomModalBottomSheet(
                                                              context: context,
                                                              isScroll: true,
                                                              itemCount:
                                                                  listStatus
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                return Column(
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left:
                                                                              20.w),
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          Navigator.pop(
                                                                              context);
                                                                          setState(
                                                                              () {
                                                                            controllers['status']!.text =
                                                                                listStatus[index];
                                                                            editStatusIndex =
                                                                                index;
                                                                          });
                                                                        },
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Icon(
                                                                              iconStatus[index],
                                                                              size: 35.sp,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 10.w,
                                                                            ),
                                                                            TextApp(
                                                                              text: listStatus[index],
                                                                              color: Colors.black,
                                                                              fontsize: 20.sp,
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Divider(
                                                                      height:
                                                                          25.h,
                                                                    )
                                                                  ],
                                                                );
                                                              });
                                                        },
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 20.h,
                                                    ),
                                                  ],
                                                )
                                              : Container(),
                                          widget.detailsOrderPickUp?.data
                                                      .orderPickupId !=
                                                  null
                                              ? (controllers['status']!.text ==
                                                          listStatus[0] ||
                                                      controllers['status']!
                                                              .text ==
                                                          listStatus[1] ||
                                                      controllers['status']!
                                                              .text ==
                                                          listStatus[2] ||
                                                      controllers['status']!
                                                              .text ==
                                                          listStatus[3] ||
                                                      controllers['status']!
                                                              .text ==
                                                          listStatus[6])
                                                  ? Container()
                                                  : TextApp(
                                                      text: " Hình ảnh",
                                                      fontsize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    )
                                              : Container(),
                                          widget.detailsOrderPickUp?.data
                                                      .orderPickupId !=
                                                  null
                                              ? (controllers['status']!.text ==
                                                          listStatus[0] ||
                                                      controllers['status']!
                                                              .text ==
                                                          listStatus[1] ||
                                                      controllers['status']!
                                                              .text ==
                                                          listStatus[2] ||
                                                      controllers['status']!
                                                              .text ==
                                                          listStatus[3] ||
                                                      controllers['status']!
                                                              .text ==
                                                          listStatus[6])
                                                  ? Container()
                                                  : (widget.detailsOrderPickUp?.data
                                                                  .orderPickupImage !=
                                                              null &&
                                                          widget
                                                                  .detailsOrderPickUp
                                                                  ?.data
                                                                  .orderPickupImage !=
                                                              "")
                                                      ? Stack(
                                                          children: [
                                                            SizedBox(
                                                                width: 1.sw,
                                                                height: 250.w,
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.r),
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    fit: BoxFit
                                                                        .contain,
                                                                    imageUrl: httpImage +
                                                                        widget
                                                                            .detailsOrderPickUp!
                                                                            .data
                                                                            .orderPickupImage!,
                                                                    placeholder:
                                                                        (context,
                                                                                url) =>
                                                                            SizedBox(
                                                                      height:
                                                                          20.w,
                                                                      width:
                                                                          20.w,
                                                                      child: const Center(
                                                                          child:
                                                                              CircularProgressIndicator()),
                                                                    ),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        const Icon(
                                                                            Icons.error),
                                                                  ),
                                                                )),
                                                            Positioned(
                                                              top: 5.w,
                                                              right: 5.w,
                                                              child: InkWell(
                                                                onTap:
                                                                    () async {
                                                                  await deleteExistImage();
                                                                  mounted
                                                                      ? setState(
                                                                          () {})
                                                                      : null;
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
                                                                  child: Center(
                                                                      child:
                                                                          Icon(
                                                                    Icons.close,
                                                                    size: 20.sp,
                                                                    color: Colors
                                                                        .black,
                                                                  )),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : selectedImage == null
                                                          ? Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
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
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(3),
                                                                child: SizedBox(
                                                                  width: 1.sw,
                                                                  height: 200.h,
                                                                  child: Center(
                                                                      child:
                                                                          Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          await pickImage();
                                                                          mounted
                                                                              ? setState(() {})
                                                                              : null;
                                                                        },
                                                                        child: Container(
                                                                            width: 120.w,
                                                                            // height: 50.h,
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(5.r),
                                                                              color: Theme.of(context).colorScheme.primary,
                                                                            ),
                                                                            child: Padding(
                                                                                padding: EdgeInsets.all(8.w),
                                                                                child: Row(
                                                                                  children: [
                                                                                    Icon(
                                                                                      Icons.collections,
                                                                                      size: 24.sp,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: 5.w,
                                                                                    ),
                                                                                    TextApp(
                                                                                      fontsize: 14.sp,
                                                                                      text: "Chọn ảnh",
                                                                                      color: Colors.white,
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  ],
                                                                                ))),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            10.h,
                                                                      ),
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          captureImage(
                                                                              setState);
                                                                          mounted
                                                                              ? setState(() {})
                                                                              : null;
                                                                        },
                                                                        child: Container(
                                                                            width: 120.w,
                                                                            // height: 50.h,
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(5.r),
                                                                              color: Theme.of(context).colorScheme.primary,
                                                                            ),
                                                                            child: Padding(
                                                                              padding: EdgeInsets.all(8.w),
                                                                              child: Row(
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.camera,
                                                                                    size: 24.sp,
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 5.w,
                                                                                  ),
                                                                                  TextApp(
                                                                                    fontsize: 14.sp,
                                                                                    text: "Chụp ảnh",
                                                                                    color: Colors.white,
                                                                                    fontWeight: FontWeight.bold,
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
                                                          : Stack(
                                                              children: [
                                                                SizedBox(
                                                                    width: 1.sw,
                                                                    height:
                                                                        250.w,
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.r),
                                                                      child: Image
                                                                          .file(
                                                                        selectedImage!,
                                                                        fit: BoxFit
                                                                            .contain,
                                                                      ),
                                                                    )),
                                                                Positioned(
                                                                  top: 5.w,
                                                                  right: 5.w,
                                                                  child:
                                                                      InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      await deleteImage();
                                                                      mounted
                                                                          ? setState(
                                                                              () {})
                                                                          : null;
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width: 30,
                                                                      height:
                                                                          30,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(15),
                                                                        color: Colors
                                                                            .white
                                                                            .withOpacity(0.8),
                                                                      ),
                                                                      child: Center(
                                                                          child: Icon(
                                                                        Icons
                                                                            .close,
                                                                        size: 20
                                                                            .sp,
                                                                        color: Colors
                                                                            .black,
                                                                      )),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                              : Container(),
                                          widget.detailsOrderPickUp!.data
                                                      .orderPickupId !=
                                                  null
                                              ? (controllers['status']!.text ==
                                                      listStatus[6])
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          height: 10.h,
                                                        ),
                                                        Row(
                                                          children: [
                                                            TextApp(
                                                              text:
                                                                  " Nguyên nhân huỷ bỏ",
                                                              fontsize: 14.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 10.h,
                                                        ),
                                                        TextFormField(
                                                          onTapOutside:
                                                              (event) {
                                                            FocusManager
                                                                .instance
                                                                .primaryFocus
                                                                ?.unfocus();
                                                          },
                                                          controller: controllers[
                                                              'cancle_reason']!,
                                                          keyboardType:
                                                              TextInputType
                                                                  .multiline,
                                                          minLines: 2,
                                                          maxLines: 5,
                                                          style: TextStyle(
                                                              fontSize: 14.sp,
                                                              color:
                                                                  Colors.black),
                                                          cursorColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          decoration:
                                                              InputDecoration(
                                                            fillColor: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary,
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary,
                                                                  width: 2.0),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.r),
                                                            ),
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.r),
                                                            ),
                                                            hintText: '',
                                                            isDense: true,
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    20.w),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 20.h,
                                                        )
                                                      ],
                                                    )
                                                  : Container()
                                              : Container(),
                                          SizedBox(
                                            height: 20.h,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  TextApp(
                                                    text: " Thời gian PickUp",
                                                    fontsize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  TextApp(
                                                    text: " *",
                                                    fontsize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10.h,
                                              ),
                                              CustomTextFormField(
                                                readonly: true,
                                                controller:
                                                    controllers['datePickUp']!,
                                                validator: (value) {
                                                  if (value != null &&
                                                      value.isNotEmpty) {
                                                    return null;
                                                  }
                                                  return "Không được để trống";
                                                },
                                                hintText: '',
                                                suffixIcon: Icon(
                                                  Icons.calendar_month,
                                                  size: 32.sp,
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                ),
                                                onTap: pickDateAndTime,
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20.h,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  TextApp(
                                                    text: " Ghi chú",
                                                    fontsize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10.h,
                                              ),
                                              CustomTextFormField(
                                                  readonly: true,
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: TextApp(
                                                            text: 'Sửa ghi chú',
                                                            fontsize: 16.sp,
                                                            color: Colors.black,
                                                          ),
                                                          content: CustomTextFormField(
                                                              controller:
                                                                  controllers[
                                                                      'note']!,
                                                              hintText: ''),
                                                          actions: [
                                                            ButtonApp(
                                                                event: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                text: 'OK',
                                                                colorText:
                                                                    Colors
                                                                        .white,
                                                                backgroundColor:
                                                                    Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .primary,
                                                                outlineColor: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary)
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  controller:
                                                      controllers['note']!,
                                                  hintText: '')
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20.h,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                // width: 100.w,
                                                child: !isLoadingButton
                                                    ? ButtonApp(
                                                        event: () {
                                                          if (_formUpdateOrderPickUpShipper
                                                                  .currentState!
                                                                  .validate() &&
                                                              editStatusIndex !=
                                                                  0) {
                                                            onHandleUpdateOrderPickUp(
                                                                orderPickUpID: widget
                                                                    .detailsOrderPickUp!
                                                                    .data
                                                                    .orderPickupId,
                                                                orderPickUpType: widget
                                                                    .detailsOrderPickUp!
                                                                    .data
                                                                    .orderPickupType,
                                                                branchIDEdit: widget
                                                                    .detailsOrderPickUp!
                                                                    .data
                                                                    .branchId,
                                                                fwd: widget
                                                                    .detailsOrderPickUp!
                                                                    .data
                                                                    .fwdId,
                                                                orderPickUpTime: controllers['datePickUp']!
                                                                    .text,
                                                                orderPickUpAWB: widget
                                                                    .detailsOrderPickUp!
                                                                    .data
                                                                    .orderPickupAwb,
                                                                orderPickUpGrossWeight: widget
                                                                    .detailsOrderPickUp!
                                                                    .data
                                                                    .orderPickupGrossWeight
                                                                    .toString(),
                                                                orderPickUpNumberPackage: widget
                                                                    .detailsOrderPickUp!
                                                                    .data
                                                                    .orderPickupNumberPackages
                                                                    .toString(),
                                                                orderPickUpPhone: widget
                                                                    .detailsOrderPickUp!
                                                                    .data
                                                                    .orderPickupPhone
                                                                    .toString(),
                                                                orderPickUpAdrees: widget
                                                                    .detailsOrderPickUp!
                                                                    .data
                                                                    .orderPickupAddress
                                                                    .toString(),
                                                                orderPickupName: widget.detailsOrderPickUp!.data.orderPickupName,
                                                                orderPickUpNote: controllers['note']!.text,
                                                                orderPickUpStatus: editStatusIndex,
                                                                longitude: double.parse(widget.detailsOrderPickUp!.data.longitude),
                                                                latitude: double.parse(widget.detailsOrderPickUp!.data.latitude),
                                                                orderPickupCancelDes: widget.detailsOrderPickUp!.data.orderPickupCancelDes);
                                                          } else if (_formUpdateOrderPickUpShipper
                                                                  .currentState!
                                                                  .validate() &&
                                                              editStatusIndex ==
                                                                  0) {
                                                            showCustomDialogModal(
                                                                context:
                                                                    navigatorKey
                                                                        .currentContext!,
                                                                textDesc:
                                                                    "Vui lòng chuyển trạng thái sang Đang đi lấy",
                                                                title:
                                                                    "Thông báo",
                                                                colorButtonOk:
                                                                    Colors.red,
                                                                btnOKText:
                                                                    "Xác nhận",
                                                                typeDialog:
                                                                    "error",
                                                                eventButtonOKPress:
                                                                    () {},
                                                                isTwoButton:
                                                                    false);
                                                          }
                                                        },
                                                        text: widget
                                                                    .detailsOrderPickUp
                                                                    ?.data
                                                                    .orderPickupId !=
                                                                null
                                                            ? "Cập nhật"
                                                            : "Tạo",
                                                        fontsize: 14.sp,
                                                        colorText: Colors.white,
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                        outlineColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )
                                                    : const Center(
                                                        child:
                                                            CircularProgressIndicator()),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                          );
                        })))
              ],
            ),
          );
        });
  }
}
