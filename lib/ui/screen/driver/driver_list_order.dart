import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/order_pickup/details_bottom_modal/details_order_pickup_bottom_modal_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/screen/order_pickup_screen_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/update/update_order_pickup_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/update/update_order_pickup_event.dart';
import 'package:scan_barcode_app/bloc/order_pickup/update/update_order_pickup_state.dart';
import 'package:scan_barcode_app/bloc/profile/get_infor/get_infor_bloc.dart';
import 'package:scan_barcode_app/bloc/shipper/details_order_pickup_shipper/details_order_pickup_shipper_bloc.dart';
import 'package:scan_barcode_app/bloc/shipper/shipper_finish/shipper_finish_bloc.dart';
import 'package:scan_barcode_app/bloc/shipper/shipper_list_order/shipper_list_order_screen_bloc.dart';
import 'package:scan_barcode_app/bloc/shipper/shipper_start/shipper_start_bloc.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/models/infor_account_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/data/models/order_pickup/details_order_pick_up.dart';
import 'package:scan_barcode_app/data/models/order_pickup/order_pickup_list_model.dart';
import 'package:scan_barcode_app/data/models/order_pickup/order_pickup_list_shipper_model.dart';
import 'package:scan_barcode_app/data/models/utils/list_branchs_model.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/maps/shipper_map.dart';
import 'package:scan_barcode_app/ui/screen/order/create_new_order_pick_up.dart';
import 'package:scan_barcode_app/ui/screen/order/filter_order.dart';
import 'package:scan_barcode_app/ui/screen/order/infor_oder_pickup_modal.dart';
import 'package:scan_barcode_app/ui/screen/shipper/edit_profile_shipper.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/utils/date_time_picker.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/image/order_pickup_image.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';

class DriverOrderScreen extends StatefulWidget {
  const DriverOrderScreen({super.key});

  @override
  State<DriverOrderScreen> createState() => _DriverOrderScreenState();
}

