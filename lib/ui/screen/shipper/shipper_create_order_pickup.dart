import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:scan_barcode_app/bloc/order_pickup/details/details_order_pickup_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/update/update_order_pickup_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/update/update_order_pickup_event.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/models/order_pickup/details_order_pick_up.dart';
import 'package:scan_barcode_app/data/models/utils/list_branchs_model.dart';
import 'package:scan_barcode_app/ui/screen/maps/map_order_pickup.dart';
import 'package:scan_barcode_app/ui/theme/theme.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'dart:math' as math;

class CreateNewOrderPickUpShipper extends StatefulWidget {
  final int? orderPickupID;
  const CreateNewOrderPickUpShipper({required this.orderPickupID, super.key});

  @override
  State<CreateNewOrderPickUpShipper> createState() =>
      _CreateNewOrderPickUpShipperState();
}

class _CreateNewOrderPickUpShipperState
    extends State<CreateNewOrderPickUpShipper> {
  final _formOrderPickUpShipper = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {};
  final ImagePicker picker = ImagePicker();
  File? selectedImage;
  String? selectedImageString;

  List<String> listVehicle = [
    "Xe tải",
    "Xe bán tải",
    "Xe máy",
  ];

  DetailsOrderPickUpModel? detailsOrderPickUp;
  bool isLoadingButton = false;
  BranchResponse? branchResponse;
  Future<void> getBranchKango() async {
    String? branchResponseJson =
        StorageUtils.instance.getString(key: 'branch_response');
    if (branchResponseJson != null) {
      branchResponse = BranchResponse.fromJson(jsonDecode(branchResponseJson));
      log("GET BRANCH OK LIST");
    }
  }

  Future<void> onGetDetailsOrderPickup(int orderPickupID) async {
    context.read<DetailsOrderPickupBloc>().add(
          HanldeGetDetailsOrderPickup(orderPickupID: orderPickupID),
        );
  }

  Future<void> autoFillData() async {
    setState(() {
      controllers['vehicle']!.text =
          listVehicle[detailsOrderPickUp!.data.orderPickupType];
      vehicleID = detailsOrderPickUp!.data.orderPickupType;
      _datePickUpController.text = formatDateTime(
          detailsOrderPickUp!.data.orderPickupDateTime.toString());
      controllers['address']!.text =
          detailsOrderPickUp!.data.orderPickupAddress ?? '';
      controllers['longitude']!.text = detailsOrderPickUp!.data.longitude;
      controllers['latitude']!.text = detailsOrderPickUp!.data.latitude;
      controllers['branch']!.text = branchResponse!
          .branchs[detailsOrderPickUp!.data.branchId - 1].branchName;
      branhID = detailsOrderPickUp!.data.branchId;
      controllers['phone']!.text =
          detailsOrderPickUp!.data.orderPickupPhone ?? '';
      controllers['awbCode']!.text =
          detailsOrderPickUp!.data.orderPickupAwb.toString();
      controllers['weight']!.text =
          detailsOrderPickUp!.data.orderPickupGrossWeight.toString();
      controllers['quantity']!.text =
          detailsOrderPickUp!.data.orderPickupNumberPackages.toString();
      controllers['note']!.text =
          detailsOrderPickUp!.data.orderPickupNote ?? '';
      controllers['status']!.text =
          listStatus[detailsOrderPickUp!.data.orderPickupStatus];
      editStatusIndex = detailsOrderPickUp!.data.orderPickupStatus;
    });
  }

  Future<void> init() async {
    await getBranchKango();

    if (widget.orderPickupID != null) {
      await onGetDetailsOrderPickup(widget.orderPickupID!);
    }
  }

  void initializeControllers(List<String> keys) {
    for (var key in keys) {
      controllers[key] = TextEditingController();
    }
  }

  @override
  void initState() {
    super.initState();
    initializeControllers([
      'weight',
      'phone',
      'address',
      'latitude',
      'longitude',
      'awbCode',
      'quantity',
      'note',
      'vehicle',
      'branch',
      'status',
      'cancle_reason'
    ]);
    init();
  }

  int? vehicleID;
  int? branhID;
  int? editStatusIndex;

  List<IconData> iconVehicle = [
    Icons.fire_truck,
    Icons.car_crash,
    Icons.motorcycle
  ];
  DateTime dateTime = DateTime(2022, 12, 24, 5, 30);
  final _datePickUpController = TextEditingController();

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
      _datePickUpController.text =
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
    final DateFormat formatter = DateFormat('dd-MM-yy HH:mm:ss');
    return formatter.format(dt);
  }

  List<String> listStatus = [
    "Đang chờ duyệt", //0
    "Đang chờ xác nhận", //1
    "Đã xác nhận"
        "Đang đi lấy", //2
    "Đã lấy", //3
    "Đã pickup", //4
    "Đã huỷ" //5
  ];

  List<IconData> iconStatus = [
    Icons.history,
    Icons.info,
    Icons.delivery_dining,
    Icons.get_app,
    Icons.check,
    Icons.cancel,
  ];

  Future<void> pickImage() async {
    final returndImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returndImage == null) return;
    setState(() {
      selectedImage = File(returndImage.path);
    });
  }

  Future<void> deleteImage() async {
    setState(() {
      selectedImage = null;
    });
  }

  Future<void> deleteExistImage() async {
    setState(() {
      detailsOrderPickUp!.data.orderPickupImage = null;
    });
  } // xoá ảnh nếu đã có từ data trả về

  void captureImage() async {
    final XFile? capturedImage =
        await picker.pickImage(source: ImageSource.camera);
    if (capturedImage != null) {
      setState(() {
        selectedImage = File(capturedImage.path);
      });
    }
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
    required String orderPickUpTime,
    required String orderPickUpAWB,
    required String orderPickUpGrossWeight,
    required String orderPickUpNumberPackage,
    required String orderPickUpPhone,
    required String orderPickUpAdrees,
    required double orderPickUpLongitude,
    required double orderPickUpLatitude,
    required String? orderPickUpNote,
    required int? orderPickUpStatus,
    required String? orderPickupCancelDes,
  }) async {
    mounted
        ? setState(() {
            isLoadingButton = true;
          })
        : null;
    if (selectedImage != null) {
      Uint8List imagebytes =
          await selectedImage!.readAsBytes(); //convert to bytes
      String base64string =
          base64Encode(imagebytes); //convert bytes to base64 string
      selectedImageString = base64string;
    }
    context.read<UpdateOrderPickupBloc>().add(
          HanldeUpdateOrderPickup(
              fwd: null,
              orderPickupName: null,
              orderPickUpID: orderPickUpID,
              orderPickUpType: orderPickUpType,
              branchIDEdit: branchIDEdit,
              orderPickUpTime: orderPickUpTime,
              orderPickUpAWB: orderPickUpAWB,
              orderPickUpGrossWeight: orderPickUpGrossWeight,
              orderPickUpNumberPackage: orderPickUpNumberPackage,
              orderPickUpPhone: orderPickUpPhone,
              orderPickUpAdrees: orderPickUpAdrees,
              orderPickUpNote: orderPickUpNote,
              orderPickUpStatus: orderPickUpStatus,
              orderPickUpImage: selectedImageString,
              longitude: orderPickUpLongitude,
              latitude: orderPickUpLatitude,
              orderPickupCancelDes: orderPickupCancelDes),
        );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.8,
      expand: false,
      builder: (BuildContext context, ScrollController scrollControllerFilter) {
        return Container(
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: MultiBlocListener(
                  listeners: [
                    BlocListener<DetailsOrderPickupBloc,
                            DetailsOrderPickupState>(
                        listener: (context, state) async {
                      if (state is HanldeGetDetailsOrderPickupSuccess) {
                        setState(() {
                          detailsOrderPickUp = state.detailsOrderPickUpModel;
                          autoFillData();
                        });
                      } else if (state is HanldeGetDetailsOrderPickupFailure) {
                        log("SAI r");
                      }
                    }),
                  ],
                  child: BlocBuilder<DetailsOrderPickupBloc,
                      DetailsOrderPickupState>(
                    builder: (context, state) {
                      return SingleChildScrollView(
                        child: Form(
                          key: _formOrderPickUpShipper,
                          child: Padding(
                            padding: EdgeInsets.all(15.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextApp(
                                  text: "Lên Lịch PickUp cho KANGO",
                                  color: const Color.fromRGBO(52, 71, 103, 1),
                                  fontFamily: "OpenSans",
                                  fontWeight: FontWeight.bold,
                                  fontsize: 20.sp,
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    widget.orderPickupID != null
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TextApp(
                                                text: " Trạng thái",
                                                fontsize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              SizedBox(
                                                height: 10.h,
                                              ),
                                              SizedBox(
                                                width: 1.sw,
                                                // height: 40.w,
                                                child: CustomTextFormField(
                                                  readonly: true,
                                                  controller:
                                                      controllers['status']!,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Nội dung không được để trống';
                                                    }
                                                    return null;
                                                  },
                                                  hintText: '',
                                                  suffixIcon: Transform.rotate(
                                                    angle: 90 * math.pi / 180,
                                                    child: Icon(
                                                      Icons.chevron_right,
                                                      size: 32.sp,
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    showMyCustomModalBottomSheet(
                                                        isScroll: true,
                                                        context: context,
                                                        itemCount:
                                                            listStatus.length,
                                                        itemBuilder:
                                                            (context, index) {
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
                                                                      controllers['status']!
                                                                              .text =
                                                                          listStatus[
                                                                              index];
                                                                      editStatusIndex =
                                                                          index;
                                                                    });
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                        iconStatus[
                                                                            index],
                                                                        size: 35
                                                                            .sp,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            10.w,
                                                                      ),
                                                                      TextApp(
                                                                        text: listStatus[
                                                                            index],
                                                                        color: Colors
                                                                            .black,
                                                                        fontsize:
                                                                            20.sp,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Divider(
                                                                height: 25.h,
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
                                    widget.orderPickupID != null
                                        ? (controllers['status']!.text ==
                                                    listStatus[0] ||
                                                controllers['status']!.text ==
                                                    listStatus[1] ||
                                                controllers['status']!.text ==
                                                    listStatus[2] ||
                                                controllers['status']!.text ==
                                                    listStatus[6])
                                            ? Container()
                                            : TextApp(
                                                text: " Hình ảnh",
                                                fontsize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              )
                                        : Container(),
                                    widget.orderPickupID != null
                                        ? (controllers['status']!.text ==
                                                    listStatus[0] ||
                                                controllers['status']!.text ==
                                                    listStatus[1] ||
                                                controllers['status']!.text ==
                                                    listStatus[2] ||
                                                controllers['status']!.text ==
                                                    listStatus[6])
                                            ? Container()
                                            : (detailsOrderPickUp?.data
                                                            .orderPickupImage !=
                                                        null &&
                                                    detailsOrderPickUp?.data
                                                            .orderPickupImage !=
                                                        "")
                                                ? Stack(
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
                                                                CachedNetworkImage(
                                                              fit: BoxFit.cover,
                                                              imageUrl: httpImage +
                                                                  detailsOrderPickUp!
                                                                      .data
                                                                      .orderPickupImage!,
                                                              placeholder:
                                                                  (context,
                                                                          url) =>
                                                                      SizedBox(
                                                                height: 20.w,
                                                                width: 20.w,
                                                                child: const Center(
                                                                    child:
                                                                        CircularProgressIndicator()),
                                                              ),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  const Icon(Icons
                                                                      .error),
                                                            ),
                                                          )),
                                                      Positioned(
                                                        top: 5.w,
                                                        right: 5.w,
                                                        child: InkWell(
                                                          onTap: () async {
                                                            await deleteExistImage();
                                                            mounted
                                                                ? setState(
                                                                    () {})
                                                                : null;
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
                                                              color:
                                                                  Colors.black,
                                                            )),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : selectedImage == null
                                                    ? Container(
                                                        padding: EdgeInsets.all(
                                                            10.w),
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
                                                              const EdgeInsets
                                                                  .all(3),
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
                                                                InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    await pickImage();
                                                                    mounted
                                                                        ? setState(
                                                                            () {})
                                                                        : null;
                                                                  },
                                                                  child: Container(
                                                                      width: 120.w,
                                                                      // height: 50.h,
                                                                      decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.r),
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .primary,
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
                                                                  height: 10.h,
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    captureImage();
                                                                    mounted
                                                                        ? setState(
                                                                            () {})
                                                                        : null;
                                                                  },
                                                                  child: Container(
                                                                      width: 120.w,
                                                                      // height: 50.h,
                                                                      decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.r),
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .primary,
                                                                      ),
                                                                      child: Padding(
                                                                        padding:
                                                                            EdgeInsets.all(8.w),
                                                                        child:
                                                                            Row(
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
                                                              height: 250.w,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.r),
                                                                child:
                                                                    Image.file(
                                                                  selectedImage!,
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),
                                                              )),
                                                          Positioned(
                                                            top: 5.w,
                                                            right: 5.w,
                                                            child: InkWell(
                                                              onTap: () async {
                                                                await deleteImage();
                                                                mounted
                                                                    ? setState(
                                                                        () {})
                                                                    : null;
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
                                                      )
                                        : Container(),
                                    controllers['status']!.text == listStatus[6]
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 10.h,
                                              ),
                                              Row(
                                                children: [
                                                  TextApp(
                                                    text: " Nguyên nhân huỷ bỏ",
                                                    fontsize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10.h,
                                              ),
                                              TextFormField(
                                                onTapOutside: (event) {
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                },
                                                controller: controllers[
                                                    'cancle_reason']!,
                                                keyboardType:
                                                    TextInputType.multiline,
                                                minLines: 2,
                                                maxLines: 5,
                                                style: TextStyle(
                                                    fontSize: 14.sp,
                                                    color: Colors.black),
                                                cursorColor: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                decoration: InputDecoration(
                                                  fillColor: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                        width: 2.0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.r),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.r),
                                                  ),
                                                  hintText: '',
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.all(20.w),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20.h,
                                              )
                                            ],
                                          )
                                        : Container(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            TextApp(
                                              text: " Loại xe",
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
                                          controller: controllers['vehicle']!,
                                          validator: (value) {
                                            if (value != null &&
                                                value.isNotEmpty) {
                                              return null;
                                            }
                                            return "Không được để trống";
                                          },
                                          hintText: '',
                                          suffixIcon: Transform.rotate(
                                            angle: 90 * math.pi / 180,
                                            child: Icon(
                                              Icons.chevron_right,
                                              size: 32.sp,
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                            ),
                                          ),
                                          onTap: () {
                                            showMyCustomModalBottomSheet(
                                                context: context,
                                                height: 0.62,
                                                isScroll: true,
                                                itemCount: listVehicle.length,
                                                itemBuilder: (context, index) {
                                                  return Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 20.w),
                                                        child: InkWell(
                                                          onTap: () async {
                                                            Navigator.pop(
                                                                context);
                                                            mounted
                                                                ? setState(() {
                                                                    controllers['vehicle']!
                                                                            .text =
                                                                        listVehicle[
                                                                            index];
                                                                    vehicleID =
                                                                        index;
                                                                  })
                                                                : null;
                                                          },
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                iconVehicle[
                                                                    index],
                                                                size: 35.sp,
                                                              ),
                                                              SizedBox(
                                                                width: 10.w,
                                                              ),
                                                              TextApp(
                                                                text:
                                                                    listVehicle[
                                                                        index],
                                                                color: Colors
                                                                    .black,
                                                                fontsize: 20.sp,
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Divider(
                                                        height: 25.h,
                                                      )
                                                    ],
                                                  );
                                                });
                                          },
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
                                          controller: _datePickUpController,
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
                                            color:
                                                Colors.black.withOpacity(0.5),
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
                                              text: " Chi nhánh",
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
                                          controller: controllers['branch']!,
                                          validator: (value) {
                                            if (value != null &&
                                                value.isNotEmpty) {
                                              return null;
                                            }
                                            return "Không được để trống";
                                          },
                                          hintText: '',
                                          suffixIcon: Transform.rotate(
                                            angle: 90 * math.pi / 180,
                                            child: Icon(
                                              Icons.chevron_right,
                                              size: 32.sp,
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                            ),
                                          ),
                                          onTap: () {
                                            showMyCustomModalBottomSheet(
                                                context: context,
                                                isScroll: true,
                                                height: 0.62,
                                                itemCount: branchResponse
                                                        ?.branchs.length ??
                                                    0,
                                                itemBuilder: (context, index) {
                                                  return (branchResponse!
                                                              .branchs
                                                              .isEmpty ||
                                                          branchResponse
                                                                  ?.branchs ==
                                                              null)
                                                      ? Container()
                                                      : Column(
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          20.w),
                                                              child: InkWell(
                                                                onTap:
                                                                    () async {
                                                                  Navigator.pop(
                                                                      context);
                                                                  mounted
                                                                      ? setState(
                                                                          () {
                                                                          controllers['branch']!.text = branchResponse!
                                                                              .branchs[index]
                                                                              .branchName;
                                                                          branhID = branchResponse!
                                                                              .branchs[index]
                                                                              .branchId;
                                                                        })
                                                                      : null;
                                                                },
                                                                child: Row(
                                                                  children: [
                                                                    TextApp(
                                                                      text: branchResponse!
                                                                          .branchs[
                                                                              index]
                                                                          .branchName,
                                                                      color: Colors
                                                                          .black,
                                                                      fontsize:
                                                                          20.sp,
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            Divider(
                                                              height: 25.h,
                                                            )
                                                          ],
                                                        );
                                                });
                                          },
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                TextApp(
                                                  text: " Địa chỉ",
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
                                            InkWell(
                                              onTap: () async {
                                                final result =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MapOrderPickUpScreen()),
                                                );

                                                if (result != null &&
                                                    result is Map<String,
                                                        dynamic>) {
                                                  print(
                                                      'Selected address: ${result['address']}');
                                                  print(
                                                      'longitude value: ${result['longitude']}');
                                                  print(
                                                      'latitude value: ${result['latitude']}');

                                                  setState(() {
                                                    controllers['address']!
                                                            .text =
                                                        result['address']
                                                            .toString();
                                                    controllers['longitude']!
                                                            .text =
                                                        result['longitude']
                                                            .toString();
                                                    controllers['latitude']!
                                                            .text =
                                                        result['latitude']
                                                            .toString();
                                                  });
                                                }
                                              },
                                              child: TextApp(
                                                text: "Mở bản đồ",
                                                fontsize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        CustomTextFormField(
                                            readonly: true,
                                            controller: controllers['address']!,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Vui lòng chọn địa chỉ';
                                              }
                                              return null;
                                            },
                                            hintText:
                                                'Mở bản đồ để chọn địa chỉ'),
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
                                              text: " Số điện thoại liên hệ",
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
                                            keyboardType: TextInputType.number,
                                            controller: controllers['phone']!,
                                            textInputFormatter: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp("[0-9]")),
                                            ],
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Vui lòng nhập số điện thoại';
                                              }

                                              bool phoneValid = RegExp(
                                                      r'^(?:[+0]9)?[0-9]{10}$')
                                                  .hasMatch(value);

                                              if (!phoneValid) {
                                                return "Số điện thoại không hợp lệ";
                                              } else {
                                                return null;
                                              }
                                            },
                                            hintText: 'Nhập số điện thoại'),
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
                                              text: " Mã AWB",
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
                                            controller: controllers['awbCode']!,
                                            validator: (value) {
                                              if (value != null &&
                                                  value.isNotEmpty) {
                                                return null;
                                              }
                                              return "Không được để trống";
                                            },
                                            hintText: ''),
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
                                              text: " Cân nặng",
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
                                            keyboardType: TextInputType.number,
                                            controller: controllers['weight']!,
                                            textInputFormatter: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp("[0-9]")),
                                            ],
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Không được để trống';
                                              }
                                              return null;
                                            },
                                            hintText: ''),
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
                                              text: " Số kiện",
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
                                            keyboardType: TextInputType.number,
                                            controller:
                                                controllers['quantity']!,
                                            textInputFormatter: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp("[0-9]")),
                                            ],
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Không được để trống';
                                              }
                                              return null;
                                            },
                                            hintText: ''),
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
                                        TextFormField(
                                          onTapOutside: (event) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          controller: controllers['note']!,
                                          keyboardType: TextInputType.multiline,
                                          minLines: 1,
                                          maxLines: 3,
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.black),
                                          cursorColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          decoration: InputDecoration(
                                            fillColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  width: 2.0),
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            hintText: '',
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.all(20.w),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          // width: 100.w,
                                          child: !isLoadingButton
                                              ? ButtonApp(
                                                  event: () {
                                                    if (_formOrderPickUpShipper
                                                        .currentState!
                                                        .validate()) {
                                                      onHandleUpdateOrderPickUp(
                                                          orderPickUpID: widget
                                                              .orderPickupID,
                                                          orderPickUpType:
                                                              vehicleID!,
                                                          branchIDEdit:
                                                              branhID!,
                                                          orderPickUpTime:
                                                              _datePickUpController
                                                                  .text,
                                                          orderPickUpAWB:
                                                              controllers['awbCode']!
                                                                  .text,
                                                          orderPickUpGrossWeight:
                                                              controllers['weight']!
                                                                  .text,
                                                          orderPickUpNumberPackage:
                                                              controllers['quantity']!
                                                                  .text,
                                                          orderPickUpPhone:
                                                              controllers['phone']!
                                                                  .text,
                                                          orderPickUpAdrees:
                                                              controllers['address']!
                                                                  .text,
                                                          orderPickUpLongitude:
                                                              double.parse(
                                                                  controllers['longitude']!
                                                                      .text),
                                                          orderPickUpLatitude:
                                                              double.parse(
                                                                  controllers['latitude']!.text),
                                                          orderPickUpNote: controllers['note']!.text,
                                                          orderPickUpStatus: editStatusIndex,
                                                          orderPickupCancelDes: editStatusIndex == 6 ? controllers['cancle_reason']!.text : null);
                                                    }
                                                  },
                                                  text: widget.orderPickupID !=
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
                                                  fontWeight: FontWeight.bold,
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
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
