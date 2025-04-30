import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/order_pickup/details_bottom_modal/details_order_pickup_bottom_modal_bloc.dart';
import 'package:scan_barcode_app/bloc/profile/get_infor/get_infor_bloc.dart';
import 'package:scan_barcode_app/bloc/shipper/details_order_pickup_shipper/details_order_pickup_shipper_bloc.dart';
import 'package:scan_barcode_app/bloc/shipper/shipper_finish/shipper_finish_bloc.dart';
import 'package:scan_barcode_app/bloc/shipper/shipper_list_order/shipper_list_order_screen_bloc.dart';
import 'package:scan_barcode_app/bloc/shipper/shipper_start/shipper_start_bloc.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/models/infor_account_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/data/models/order_pickup/details_order_pick_up.dart';
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
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class ShipperOrderScreen extends StatefulWidget {
  const ShipperOrderScreen({super.key});

  @override
  State<ShipperOrderScreen> createState() => _ShipperOrderScreenState();
}

class _ShipperOrderScreenState extends State<ShipperOrderScreen>
    with TickerProviderStateMixin {
  InforAccountModel? dataUser;
  DetailsOrderPickUpModel? detailsOrderPickUp;
  LatLng _initialPosition = LatLng(0, 0);
  late final TabController _tabController1;
  final scrollListBillControllerTab1 = ScrollController();
  final scrollListBillControllerTab2 = ScrollController();
  final scrollListBillControllerTab3 = ScrollController();
  final textSearchController = TextEditingController();
  final _dateStartController = TextEditingController();
  final _dateEndController = TextEditingController();
  final branchTextController = TextEditingController();
  final statusTextController = TextEditingController();
  DateTime? _startDate, _endDate;
  String? _endDateError;
  BranchResponse? branchResponse;
  int? branchID, pickupShipStatusID, shipperId, cuurentIDOrder;
  String query = '';
  int currentTab = 0;
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

  @override
  void initState() {
    super.initState();

    _tabController1 = TabController(length: 3, vsync: this);
    _tabController1.addListener(_handleTabChange);
    getCurrentPosition();
    init();

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
    });
    if (indexTab == 0) {
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

  @override
  void dispose() {
    _tabController1.removeListener(_handleTabChange);
    _tabController1.dispose();
    super.dispose();
    textSearchController.dispose();
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
        // actions: [_widgetAvatar()],
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
                                          BlocProvider.of<
                                                      GetShipperListOrderScreenBloc>(
                                                  context)
                                              .add(FetchListOrderPickupShipper(
                                                  status: null,
                                                  startDate: null,
                                                  endDate: null,
                                                  branchId: null,
                                                  keywords: query,
                                                  pickupShipStatus: 1,
                                                  shipperId:
                                                      dataUser?.data.userId));
                                        },
                                        child: SingleChildScrollView(
                                          controller:
                                              scrollListBillControllerTab1,
                                          physics:
                                              AlwaysScrollableScrollPhysics(),
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
                                                                          state.isEdit
                                                                              ? _buildSlidableItem(
                                                                                  dataOrderPickup: dataOrderPickup,
                                                                                  isEdit: true,
                                                                                  onInfoPressed: () {
                                                                                    showBottomDialogPickup(dataOrderPickup.orderPickupId);
                                                                                  },
                                                                                  onEditPressed: () {
                                                                                    _navigateToNextScreen();
                                                                                  },
                                                                                  onMapPressed: () {
                                                                                    getDetailsOrder(orderPickupID: dataOrderPickup.orderPickupId);
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
                                    errorText:
                                        'Failed to fetch orders: ${state.message}',
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
                                                                              child: state.isEdit
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
                                                                              child: state.isEdit
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
          if (currentTab == 0)
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
                                duration: Duration(
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
                              ? Icons.arrow_circle_right
                              : dataOrderPickup.orderPickupStatus == 3
                                  ? Icons.check_circle_rounded
                                  : dataOrderPickup.orderPickupStatus == 4
                                      ? Icons.get_app
                                      : Icons.cancel,
                  color: dataOrderPickup.orderPickupStatus == 0
                      ? Colors.grey
                      : dataOrderPickup.orderPickupStatus == 1
                          ? Color.fromARGB(255, 243, 219, 8)
                          : dataOrderPickup.orderPickupStatus == 2
                              ? Colors.green
                              : dataOrderPickup.orderPickupStatus == 3
                                  ? Colors.blue
                                  : dataOrderPickup.orderPickupStatus == 4
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
                              ? "Đang đi lấy"
                              : dataOrderPickup.orderPickupStatus == 3
                                  ? "Đã lấy"
                                  : dataOrderPickup.orderPickupStatus == 4
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
                      text: "Creater: ${dataOrderPickup.user.userContactName}",
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
  }) {
    return Slidable(
      key: ValueKey(dataOrderPickup),
      endActionPane: ActionPane(
        extentRatio: isEdit ? 0.9 : 0.3,
        dragDismissible: false,
        motion: const ScrollMotion(),
        children: [
          CustomSlidableAction(
            onPressed: (_) => onInfoPressed(),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                SizedBox(height: 4),
                Text(
                  'Thêm',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (isEdit) ...[
            CustomSlidableAction(
              onPressed: (_) => onEditPressed?.call(),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Sửa',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            CustomSlidableAction(
              onPressed: (_) => onMapPressed?.call(),
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    color: Colors.white,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Bản đồ',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      child: ListTile(
        title: SizedBox(
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
                                          : dataOrderPickup.orderPickupStatus ==
                                                  5
                                              ? Icons.get_app
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
                                          : dataOrderPickup.orderPickupStatus ==
                                                  5
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
                                      ? "Đang đi lấy"
                                      : dataOrderPickup.orderPickupStatus == 4
                                          ? "Đã lấy"
                                          : dataOrderPickup.orderPickupStatus ==
                                                  5
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
                              "Creater: ${dataOrderPickup.user.userContactName}",
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
                          text:
                              "Địa chỉ: ${dataOrderPickup.orderPickupAddress}",
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
                          maxLines: 3,
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
        ),
      ),
    );
  }

  Widget _widgetAvatar() {
    return Padding(
      padding: EdgeInsets.only(right: 20),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfileShipper()),
          );
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