class _DriverOrderScreenState extends State<DriverOrderScreen>
    with TickerProviderStateMixin {
  InforAccountModel? dataUser;
  DetailsOrderPickUpModel? detailsOrderPickUp;
  LatLng _initialPosition = LatLng(0, 0);
  late final TabController _tabController1;
  final scrollListBillControllerTab1 = ScrollController();
  final scrollListBillControllerTab2 = ScrollController();
  final scrollListBillControllerTab3 = ScrollController();
  final textSearchController = TextEditingController();

  final cancelReasonController = TextEditingController();
  final _dateStartController = TextEditingController();
  final _dateEndController = TextEditingController();
  final branchTextController = TextEditingController();
  final statusTextController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  DateTime? _startDate, _endDate;
  String? _endDateError;
  BranchResponse? branchResponse;
  int? branchID, pickupShipStatusID, shipperId, cuurentIDOrder;
  String query = '';
  int currentTab = 0;
  File? selectedImage;
  String? selectedImageString;

// Thêm biến để lưu trạng thái tab
  int _lastActiveTab = 0;
  // bool _isButtonVisible = true;
  List<String> listStatus = [
    "Đang chờ duyệt", //0
    "Đang chờ xác nhận", //1
    "Đã xác nhận", //2
    "Đang đi lấy", //3
    "Đã lấy", //4
    "Đã pickup", //5
    "Đã huỷ" //6
  ];
  bool _hasCheckedInitially = false;
  Timer? _orderCheckTimer;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<int> _previousOrderIds = [];

  void _updateBrandID(int newBrandID) {
    setState(() {
      branchID = newBrandID;
    });
  }

  void applyFilterFuntion() {
    setState(() {
      Navigator.pop(context);

      BlocProvider.of<GetShipperListOrderScreenBloc>(context).add(
          FetchListOrderPickupShipper(
              status: null,
              startDate: _startDate?.toString(),
              endDate: _endDate?.toString(),
              branchId: branchID,
              keywords: query,
              pickupShipStatus: pickupShipStatusID,
              shipperId: shipperId));
    });
  }

  void onDeleteOrderPickUp(int orderPickupID) {
    context.read<GetListOrderPickupScreenBloc>().add(
          HandleDeleteOrderPickUp(
              orderPickupID: orderPickupID,
              orderCancelDes: cancelReasonController.text),
        );
  }

  Future<void> clearFilterFuntion() async {
    setState(() {
      _endDateError = null;
      statusTextController.clear();
      _dateStartController.clear();
      _dateEndController.clear();
      listStatus.clear();
      _startDate = null;
      _endDate = null;
      branchID = null;
    });
    Navigator.pop(context);

    BlocProvider.of<GetShipperListOrderScreenBloc>(context).add(
        FetchListOrderPickupShipper(
            status: null,
            startDate: null,
            endDate: null,
            branchId: null,
            keywords: query,
            pickupShipStatus: pickupShipStatusID,
            shipperId: shipperId));
  }

  Future<void> getInforUser() async {
    final int? userID = StorageUtils.instance.getInt(key: 'user_ID');
    context
        .read<GetInforProfileBloc>()
        .add(HandleGetInforProfile(userID: userID));
  }

  Future onFetchListOrderPickUpShipper() async {
    try {
      BlocProvider.of<GetShipperListOrderScreenBloc>(context)
          .add(FetchListOrderPickupShipper(
        status: null,
        startDate: null,
        endDate: null,
        branchId: null,
        keywords: query,
        pickupShipStatus: 1,
        shipperId: dataUser?.data.userId ?? 0, // Giá trị mặc định nếu null
      ));
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> getBranchKango() async {
    String? branchResponseJson =
        StorageUtils.instance.getString(key: 'branch_response');
    if (branchResponseJson != null) {
      branchResponse = BranchResponse.fromJson(jsonDecode(branchResponseJson));
      log("GET BRANCH OK LIST");
    }
  }

  Future<void> getCurrentPosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle the case where permission is denied
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle the case where permission is permanently denied
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      mounted
          ? setState(() {
              _initialPosition = LatLng(position.latitude, position.longitude);
            })
          : null;
    } catch (e) {
      print("Error initializing map: $e");
      // Handle errors such as location permission not granted
    }
  }

  void init() async {
    await getBranchKango();
    await getInforUser();
  }

  void _listenToOrdersBloc() {
    BlocProvider.of<GetShipperListOrderScreenBloc>(context)
        .stream
        .listen((state) async {
      if (state is HandleGetShipperListOrderScreenSuccess) {
        if (!_hasCheckedInitially) {
          // Load previous order IDs from storage
          _previousOrderIds = await _loadPreviousOrderIds();
          _hasCheckedInitially = true;

          // Kiểm tra đơn hàng mới ngay khi mở app
          final currentOrderIds = state.data
              .where((order) => order.orderPickupStatus == 1)
              .map((order) => order.orderPickupId)
              .toList();

          final newOrders = currentOrderIds
              .where((id) => !_previousOrderIds.contains(id))
              .toList();

          if (newOrders.isNotEmpty) {
            await _showNewOrdersNotification(newOrders.length);
            _previousOrderIds = currentOrderIds;
            // Save updated IDs to storage
            await _savePreviousOrderIds(currentOrderIds);
          }
        } else {
          await _checkForNewOrders();
        }
      }
    });
  }

  Future<void> _showNewOrdersNotification(int numberOfNewOrders) async {
    const androidDetails = AndroidNotificationDetails(
      'new_orders_channel',
      'New Orders',
      channelDescription: 'Notifications for new pickup orders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );

    const iOSDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Đơn Hàng Mới',
      'Bạn có $numberOfNewOrders đơn hàng mới Đang chờ xác nhận',
      notificationDetails,
      payload: numberOfNewOrders.toString(),
    );
  }

//Cấu hình thông báo cho IOS và Android
  Future<void> _initializeNotifications() async {
    try {
      // Cấu hình cho Android
      const androidInitialize =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      // Cấu hình cho iOS
      const iOSInitialize = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
      );

      // Kết hợp cấu hình cho cả 2 nền tảng
      const initializationSettings = InitializationSettings(
        android: androidInitialize,
        iOS: iOSInitialize,
      );

      // Khởi tạo plugin với cấu hình và xử lý khi nhấn thông báo
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {
          final String? payload = notificationResponse.payload;

          if (payload != null) {
            try {
              final orderId = int.parse(payload);

              if (context.mounted) {
                // Sử dụng bloc đã có để lấy chi tiết đơn hàng
                BlocProvider.of<DetailsOrderPickupModalBottomBloc>(context).add(
                  HanldeGetDetailsOrderPickupModalBottom(
                    orderPickupID: orderId,
                  ),
                );
              }
            } catch (e) {
              print('Error handling notification tap: $e');
              // Hiển thị dialog lỗi
              if (context.mounted) {
                showDialog(
                  context: navigatorKey.currentContext!,
                  builder: (BuildContext context) {
                    return ErrorDialog(
                      eventConfirm: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              }
            }
          }
        },
      );

      // Kiểm tra và xử lý quyền thông báo trên iOS
      if (Platform.isIOS) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }

      // Kiểm tra và xử lý quyền thông báo trên Android 13 trở lên
      if (Platform.isAndroid) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }

      // Kiểm tra pending notification
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? pendingPayload =
          prefs.getString('pending_notification_payload');
      if (pendingPayload != null) {
        try {
          final orderId = int.parse(pendingPayload);
          if (context.mounted) {
            BlocProvider.of<DetailsOrderPickupModalBottomBloc>(context).add(
              HanldeGetDetailsOrderPickupModalBottom(
                orderPickupID: orderId,
              ),
            );
          }
        } catch (e) {
          print('Error handling pending notification: $e');
        }
        await prefs.remove('pending_notification_payload');
      }
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> _savePreviousOrderIds(List<int> orderIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('previous_order_ids', jsonEncode(orderIds));
  }

  Future<List<int>> _loadPreviousOrderIds() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedIds = prefs.getString('previous_order_ids');
    if (savedIds != null) {
      final List<dynamic> decodedList = jsonDecode(savedIds);
      return decodedList.map((e) => e as int).toList();
    }
    return [];
  }

// Thêm hàm mới để kiểm tra đơn hàng mới
  Future<void> _checkForNewOrders() async {
    try {
      final bloc = BlocProvider.of<GetShipperListOrderScreenBloc>(context);
      final state = bloc.state;

      if (state is HandleGetShipperListOrderScreenSuccess) {
        final currentOrderIds = state.data
            .where((order) => order.orderPickupStatus == 1)
            .map((order) => order.orderPickupId)
            .toList();

        final newOrders = currentOrderIds
            .where((id) => !_previousOrderIds.contains(id))
            .toList();

        if (newOrders.isNotEmpty) {
          await _showNewOrdersNotification(newOrders.length);
          _previousOrderIds = currentOrderIds;
          // Save updated IDs to storage
          await _savePreviousOrderIds(currentOrderIds);
        }
      }
    } catch (e) {
      print('Error checking for new orders: $e');
    }
  }

  void _startOrderCheck() {
    // Chạy ngay lần đầu
    _checkForNewOrders();

    // Sau đó mới tạo timer 5 phút
    _orderCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkForNewOrders();
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _tabController1 = TabController(length: 3, vsync: this);
    _tabController1.addListener(_handleTabChange);
    pickupShipStatusID =
        _lastActiveTab == 0 ? 1 : (_lastActiveTab == 1 ? 2 : 0);
    getCurrentPosition();
    init();
    _loadPreviousOrderIds().then((loadedIds) {
      setState(() {
        _previousOrderIds = loadedIds;
      });
    });
    _listenToOrdersBloc();
    _startOrderCheck();
    // Set tab controller về tab cuối cùng được active
    _tabController1.index = _lastActiveTab;
    scrollListBillControllerTab1.addListener(_onScrollTab1);
    scrollListBillControllerTab2.addListener(_onScrollTab2);
    scrollListBillControllerTab3.addListener(_onScrollTab3);
  }

  void _handleTabChange() {
    if (_tabController1.indexIsChanging) {
      return;
    }

    final indexTab = _tabController1.index;
    log("Tab index: $indexTab");
    setState(() {
      currentTab = indexTab;
      _lastActiveTab = indexTab; // Lưu lại tab hiện tại
    });
    if (indexTab == 0) {
      try {
        BlocProvider.of<GetShipperListOrderScreenBloc>(context)
            .add(FetchListOrderPickupShipper(
          status: null,
          startDate: null,
          endDate: null,
          branchId: null,
          keywords: query,
          pickupShipStatus: 1,
          shipperId: dataUser?.data.userId ?? 0, // Giá trị mặc định nếu null
        ));
        setState(() {
          pickupShipStatusID = 1;
        });
      } catch (e) {
        log("Error: $e");
      }
    } else if (indexTab == 1) {
      BlocProvider.of<GetShipperListOrderScreenBloc>(context)
          .add(FetchListOrderPickupShipper(
        status: null,
        startDate: null,
        endDate: null,
        branchId: null,
        keywords: query,
        pickupShipStatus: 2,
        shipperId: dataUser?.data.userId,
      ));
      setState(() {
        pickupShipStatusID = 2;
      });
    } else {
      BlocProvider.of<GetShipperListOrderScreenBloc>(context)
          .add(FetchListOrderPickupShipper(
        status: null,
        startDate: null,
        endDate: null,
        branchId: null,
        keywords: query,
        pickupShipStatus: 0,
        shipperId: dataUser?.data.userId,
      ));
      setState(() {
        pickupShipStatusID = 0;
      });
    }
  }

  void _onScrollTab1() {
    if (scrollListBillControllerTab1.position.maxScrollExtent ==
        scrollListBillControllerTab1.offset) {
      BlocProvider.of<GetShipperListOrderScreenBloc>(context).add(
          LoadMoreListOrderPickupShipper(
              status: null,
              startDate: _startDate?.toString(),
              endDate: _endDate?.toString(),
              branchId: branchID,
              keywords: query,
              pickupShipStatus: pickupShipStatusID,
              shipperId: shipperId));
    }
  }

  void _onScrollTab2() {
    if (scrollListBillControllerTab2.position.maxScrollExtent ==
        scrollListBillControllerTab2.offset) {
      BlocProvider.of<GetShipperListOrderScreenBloc>(context).add(
          LoadMoreListOrderPickupShipper(
              status: null,
              startDate: _startDate?.toString(),
              endDate: _endDate?.toString(),
              branchId: branchID,
              keywords: query,
              pickupShipStatus: pickupShipStatusID,
              shipperId: shipperId));
    }
  }

  void _onScrollTab3() {
    if (scrollListBillControllerTab3.position.maxScrollExtent ==
        scrollListBillControllerTab3.offset) {
      BlocProvider.of<GetShipperListOrderScreenBloc>(context).add(
          LoadMoreListOrderPickupShipper(
              status: null,
              startDate: _startDate?.toString(),
              endDate: _endDate?.toString(),
              branchId: branchID,
              keywords: query,
              pickupShipStatus: pickupShipStatusID,
              shipperId: shipperId));
    }
  }

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

/*
  Future<void> deleteExistImage(
      OrdersPickupShipperItemData dataOrderPickup) async {
    setState(() {
      dataOrderPickup.orderPickupImage = null;
      selectedImage = null;
    });
  } // xoá ảnh nếu đã có từ data trả về
*/
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

  void _showImageDialog(
      BuildContext context, OrdersPickupShipperItemData dataOrderPickup) {
    bool isLoading = false;

    // Tạo state local để quản lý ảnh
    String? currentImage = dataOrderPickup.orderPickupImage;

    // Store the bloc reference before showing dialog
    final updateBloc = context.read<UpdateOrderPickupBloc>();
    // Store query and user data references
    final currentQuery = query;
    final currentUserId = dataUser?.data.userId;
// Thêm biến để lưu trữ trạng thái trước đó
    int? previousStatus;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async {
            setState(() {
              selectedImage = null;
            });
            return true;
          },
          child: StatefulBuilder(builder: (context, setState) {
            Future<void> deleteExistImage(
                OrdersPickupShipperItemData data) async {
              setState(() {
                currentImage = "";
                selectedImage = null;
                previousStatus = data.orderPickupStatus;
              });
            }

            return AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              content: Container(
                padding: EdgeInsets.all(10.w),
                child: DottedBorder(
                  dashPattern: const [3, 1, 0, 2],
                  color: Colors.black.withOpacity(0.6),
                  strokeWidth: 1.5,
                  padding: const EdgeInsets.all(3),
                  child: SizedBox(
                    width: 1.sw,
                    height: 400.h,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (currentImage != null && currentImage!.isNotEmpty)
                            Column(
                              children: [
                                Stack(
                                  children: [
                                    SizedBox(
                                      width: 1.sw,
                                      height: 300.h,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          child: selectedImage != null
                                              ? Image.file(
                                                  selectedImage!,
                                                  fit: BoxFit.contain,
                                                  width: 1.sw,
                                                  height: 300.h,
                                                )
                                              : OrderPickupImage(
                                                  imageUrl: httpImage +
                                                      dataOrderPickup
                                                          .orderPickupImage!)),
                                    ),
                                    Positioned(
                                      right: 5,
                                      top: 5,
                                      child: InkWell(
                                        onTap: () async {
                                          await deleteExistImage(
                                              dataOrderPickup);
                                          setState(() {});
                                        },
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color:
                                                Colors.white.withOpacity(0.8),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.close,
                                              size: 20.sp,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: isLoading
                                          ? null
                                          : () async {
                                              setState(() {
                                                isLoading = true;
                                              });

                                              String? imageUrl;
                                              try {
                                                if (detailsOrderPickUp !=
                                                        null &&
                                                    detailsOrderPickUp!.data
                                                            .orderPickupImage !=
                                                        null) {
                                                  imageUrl = httpImage +
                                                      detailsOrderPickUp!.data
                                                          .orderPickupImage!;
                                                }

                                                if (imageUrl != null) {
                                                  selectedImageString =
                                                      await convertImageUrlToBase64(
                                                          imageUrl);
                                                } else if (selectedImage !=
                                                    null) {
                                                  Uint8List imageBytes =
                                                      await selectedImage!
                                                          .readAsBytes();
                                                  selectedImageString =
                                                      base64Encode(imageBytes);
                                                } else {
                                                  print(
                                                      "❌ Không có ảnh để cập nhật!");
                                                }

                                                updateBloc.add(
                                                  HanldeUpdateOrderPickup(
                                                    orderPickUpID:
                                                        dataOrderPickup
                                                            .orderPickupId,
                                                    orderPickUpType:
                                                        dataOrderPickup
                                                            .orderPickupType,
                                                    branchIDEdit:
                                                        dataOrderPickup
                                                            .branchId,
                                                    orderPickUpTime:
                                                        dataOrderPickup
                                                            .orderPickupDateTime
                                                            .toString(),
                                                    orderPickUpAWB:
                                                        dataOrderPickup
                                                            .orderPickupAwb,
                                                    orderPickUpGrossWeight:
                                                        dataOrderPickup
                                                            .orderPickupGrossWeight
                                                            .toString(),
                                                    orderPickUpNumberPackage:
                                                        dataOrderPickup
                                                            .orderPickupNumberPackages
                                                            .toString(),
                                                    orderPickUpPhone:
                                                        dataOrderPickup
                                                            .orderPickupPhone,
                                                    orderPickUpAdrees:
                                                        dataOrderPickup
                                                            .orderPickupAddress,
                                                    orderPickUpNote:
                                                        dataOrderPickup
                                                            .orderPickupNote,
                                                    orderPickUpStatus: 5,
                                                    orderPickUpImage:
                                                        selectedImageString,
                                                    fwd: dataOrderPickup.fwdId,
                                                    orderPickupName:
                                                        dataOrderPickup
                                                            .orderPickupName,
                                                    longitude: double.parse(
                                                        dataOrderPickup
                                                            .longitude),
                                                    latitude: double.parse(
                                                        dataOrderPickup
                                                            .latitude),
                                                    orderPickupCancelDes:
                                                        dataOrderPickup
                                                            .orderPickupCancelDes,
                                                  ),
                                                );

                                                // Create a completer to handle the async operation
                                                final completer =
                                                    Completer<void>();
                                                late StreamSubscription
                                                    subscription;

                                                subscription =
                                                    updateBloc.stream.listen(
                                                  (state) {
                                                    if (state
                                                        is UpdateOrderPickupSuccess) {
                                                      subscription.cancel();
                                                      completer.complete();

                                                      // Close dialog first
                                                      Navigator.of(context)
                                                          .pop();

                                                      // Show success dialog
                                                      showCustomDialogModal(
                                                        context: navigatorKey
                                                            .currentContext!,
                                                        textDesc:
                                                            "Cập nhật đơn hàng đã pickup thành công!",
                                                        title: "Thông báo",
                                                        colorButtonOk:
                                                            Colors.green,
                                                        btnOKText: "Xác nhận",
                                                        typeDialog: "success",
                                                        onDismissCallback: () {
                                                          // Làm mới danh sách khi dialog đóng
                                                          if (navigatorKey
                                                                  .currentContext !=
                                                              null) {
                                                            BlocProvider.of<
                                                                GetShipperListOrderScreenBloc>(
                                                              navigatorKey
                                                                  .currentContext!,
                                                            ).add(
                                                              FetchListOrderPickupShipper(
                                                                status: null,
                                                                startDate: null,
                                                                endDate: null,
                                                                branchId: null,
                                                                keywords: query,
                                                                pickupShipStatus:
                                                                    1,
                                                                shipperId:
                                                                    dataUser
                                                                        ?.data
                                                                        .userId,
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        eventButtonOKPress: () {
                                                          // Làm mới danh sách khi nhấn nút OK
                                                          if (navigatorKey
                                                                  .currentContext !=
                                                              null) {
                                                            BlocProvider.of<
                                                                GetShipperListOrderScreenBloc>(
                                                              navigatorKey
                                                                  .currentContext!,
                                                            ).add(
                                                              FetchListOrderPickupShipper(
                                                                status: null,
                                                                startDate: null,
                                                                endDate: null,
                                                                branchId: null,
                                                                keywords: query,
                                                                pickupShipStatus:
                                                                    1,
                                                                shipperId:
                                                                    dataUser
                                                                        ?.data
                                                                        .userId,
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        isTwoButton: false,
                                                      );

                                                      setState(() {
                                                        selectedImage = null;
                                                      });
                                                    }

                                                    if (state
                                                        is UpdateOrderPickupFailure) {
                                                      subscription.cancel();
                                                      completer.complete();

                                                      // Close dialog first
                                                      Navigator.of(context)
                                                          .pop();

                                                      // Show error dialog
                                                      showCustomDialogModal(
                                                        context: navigatorKey
                                                            .currentContext!,
                                                        textDesc: state
                                                                .errorText ??
                                                            "Đã có lỗi xảy ra",
                                                        title: "Thông báo",
                                                        colorButtonOk:
                                                            Colors.red,
                                                        btnOKText: "Xác nhận",
                                                        typeDialog: "error",
                                                        eventButtonOKPress:
                                                            () {},
                                                        isTwoButton: false,
                                                      );
                                                      setState(() {
                                                        selectedImage = null;
                                                      });
                                                    }
                                                  },
                                                  onError: (error) {
                                                    subscription.cancel();
                                                    completer
                                                        .completeError(error);
                                                    setState(() {
                                                      selectedImage = null;
                                                    });
                                                  },
                                                );

                                                // Wait for the operation to complete
                                                await completer.future;
                                              } finally {
                                                if (mounted) {
                                                  setState(() {
                                                    isLoading = false;
                                                    setState(() {
                                                      selectedImage = null;
                                                    });
                                                  });
                                                }
                                              }
                                            },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.r),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.9),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15.w, vertical: 8.h),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (isLoading)
                                                SizedBox(
                                                  width: 20.sp,
                                                  height: 20.sp,
                                                  child:
                                                      const CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              else
                                                Icon(
                                                  Icons.edit,
                                                  size: 20.sp,
                                                  color: Colors.white,
                                                ),
                                              SizedBox(width: 5.w),
                                              TextApp(
                                                fontsize: 14.sp,
                                                text: isLoading
                                                    ? "Đang xử lý"
                                                    : "Cập nhật",
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    InkWell(
                                      onTap: () async {
                                        await deleteExistImage(dataOrderPickup);
                                        setState(() {});
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.r),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.9),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15.w, vertical: 8.h),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.replay_outlined,
                                                size: 20.sp,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 5.w),
                                              TextApp(
                                                fontsize: 14.sp,
                                                text: "Chọn lại",
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          else if (selectedImage == null)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    await pickImage();
                                    setState(() {});
                                  },
                                  child: Container(
                                    width: 120.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.r),
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
                                          SizedBox(width: 5.w),
                                          TextApp(
                                            fontsize: 14.sp,
                                            text: "Chọn ảnh",
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                InkWell(
                                  onTap: () async {
                                    captureImage(setState);
                                  },
                                  child: Container(
                                    width: 120.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.r),
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                                          SizedBox(width: 5.w),
                                          TextApp(
                                            fontsize: 14.sp,
                                            text: "Chụp ảnh",
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.r),
                                      child: Image.file(
                                        selectedImage!,
                                        fit: BoxFit.contain,
                                        width: 1.sw,
                                        height: 300.h,
                                      ),
                                    ),
                                    Positioned(
                                      right: 5,
                                      top: 5,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedImage = null;
                                          });
                                        },
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color:
                                                Colors.white.withOpacity(0.8),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.close,
                                              size: 20.sp,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: isLoading
                                          ? null
                                          : () async {
                                              if (selectedImage == null) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Vui lòng chọn ảnh!'),
                                                  ),
                                                );
                                              } else {
                                                setState(() {
                                                  isLoading = true;
                                                });

                                                try {
                                                  int updateStatus =
                                                      previousStatus == 4
                                                          ? 5
                                                          : 4;
                                                  if (selectedImage != null) {
                                                    // Nếu có ảnh mới, convert ảnh mới sang base64
                                                    Uint8List imagebytes =
                                                        await selectedImage!
                                                            .readAsBytes();
                                                    selectedImageString =
                                                        base64Encode(
                                                            imagebytes);
                                                  } else if (detailsOrderPickUp
                                                              ?.data
                                                              .orderPickupImage !=
                                                          null &&
                                                      detailsOrderPickUp!
                                                          .data
                                                          .orderPickupImage!
                                                          .isNotEmpty) {
                                                    // Nếu không có ảnh mới nhưng có ảnh cũ, sử dụng ảnh cũ
                                                    String imageUrl = httpImage +
                                                        detailsOrderPickUp!.data
                                                            .orderPickupImage!;
                                                    selectedImageString =
                                                        await convertImageUrlToBase64(
                                                            imageUrl);
                                                  } else {
                                                    // Không có cả ảnh mới và ảnh cũ
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              'Vui lòng chọn ảnh!')),
                                                    );
                                                    return;
                                                  }

                                                  updateBloc.add(
                                                    HanldeUpdateOrderPickup(
                                                      orderPickUpID:
                                                          dataOrderPickup
                                                              .orderPickupId,
                                                      orderPickUpType:
                                                          dataOrderPickup
                                                              .orderPickupType,
                                                      branchIDEdit:
                                                          dataOrderPickup
                                                              .branchId,
                                                      orderPickUpTime:
                                                          dataOrderPickup
                                                              .orderPickupDateTime
                                                              .toString(),
                                                      orderPickUpAWB:
                                                          dataOrderPickup
                                                              .orderPickupAwb,
                                                      orderPickUpGrossWeight:
                                                          dataOrderPickup
                                                              .orderPickupGrossWeight
                                                              .toString(),
                                                      orderPickUpNumberPackage:
                                                          dataOrderPickup
                                                              .orderPickupNumberPackages
                                                              .toString(),
                                                      orderPickUpPhone:
                                                          dataOrderPickup
                                                              .orderPickupPhone,
                                                      orderPickUpAdrees:
                                                          dataOrderPickup
                                                              .orderPickupAddress,
                                                      orderPickUpNote:
                                                          dataOrderPickup
                                                              .orderPickupNote,
                                                      orderPickUpStatus:
                                                          updateStatus,
                                                      orderPickUpImage:
                                                          selectedImageString,
                                                      fwd:
                                                          dataOrderPickup.fwdId,
                                                      orderPickupName:
                                                          dataOrderPickup
                                                              .orderPickupName,
                                                      longitude: double.parse(
                                                          dataOrderPickup
                                                              .longitude),
                                                      latitude: double.parse(
                                                          dataOrderPickup
                                                              .latitude),
                                                      orderPickupCancelDes:
                                                          dataOrderPickup
                                                              .orderPickupCancelDes,
                                                    ),
                                                  );

                                                  // Create a completer to handle the async operation
                                                  final completer =
                                                      Completer<void>();
                                                  late StreamSubscription
                                                      subscription;

                                                  subscription =
                                                      updateBloc.stream.listen(
                                                    (state) {
                                                      if (state
                                                          is UpdateOrderPickupSuccess) {
                                                        subscription.cancel();
                                                        completer.complete();

                                                        // Close dialog first
                                                        Navigator.of(context)
                                                            .pop();
                                                        WidgetsBinding.instance
                                                            .addPostFrameCallback(
                                                                (_) {
                                                          showCustomDialogModal(
                                                            context: navigatorKey
                                                                .currentContext!,
                                                            textDesc: previousStatus ==
                                                                    4
                                                                ? "Cập nhật đơn hàng đã pickup thành công!"
                                                                : "Cập nhật đơn hàng đã lấy thành công!",
                                                            title: "Thông báo",
                                                            colorButtonOk:
                                                                Colors.green,
                                                            btnOKText:
                                                                "Xác nhận",
                                                            typeDialog:
                                                                "success",
                                                            onDismissCallback:
                                                                () {
                                                              // Làm mới danh sách khi dialog đóng
                                                              if (navigatorKey
                                                                      .currentContext !=
                                                                  null) {
                                                                BlocProvider.of<
                                                                    GetShipperListOrderScreenBloc>(
                                                                  navigatorKey
                                                                      .currentContext!,
                                                                ).add(
                                                                  FetchListOrderPickupShipper(
                                                                    status:
                                                                        null,
                                                                    startDate:
                                                                        null,
                                                                    endDate:
                                                                        null,
                                                                    branchId:
                                                                        null,
                                                                    keywords:
                                                                        query,
                                                                    pickupShipStatus:
                                                                        1,
                                                                    shipperId:
                                                                        dataUser
                                                                            ?.data
                                                                            .userId,
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                            eventButtonOKPress:
                                                                () {
                                                              // Làm mới danh sách khi nhấn nút OK
                                                              if (navigatorKey
                                                                      .currentContext !=
                                                                  null) {
                                                                BlocProvider.of<
                                                                    GetShipperListOrderScreenBloc>(
                                                                  navigatorKey
                                                                      .currentContext!,
                                                                ).add(
                                                                  FetchListOrderPickupShipper(
                                                                    status:
                                                                        null,
                                                                    startDate:
                                                                        null,
                                                                    endDate:
                                                                        null,
                                                                    branchId:
                                                                        null,
                                                                    keywords:
                                                                        query,
                                                                    pickupShipStatus:
                                                                        1,
                                                                    shipperId:
                                                                        dataUser
                                                                            ?.data
                                                                            .userId,
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                            isTwoButton: false,
                                                          );

                                                          setState(() {
                                                            selectedImage =
                                                                null;
                                                          });
                                                        });
                                                        // Show success dialog
                                                      }

                                                      if (state
                                                          is UpdateOrderPickupFailure) {
                                                        subscription.cancel();
                                                        completer.complete();

                                                        // Close dialog first
                                                        Navigator.of(context)
                                                            .pop();

                                                        // Show error dialog
                                                        showCustomDialogModal(
                                                          context: navigatorKey
                                                              .currentContext!,
                                                          textDesc: state
                                                                  .errorText ??
                                                              "Đã có lỗi xảy ra",
                                                          title: "Thông báo",
                                                          colorButtonOk:
                                                              Colors.red,
                                                          btnOKText: "Xác nhận",
                                                          typeDialog: "error",
                                                          eventButtonOKPress:
                                                              () {},
                                                          isTwoButton: false,
                                                        );
                                                        setState(() {
                                                          selectedImage = null;
                                                        });
                                                      }
                                                    },
                                                    onError: (error) {
                                                      subscription.cancel();
                                                      completer
                                                          .completeError(error);
                                                      setState(() {
                                                        selectedImage = null;
                                                      });
                                                    },
                                                  );

                                                  // Wait for the operation to complete
                                                  await completer.future;
                                                } finally {
                                                  if (mounted) {
                                                    setState(() {
                                                      isLoading = false;
                                                      setState(() {
                                                        selectedImage = null;
                                                      });
                                                    });
                                                  }
                                                }
                                              }
                                            },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.r),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.9),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15.w, vertical: 8.h),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (isLoading)
                                                SizedBox(
                                                  width: 20.sp,
                                                  height: 20.sp,
                                                  child:
                                                      const CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              else
                                                Icon(
                                                  Icons.edit,
                                                  size: 20.sp,
                                                  color: Colors.white,
                                                ),
                                              SizedBox(width: 5.w),
                                              TextApp(
                                                fontsize: 14.sp,
                                                text: isLoading
                                                    ? "Đang xử lý"
                                                    : "Cập nhật",
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    InkWell(
                                      onTap: () async {
                                        await deleteExistImage(dataOrderPickup);
                                        setState(() {});
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.r),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.9),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15.w, vertical: 8.h),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.replay_outlined,
                                                size: 20.sp,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 5.w),
                                              TextApp(
                                                fontsize: 14.sp,
                                                text: "Chọn lại",
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    ).then((_) {
      setState(() {
        selectedImage = null;
      });
    });
  }

  @override
  void dispose() {
    _tabController1.removeListener(_handleTabChange);
    _tabController1.dispose();
    _orderCheckTimer?.cancel();
    super.dispose();
    textSearchController.dispose();
    cancelReasonController.dispose();
    _dateStartController.dispose();
    _dateEndController.dispose();
  }

  void searchProduct(String query) {
    mounted
        ? setState(() {
            this.query = query;

            BlocProvider.of<GetShipperListOrderScreenBloc>(context).add(
                FetchListOrderPickupShipper(
                    status: null,
                    startDate: _startDate?.toString(),
                    endDate: _endDate?.toString(),
                    branchId: branchID,
                    keywords: query,
                    pickupShipStatus: pickupShipStatusID,
                    shipperId: shipperId));
          })
        : null;
  }

  void buildCupertinoDateStartPicker(BuildContext context) {
    showCupertinoDatePicker(
      context,
      initialDate: _startDate,
      onDateChanged: (picked) {
        setState(() {
          _startDate = picked;
        });
      },
      onCancel: () {
        Navigator.of(context).pop();
      },
      onConfirm: () {
        setState(() {
          _dateStartController.text = formatDateMonthYear(
              (_startDate ?? DateTime.now()).toString().split(" ")[0]);
          _endDateError = null;
          Navigator.of(context).pop();
        });
      },
    );
  }

  void buildCupertinoDateEndPicker(BuildContext context) {
    showCupertinoDatePicker(
      context,
      initialDate: _endDate,
      onDateChanged: (picked) {
        setState(() {
          _endDate = picked;
        });
      },
      onCancel: () {
        Navigator.of(context).pop();
      },
      onConfirm: () {
        if ((_endDate ?? DateTime.now())
            .isBefore(_startDate ?? DateTime.now())) {
          showCustomDialogModal(
              context: navigatorKey.currentContext!,
              textDesc: "Nhỏ hơn ngày bắt đầu",
              title: "Thông báo",
              colorButtonOk: Colors.red,
              btnOKText: "Xác nhận",
              typeDialog: "error",
              eventButtonOKPress: () {},
              isTwoButton: false);
        } else {
          setState(() {
            _dateEndController.text = formatDateMonthYear(
                (_endDate ?? DateTime.now()).toString().split(" ")[0]);
            _endDateError = null;
            Navigator.of(context).pop();
          });
        }
      },
    );
  }

  /// This builds material date picker in Android
  Future<void> buildMaterialDateStartPicker(BuildContext context) async {
    showMaterialDatePicker(
      context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2),
      onDatePicked: (picked) {
        setState(() {
          _startDate = picked;
          _dateStartController.text = formatDateMonthYear(
              (_startDate ?? DateTime.now()).toString().split(" ")[0]);
          _endDateError = null;
        });
      },
    );
  }

  Future<void> buildMaterialDateEndPicker(BuildContext context) async {
    showMaterialDatePicker(
      context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2),
      onDatePicked: (picked) {
        setState(() {
          _endDate = picked;
          _dateEndController.text = formatDateMonthYear(
              (_endDate ?? DateTime.now()).toString().split(" ")[0]);
          _endDateError = null;
        });
      },
    );
  }

  Future<void> selectDayStart() async {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return buildMaterialDateStartPicker(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return buildCupertinoDateStartPicker(context);
    }
  }

  Future<void> selectDayEnd() async {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return buildMaterialDateEndPicker(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return buildCupertinoDateEndPicker(context);
    }
  }

  void getDetailsOrder({required int orderPickupID}) {
    context
        .read<DetailsOrderPickupShipperBloc>()
        .add(HanldeGetDetailsOrderShipperPickup(orderPickupID: orderPickupID));
  }

  void showBottomDialogPickup(int orderPickupID) {
    context.read<DetailsOrderPickupModalBottomBloc>().add(
          HanldeGetDetailsOrderPickupModalBottom(orderPickupID: orderPickupID),
        );
  }

  void showDialogDetailsOrderPickUp(
      BuildContext context, DetailsOrderPickUpModel? detailsOrderPickUp) {
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
        return OrderPickupDetailsDialog(
          detailsOrderPickUp: detailsOrderPickUp,
          dataUser: dataUser,
          shipperLongitude: 0,
          shipperLatitude: 0,
          isShipper: true,
        );
      },
    );
  }

  Future<void> shipperStart() async {
    context
        .read<ShipperStartBloc>()
        .add(HanldeShipperStart(shipperID: dataUser!.data.userId));
  }

  Future<void> shipperFinishAll() async {
    log("ALOOO");
    context.read<ShipperFinishBloc>().add(HanldeShipperFinish(
        shipperLongitude: null, shipperLatitude: null, shipperLocation: null));
  }

  Future<void> _navigateToNextScreen() async {
    // Navigate to the next screen and wait for it to be popped
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNewOrderPickUpScreen(
          isShipper: true,

          orderPickupID: cuurentIDOrder, // Pass necessary data here
        ),
      ),
    );

    // This will be called when returning from CreateNewOrderPickUpScreen
    print('Returned from CreateNewOrderPickUpScreen');
    init();
    // Add your logic here (reinitialize state, fetch data, etc.)
  }

  bool isExpanded = false;
  bool isHaveOrder = false;
  Offset _fabPosition = Offset(50.w, 50.w);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: TextApp(
          text: "Đơn hàng của tôi",
          fontsize: 20.sp,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        actions: [_widgetAvatar()],
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          MultiBlocListener(
            listeners: [
              BlocListener<GetShipperListOrderScreenBloc,
                      HandleGetShipperListOrderScreenState>(
                  listener: (context, state) {
                if (state is HandleGetShipperListOrderScreenSuccess) {
                  (state.data.isEmpty && dataUser?.data.userIsFreeTime == 0)
                      ? shipperFinishAll()
                      : null;
                  setState(() {
                    state.data.isNotEmpty
                        ? (
                            isHaveOrder = true,
                            dataUser?.data.userIsFreeTime == 1
                                ? isExpanded = true
                                : isExpanded = false,
                          )
                        : (isHaveOrder = false, isExpanded = false);
                  });
                }
              }),
              BlocListener<GetListOrderPickupScreenBloc,
                  HandleGetListOrderPickupState>(
                listener: (context, state) {
                  if (state is HandleDeleteOrderPickUpSuccess) {
                    showCustomDialogModal(
                      context: navigatorKey.currentContext!,
                      textDesc: state.message,
                      title: "Thông báo",
                      colorButtonOk: Colors.green,
                      btnOKText: "Xác nhận",
                      typeDialog: "success",
                      eventButtonOKPress: () {
                        cancelReasonController.clear();
                      },
                      isTwoButton: false,
                    );
                    // Refresh the list after delete
                    BlocProvider.of<GetShipperListOrderScreenBloc>(
                      navigatorKey.currentContext!,
                    ).add(
                      FetchListOrderPickupShipper(
                        status: null,
                        startDate: null,
                        endDate: null,
                        branchId: null,
                        keywords: query,
                        pickupShipStatus: 1,
                        shipperId: dataUser?.data.userId,
                      ),
                    );
                  } else if (state is HandleDeleteOrderPickUpFailure) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ErrorDialog(
                          errorText: state.message,
                          eventConfirm: () {
                            Navigator.pop(context);
                            cancelReasonController.clear();
                          },
                        );
                      },
                    );
                  }
                },
              ),
              BlocListener<ShipperFinishBloc, ShipperFinishState>(
                  listener: (context, state) {
                if (state is ShipperFinishSuccess) {
                  getInforUser();
                }
              }),
              BlocListener<ShipperStartBloc, ShipperStartState>(
                  listener: (context, state) {
                if (state is ShipperStartSuccess) {
                  showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: "Bắt đầu hành trình thành công.",
                    title: "Thông báo",
                    colorButtonOk: Colors.green,
                    btnOKText: "Xác nhận",
                    typeDialog: "success",
                    eventButtonOKPress: () {},
                    isTwoButton: false,
                  );
                  BlocProvider.of<GetShipperListOrderScreenBloc>(context)
                      .add(FetchListOrderPickupShipper(
                    status: null,
                    startDate: null,
                    endDate: null,
                    branchId: null,
                    keywords: query,
                    pickupShipStatus: 1,
                    shipperId: dataUser?.data.userId,
                  ));
                } else if (state is ShipperStartFailure) {
                  showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: state.errorText ?? 'Có lôi xảy ra',
                    title: "Thông báo",
                    colorButtonOk: Colors.red,
                    btnOKText: "Xác nhận",
                    typeDialog: "error",
                    eventButtonOKPress: () {},
                    isTwoButton: false,
                  );
                }
              }),
              BlocListener<GetInforProfileBloc, GetInforProfileState>(
                  listener: (context, state) {
                if (state is GetInforProfileStateSuccess) {
                  setState(() {
                    dataUser = state.inforAccountModel;
                  });
                  onFetchListOrderPickUpShipper();
                }
              }),
              BlocListener<DetailsOrderPickupModalBottomBloc,
                  DetailsOrderPickupModalBottomState>(
                listener: (context, state) {
                  if (state is HanldeGetDetailsOrderPickupModalBottomSuccess) {
                    detailsOrderPickUp = state.detailsOrderPickUpModel;

                    showDialogDetailsOrderPickUp(context, detailsOrderPickUp);
                  } else if (state
                      is HanldeGetDetailsOrderPickupModalBottomFailure) {
                    showDialog(
                      context: navigatorKey.currentContext!,
                      builder: (BuildContext context) {
                        return ErrorDialog(
                          errorText: state.message,
                          eventConfirm: () {
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  }
                },
              ),
              BlocListener<DetailsOrderPickupShipperBloc,
                  DetailsOrderPickupShipperState>(listener: (context, state) {
                if (state is HanldeGetDetailsOrderPickupShipperSuccess) {
                  print(
                      "Order pickup ID: ${state.detailsOrderPickUpModel.data.orderPickupId}");
                  print(
                      "Longitude: ${state.detailsOrderPickUpModel.data.longitude}");
                  print(
                      "Latitude: ${state.detailsOrderPickUpModel.data.latitude}");

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.push(
                      navigatorKey.currentContext!,
                      MaterialPageRoute(
                        builder: (context) => MapShipperTest(
                          idKeyDestination: state
                              .detailsOrderPickUpModel.data.orderPickupId
                              .toString(),
                          detailsOrderPickUp: state.detailsOrderPickUpModel,
                          longitude: double.parse(
                              state.detailsOrderPickUpModel.data.longitude),
                          latitude: double.parse(
                              state.detailsOrderPickUpModel.data.latitude),
                        ),
                      ),
                    );
                  });
                } else if (state is HanldeGetDetailsOrderPickupShipperFailure) {
                  showDialog(
                    context: navigatorKey.currentContext!,
                    builder: (BuildContext context) {
                      return ErrorDialog(
                        errorText: state.message,
                        eventConfirm: () {
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }
              })
            ],
            child: BlocBuilder<GetInforProfileBloc, GetInforProfileState>(
                builder: (context, state) {
              if (state is GetInforProfileStateLoading) {
                return Center(
                  child: SizedBox(
                    width: 100.w,
                    height: 100.w,
                    child: Lottie.asset('assets/lottie/loading_kango.json'),
                  ),
                );
              } else if (state is GetInforProfileStateSuccess) {
                return SafeArea(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50.h,
                        child: TabBar(
                          controller: _tabController1,
                          isScrollable: false,
                          tabs: const <Widget>[
                            Tab(text: "Đang làm"),
                            Tab(text: "Hoàn thành"),
                            Tab(text: "Đã huỷ"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController1,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            //Tab1

                            BlocBuilder<GetShipperListOrderScreenBloc,
                                HandleGetShipperListOrderScreenState>(
                              builder: (context, state) {
                                if (state
                                    is HandleGetShipperListOrderScreenLoading) {
                                  return Center(
                                    child: SizedBox(
                                      width: 100.w,
                                      height: 100.w,
                                      child: Lottie.asset(
                                          'assets/lottie/loading_kango.json'),
                                    ),
                                  );
                                } else if (state
                                    is HandleGetShipperListOrderScreenSuccess) {
                                  return SlidableAutoCloseBehavior(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        Slidable.of(context)?.close();
                                      },
                                      child: RefreshIndicator(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        onRefresh: () async {
                                          _endDateError = null;
                                          statusTextController.clear();
                                          _dateStartController.clear();
                                          _dateEndController.clear();
                                          listStatus.clear();
                                          _startDate = null;
                                          _endDate = null;
                                          branchID = null;
                                          pickupShipStatusID = 1;
                                          shipperId = null;

                                          try {
                                            BlocProvider.of<
                                                        GetShipperListOrderScreenBloc>(
                                                    context)
                                                .add(
                                              FetchListOrderPickupShipper(
                                                status: null,
                                                startDate: null,
                                                endDate: null,
                                                branchId: null,
                                                keywords: query,
                                                pickupShipStatus: 1,
                                                shipperId:
                                                    dataUser?.data.userId ?? 0,
                                              ),
                                            );

                                            // Wait a moment for the state to update
                                            await Future.delayed(
                                                Duration(seconds: 1));

                                            // Check for new orders
                                            await _checkForNewOrders();
                                          } catch (e) {
                                            print("Error: $e");
                                          }
                                        },
                                        child: SingleChildScrollView(
                                          controller:
                                              scrollListBillControllerTab1,
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 10.h,
                                              ),
                                              Container(
                                                  width: 1.sw,
                                                  padding: EdgeInsets.all(10.w),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextFormField(
                                                          textInputAction:
                                                              TextInputAction
                                                                  .search,
                                                          onFieldSubmitted:
                                                              (value) {
                                                            searchProduct(
                                                                value); // Gọi hàm tìm kiếm khi người dùng nhấn Enter/Search
                                                          },
                                                          onTapOutside:
                                                              (event) {
                                                            FocusManager
                                                                .instance
                                                                .primaryFocus
                                                                ?.unfocus();
                                                          },
                                                          // onChanged: searchProduct,
                                                          controller:
                                                              textSearchController,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                          cursorColor:
                                                              Colors.black,
                                                          decoration:
                                                              InputDecoration(
                                                                  suffixIcon:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      searchProduct(
                                                                          textSearchController
                                                                              .text);
                                                                    },
                                                                    child: const Icon(
                                                                        Icons
                                                                            .search),
                                                                  ),
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .primary,
                                                                        width:
                                                                            2.0),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  isDense: true,
                                                                  hintText:
                                                                      "Tìm kiếm...",
                                                                  contentPadding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          15)),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 15.w,
                                                      ),
                                                      FileterOrderWidget(
                                                          isShowFilterStatus:
                                                              false,
                                                          dateStartController:
                                                              _dateStartController,
                                                          dateEndController:
                                                              _dateEndController,
                                                          statusTextController:
                                                              statusTextController,
                                                          branchTextController:
                                                              branchTextController,
                                                          searchTypeTextController:
                                                              textSearchController,
                                                          brandIDParam:
                                                              branchID,
                                                          listStatus:
                                                              listStatus,
                                                          branchResponse:
                                                              branchResponse,
                                                          selectDayStart:
                                                              selectDayStart,
                                                          selectDayEnd:
                                                              selectDayEnd,
                                                          getEndDateError: () =>
                                                              _endDateError,
                                                          clearFliterFunction:
                                                              clearFilterFuntion,
                                                          applyFliterFunction:
                                                              applyFilterFuntion,
                                                          onBrandIDChanged:
                                                              _updateBrandID),
                                                    ],
                                                  )),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  state.data.isEmpty
                                                      ? const NoDataFoundWidget()
                                                      : SizedBox(
                                                          width: 1.sw,
                                                          child:
                                                              ListView.builder(
                                                                  physics:
                                                                      const NeverScrollableScrollPhysics(),
                                                                  shrinkWrap:
                                                                      true,
                                                                  itemCount: state.hasReachedMax
                                                                      ? state
                                                                          .data
                                                                          .length
                                                                      : state.data
                                                                              .length +
                                                                          1,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    if (index >=
                                                                        state
                                                                            .data
                                                                            .length) {
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
                                                                    } else {
                                                                      final dataOrderPickup =
                                                                          state.data[
                                                                              index];
                                                                      cuurentIDOrder =
                                                                          dataOrderPickup
                                                                              .orderPickupId;

                                                                      return Column(
                                                                        children: [
                                                                          const Divider(
                                                                            height:
                                                                                1,
                                                                          ),
                                                                          state.isEdit == false
                                                                              ? _buildSlidableItem(
                                                                                  dataOrderPickup: dataOrderPickup,
                                                                                  isEdit: true,
                                                                                  onInfoPressed: () {
                                                                                    showBottomDialogPickup(
                                                                                      dataOrderPickup.orderPickupId,
                                                                                    );
                                                                                  },
                                                                                  onEditPressed: () {
                                                                                    _navigateToNextScreen();
                                                                                  },
                                                                                  onMapPressed: () {
                                                                                    getDetailsOrder(orderPickupID: dataOrderPickup.orderPickupId);
                                                                                  },
                                                                                  onConfirmPressed: () {
                                                                                    // Hiển thị dialog xác nhận trước khi cập nhật
                                                                                    showCustomDialogModal(
                                                                                      context: navigatorKey.currentContext!,
                                                                                      textDesc: "Bạn có chắc muốn xác nhận đơn hàng?",
                                                                                      title: "Thông báo",
                                                                                      colorButtonOk: Colors.blue,
                                                                                      btnOKText: "Xác nhận",
                                                                                      typeDialog: "question",
                                                                                      eventButtonOKPress: () {
                                                                                        // Khai báo biến subscription trước
                                                                                        StreamSubscription? subscription;
                                                                                        bool hasCompleted = false;
                                                                                        // Gửi sự kiện cập nhật đơn hàng
                                                                                        context.read<UpdateOrderPickupBloc>().add(
                                                                                              HanldeUpdateOrderPickup(
                                                                                                orderPickUpID: dataOrderPickup.orderPickupId,
                                                                                                orderPickUpType: dataOrderPickup.orderPickupType,
                                                                                                branchIDEdit: dataOrderPickup.branchId,
                                                                                                orderPickUpTime: dataOrderPickup.orderPickupDateTime.toString(),
                                                                                                orderPickUpAWB: dataOrderPickup.orderPickupAwb,
                                                                                                orderPickUpGrossWeight: dataOrderPickup.orderPickupGrossWeight.toString(),
                                                                                                orderPickUpNumberPackage: dataOrderPickup.orderPickupNumberPackages.toString(),
                                                                                                orderPickUpPhone: dataOrderPickup.orderPickupPhone,
                                                                                                orderPickUpAdrees: dataOrderPickup.orderPickupAddress,
                                                                                                orderPickUpNote: dataOrderPickup.orderPickupNote,
                                                                                                orderPickUpStatus: 2, // Cập nhật trạng thái
                                                                                                orderPickUpImage: "",
                                                                                                fwd: dataOrderPickup.fwdId,
                                                                                                orderPickupName: dataOrderPickup.orderPickupName,
                                                                                                longitude: double.parse(dataOrderPickup.longitude),
                                                                                                latitude: double.parse(dataOrderPickup.latitude),
                                                                                                orderPickupCancelDes: dataOrderPickup.orderPickupCancelDes,
                                                                                              ),
                                                                                            );

                                                                                        // Lắng nghe sự kiện cập nhật trạng thái
                                                                                        subscription = context.read<UpdateOrderPickupBloc>().stream.listen(
                                                                                          (state) {
                                                                                            // Kiểm tra nếu đã xử lý rồi thì không làm gì nữa
                                                                                            if (hasCompleted) {
                                                                                              subscription?.cancel();
                                                                                              return;
                                                                                            }
                                                                                            if (state is UpdateOrderPickupSuccess) {
                                                                                              hasCompleted = true;
                                                                                              subscription?.cancel(); // Hủy đăng ký sau khi hoàn thành
                                                                                              // Hiển thị dialog thành công
                                                                                              showCustomDialogModal(
                                                                                                context: navigatorKey.currentContext!,
                                                                                                textDesc: "Xác nhận đơn hàng thành công!",
                                                                                                title: "Thông báo",
                                                                                                colorButtonOk: Colors.green,
                                                                                                btnOKText: "Xác nhận",
                                                                                                typeDialog: "success",
                                                                                                onDismissCallback: () {
                                                                                                  // Làm mới danh sách khi dialog đóng
                                                                                                  if (navigatorKey.currentContext != null) {
                                                                                                    BlocProvider.of<GetShipperListOrderScreenBloc>(
                                                                                                      navigatorKey.currentContext!,
                                                                                                    ).add(
                                                                                                      FetchListOrderPickupShipper(
                                                                                                        status: null,
                                                                                                        startDate: null,
                                                                                                        endDate: null,
                                                                                                        branchId: null,
                                                                                                        keywords: query,
                                                                                                        pickupShipStatus: 1,
                                                                                                        shipperId: dataUser?.data.userId,
                                                                                                      ),
                                                                                                    );
                                                                                                  }
                                                                                                },
                                                                                                eventButtonOKPress: () {
                                                                                                  // Làm mới danh sách khi nhấn nút OK
                                                                                                  if (navigatorKey.currentContext != null) {
                                                                                                    BlocProvider.of<GetShipperListOrderScreenBloc>(
                                                                                                      navigatorKey.currentContext!,
                                                                                                    ).add(
                                                                                                      FetchListOrderPickupShipper(
                                                                                                        status: null,
                                                                                                        startDate: null,
                                                                                                        endDate: null,
                                                                                                        branchId: null,
                                                                                                        keywords: query,
                                                                                                        pickupShipStatus: 1,
                                                                                                        shipperId: dataUser?.data.userId,
                                                                                                      ),
                                                                                                    );
                                                                                                  }
                                                                                                },
                                                                                                isTwoButton: false,
                                                                                              );
                                                                                            }

                                                                                            if (state is UpdateOrderPickupFailure) {
                                                                                              hasCompleted = true; // Đánh dấu đã xử lý
                                                                                              subscription?.cancel(); // Hủy đăng ký
                                                                                              // Hiển thị dialog lỗi
                                                                                              showCustomDialogModal(
                                                                                                context: navigatorKey.currentContext!,
                                                                                                textDesc: state.errorText ?? "Đã có lỗi xảy ra",
                                                                                                title: "Thông báo",
                                                                                                colorButtonOk: Colors.red,
                                                                                                btnOKText: "Xác nhận",
                                                                                                typeDialog: "error",
                                                                                                eventButtonOKPress: () {},
                                                                                                isTwoButton: false,
                                                                                              );
                                                                                            }
                                                                                          },
                                                                                          onError: (error) {
                                                                                            if (!hasCompleted) {
                                                                                              hasCompleted = true;
                                                                                              subscription?.cancel();
                                                                                              return;
                                                                                            }
                                                                                            // Hiển thị thông báo lỗi chung
                                                                                            showCustomDialogModal(
                                                                                              context: navigatorKey.currentContext!,
                                                                                              textDesc: "Đã có lỗi xảy ra. Vui lòng thử lại sau.",
                                                                                              title: "Thông báo",
                                                                                              colorButtonOk: Colors.red,
                                                                                              btnOKText: "Xác nhận",
                                                                                              typeDialog: "error",
                                                                                              eventButtonOKPress: () {},
                                                                                              isTwoButton: false,
                                                                                            );
                                                                                          },
                                                                                        );
                                                                                      },
                                                                                      isTwoButton: true,
                                                                                    );
                                                                                  },
                                                                                  onTakeOrderPressed: () {
                                                                                    // Hiển thị dialog xác nhận trước khi cập nhật
                                                                                    showCustomDialogModal(
                                                                                      context: navigatorKey.currentContext!,
                                                                                      textDesc: "Bạn có chắc muốn cập nhật đơn hàng?",
                                                                                      title: "Thông báo",
                                                                                      colorButtonOk: Colors.blue,
                                                                                      btnOKText: "Xác nhận",
                                                                                      typeDialog: "question",
                                                                                      eventButtonOKPress: () {
                                                                                        // Khai báo biến subscription trước
                                                                                        StreamSubscription? subscription;

                                                                                        bool hasCompleted = false;
                                                                                        // Gửi sự kiện cập nhật đơn hàng
                                                                                        context.read<UpdateOrderPickupBloc>().add(
                                                                                              HanldeUpdateOrderPickup(
                                                                                                orderPickUpID: dataOrderPickup.orderPickupId,
                                                                                                orderPickUpType: dataOrderPickup.orderPickupType,
                                                                                                branchIDEdit: dataOrderPickup.branchId,
                                                                                                orderPickUpTime: dataOrderPickup.orderPickupDateTime.toString(),
                                                                                                orderPickUpAWB: dataOrderPickup.orderPickupAwb,
                                                                                                orderPickUpGrossWeight: dataOrderPickup.orderPickupGrossWeight.toString(),
                                                                                                orderPickUpNumberPackage: dataOrderPickup.orderPickupNumberPackages.toString(),
                                                                                                orderPickUpPhone: dataOrderPickup.orderPickupPhone,
                                                                                                orderPickUpAdrees: dataOrderPickup.orderPickupAddress,
                                                                                                orderPickUpNote: dataOrderPickup.orderPickupNote,
                                                                                                orderPickUpStatus: 3, // Cập nhật trạng thái
                                                                                                orderPickUpImage: "",
                                                                                                fwd: dataOrderPickup.fwdId,
                                                                                                orderPickupName: dataOrderPickup.orderPickupName,
                                                                                                longitude: double.parse(dataOrderPickup.longitude),
                                                                                                latitude: double.parse(dataOrderPickup.latitude),
                                                                                                orderPickupCancelDes: dataOrderPickup.orderPickupCancelDes,
                                                                                              ),
                                                                                            );

                                                                                        // Lắng nghe sự kiện cập nhật trạng thái
                                                                                        subscription = context.read<UpdateOrderPickupBloc>().stream.listen(
                                                                                          (state) {
                                                                                            if (hasCompleted) {
                                                                                              subscription?.cancel();
                                                                                              return;
                                                                                            }
                                                                                            if (state is UpdateOrderPickupSuccess) {
                                                                                              hasCompleted = true;
                                                                                              subscription?.cancel(); // Hủy đăng ký sau khi hoàn thành
                                                                                              // Hiển thị dialog thành công
                                                                                              showCustomDialogModal(
                                                                                                context: navigatorKey.currentContext!,
                                                                                                textDesc: "Cập nhật đơn hàng đang lấy thành công!",
                                                                                                title: "Thông báo",
                                                                                                colorButtonOk: Colors.green,
                                                                                                btnOKText: "Xác nhận",
                                                                                                typeDialog: "success",
                                                                                                onDismissCallback: () {
                                                                                                  // Làm mới danh sách khi dialog đóng
                                                                                                  if (navigatorKey.currentContext != null) {
                                                                                                    BlocProvider.of<GetShipperListOrderScreenBloc>(
                                                                                                      navigatorKey.currentContext!,
                                                                                                    ).add(
                                                                                                      FetchListOrderPickupShipper(
                                                                                                        status: null,
                                                                                                        startDate: null,
                                                                                                        endDate: null,
                                                                                                        branchId: null,
                                                                                                        keywords: query,
                                                                                                        pickupShipStatus: 1,
                                                                                                        shipperId: dataUser?.data.userId,
                                                                                                      ),
                                                                                                    );
                                                                                                  }
                                                                                                },
                                                                                                eventButtonOKPress: () {
                                                                                                  // Làm mới danh sách khi nhấn nút OK
                                                                                                  if (navigatorKey.currentContext != null) {
                                                                                                    BlocProvider.of<GetShipperListOrderScreenBloc>(
                                                                                                      navigatorKey.currentContext!,
                                                                                                    ).add(
                                                                                                      FetchListOrderPickupShipper(
                                                                                                        status: null,
                                                                                                        startDate: null,
                                                                                                        endDate: null,
                                                                                                        branchId: null,
                                                                                                        keywords: query,
                                                                                                        pickupShipStatus: 1,
                                                                                                        shipperId: dataUser?.data.userId,
                                                                                                      ),
                                                                                                    );
                                                                                                  }
                                                                                                },
                                                                                                isTwoButton: false,
                                                                                              );
                                                                                            }

                                                                                            if (state is UpdateOrderPickupFailure) {
                                                                                              hasCompleted = true;
                                                                                              subscription?.cancel(); // Hủy đăng ký
                                                                                              // Hiển thị dialog lỗi
                                                                                              showCustomDialogModal(
                                                                                                context: navigatorKey.currentContext!,
                                                                                                textDesc: state.errorText ?? "Đã có lỗi xảy ra",
                                                                                                title: "Thông báo",
                                                                                                colorButtonOk: Colors.red,
                                                                                                btnOKText: "Xác nhận",
                                                                                                typeDialog: "error",
                                                                                                eventButtonOKPress: () {},
                                                                                                isTwoButton: false,
                                                                                              );
                                                                                            }
                                                                                          },
                                                                                          onError: (error) {
                                                                                            if (!hasCompleted) {
                                                                                              hasCompleted = true;
                                                                                              subscription?.cancel();
                                                                                              return;
                                                                                            }
                                                                                            // Hiển thị thông báo lỗi chung
                                                                                            showCustomDialogModal(
                                                                                              context: navigatorKey.currentContext!,
                                                                                              textDesc: "Đã có lỗi xảy ra. Vui lòng thử lại sau.",
                                                                                              title: "Thông báo",
                                                                                              colorButtonOk: Colors.red,
                                                                                              btnOKText: "Xác nhận",
                                                                                              typeDialog: "error",
                                                                                              eventButtonOKPress: () {},
                                                                                              isTwoButton: false,
                                                                                            );
                                                                                          },
                                                                                        );
                                                                                      },
                                                                                      isTwoButton: true,
                                                                                    );
                                                                                  },
                                                                                  onTakedOrderPressed: () {
                                                                                    // Gọi dialog trước khi cập nhật order
                                                                                    _showImageDialog(context, dataOrderPickup);
                                                                                  },
                                                                                  onPickupedOrderPressed: () {
                                                                                    _showImageDialog(context, dataOrderPickup);
                                                                                  },
                                                                                  onOrderCancelPressed: () {
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      builder: (context) => AlertDialog(
                                                                                        title: Text('Hủy đơn', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                                                                        content: Column(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            TextApp(
                                                                                              text: "Nguyên nhân huỷ bỏ",
                                                                                              fontsize: 14.sp,
                                                                                              fontWeight: FontWeight.bold,
                                                                                              color: Colors.black,
                                                                                            ),
                                                                                            SizedBox(height: 10.h),
                                                                                            TextFormField(
                                                                                              onTapOutside: (event) {
                                                                                                FocusManager.instance.primaryFocus?.unfocus();
                                                                                              },
                                                                                              controller: cancelReasonController,
                                                                                              keyboardType: TextInputType.multiline,
                                                                                              minLines: 2,
                                                                                              maxLines: 5,
                                                                                              style: TextStyle(fontSize: 14.sp, color: Colors.black),
                                                                                              cursorColor: Theme.of(context).colorScheme.primary,
                                                                                              decoration: InputDecoration(
                                                                                                fillColor: Theme.of(context).colorScheme.primary,
                                                                                                focusedBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                                                                                                  borderRadius: BorderRadius.circular(8.r),
                                                                                                ),
                                                                                                border: OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(8.r),
                                                                                                ),
                                                                                                hintText: 'Nhập lý do hủy đơn',
                                                                                                isDense: true,
                                                                                                contentPadding: EdgeInsets.all(20.w),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        actions: [
                                                                                          TextButton(
                                                                                            onPressed: () => Navigator.pop(context),
                                                                                            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                                                                                          ),
                                                                                          TextButton(
                                                                                            onPressed: () {
                                                                                              if (cancelReasonController.text.trim().isEmpty) {
                                                                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập lý do hủy đơn')));
                                                                                                return;
                                                                                              }
                                                                                              Navigator.pop(context);

                                                                                              onDeleteOrderPickUp(dataOrderPickup.orderPickupId);
                                                                                              setState(() {
                                                                                                cancelReasonController.dispose;
                                                                                              });
/*
                                                                                              // Đóng dialog
                                                                                              Navigator.pop(context);

                                                                                              // Gọi API cập nhật trạng thái
                                                                                              context.read<UpdateOrderPickupBloc>().add(
                                                                                                    HanldeUpdateOrderPickup(
                                                                                                      orderPickUpID: dataOrderPickup.orderPickupId,
                                                                                                      orderPickUpType: dataOrderPickup.orderPickupType,
                                                                                                      branchIDEdit: dataOrderPickup.branchId,
                                                                                                      orderPickUpTime: dataOrderPickup.orderPickupDateTime.toString(),
                                                                                                      orderPickUpAWB: dataOrderPickup.orderPickupAwb,
                                                                                                      orderPickUpGrossWeight: dataOrderPickup.orderPickupGrossWeight.toString(),
                                                                                                      orderPickUpNumberPackage: dataOrderPickup.orderPickupNumberPackages.toString(),
                                                                                                      orderPickUpPhone: dataOrderPickup.orderPickupPhone,
                                                                                                      orderPickUpAdrees: dataOrderPickup.orderPickupAddress,
                                                                                                      orderPickUpNote: dataOrderPickup.orderPickupNote,
                                                                                                      orderPickUpStatus: 6, // Status hủy đơn
                                                                                                      orderPickUpImage: "",
                                                                                                      fwd: dataOrderPickup.fwdId,
                                                                                                      orderPickupName: dataOrderPickup.orderPickupName,
                                                                                                      longitude: double.parse(dataOrderPickup.longitude),
                                                                                                      latitude: double.parse(dataOrderPickup.latitude),
                                                                                                      orderPickupCancelDes: cancelReasonController.text.trim(), // Lý do hủy
                                                                                                    ),
                                                                                                  );

                                                                                              // Lắng nghe kết quả cập nhật
                                                                                              context.read<UpdateOrderPickupBloc>().stream.listen((state) {
                                                                                                if (state is UpdateOrderPickupSuccess) {
                                                                                                  // Hiển thị thông báo thành công
                                                                                                  showCustomDialogModal(
                                                                                                    context: navigatorKey.currentContext!,
                                                                                                    textDesc: "Hủy đơn thành công!",
                                                                                                    title: "Thông báo",
                                                                                                    colorButtonOk: Colors.green,
                                                                                                    btnOKText: "Xác nhận",
                                                                                                    typeDialog: "success",
                                                                                                    onDismissCallback: () {
                                                                                                      setState(() {
                                                                                                        cancelReasonController.text = '';
                                                                                                      });
                                                                                                      // Làm mới danh sách khi dialog đóng
                                                                                                      if (navigatorKey.currentContext != null) {
                                                                                                        BlocProvider.of<GetShipperListOrderScreenBloc>(
                                                                                                          navigatorKey.currentContext!,
                                                                                                        ).add(
                                                                                                          FetchListOrderPickupShipper(
                                                                                                            status: null,
                                                                                                            startDate: null,
                                                                                                            endDate: null,
                                                                                                            branchId: null,
                                                                                                            keywords: query,
                                                                                                            pickupShipStatus: 1,
                                                                                                            shipperId: dataUser?.data.userId,
                                                                                                          ),
                                                                                                        );
                                                                                                      }
                                                                                                    },
                                                                                                    eventButtonOKPress: () {
                                                                                                      // Làm mới danh sách khi nhấn nút OK
                                                                                                      setState(() {
                                                                                                        cancelReasonController.text = '';
                                                                                                      });
                                                                                                      if (navigatorKey.currentContext != null) {
                                                                                                        BlocProvider.of<GetShipperListOrderScreenBloc>(
                                                                                                          navigatorKey.currentContext!,
                                                                                                        ).add(
                                                                                                          FetchListOrderPickupShipper(
                                                                                                            status: null,
                                                                                                            startDate: null,
                                                                                                            endDate: null,
                                                                                                            branchId: null,
                                                                                                            keywords: query,
                                                                                                            pickupShipStatus: 1,
                                                                                                            shipperId: dataUser?.data.userId,
                                                                                                          ),
                                                                                                        );
                                                                                                      }
                                                                                                    },
                                                                                                    isTwoButton: false,
                                                                                                  );
                                                                                                }

                                                                                                if (state is UpdateOrderPickupFailure) {
                                                                                                  // Hiển thị thông báo lỗi
                                                                                                  showCustomDialogModal(
                                                                                                    context: navigatorKey.currentContext!,
                                                                                                    textDesc: state.errorText ?? "Đã có lỗi xảy ra",
                                                                                                    title: "Thông báo",
                                                                                                    colorButtonOk: Colors.red,
                                                                                                    btnOKText: "Xác nhận",
                                                                                                    typeDialog: "error",
                                                                                                    eventButtonOKPress: () {},
                                                                                                    isTwoButton: false,
                                                                                                  );
                                                                                                }
                                                                                              });*/
                                                                                            },
                                                                                            child: Text('Xác nhận', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    );
                                                                                  })
                                                                              : _noEditContainer(dataOrderPickup: dataOrderPickup)
                                                                        ],
                                                                      );
                                                                    }
                                                                  }),
                                                        ),
                                                  SizedBox(
                                                    height: 10.h,
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (state
                                    is HandleGetShipperListOrderScreenFailure) {
                                  return ErrorDialog(
                                    eventConfirm: () {
                                      Navigator.pop(context);
                                    },
                                    errorText: state.message,
                                  );
                                }
                                return const Center(child: NoDataFoundWidget());
                              },
                            ),
                            //Tab2
                            BlocBuilder<GetShipperListOrderScreenBloc,
                                HandleGetShipperListOrderScreenState>(
                              builder: (context, state) {
                                if (state
                                    is HandleGetShipperListOrderScreenLoading) {
                                  return Center(
                                    child: SizedBox(
                                      width: 100.w,
                                      height: 100.w,
                                      child: Lottie.asset(
                                          'assets/lottie/loading_kango.json'),
                                    ),
                                  );
                                } else if (state
                                    is HandleGetShipperListOrderScreenSuccess) {
                                  return SlidableAutoCloseBehavior(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        Slidable.of(context)?.close();
                                      },
                                      child: RefreshIndicator(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        onRefresh: () async {
                                          _endDateError = null;
                                          statusTextController.clear();
                                          _dateStartController.clear();
                                          _dateEndController.clear();
                                          listStatus.clear();
                                          _startDate = null;
                                          _endDate = null;
                                          branchID = null;
                                          pickupShipStatusID = null;
                                          shipperId = null;
                                          BlocProvider.of<
                                                      GetShipperListOrderScreenBloc>(
                                                  context)
                                              .add(FetchListOrderPickupShipper(
                                                  status: null,
                                                  startDate: null,
                                                  endDate: null,
                                                  branchId: null,
                                                  keywords: query,
                                                  pickupShipStatus: 2,
                                                  shipperId:
                                                      dataUser?.data.userId));
                                        },
                                        child: SingleChildScrollView(
                                          controller:
                                              scrollListBillControllerTab2,
                                          physics:
                                              AlwaysScrollableScrollPhysics(),
                                          child: Column(
                                            children: [
                                              Container(
                                                  width: 1.sw,
                                                  padding: EdgeInsets.all(10.w),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextFormField(
                                                          onTapOutside:
                                                              (event) {
                                                            FocusManager
                                                                .instance
                                                                .primaryFocus
                                                                ?.unfocus();
                                                          },
                                                          // onChanged: searchProduct,
                                                          controller:
                                                              textSearchController,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                          cursorColor:
                                                              Colors.black,
                                                          decoration:
                                                              InputDecoration(
                                                                  suffixIcon:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      searchProduct(
                                                                          textSearchController
                                                                              .text);
                                                                    },
                                                                    child: const Icon(
                                                                        Icons
                                                                            .search),
                                                                  ),
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .primary,
                                                                        width:
                                                                            2.0),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  isDense: true,
                                                                  hintText:
                                                                      "Tìm kiếm...",
                                                                  contentPadding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          15)),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 15.w,
                                                      ),
                                                      FileterOrderWidget(
                                                          isShowFilterStatus:
                                                              false,
                                                          dateStartController:
                                                              _dateStartController,
                                                          dateEndController:
                                                              _dateEndController,
                                                          statusTextController:
                                                              statusTextController,
                                                          branchTextController:
                                                              branchTextController,
                                                          searchTypeTextController:
                                                              textSearchController,
                                                          brandIDParam:
                                                              branchID,
                                                          listStatus:
                                                              listStatus,
                                                          branchResponse:
                                                              branchResponse,
                                                          selectDayStart:
                                                              selectDayStart,
                                                          selectDayEnd:
                                                              selectDayEnd,
                                                          getEndDateError: () =>
                                                              _endDateError,
                                                          clearFliterFunction:
                                                              clearFilterFuntion,
                                                          applyFliterFunction:
                                                              applyFilterFuntion,
                                                          onBrandIDChanged:
                                                              _updateBrandID),
                                                    ],
                                                  )),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  state.data.isEmpty
                                                      ? const NoDataFoundWidget()
                                                      : SizedBox(
                                                          width: 1.sw,
                                                          child:
                                                              ListView.builder(
                                                                  physics:
                                                                      const NeverScrollableScrollPhysics(),
                                                                  shrinkWrap:
                                                                      true,
                                                                  itemCount: state.hasReachedMax
                                                                      ? state
                                                                          .data
                                                                          .length
                                                                      : state.data
                                                                              .length +
                                                                          1,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    if (index >=
                                                                        state
                                                                            .data
                                                                            .length) {
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
                                                                    } else {
                                                                      final dataOrderPickup =
                                                                          state.data[
                                                                              index];

                                                                      return Column(
                                                                        children: [
                                                                          const Divider(
                                                                            height:
                                                                                1,
                                                                          ),
                                                                          Container(
                                                                              width: 1.sw,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(0.r),
                                                                                color: Colors.white,
                                                                              ),
                                                                              child: state.isEdit == false
                                                                                  ? _buildSlidableItem(
                                                                                      dataOrderPickup: dataOrderPickup,
                                                                                      isEdit: false,
                                                                                      onInfoPressed: () {
                                                                                        showBottomDialogPickup(dataOrderPickup.orderPickupId);
                                                                                      })
                                                                                  : _noEditContainer(dataOrderPickup: dataOrderPickup)),
                                                                        ],
                                                                      );
                                                                    }
                                                                  }),
                                                        ),
                                                  SizedBox(
                                                    height: 10.h,
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (state
                                    is HandleGetShipperListOrderScreenFailure) {
                                  return ErrorDialog(
                                    eventConfirm: () {
                                      Navigator.pop(context);
                                    },
                                    errorText: state.message,
                                  );
                                }
                                return const Center(child: NoDataFoundWidget());
                              },
                            ),
                            //Tab3
                            BlocBuilder<GetShipperListOrderScreenBloc,
                                HandleGetShipperListOrderScreenState>(
                              builder: (context, state) {
                                if (state
                                    is HandleGetShipperListOrderScreenLoading) {
                                  return Center(
                                    child: SizedBox(
                                      width: 100.w,
                                      height: 100.w,
                                      child: Lottie.asset(
                                          'assets/lottie/loading_kango.json'),
                                    ),
                                  );
                                } else if (state
                                    is HandleGetShipperListOrderScreenSuccess) {
                                  return SlidableAutoCloseBehavior(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        Slidable.of(context)?.close();
                                      },
                                      child: RefreshIndicator(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        onRefresh: () async {
                                          _endDateError = null;
                                          statusTextController.clear();
                                          _dateStartController.clear();
                                          _dateEndController.clear();
                                          listStatus.clear();
                                          _startDate = null;
                                          _endDate = null;
                                          branchID = null;
                                          pickupShipStatusID = null;
                                          shipperId = null;
                                          BlocProvider.of<
                                                      GetShipperListOrderScreenBloc>(
                                                  context)
                                              .add(FetchListOrderPickupShipper(
                                                  status: null,
                                                  startDate: null,
                                                  endDate: null,
                                                  branchId: null,
                                                  keywords: query,
                                                  pickupShipStatus: 0,
                                                  shipperId:
                                                      dataUser?.data.userId));
                                        },
                                        child: SingleChildScrollView(
                                          controller:
                                              scrollListBillControllerTab3,
                                          physics:
                                              AlwaysScrollableScrollPhysics(),
                                          child: Column(
                                            children: [
                                              Container(
                                                  width: 1.sw,
                                                  padding: EdgeInsets.all(10.w),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextFormField(
                                                          onTapOutside:
                                                              (event) {
                                                            FocusManager
                                                                .instance
                                                                .primaryFocus
                                                                ?.unfocus();
                                                          },
                                                          // onChanged: searchProduct,
                                                          controller:
                                                              textSearchController,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                          cursorColor:
                                                              Colors.black,
                                                          decoration:
                                                              InputDecoration(
                                                                  suffixIcon:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      searchProduct(
                                                                          textSearchController
                                                                              .text);
                                                                    },
                                                                    child: const Icon(
                                                                        Icons
                                                                            .search),
                                                                  ),
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .primary,
                                                                        width:
                                                                            2.0),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  isDense: true,
                                                                  hintText:
                                                                      "Tìm kiếm...",
                                                                  contentPadding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          15)),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 15.w,
                                                      ),
                                                      FileterOrderWidget(
                                                          isShowFilterStatus:
                                                              false,
                                                          dateStartController:
                                                              _dateStartController,
                                                          dateEndController:
                                                              _dateEndController,
                                                          statusTextController:
                                                              statusTextController,
                                                          branchTextController:
                                                              branchTextController,
                                                          searchTypeTextController:
                                                              textSearchController,
                                                          brandIDParam:
                                                              branchID,
                                                          listStatus:
                                                              listStatus,
                                                          branchResponse:
                                                              branchResponse,
                                                          selectDayStart:
                                                              selectDayStart,
                                                          selectDayEnd:
                                                              selectDayEnd,
                                                          getEndDateError: () =>
                                                              _endDateError,
                                                          clearFliterFunction:
                                                              clearFilterFuntion,
                                                          applyFliterFunction:
                                                              applyFilterFuntion,
                                                          onBrandIDChanged:
                                                              _updateBrandID),
                                                    ],
                                                  )),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  state.data.isEmpty
                                                      ? const NoDataFoundWidget()
                                                      : SizedBox(
                                                          width: 1.sw,
                                                          child:
                                                              ListView.builder(
                                                                  physics:
                                                                      const NeverScrollableScrollPhysics(),
                                                                  shrinkWrap:
                                                                      true,
                                                                  itemCount: state.hasReachedMax
                                                                      ? state
                                                                          .data
                                                                          .length
                                                                      : state.data
                                                                              .length +
                                                                          1,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    if (index >=
                                                                        state
                                                                            .data
                                                                            .length) {
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
                                                                    } else {
                                                                      final dataOrderPickup =
                                                                          state.data[
                                                                              index];

                                                                      return Column(
                                                                        children: [
                                                                          const Divider(
                                                                            height:
                                                                                1,
                                                                          ),
                                                                          Container(
                                                                              width: 1.sw,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(0.r),
                                                                                color: Colors.white,
                                                                              ),
                                                                              child: state.isEdit == false
                                                                                  ? _buildSlidableItem(
                                                                                      dataOrderPickup: dataOrderPickup,
                                                                                      isEdit: false,
                                                                                      onInfoPressed: () {
                                                                                        showBottomDialogPickup(dataOrderPickup.orderPickupId);
                                                                                      })
                                                                                  : _noEditContainer(dataOrderPickup: dataOrderPickup)),
                                                                        ],
                                                                      );
                                                                    }
                                                                  }),
                                                        ),
                                                  SizedBox(
                                                    height: 10.h,
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (state
                                    is HandleGetShipperListOrderScreenFailure) {
                                  return ErrorDialog(
                                    eventConfirm: () {
                                      Navigator.pop(context);
                                    },
                                    errorText:
                                        'Failed to fetch orders: ${state.message}',
                                  );
                                }
                                return const Center(child: NoDataFoundWidget());
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is GetInforProfileStateFailure) {
                return ErrorDialog(
                  eventConfirm: () {
                    Navigator.pop(context);
                  },
                  errorText: 'Không lấy được dữ liệu người dùng',
                );
              }
              return const Center(child: NoDataFoundWidget());
            }),
          ),
          /*if (currentTab == 0)
            Positioned(
              right: _fabPosition.dx,
              bottom: _fabPosition.dy,
              child: Draggable(
                feedback: Material(
                    type: MaterialType.transparency,
                    child: Stack(
                      children: [
                        !isExpanded
                            ? InkWell(
                                onTap: () {
                                  setState(() {
                                    isExpanded = !isExpanded;
                                  });
                                },
                                child: AnimatedContainer(
                                    width: 60.w,
                                    height: 60.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30.w),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.8),
                                    ),
                                    duration: Duration(milliseconds: 300),
                                    child: dataUser?.data.userIsFreeTime == 0
                                        ? Icon(
                                            Icons.local_shipping,
                                            size: 36.sp,
                                            color: Colors.white,
                                          )
                                        : Stack(
                                            children: [
                                              Center(
                                                child: Icon(
                                                  Icons.local_shipping,
                                                  size: 36.sp,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              isHaveOrder
                                                  ? Positioned(
                                                      top: 0,
                                                      right: 0,
                                                      child: Icon(
                                                        Icons.info,
                                                        size: 24.sp,
                                                        color: Colors.orange,
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          )),
                              )
                            : AnimatedContainer(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.r),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.6),
                                ),
                                duration: const Duration(
                                    milliseconds: 300), // Animation duration
                                curve: Curves.easeInOut, // Smooth animation
                                width: 1.sw - 180.w,
                                height: 120.h, // Set the height as constant
                                alignment:
                                    Alignment.centerLeft, // Align content
                                child: dataUser?.data.userIsFreeTime == 0
                                    ? Stack(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(10.w),
                                                margin: EdgeInsets.all(10.w),
                                                width: 1.sw,
                                                child: TextApp(
                                                  textAlign: TextAlign.center,
                                                  text:
                                                      "Bạn đang đi giao hàng!",
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontsize: 16.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Positioned(
                                              top: 5.w,
                                              right: 5.w,
                                              child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      isExpanded = !isExpanded;
                                                    });
                                                  },
                                                  child: Container(
                                                      width: 30.w,
                                                      height: 30.w,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.r),
                                                        color: Colors.white,
                                                      ),
                                                      child: Icon(
                                                        Icons.close,
                                                        size: 18.sp,
                                                        color: Colors.black,
                                                      ))))
                                        ],
                                      )
                                    : Stack(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 10.h,
                                              ),
                                              Container(
                                                width: 1.sw,
                                                child: TextApp(
                                                  textAlign: TextAlign.center,
                                                  text: "Bạn đang rảnh rỗi!",
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontsize: 16.sp,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10.h,
                                              ),
                                              isHaveOrder
                                                  ? ButtonApp(
                                                      event: () {
                                                        shipperStart();
                                                        getInforUser();
                                                      },
                                                      text: "Bắt đầu lấy đơn",
                                                      colorText:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      backgroundColor:
                                                          Colors.white,
                                                      outlineColor:
                                                          Colors.white)
                                                  : Container()
                                            ],
                                          ),
                                          Positioned(
                                              top: 5.w,
                                              right: 5.w,
                                              child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      isExpanded = !isExpanded;
                                                    });
                                                  },
                                                  child: Container(
                                                      width: 30.w,
                                                      height: 30.w,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.r),
                                                        color: Colors.white,
                                                      ),
                                                      child: Icon(
                                                        Icons.close,
                                                        size: 18.sp,
                                                        color: Colors.black,
                                                      ))))
                                        ],
                                      )),
                      ],
                    )),
                childWhenDragging: Container(),
                child: Stack(
                  children: [
                    !isExpanded
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                isExpanded = !isExpanded;
                              });
                            },
                            child: AnimatedContainer(
                                width: 60.w,
                                height: 60.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.w),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.8),
                                ),
                                duration: const Duration(milliseconds: 300),
                                child: dataUser?.data.userIsFreeTime == 0
                                    ? Icon(
                                        Icons.local_shipping,
                                        size: 36.sp,
                                        color: Colors.white,
                                      )
                                    : Stack(
                                        children: [
                                          Center(
                                            child: Icon(
                                              Icons.local_shipping,
                                              size: 36.sp,
                                              color: Colors.white,
                                            ),
                                          ),
                                          isHaveOrder
                                              ? Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: Icon(
                                                    Icons.info,
                                                    size: 24.sp,
                                                    color: Colors.orange,
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      )),
                          )
                        : AnimatedContainer(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.6),
                            ),
                            duration: Duration(
                                milliseconds: 300), // Animation duration
                            curve: Curves.easeInOut, // Smooth animation
                            width: 1.sw - 180.w,
                            height: 120.h, // Set the height as constant
                            alignment: Alignment.centerLeft, // Align content
                            child: dataUser?.data.userIsFreeTime == 0
                                ? Stack(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(10.w),
                                            margin: EdgeInsets.all(10.w),
                                            width: 1.sw,
                                            child: TextApp(
                                              textAlign: TextAlign.center,
                                              text: "Bạn đang đi giao hàng!",
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontsize: 16.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Positioned(
                                          top: 5.w,
                                          right: 5.w,
                                          child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  isExpanded = !isExpanded;
                                                });
                                              },
                                              child: Container(
                                                  width: 30.w,
                                                  height: 30.w,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.r),
                                                    color: Colors.white,
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 18.sp,
                                                    color: Colors.black,
                                                  ))))
                                    ],
                                  )
                                : Stack(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Container(
                                            width: 1.sw,
                                            child: TextApp(
                                              textAlign: TextAlign.center,
                                              text: "Bạn đang rảnh rỗi!",
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontsize: 16.sp,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          isHaveOrder
                                              ? ButtonApp(
                                                  event: () {
                                                    shipperStart();
                                                    getInforUser();
                                                  },
                                                  text: "Bắt đầu lấy đơn",
                                                  colorText: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  fontWeight: FontWeight.bold,
                                                  backgroundColor: Colors.white,
                                                  outlineColor: Colors.white)
                                              : Container()
                                        ],
                                      ),
                                      Positioned(
                                          top: 5.w,
                                          right: 5.w,
                                          child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  isExpanded = !isExpanded;
                                                });
                                              },
                                              child: Container(
                                                  width: 30.w,
                                                  height: 30.w,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.r),
                                                    color: Colors.white,
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 18.sp,
                                                    color: Colors.black,
                                                  ))))
                                    ],
                                  )),
                  ],
                ),
                onDraggableCanceled: (velocity, offset) {
                  isExpanded
                      ? setState(() {
                          _fabPosition = Offset(
                            1.sw -
                                offset.dx -
                                250.w, // Width adjustment for right position
                            1.sh -
                                offset.dy -
                                210.h, // Height adjustment for bottom position
                          );
                        })
                      : setState(() {
                          _fabPosition = Offset(
                            1.sw -
                                offset.dx -
                                60.w, // Width adjustment for right position
                            1.sh -
                                offset.dy -
                                150.h, // Height adjustment for bottom position
                          );
                        });
                },
              ),
            ),
        */
        ],
      ),
    );
  }

  Widget _noEditContainer({required dataOrderPickup}) {
    return SizedBox(
      width: 1.sw,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80.w,
            child: Column(
              children: [
                Icon(
                  dataOrderPickup.orderPickupStatus == 0
                      ? Icons.replay_circle_filled
                      : dataOrderPickup.orderPickupStatus == 1
                          ? Icons.info
                          : dataOrderPickup.orderPickupStatus == 2
                              ? Icons.check_circle_outline
                              : dataOrderPickup.orderPickupStatus == 3
                                  ? Icons.arrow_circle_right
                                  : dataOrderPickup.orderPickupStatus == 4
                                      ? Icons.check_circle_rounded
                                      : dataOrderPickup.orderPickupStatus == 5
                                          ? Icons.fire_truck_sharp
                                          : Icons.cancel,
                  color: dataOrderPickup.orderPickupStatus == 0
                      ? Colors.grey
                      : dataOrderPickup.orderPickupStatus == 1
                          ? const Color.fromARGB(255, 243, 219, 8)
                          : dataOrderPickup.orderPickupStatus == 2
                              ? Colors.green.shade700
                              : dataOrderPickup.orderPickupStatus == 3
                                  ? Colors.green
                                  : dataOrderPickup.orderPickupStatus == 4
                                      ? Colors.blue
                                      : dataOrderPickup.orderPickupStatus == 5
                                          ? Colors.blue
                                          : Colors.red,
                  size: 48.sp,
                ),
                TextApp(
                  isOverFlow: false,
                  softWrap: true,
                  text: dataOrderPickup.orderPickupStatus == 0
                      ? "Đang chờ duyệt"
                      : dataOrderPickup.orderPickupStatus == 1
                          ? "Đang chờ xác nhận"
                          : dataOrderPickup.orderPickupStatus == 2
                              ? "Đã xác nhận"
                              : dataOrderPickup.orderPickupStatus == 3
                                  ? "Đang chờ xác nhận"
                                  : dataOrderPickup.orderPickupStatus == 4
                                      ? "Đã lấy"
                                      : dataOrderPickup.orderPickupStatus == 5
                                          ? "Đã pickup"
                                          : "Đã huỷ",
                  fontsize: 14.sp,
                  color: Colors.black,
                  maxLines: 3,
                  fontWeight: FontWeight.normal,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextApp(
                    text: dataOrderPickup.orderPickupCode,
                    fontsize: 18.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(
                    width: 65.w,
                  ),
                  TextApp(
                      text: dataOrderPickup.orderPickupDateTime ?? '',
                      fontsize: 12.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 300.w,
                    child: TextApp(
                      softWrap: true,
                      isOverFlow: false,
                      text:
                          "Người tạo: ${dataOrderPickup.user.userContactName}",
                      fontsize: 16.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 300.w,
                    child: TextApp(
                      softWrap: true,
                      isOverFlow: false,
                      text: "Địa chỉ: ${dataOrderPickup.orderPickupAddress}",
                      fontsize: 16.sp,
                      maxLines: 3,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 300.w,
                    child: TextApp(
                      softWrap: true,
                      isOverFlow: false,
                      text:
                          "Note: ${dataOrderPickup.orderPickupNote ?? 'Không có ghi chú'}",
                      fontsize: 16.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSlidableItem({
    required dataOrderPickup,
    required bool isEdit,
    required VoidCallback onInfoPressed,
    VoidCallback? onEditPressed,
    VoidCallback? onMapPressed,
    VoidCallback? onConfirmPressed,
    VoidCallback? onTakeOrderPressed,
    VoidCallback? onTakedOrderPressed,
    VoidCallback? onPickupedOrderPressed,
    VoidCallback? onOrderCancelPressed,
  }) {
    return Slidable(
        key: ValueKey(dataOrderPickup),
        endActionPane: ActionPane(
          extentRatio: isEdit ? 1 : 0.3,
          motion: const DrawerMotion(), // Hiệu ứng mượt mà hơn khi vuốt
          children: [
            // Nút Thêm thông tin
            CustomSlidableAction(
              onPressed: (_) => onInfoPressed(),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Chi tiết',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Nút xác nhận cho trạng thái 1
            if (dataOrderPickup.orderPickupStatus == 1)
              CustomSlidableAction(
                onPressed: (_) => onConfirmPressed?.call(),
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Xác nhận',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            // Nút đang đi lấy cho trạng thái 2
            if (dataOrderPickup.orderPickupStatus == 2)
              CustomSlidableAction(
                onPressed: (_) => onTakeOrderPressed?.call(),
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Đang đi lấy',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            // Nút đã lấy cho trạng thái 3
            if (dataOrderPickup.orderPickupStatus == 3)
              CustomSlidableAction(
                onPressed: (_) => onTakedOrderPressed?.call(),
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Đã lấy',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            // Nút đã pickup cho trạng thái 4
            if (dataOrderPickup.orderPickupStatus == 4)
              CustomSlidableAction(
                onPressed: (_) => onPickupedOrderPressed?.call(),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fire_truck_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Đã pickup',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),

            // Nút hủy đơn cho trạng thái 2, 3, 4
            if (dataOrderPickup.orderPickupStatus == 2 ||
                dataOrderPickup.orderPickupStatus == 3 ||
                dataOrderPickup.orderPickupStatus == 4)
              CustomSlidableAction(
                onPressed: (_) => onOrderCancelPressed?.call(),
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cancel_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Hủy đơn',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            // Nút bản đồ khi isEdit = true và trạng thái 3 hoặc 4
            if (isEdit &&
                (dataOrderPickup.orderPickupStatus == 3 ||
                    dataOrderPickup.orderPickupStatus == 4))
              CustomSlidableAction(
                onPressed: (_) => onMapPressed?.call(),
                backgroundColor: Colors.deepPurple.shade600,
                foregroundColor: Colors.white,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Bản đồ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
        child: Material(
          color: Colors.white,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              log("kkk");
            },
            child: Card(
              color: Colors.white,
              elevation: 2,
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(
                  color: dataOrderPickup.orderPickupStatus == 0
                      ? Colors.grey.shade300
                      : dataOrderPickup.orderPickupStatus == 1
                          ? Colors.amber.shade200
                          : dataOrderPickup.orderPickupStatus == 2
                              ? Colors.green.shade200
                              : dataOrderPickup.orderPickupStatus == 3
                                  ? Colors.green.shade300
                                  : dataOrderPickup.orderPickupStatus == 4
                                      ? Colors.blue.shade200
                                      : dataOrderPickup.orderPickupStatus == 5
                                          ? Colors.blue.shade300
                                          : Colors.red.shade200,
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Status icon column
                    Container(
                      width: 70.w,
                      decoration: BoxDecoration(
                        color: dataOrderPickup.orderPickupStatus == 0
                            ? Colors.grey.shade100
                            : dataOrderPickup.orderPickupStatus == 1
                                ? Colors.amber.shade50
                                : dataOrderPickup.orderPickupStatus == 2
                                    ? Colors.green.shade50
                                    : dataOrderPickup.orderPickupStatus == 3
                                        ? Colors.green.shade100
                                        : dataOrderPickup.orderPickupStatus == 4
                                            ? Colors.blue.shade50
                                            : dataOrderPickup
                                                        .orderPickupStatus ==
                                                    5
                                                ? Colors.blue.shade100
                                                : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            dataOrderPickup.orderPickupStatus == 0
                                ? Icons.pending_outlined
                                : dataOrderPickup.orderPickupStatus == 1
                                    ? Icons.info_outline
                                    : dataOrderPickup.orderPickupStatus == 2
                                        ? Icons.check_circle_outline
                                        : dataOrderPickup.orderPickupStatus == 3
                                            ? Icons.local_shipping_outlined
                                            : dataOrderPickup
                                                        .orderPickupStatus ==
                                                    4
                                                ? Icons.check_circle
                                                : dataOrderPickup
                                                            .orderPickupStatus ==
                                                        5
                                                    ? Icons.inventory_2
                                                    : Icons.cancel_outlined,
                            color: dataOrderPickup.orderPickupStatus == 0
                                ? Colors.grey.shade700
                                : dataOrderPickup.orderPickupStatus == 1
                                    ? Colors.amber.shade700
                                    : dataOrderPickup.orderPickupStatus == 2
                                        ? Colors.green.shade700
                                        : dataOrderPickup.orderPickupStatus == 3
                                            ? Colors.green
                                            : dataOrderPickup
                                                        .orderPickupStatus ==
                                                    4
                                                ? Colors.blue.shade700
                                                : dataOrderPickup
                                                            .orderPickupStatus ==
                                                        5
                                                    ? Colors.blue.shade800
                                                    : Colors.red.shade700,
                            size: 32.sp,
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: dataOrderPickup.orderPickupStatus == 0
                                  ? Colors.grey.shade200
                                  : dataOrderPickup.orderPickupStatus == 1
                                      ? Colors.amber.shade100
                                      : dataOrderPickup.orderPickupStatus == 2
                                          ? Colors.green.shade100
                                          : dataOrderPickup.orderPickupStatus ==
                                                  3
                                              ? Colors.green.shade200
                                              : dataOrderPickup
                                                          .orderPickupStatus ==
                                                      4
                                                  ? Colors.blue.shade100
                                                  : dataOrderPickup
                                                              .orderPickupStatus ==
                                                          5
                                                      ? Colors.blue.shade200
                                                      : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              dataOrderPickup.orderPickupStatus == 0
                                  ? "Chờ duyệt"
                                  : dataOrderPickup.orderPickupStatus == 1
                                      ? "Chờ xác nhận"
                                      : dataOrderPickup.orderPickupStatus == 2
                                          ? "Đã xác nhận"
                                          : dataOrderPickup.orderPickupStatus ==
                                                  3
                                              ? "Đang lấy"
                                              : dataOrderPickup
                                                          .orderPickupStatus ==
                                                      4
                                                  ? "Đã lấy"
                                                  : dataOrderPickup
                                                              .orderPickupStatus ==
                                                          5
                                                      ? "Đã pickup"
                                                      : "Đã huỷ",
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: dataOrderPickup.orderPickupStatus == 0
                                    ? Colors.grey.shade800
                                    : dataOrderPickup.orderPickupStatus == 1
                                        ? Colors.amber.shade800
                                        : dataOrderPickup.orderPickupStatus == 2
                                            ? Colors.green.shade800
                                            : dataOrderPickup
                                                        .orderPickupStatus ==
                                                    3
                                                ? Colors.green.shade900
                                                : dataOrderPickup
                                                            .orderPickupStatus ==
                                                        4
                                                    ? Colors.blue.shade800
                                                    : dataOrderPickup
                                                                .orderPickupStatus ==
                                                            5
                                                        ? Colors.blue.shade900
                                                        : Colors.red.shade800,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Order details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order code and date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  dataOrderPickup.orderPickupCode,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                dataOrderPickup.orderPickupDateTime ?? '',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),

                          // Creator
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 16.sp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.8),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  "Created by: ${dataOrderPickup.user.userContactName}",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),

// Address
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16.sp,
                                color: Colors.orange.shade700,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  "${dataOrderPickup.orderPickupAddress}",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade800,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),

                          // Note
                          if (dataOrderPickup.orderPickupNote != null &&
                              dataOrderPickup.orderPickupNote!.isNotEmpty)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.notes,
                                  size: 16.sp,
                                  color: Colors.grey.shade700,
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    "Note: ${dataOrderPickup.orderPickupNote}",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade800,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _widgetAvatar() {
    return Padding(
      padding: EdgeInsets.only(right: 20),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfileShipper()),
          );
          // Sau khi quay về, fetch dữ liệu dựa trên tab cuối cùng được active
          BlocProvider.of<GetShipperListOrderScreenBloc>(context)
              .add(FetchListOrderPickupShipper(
            status: null,
            startDate: null,
            endDate: null,
            branchId: null,
            keywords: query,
            pickupShipStatus:
                _lastActiveTab == 0 ? 1 : (_lastActiveTab == 1 ? 2 : 0),
            shipperId: dataUser?.data.userId,
          ));
        },
        child: Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(width: 2, color: Colors.white),
              color: Colors.black),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.w),
            child: dataUser?.data.userLogo == null
                ? Image.asset(
                    'assets/images/user_avatar.png',
                    fit: BoxFit.contain,
                  )
                : Container(
                    width: 60.w,
                    height: 60.w,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.r),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: httpImage + dataUser!.data.userLogo!,
                        placeholder: (context, url) => SizedBox(
                          height: 20.w,
                          width: 20.w,
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
