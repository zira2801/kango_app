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
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/order_pickup/details/details_order_pickup_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/get_fwd_list/get_fwd_list_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/screen/order_pickup_screen_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/update/update_order_pickup_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/update/update_order_pickup_event.dart';
import 'package:scan_barcode_app/bloc/order_pickup/update/update_order_pickup_state.dart';
import 'package:scan_barcode_app/bloc/shipper/shipper_list_order/shipper_list_order_screen_bloc.dart';
import 'package:scan_barcode_app/data/models/order_pickup/details_order_pick_up.dart';
import 'package:scan_barcode_app/data/models/utils/list_branchs_model.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/home/index.dart';
import 'package:scan_barcode_app/ui/screen/maps/map_order_pickup.dart';
import 'package:scan_barcode_app/ui/screen/order/order_pickup_screen.dart';
import 'package:scan_barcode_app/ui/screen/shipper/index_shipper.dart';
import 'package:scan_barcode_app/ui/theme/theme.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/image/enhanced_Image_view.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'dart:math' as math;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:http/http.dart' as http;

class CreateNewOrderPickUpScreen extends StatefulWidget {
  final int? orderPickupID;
  final bool isShipper;
  final bool isOpsLead;
  final bool isSale;
  final int? fwdID;
  const CreateNewOrderPickUpScreen(
      {required this.orderPickupID,
      required this.isShipper,
      this.isSale = false,
      this.isOpsLead = false,
      this.fwdID,
      super.key});

  @override
  State<CreateNewOrderPickUpScreen> createState() =>
      _CreateNewOrderPickUpScreenState();
}

class _CreateNewOrderPickUpScreenState
    extends State<CreateNewOrderPickUpScreen> {
  final _formField = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {};
  final ImagePicker picker = ImagePicker();
  final scrollListFWDController = ScrollController();
  File? selectedImage;
  String? selectedImageString;
  String query = '';
  List<String> listVehicle = [
    "Xe tải",
    "Xe bán tải",
    "Xe máy",
  ];

  DetailsOrderPickUpModel? detailsOrderPickUp;
  bool isLoadingButton = false;
  BranchResponse? branchResponse;

  Future<void> onGetDetailsOrderPickup(int orderPickupID) async {
    context.read<DetailsOrderPickupBloc>().add(
          HanldeGetDetailsOrderPickup(orderPickupID: orderPickupID),
        );
  }

  Future<void> getBranchKango() async {
    String? branchResponseJson =
        StorageUtils.instance.getString(key: 'branch_response');
    if (branchResponseJson != null) {
      branchResponse = BranchResponse.fromJson(jsonDecode(branchResponseJson));
      log("GET BRANCH OK LIST");
    }
  }

  void _fetchInitialData() {
    BlocProvider.of<GetListOrderPickupScreenBloc>(context).add(
      FetchListOrderPickup(
        fwdId: widget.fwdID,
        status: null,
        startDate: null,
        endDate: null,
        branchId: null,
        keywords: query,
      ),
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
      controllers['longitude']!.text = detailsOrderPickUp!.data.longitude;
      controllers['latitude']!.text = detailsOrderPickUp!.data.latitude;
      editStatusIndex = detailsOrderPickUp!.data.orderPickupStatus;
      controllers['senderName']!.text =
          detailsOrderPickUp!.data.orderPickupName ?? '';
      controllers['fwdReciver']!.text =
          detailsOrderPickUp!.data.fwd?.userCompanyName ?? '';
      fwdID = detailsOrderPickUp!.data.fwd?.userId;
      controllers['cancle_reason']!.text =
          detailsOrderPickUp!.data.orderPickupCancelDes ?? '';
      selectedImageString = detailsOrderPickUp!.data.orderPickupImage;
    });
  }

  Future<void> init() async {
    await getBranchKango();
    onGetListFWD(keywords: null);

    if (widget.orderPickupID != null) {
      await onGetDetailsOrderPickup(widget.orderPickupID!);
    }
  }

  void initializeControllers(List<String> keys) {
    for (var key in keys) {
      controllers[key] = TextEditingController();
    }
  }

  void onGetListFWD({required String? keywords}) {
    context.read<GetListFWDScreenBloc>().add(
          FetchListFWD(keywords: keywords),
        );
  }

  @override
  void initState() {
    super.initState();
    initializeControllers([
      'search',
      'fwdReciver',
      'weight',
      'senderName',
      'phone',
      'address',
      'longitude',
      'latitude',
      'awbCode',
      'quantity',
      'note',
      'vehicle',
      'branch',
      'status',
      'cancle_reason'
    ]);
    init();
    scrollListFWDController.addListener(_onScrollListFwd);
  }

  void _onScrollListFwd() {
    if (scrollListFWDController.position.maxScrollExtent ==
        scrollListFWDController.offset) {
      BlocProvider.of<GetListFWDScreenBloc>(context)
          .add(LoadMoreListFWD(keywords: controllers['search']!.text));
    }
  }

  int? vehicleID;
  int? branhID;
  int? editStatusIndex;
  int? fwdID;

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

//Chọn thời gian
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
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
    return formatter.format(dt);
  }

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
    Icons.check_circle_outline,
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
      selectedImage = null;
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
    scrollListFWDController.dispose();
    super.dispose();
  }

  Future<void> onHandleUpdateOrderPickUp({
    required int? orderPickUpID,
    required int? fwd,
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
    required String? orderPickupName,
    required int? orderPickUpStatus,
    required String? orderPickupCancelDes,
  }) async {
    // Set trạng thái loading
    mounted
        ? setState(() {
            isLoadingButton = true;
          })
        : null;

    // Kiểm tra hợp lệ trước khi gửi request
    bool isValidToSubmit = true;
    String? errorMessage;

    //Kiểm tra trạng thái 6 (Hủy bỏ)
    if (editStatusIndex == 6 &&
        (orderPickupCancelDes == null || orderPickupCancelDes == '')) {
      isValidToSubmit = false;
      errorMessage = "Nguyên nhân hủy không được để trống";
    }

    // Kiểm tra trạng thái 4 hoặc 5 và ảnh không được trống
    else if ((editStatusIndex == 4 || editStatusIndex == 5) &&
        selectedImage == null &&
        (detailsOrderPickUp?.data.orderPickupImage == null ||
            detailsOrderPickUp?.data.orderPickupImage == '')) {
      isValidToSubmit = false;
      errorMessage = "Hình ảnh không được để trống";
    }

    // Hiển thị thông báo lỗi nếu không hợp lệ và dừng xử lý
    if (!isValidToSubmit) {
      setState(() {
        isLoadingButton = false;
      });

      // Thông báo lỗi client-side
      showCustomDialogModal(
        context: navigatorKey.currentContext!,
        textDesc: errorMessage!,
        title: "Thông báo lỗi",
        colorButtonOk: Colors.red,
        btnOKText: "Xác nhận",
        typeDialog: "error",
        eventButtonOKPress: () {},
        isTwoButton: false,
      );
      return;
    }

    // Xử lý ảnh chỉ khi đã vượt qua các kiểm tra hợp lệ
    // Xử lý ảnh dựa theo trạng thái
    if (selectedImage != null) {
      // Nếu có chọn ảnh mới thì dùng ảnh mới
      Uint8List imageBytes = await selectedImage!.readAsBytes();
      selectedImageString = base64Encode(imageBytes);
    } else if (detailsOrderPickUp?.data.orderPickupImage != null &&
        detailsOrderPickUp?.data.orderPickupImage != '') {
      // Nếu có ảnh URL nhưng không có ảnh mới, tải ảnh về trước khi encode Base64
      String imageUrl = httpImage + detailsOrderPickUp!.data.orderPickupImage!;
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

    // Gửi sự kiện cập nhật order chỉ khi tất cả điều kiện đã được kiểm tra
    context.read<UpdateOrderPickupBloc>().add(
          HanldeUpdateOrderPickup(
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
            fwd: fwd,
            orderPickupName: orderPickupName,
            longitude: orderPickUpLongitude,
            latitude: orderPickUpLatitude,
            orderPickupCancelDes: orderPickupCancelDes,
          ),
        );
  }

// Hàm tải ảnh từ URL và chuyển thành base64
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

  @override
  Widget build(BuildContext context) {
    final String? userPosition =
        StorageUtils.instance.getString(key: 'user_position');
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          shadowColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: TextApp(
            text: widget.orderPickupID != null
                ? "Update Order Pickup"
                : "Create Order Pickup",
            fontsize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          leading: InkWell(
              onTap: () {
                // Kiểm tra còn màn hình trong stack không
                if (widget.isShipper) {
                  context.pop();
                } else if (widget.isOpsLead) {
                  context.pop();
                } else if (widget.isSale) {
                  context.pop();
                } else {
                  context.pop();
                }
              },
              child: SizedBox(
                width: 50.w,
                height: 50.w,
                child: Icon(
                  Icons.chevron_left,
                  color: Colors.black,
                  size: 42.sp,
                ),
              )),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<DetailsOrderPickupBloc, DetailsOrderPickupState>(
                listener: (context, state) async {
              if (state is HanldeGetDetailsOrderPickupSuccess) {
                setState(() {
                  detailsOrderPickUp = state.detailsOrderPickUpModel;
                  autoFillData();
                });
              }
            }),
            BlocListener<UpdateOrderPickupBloc, UpdateOrderPickupState>(
                listener: (context, state) async {
              if (state is UpdateOrderPickupSuccess) {
                _fetchInitialData();
                mounted
                    ? setState(() {
                        isLoadingButton = false;
                      })
                    : null;
                widget.isShipper
                    ? Navigator.pop(context)
                    : Navigator.pop(context);
                showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: widget.orderPickupID != null
                        ? "Cập nhật thành công!"
                        : "Cập tạo đơn pickup thành công!",
                    title: "Thông báo",
                    colorButtonOk: Colors.green,
                    btnOKText: "Xác nhận",
                    typeDialog: "success",
                    eventButtonOKPress: () {},
                    isTwoButton: false);
              } else if (state is UpdateOrderPickupFailure) {
                mounted
                    ? setState(() {
                        isLoadingButton = false;
                      })
                    : null;
                showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: state.errorText ?? "Đã có lỗi xảy ra",
                    title: "Thông báo",
                    colorButtonOk: Colors.red,
                    btnOKText: "Xác nhận",
                    typeDialog: "error",
                    eventButtonOKPress: () {},
                    isTwoButton: false);
              }
            }),
          ],
          child: BlocBuilder<DetailsOrderPickupBloc, DetailsOrderPickupState>(
            builder: (context, state) {
              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Form(
                        key: _formField,
                        child: Column(
                          children: [
                            Container(
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.all(20.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                        angle:
                                                            90 * math.pi / 180,
                                                        child: Icon(
                                                          Icons.chevron_right,
                                                          size: 32.sp,
                                                          color: Colors.black
                                                              .withOpacity(0.5),
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
                                                                        left: 20
                                                                            .w),
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
                                                                            size:
                                                                                35.sp,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                10.w,
                                                                          ),
                                                                          TextApp(
                                                                            text:
                                                                                listStatus[index],
                                                                            color:
                                                                                Colors.black,
                                                                            fontsize:
                                                                                20.sp,
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
                                        widget.orderPickupID != null
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
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  )
                                            : Container(),
                                        widget.orderPickupID != null
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
                                                : (detailsOrderPickUp?.data
                                                                .orderPickupImage !=
                                                            null &&
                                                        detailsOrderPickUp?.data
                                                                .orderPickupImage !=
                                                            "")
                                                    ? Stack(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () async {
                                                              await Navigator.of(
                                                                      context)
                                                                  .push(
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          EnhancedImageViewer(
                                                                    imageUrl: httpImage +
                                                                        detailsOrderPickUp!
                                                                            .data
                                                                            .orderPickupImage!,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Hero(
                                                              tag:
                                                                  'imageHero${httpImage + detailsOrderPickUp!.data.orderPickupImage!}',
                                                              child: SizedBox(
                                                                  width: 1.sw,
                                                                  height: 250.w,
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.r),
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      fit: BoxFit
                                                                          .contain,
                                                                      imageUrl: httpImage +
                                                                          detailsOrderPickUp!
                                                                              .data
                                                                              .orderPickupImage!,
                                                                      placeholder:
                                                                          (context, url) =>
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
                                                            ),
                                                          ),
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
                                                                EdgeInsets.all(
                                                                    10.w),
                                                            child: DottedBorder(
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
                                                              strokeWidth: 1.5,
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
                                                                            borderRadius:
                                                                                BorderRadius.circular(5.r),
                                                                            color:
                                                                                Theme.of(context).colorScheme.primary,
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
                                                                        captureImage();
                                                                        mounted
                                                                            ? setState(() {})
                                                                            : null;
                                                                      },
                                                                      child: Container(
                                                                          width: 120.w,
                                                                          // height: 50.h,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(5.r),
                                                                            color:
                                                                                Theme.of(context).colorScheme.primary,
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
                                                                child: InkWell(
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
                                                                        child: Icon(
                                                                      Icons
                                                                          .close,
                                                                      size:
                                                                          20.sp,
                                                                      color: Colors
                                                                          .black,
                                                                    )),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                            : Container(),
                                        widget.orderPickupID != null
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
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 10.h,
                                                      ),
                                                      TextFormField(
                                                        onTapOutside: (event) {
                                                          FocusManager.instance
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
                                                          fillColor:
                                                              Theme.of(context)
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
                                          height: 10.h,
                                        ),
                                        userPosition != 'fwd'
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      TextApp(
                                                        text:
                                                            " Chọn công ty(FWD)",
                                                        fontsize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10.h,
                                                  ),
                                                  CustomTextFormField(
                                                    readonly: true,
                                                    controller: controllers[
                                                        'fwdReciver']!,
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
                                                      showModalBottomSheet(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                    15.r),
                                                            topLeft:
                                                                Radius.circular(
                                                                    15.r),
                                                          ),
                                                        ),
                                                        clipBehavior: Clip
                                                            .antiAliasWithSaveLayer,
                                                        context: context,
                                                        isScrollControlled:
                                                            true,
                                                        builder: (context) {
                                                          return DraggableScrollableSheet(
                                                            maxChildSize: 0.8,
                                                            initialChildSize:
                                                                0.8,
                                                            expand: false,
                                                            builder: (BuildContext
                                                                    context,
                                                                ScrollController
                                                                    scrollController) {
                                                              return Container(
                                                                color: Colors
                                                                    .white,
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Container(
                                                                      width:
                                                                          50.w,
                                                                      height:
                                                                          5.w,
                                                                      margin: EdgeInsets.only(
                                                                          top: 15
                                                                              .h,
                                                                          bottom:
                                                                              15.h),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10.r),
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width:
                                                                          1.sw,
                                                                      padding: EdgeInsets
                                                                          .all(15
                                                                              .w),
                                                                      child:
                                                                          TextFormField(
                                                                        onTapOutside:
                                                                            (event) {
                                                                          FocusManager
                                                                              .instance
                                                                              .primaryFocus
                                                                              ?.unfocus();
                                                                        },
                                                                        onFieldSubmitted:
                                                                            (value) {
                                                                          onGetListFWD(
                                                                              keywords: controllers['search']!.text);
                                                                        },
                                                                        // onChanged: searchProduct,
                                                                        controller:
                                                                            controllers['search'],
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.black),
                                                                        cursorColor:
                                                                            Colors.black,
                                                                        decoration: InputDecoration(
                                                                            suffixIcon: InkWell(
                                                                              onTap: () {
                                                                                log(controllers['search']!.text);
                                                                                onGetListFWD(keywords: controllers['search']!.text);
                                                                              },
                                                                              child: const Icon(Icons.search),
                                                                            ),
                                                                            filled: true,
                                                                            fillColor: Colors.white,
                                                                            focusedBorder: OutlineInputBorder(
                                                                              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                                                                              borderRadius: BorderRadius.circular(8),
                                                                            ),
                                                                            border: OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(8),
                                                                            ),
                                                                            isDense: true,
                                                                            hintText: "Tìm kiếm...",
                                                                            contentPadding: const EdgeInsets.all(15)),
                                                                      ),
                                                                    ),
                                                                    BlocBuilder<
                                                                            GetListFWDScreenBloc,
                                                                            HandleGetListFWDState>(
                                                                        builder:
                                                                            (context,
                                                                                state) {
                                                                      if (state
                                                                          is HandleGetListFWDLoading) {
                                                                        return Center(
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                100.w,
                                                                            height:
                                                                                100.w,
                                                                            child:
                                                                                Lottie.asset('assets/lottie/loading_kango.json'),
                                                                          ),
                                                                        );
                                                                      } else if (state
                                                                          is HandleGetListFWDSuccess) {
                                                                        return Expanded(
                                                                            child: state.data.isEmpty
                                                                                ? const NoDataFoundWidget()
                                                                                : SizedBox(
                                                                                    width: 1.sw,
                                                                                    child: ListView.builder(
                                                                                        padding: EdgeInsets.zero,
                                                                                        controller: scrollListFWDController,
                                                                                        itemCount: state.hasReachedMax ? state.data.length : state.data.length + 1,
                                                                                        itemBuilder: (context, index) {
                                                                                          if (index >= state.data.length) {
                                                                                            return Center(
                                                                                              child: SizedBox(
                                                                                                width: 100.w,
                                                                                                height: 100.w,
                                                                                                child: Lottie.asset('assets/lottie/loading_kango.json'),
                                                                                              ),
                                                                                            );
                                                                                          } else {
                                                                                            final dataFwd = state.data[index];
                                                                                            return Column(
                                                                                              children: [
                                                                                                Padding(
                                                                                                  padding: EdgeInsets.only(left: 15.w),
                                                                                                  child: InkWell(
                                                                                                    onTap: () async {
                                                                                                      Navigator.pop(context);

                                                                                                      mounted
                                                                                                          ? setState(() {
                                                                                                              controllers['fwdReciver']!.text = dataFwd.userCompanyName;
                                                                                                              controllers['senderName']!.text = dataFwd.userContactName;
                                                                                                              controllers['phone']!.text = dataFwd.userPhone;
                                                                                                              fwdID = dataFwd.userId;
                                                                                                            })
                                                                                                          : null;
                                                                                                    },
                                                                                                    child: Row(
                                                                                                      children: [
                                                                                                        SizedBox(
                                                                                                          width: 1.sw - 80.w,
                                                                                                          child: TextApp(
                                                                                                            text: dataFwd.userCompanyName,
                                                                                                            color: Colors.black,
                                                                                                            fontsize: 14.sp,
                                                                                                            maxLines: 3,
                                                                                                          ),
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
                                                                                          }
                                                                                        }),
                                                                                  ));
                                                                      } else if (state
                                                                          is HandleGetListFWDFailure) {
                                                                        return ErrorDialog(
                                                                          eventConfirm:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          errorText:
                                                                              'Failed to fetch orders: ${state.message}',
                                                                        );
                                                                      }
                                                                      return const Center(
                                                                          child:
                                                                              NoDataFoundWidget());
                                                                    })
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                  SizedBox(
                                                    height: 20.h,
                                                  ),
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
                                                  text: " Tên người gửi",
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
                                                controller:
                                                    controllers['senderName']!,
                                                validator: (value) {
                                                  if (value != null &&
                                                      value.isNotEmpty) {
                                                    return null;
                                                  }
                                                  return 'Vui lòng nhập tên người gửi';
                                                },
                                                hintText: 'Nhập tên người gửi'),
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
                                              controller:
                                                  controllers['vehicle']!,
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
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                              onTap: () {
                                                showMyCustomModalBottomSheet(
                                                    context: context,
                                                    height: 0.62,
                                                    isScroll: true,
                                                    itemCount:
                                                        listVehicle.length,
                                                    itemBuilder:
                                                        (context, index) {
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
                                                                    ? setState(
                                                                        () {
                                                                        controllers['vehicle']!.text =
                                                                            listVehicle[index];
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
                                                                    text: listVehicle[
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
                                              controller:
                                                  controllers['branch']!,
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
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                              onTap: () {
                                                showMyCustomModalBottomSheet(
                                                    context: context,
                                                    height: 0.62,
                                                    isScroll: true,
                                                    itemCount: branchResponse
                                                            ?.branchs.length ??
                                                        0,
                                                    itemBuilder:
                                                        (context, index) {
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
                                                                  child:
                                                                      InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      Navigator.pop(
                                                                          context);
                                                                      mounted
                                                                          ? setState(
                                                                              () {
                                                                              controllers['branch']!.text = branchResponse!.branchs[index].branchName;
                                                                              branhID = branchResponse!.branchs[index].branchId;
                                                                            })
                                                                          : null;
                                                                    },
                                                                    child: Row(
                                                                      children: [
                                                                        TextApp(
                                                                          text: branchResponse!
                                                                              .branchs[index]
                                                                              .branchName,
                                                                          color:
                                                                              Colors.black,
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    TextApp(
                                                      text: " Địa chỉ",
                                                      fontsize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                    TextApp(
                                                      text: " *",
                                                      fontsize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                        controllers[
                                                                'longitude']!
                                                            .text = result[
                                                                'longitude']
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
                                                controller:
                                                    controllers['address']!,
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
                                                  text:
                                                      " Số điện thoại liên hệ",
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
                                                keyboardType:
                                                    TextInputType.number,
                                                controller:
                                                    controllers['phone']!,
                                                textInputFormatter: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp("[0-9]")),
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
                                                controller:
                                                    controllers['awbCode']!,
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
                                                keyboardType:
                                                    TextInputType.number,
                                                controller:
                                                    controllers['weight']!,
                                                textInputFormatter: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp("[0-9]")),
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
                                                keyboardType:
                                                    TextInputType.number,
                                                controller:
                                                    controllers['quantity']!,
                                                textInputFormatter: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp("[0-9]")),
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
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                              },
                                              controller: controllers['note']!,
                                              keyboardType:
                                                  TextInputType.multiline,
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
                                                        if (_formField
                                                            .currentState!
                                                            .validate()) {
                                                          onHandleUpdateOrderPickUp(
                                                              orderPickUpID: widget
                                                                  .orderPickupID,
                                                              orderPickUpType:
                                                                  vehicleID!,
                                                              branchIDEdit:
                                                                  branhID!,
                                                              fwd: fwdID,
                                                              orderPickupName:
                                                                  controllers['senderName']!
                                                                      .text,
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
                                                      text:
                                                          widget.orderPickupID !=
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }
}
