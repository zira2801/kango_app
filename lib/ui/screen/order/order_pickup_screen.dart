import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/order_pickup/delete_shipper_form_order/delete_shipper_form_order_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/details_bottom_modal/details_order_pickup_bottom_modal_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/get_shipper_list/get_shipper_list_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/screen/order_pickup_screen_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/update/update_order_pickup_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/update/update_order_pickup_event.dart';
import 'package:scan_barcode_app/bloc/order_pickup/update/update_order_pickup_state.dart';
import 'package:scan_barcode_app/bloc/shipper/take_order_pickup/take_order_pickup_bloc.dart';
import 'package:scan_barcode_app/data/models/order_pickup/details_order_pick_up.dart';
import 'package:scan_barcode_app/data/models/utils/list_branchs_model.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/order/create_new_order_pick_up.dart';
import 'package:scan_barcode_app/ui/screen/order/filter_order.dart';
import 'package:scan_barcode_app/ui/screen/order/infor_oder_pickup_modal.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/utils/date_time_picker.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class OrderPickUpScreen extends StatefulWidget {
  final int? fwdID;
  const OrderPickUpScreen({
    Key? key,
    this.fwdID,
  }) : super(key: key);

  @override
  State<OrderPickUpScreen> createState() => _OrderPickUpScreenState();
}

class _OrderPickUpScreenState extends State<OrderPickUpScreen> {
  DetailsOrderPickUpModel? detailsOrderPickUp;

  final scrollListBillController = ScrollController();
  final textSearchController = TextEditingController();
  final _dateStartController = TextEditingController();
  final _dateEndController = TextEditingController();
  final branchTextController = TextEditingController();
  final statusTextController = TextEditingController();
  final searchShipperTextController = TextEditingController();
  final scrollListShipperFreeController = ScrollController();

  // Tạo controller cho text field
  final cancelReasonController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _endDateError;
  final ImagePicker picker = ImagePicker();
  File? selectedImage;
  String? selectedImageString;
  BranchResponse? branchResponse;
  final navigatorKey = GlobalKey<NavigatorState>();
  // List<String> listNameBrach = [];

  int? branchID;
  String query = '';

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
    if ((_startDate != null && _endDate == null) ||
        (_startDate == null && _endDate != null)) {
      showCustomDialogModal(
        context: context,
        textDesc: "Vui lòng chọn cả ngày bắt đầu và ngày kết thúc.",
        title: "Thông báo",
        colorButtonOk: Colors.red,
        btnOKText: "Xác nhận",
        typeDialog: "error",
        eventButtonOKPress: () {},
        isTwoButton: false,
      );
      return; // Dừng hàm nếu không đủ điều kiện
    }
    setState(() {
      Navigator.pop(context);

      BlocProvider.of<GetListOrderPickupScreenBloc>(context).add(
          FetchListOrderPickup(
              fwdId: widget.fwdID,
              status: listStatus.indexOf(statusTextController.text) == -1
                  ? null
                  : listStatus.indexOf(statusTextController.text),
              startDate: _startDate?.toString(),
              endDate: _endDate?.toString(),
              branchId: branchID,
              keywords: query));
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

    BlocProvider.of<GetListOrderPickupScreenBloc>(context).add(
        FetchListOrderPickup(
            fwdId: widget.fwdID,
            status: null,
            startDate: null,
            endDate: null,
            branchId: null,
            keywords: query));
  }

  void showDialogDetailsOrderPickUp(
      BuildContext context, DetailsOrderPickUpModel? detailsOrderPickUp) {
    if (detailsOrderPickUp != null) {
      Future.microtask(() {
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
            );
          },
        );
      });
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

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
    scrollListBillController.addListener(_onScroll);
    getBranchKango();
    _fetchInitialData();
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

// Gọi trang khác và xử lý khi quay lại
  Future<void> navigateToCreateOrEditScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateNewOrderPickUpScreen(
          orderPickupID: null, // If creating new
          isShipper: false,
          isOpsLead: false,
          isSale: false,
        ),
      ),
    );

    // Check if data was modified and reload if necessary
    if (result == true) {
      _fetchInitialData();
    }
  }

  void _onScroll() {
    if (scrollListBillController.position.maxScrollExtent ==
        scrollListBillController.offset) {
      BlocProvider.of<GetListOrderPickupScreenBloc>(context).add(
          LoadMoreListOrderPickup(
              fwdId: widget.fwdID,
              status: listStatus.indexOf(statusTextController.text) == -1
                  ? null
                  : listStatus.indexOf(statusTextController.text),
              startDate: _startDate?.toString(),
              endDate: _endDate?.toString(),
              branchId: branchID,
              keywords: query));
    }
  }

  void _onScrollListShipper() {
    if (scrollListShipperFreeController.position.maxScrollExtent ==
        scrollListShipperFreeController.offset) {
      BlocProvider.of<GetListShipperFreeScreenBloc>(context)
          .add(LoadMoreListShipperFree(keywords: query));
    }
  }

  @override
  void dispose() {
    scrollListBillController.removeListener(_onScroll);
    scrollListBillController.dispose();
    textSearchController.dispose();
    _dateStartController.dispose();
    _dateEndController.dispose();
    searchShipperTextController.dispose();
    scrollListShipperFreeController.dispose();
    super.dispose();
  }

  void searchProduct(String query) {
    mounted
        ? setState(() {
            this.query = query;

            BlocProvider.of<GetListOrderPickupScreenBloc>(context).add(
                FetchListOrderPickup(
                    fwdId: widget.fwdID,
                    status: listStatus.indexOf(statusTextController.text) == -1
                        ? null
                        : listStatus.indexOf(statusTextController.text),
                    startDate: _startDate?.toString(),
                    endDate: _endDate?.toString(),
                    branchId: branchID,
                    keywords: query));
          })
        : null;
  }

  /// This builds cupertion date picker in iOS
  void buildCupertinoDateStartPicker(BuildContext context) {
    // Lưu lại giá trị ban đầu của controller
    String originalControllerText = _dateStartController.text;
    DateTime? originalStartDate = _startDate;

    showCupertinoDatePicker(
      context,
      initialDate: _startDate,
      onDateChanged: (picked) {
        setState(() {
          _startDate = picked;
        });
      },
      onCancel: () {
        // Khôi phục lại giá trị ban đầu
        setState(() {
          _startDate = originalStartDate;
          _dateStartController.text = originalControllerText;
        });
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
    DateTime? originalEndDate = _endDate; // Store the original date

    showCupertinoDatePicker(
      context,
      initialDate: _endDate,
      onDateChanged: (picked) {
        setState(() {
          _endDate = picked;
        });
      },
      onCancel: () {
        // Restore the original date and clear the text field
        setState(() {
          _endDate = originalEndDate;
          _dateEndController.clear();
        });
        Navigator.of(context).pop();
      },
      onConfirm: () {
        if ((_endDate ?? DateTime.now())
            .isBefore(_startDate ?? DateTime.now())) {
          showCustomDialogModal(
              context: context,
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
    // Lưu lại giá trị ban đầu của controller
    String originalControllerText = _dateStartController.text;
    DateTime? originalStartDate = _startDate;

    await showMaterialDatePicker(
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
      onCancel: () {
        // Nếu đã có giá trị ban đầu, khôi phục lại giá trị đó
        setState(() {
          _startDate = originalStartDate;
          _dateStartController.text = originalControllerText;
        });
      },
    );
  }

  Future<void> buildMaterialDateEndPicker(BuildContext context) async {
    // Lưu lại giá trị ban đầu của controller
    String originalControllerText = _dateEndController.text;
    DateTime? originalEndDate = _endDate;

    await showMaterialDatePicker(
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
      onCancel: () {
        // Nếu đã có giá trị ban đầu, khôi phục lại giá trị đó
        setState(() {
          _endDate = originalEndDate;
          _dateEndController.text = originalControllerText;
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

  void onDeleteOrderPickUp(int orderPickupID) {
    context.read<GetListOrderPickupScreenBloc>().add(
          HandleDeleteOrderPickUp(
              orderPickupID: orderPickupID,
              orderCancelDes: cancelReasonController.text),
        );
  }

  void onDeleteShipperFormOrderPickUp(int orderPickupID) {
    context.read<DeleteShipperFormBloc>().add(
          HandleDeleteShipperFormOrder(orderPickupID: orderPickupID),
        );
  }

  void onGetDetailsOrderPickup(int orderPickupID) {
    context.read<DetailsOrderPickupModalBottomBloc>().add(
          HanldeGetDetailsOrderPickupModalBottom(orderPickupID: orderPickupID),
        );
  }

  void onGetListShipperFree({required String? keywords}) {
    context.read<GetListShipperFreeScreenBloc>().add(
          FetchListShipperFree(keywords: keywords),
        );
  }

  void onChooseShipper({
    required int orderPickUpID,
    required int shipperID,
  }) {
    context.read<TakeOrderPickupBloc>().add(
          HanldeTakeOrderPickupShipper(
              shipperID: shipperID,
              orderPickUpID: orderPickUpID,
              shipperLongitude: null,
              shipperLatitude: null,
              locationAddress: null),
        );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    int? positionID = StorageUtils.instance.getInt(key: 'positionID');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: TextApp(
          text: "Order Pickup",
          fontsize: 20.sp,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      body: MultiBlocListener(
        listeners: [
          BlocListener<GetListOrderPickupScreenBloc,
              HandleGetListOrderPickupState>(
            listener: (context, state) {
              if (state is HandleDeleteOrderPickUpSuccess) {
                showCustomDialogModal(
                  context: navigatorKey.currentContext!,
                  textDesc: "Đã xóa order pickup này thành công.",
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
                BlocProvider.of<GetListOrderPickupScreenBloc>(context).add(
                    FetchListOrderPickup(
                        fwdId: widget.fwdID,
                        status: null,
                        startDate: null,
                        endDate: null,
                        branchId: null,
                        keywords: query));
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
          BlocListener<DetailsOrderPickupModalBottomBloc,
              DetailsOrderPickupModalBottomState>(
            listener: (context, state) {
              if (state is HanldeGetDetailsOrderPickupModalBottomSuccess) {
                // setState(() {
                //   detailsOrderPickUp = state.detailsOrderPickUpModel;
                // });
                showDialogDetailsOrderPickUp(
                    context, state.detailsOrderPickUpModel);
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
          BlocListener<TakeOrderPickupBloc, TakeOrderPickupState>(
            listener: (context, state) {
              if (state is TakeOrderPickupSuccess) {
                showCustomDialogModal(
                  context: context,
                  textDesc: "Giao đơn cho shipper thành công.",
                  title: "Thông báo",
                  colorButtonOk: Colors.green,
                  btnOKText: "Xác nhận",
                  typeDialog: "success",
                  eventButtonOKPress: () {},
                  isTwoButton: false,
                );
                BlocProvider.of<GetListOrderPickupScreenBloc>(context).add(
                    FetchListOrderPickup(
                        fwdId: widget.fwdID,
                        status: null,
                        startDate: null,
                        endDate: null,
                        branchId: null,
                        keywords: query));
              } else if (state is TakeOrderPickupFailure) {
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
          BlocListener<DeleteShipperFormBloc, DeleteShipperFormOrderState>(
            listener: (context, state) {
              if (!context.mounted) return;

              if (state is DeleteShipperFormOrderStateSuccess) {
                showCustomDialogModal(
                  context: context,
                  textDesc: state.message,
                  title: "Thông báo",
                  colorButtonOk: Colors.green,
                  btnOKText: "Xác nhận",
                  typeDialog: "success",
                  eventButtonOKPress: () {
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
                  },
                  isTwoButton: false,
                );
              } else if (state is DeleteShipperFormOrderStateFailure) {
                // ... your error handling code
              }
            },
          )
        ],
        child: BlocBuilder<GetListOrderPickupScreenBloc,
            HandleGetListOrderPickupState>(
          builder: (context, state) {
            if (state is HandleDeleteOrderPickUpLoading) {
              return Center(
                child: SizedBox(
                  width: 100.w,
                  height: 100.w,
                  child: Lottie.asset('assets/lottie/loading_kango.json'),
                ),
              );
            } else if (state is HandleGetListOrderPickupSuccess) {
              final String? position =
                  StorageUtils.instance.getString(key: 'user_position');
              return SlidableAutoCloseBehavior(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Slidable.of(context)?.close();
                  },
                  child: RefreshIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    onRefresh: () async {
                      _endDateError = null;
                      statusTextController.clear();
                      _dateStartController.clear();
                      _dateEndController.clear();
                      listStatus.clear();
                      _startDate = null;
                      _endDate = null;
                      branchID = null;

                      BlocProvider.of<GetListOrderPickupScreenBloc>(context)
                          .add(FetchListOrderPickup(
                              fwdId: widget.fwdID,
                              status: null,
                              startDate: null,
                              endDate: null,
                              branchId: null,
                              keywords: query));
                    },
                    child: Column(
                      children: [
                        Container(
                            width: 1.sw,
                            padding: EdgeInsets.all(10.w),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    onTapOutside: (event) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    onFieldSubmitted: (value) {
                                      searchProduct(textSearchController.text);
                                    },
                                    // onChanged: searchProduct,
                                    controller: textSearchController,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black),
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                        suffixIcon: InkWell(
                                          onTap: () {
                                            searchProduct(
                                                textSearchController.text);
                                          },
                                          child: const Icon(Icons.search),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        isDense: true,
                                        hintText: "Tìm kiếm...",
                                        contentPadding:
                                            const EdgeInsets.all(15)),
                                  ),
                                ),
                                SizedBox(
                                  width: 15.w,
                                ),
                                FileterOrderWidget(
                                    dateStartController: _dateStartController,
                                    dateEndController: _dateEndController,
                                    statusTextController: statusTextController,
                                    branchTextController: branchTextController,
                                    searchTypeTextController:
                                        textSearchController,
                                    brandIDParam: branchID,
                                    listStatus: listStatus,
                                    branchResponse: branchResponse,
                                    selectDayStart: selectDayStart,
                                    selectDayEnd: selectDayEnd,
                                    getEndDateError: () => _endDateError,
                                    clearFliterFunction: clearFilterFuntion,
                                    applyFliterFunction: applyFilterFuntion,
                                    onBrandIDChanged: _updateBrandID),
                              ],
                            )),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollListBillController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 10.h,
                                ),
                                state.isEdit
                                    ? SizedBox(
                                        width: 300.w,
                                        height: 50.w,
                                        child: ButtonApp(
                                            event: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const CreateNewOrderPickUpScreen(
                                                    orderPickupID: null,
                                                    isOpsLead: true,
                                                    isSale: true,
                                                    isShipper: false,
                                                  ),
                                                ),
                                              );
                                            },
                                            text: "Create New Order Pickup",
                                            colorText: Colors.white,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            outlineColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.bold,
                                            fontsize: 14.sp),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: 15.h,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    state.data.isEmpty
                                        ? const NoDataFoundWidget()
                                        : SizedBox(
                                            width: 1.sw,
                                            child: ListView.builder(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: state.hasReachedMax
                                                    ? state.data.length
                                                    : state.data.length + 1,
                                                itemBuilder: (context, index) {
                                                  if (index >=
                                                      state.data.length) {
                                                    return Center(
                                                      child: SizedBox(
                                                        width: 100.w,
                                                        height: 100.w,
                                                        child: Lottie.asset(
                                                            'assets/lottie/loading_kango.json'),
                                                      ),
                                                    );
                                                  } else {
                                                    final dataOrderPickup =
                                                        state.data[index];

                                                    final isEdit = state.isEdit;
                                                    return Column(
                                                      children: [
                                                        const Divider(
                                                          height: 1,
                                                        ),
                                                        Container(
                                                            width: 1.sw,
                                                            clipBehavior:
                                                                Clip.hardEdge,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0.r),
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            child:
                                                                (state.isEdit)
                                                                    ? Slidable(
                                                                        key: ValueKey(
                                                                            dataOrderPickup),
                                                                        endActionPane:
                                                                            ActionPane(
                                                                          extentRatio: (isEdit == true)
                                                                              ? 1
                                                                              : 0.3,
                                                                          dragDismissible:
                                                                              false,
                                                                          motion:
                                                                              const ScrollMotion(),
                                                                          dismissible:
                                                                              DismissiblePane(onDismissed: () {}),
                                                                          children: [
                                                                            ...[
                                                                              CustomSlidableAction(
                                                                                onPressed: (context) {
                                                                                  onGetDetailsOrderPickup(dataOrderPickup.orderPickupId);
                                                                                },
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
                                                                                      'Chi tiết',
                                                                                      style: TextStyle(color: Colors.white),
                                                                                      textAlign: TextAlign.center,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              (isEdit == true)
                                                                                  ? CustomSlidableAction(
                                                                                      onPressed: (context) async {
                                                                                        Navigator.push(
                                                                                          context,
                                                                                          MaterialPageRoute(
                                                                                            builder: (context) => CreateNewOrderPickUpScreen(
                                                                                              isShipper: false,
                                                                                              orderPickupID: dataOrderPickup.orderPickupId,
                                                                                              fwdID: widget.fwdID,
                                                                                            ),
                                                                                          ),
                                                                                        ).then((_) {
                                                                                          Future.microtask(() {
                                                                                            if (context.mounted) {
                                                                                              Navigator.pop(context, true);
                                                                                            }
                                                                                          });
                                                                                        });
                                                                                      },
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
                                                                                    )
                                                                                  : Container(),
                                                                              (dataOrderPickup.orderPickupStatus == 0 && widget.fwdID == null && position == 'ops_leader')
                                                                                  ? CustomSlidableAction(
                                                                                      onPressed: (context) async {
                                                                                        onGetListShipperFree(keywords: null);
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
                                                                                            return DraggableScrollableSheet(
                                                                                              maxChildSize: 0.8,
                                                                                              expand: false,
                                                                                              builder: (BuildContext context, ScrollController scrollController) {
                                                                                                return Container(
                                                                                                  color: Colors.white,
                                                                                                  child: Column(
                                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                                    children: [
                                                                                                      Container(
                                                                                                        width: 50.w,
                                                                                                        height: 5.w,
                                                                                                        margin: EdgeInsets.only(top: 15.h, bottom: 15.h),
                                                                                                        decoration: BoxDecoration(
                                                                                                          borderRadius: BorderRadius.circular(10.r),
                                                                                                          color: Colors.grey,
                                                                                                        ),
                                                                                                      ),
                                                                                                      Container(
                                                                                                        width: 1.sw,
                                                                                                        padding: EdgeInsets.all(15.w),
                                                                                                        child: TextFormField(
                                                                                                          onTapOutside: (event) {
                                                                                                            FocusManager.instance.primaryFocus?.unfocus();
                                                                                                          },
                                                                                                          // onChanged: searchProduct,
                                                                                                          controller: searchShipperTextController,
                                                                                                          style: const TextStyle(fontSize: 12, color: Colors.black),
                                                                                                          cursorColor: Colors.black,
                                                                                                          decoration: InputDecoration(
                                                                                                              suffixIcon: InkWell(
                                                                                                                onTap: () {
                                                                                                                  // onGetListFWD(
                                                                                                                  //     keywords: controllers['search']!.text);
                                                                                                                  onGetListShipperFree(keywords: searchShipperTextController.text);
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
                                                                                                      BlocBuilder<GetListShipperFreeScreenBloc, HandleGetListShipperFreeState>(builder: (context, state) {
                                                                                                        if (state is HandleGetListShipperFreeLoading) {
                                                                                                          return Center(
                                                                                                            child: SizedBox(
                                                                                                              width: 100.w,
                                                                                                              height: 100.w,
                                                                                                              child: Lottie.asset('assets/lottie/loading_kango.json'),
                                                                                                            ),
                                                                                                          );
                                                                                                        } else if (state is HandleGetListShipperFreeSuccess) {
                                                                                                          return Expanded(
                                                                                                            child: state.data.isEmpty
                                                                                                                ? const NoDataFoundWidget()
                                                                                                                : SizedBox(
                                                                                                                    width: 1.sw,
                                                                                                                    child: ListView.builder(
                                                                                                                        shrinkWrap: true,
                                                                                                                        // padding: EdgeInsets.only(top: 10.w),
                                                                                                                        controller: scrollListShipperFreeController,
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
                                                                                                                            final dataShipper = state.data[index];
                                                                                                                            return Column(
                                                                                                                              children: [
                                                                                                                                Padding(
                                                                                                                                  padding: EdgeInsets.only(left: 20.w),
                                                                                                                                  child: InkWell(
                                                                                                                                    onTap: () async {
                                                                                                                                      showCustomDialogModal(
                                                                                                                                          context: context,
                                                                                                                                          textDesc: "Bạn có chắc muốn chọn shipper ${state.data[index].userContactName} thực hiện đơn này ?",
                                                                                                                                          title: "Thông báo",
                                                                                                                                          colorButtonOk: Colors.blue,
                                                                                                                                          btnOKText: "Xác nhận",
                                                                                                                                          typeDialog: "question",
                                                                                                                                          eventButtonOKPress: () {
                                                                                                                                            Navigator.pop(context);
                                                                                                                                            onChooseShipper(orderPickUpID: dataOrderPickup.orderPickupId, shipperID: state.data[index].userId);
                                                                                                                                          },
                                                                                                                                          isTwoButton: true);
                                                                                                                                    },
                                                                                                                                    child: Row(
                                                                                                                                      children: [
                                                                                                                                        SizedBox(
                                                                                                                                          width: 1.sw - 80.w,
                                                                                                                                          child: TextApp(
                                                                                                                                            text: dataShipper.userContactName ?? '',
                                                                                                                                            color: Colors.black,
                                                                                                                                            fontsize: 16.sp,
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
                                                                                                                  ),
                                                                                                          );
                                                                                                        } else if (state is HandleGetListShipperFreeFailure) {
                                                                                                          return ErrorDialog(
                                                                                                            eventConfirm: () {
                                                                                                              Navigator.pop(context);
                                                                                                            },
                                                                                                            errorText: 'Lỗi khi lấy thông tin đơn hàng: ${state.message}',
                                                                                                          );
                                                                                                        }
                                                                                                        return const Center(child: NoDataFoundWidget());
                                                                                                      })
                                                                                                    ],
                                                                                                  ),
                                                                                                );
                                                                                              },
                                                                                            );
                                                                                          },
                                                                                        );
                                                                                      },
                                                                                      backgroundColor: Colors.purple,
                                                                                      foregroundColor: Colors.white,
                                                                                      child: const Column(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Icon(
                                                                                            Icons.delivery_dining,
                                                                                            color: Colors.white,
                                                                                          ),
                                                                                          SizedBox(height: 4),
                                                                                          Text(
                                                                                            'Giao',
                                                                                            style: TextStyle(color: Colors.white),
                                                                                            textAlign: TextAlign.center,
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    )
                                                                                  : Container(),
                                                                              ((dataOrderPickup.orderPickupStatus == 1) && widget.fwdID == null && positionID == 8)
                                                                                  ? CustomSlidableAction(
                                                                                      onPressed: (context) {
                                                                                        if (_scaffoldKey.currentContext != null) {
                                                                                          showDialog(
                                                                                            context: _scaffoldKey.currentContext!,
                                                                                            builder: (BuildContext dialogContext) {
                                                                                              return AlertDialog(
                                                                                                shape: RoundedRectangleBorder(
                                                                                                  borderRadius: BorderRadius.circular(15), // Bo tròn các góc
                                                                                                ),
                                                                                                title: TextApp(
                                                                                                  text: "Thông báo",

                                                                                                  fontsize: 20.sp, // Tăng kích thước font tiêu đề
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                  color: Theme.of(context).colorScheme.primary, // Thêm màu sắc cho tiêu đề
                                                                                                ),
                                                                                                content: TextApp(
                                                                                                  text: "Bạn có chắc muốn xoá shipper này?",

                                                                                                  fontsize: 16.sp, // Tăng kích thước font nội dung
                                                                                                  color: Colors.black87, // Màu chữ dễ đọc
                                                                                                ),
                                                                                                actions: [
                                                                                                  TextButton(
                                                                                                    onPressed: () {
                                                                                                      if (dialogContext.mounted) {
                                                                                                        Navigator.pop(dialogContext);
                                                                                                      }
                                                                                                      onDeleteShipperFormOrderPickUp(dataOrderPickup.orderPickupId);
                                                                                                    },
                                                                                                    child: TextApp(
                                                                                                      text: "Xác nhận",
                                                                                                      fontWeight: FontWeight.w600,
                                                                                                      color: Theme.of(context).colorScheme.primary, // Màu chữ nút
                                                                                                      fontsize: 18.sp, // Tăng kích thước chữ
                                                                                                    ),
                                                                                                  ),
                                                                                                  TextButton(
                                                                                                    onPressed: () {
                                                                                                      if (dialogContext.mounted) {
                                                                                                        Navigator.pop(dialogContext);
                                                                                                      }
                                                                                                    },
                                                                                                    child: TextApp(
                                                                                                      text: "Huỷ",

                                                                                                      color: Colors.red, // Màu chữ nút
                                                                                                      fontWeight: FontWeight.w600,
                                                                                                      fontsize: 18.sp, // Tăng kích thước chữ
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                                backgroundColor: Colors.white, // Màu nền hộp thoại
                                                                                                elevation: 10, // Thêm bóng đổ
                                                                                              );
                                                                                            },
                                                                                          );
                                                                                        }
                                                                                      },
                                                                                      backgroundColor: Colors.red,
                                                                                      foregroundColor: Colors.white,
                                                                                      child: const Column(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Icon(
                                                                                            Icons.delivery_dining,
                                                                                            color: Colors.white,
                                                                                          ),
                                                                                          SizedBox(height: 4),
                                                                                          Text(
                                                                                            'Xóa\nshipper',
                                                                                            style: TextStyle(color: Colors.white),
                                                                                            textAlign: TextAlign.center,
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    )
                                                                                  : Container(),
                                                                              ((dataOrderPickup.orderPickupStatus == 2 || dataOrderPickup.orderPickupStatus == 3 || dataOrderPickup.orderPickupStatus == 4) && widget.fwdID == null && positionID == 9)
                                                                                  ? CustomSlidableAction(
                                                                                      onPressed: (context) {
                                                                                        showDialog(
                                                                                            context: context,
                                                                                            builder: (context) => AlertDialog(
                                                                                                  title: Text('Hủy đơn', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                                                                                  content: Column(
                                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                    children: [
                                                                                                      TextApp(
                                                                                                        text: "Nguyên nhân hủy",
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
                                                                                                      onPressed: () async {
                                                                                                        if (cancelReasonController.text.trim().isEmpty) {
                                                                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                                                                            const SnackBar(content: Text('Vui lòng nhập lý do hủy đơn')),
                                                                                                          );
                                                                                                          return;
                                                                                                        }

                                                                                                        // Đóng dialog
                                                                                                        Navigator.pop(context);

                                                                                                        onDeleteOrderPickUp(dataOrderPickup.orderPickupId);
                                                                                                        setState(() {
                                                                                                          cancelReasonController.dispose;
                                                                                                        });
                                                                                                        // _fetchInitialData();
                                                                                                      },
                                                                                                      child: Text(
                                                                                                        'Xác nhận',
                                                                                                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ));
                                                                                      },
                                                                                      backgroundColor: Colors.red,
                                                                                      foregroundColor: Colors.white,
                                                                                      child: const Column(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Icon(
                                                                                            Icons.delete,
                                                                                            color: Colors.white,
                                                                                          ),
                                                                                          SizedBox(height: 4),
                                                                                          Text(
                                                                                            'Hủy\nđơn',
                                                                                            style: TextStyle(color: Colors.white),
                                                                                            textAlign: TextAlign.center,
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    )
                                                                                  : Container(),
                                                                            ]
                                                                          ],
                                                                        ),
                                                                        child:
                                                                            Card(
                                                                          color:
                                                                              Colors.white,
                                                                          elevation:
                                                                              2,
                                                                          margin: EdgeInsets.symmetric(
                                                                              horizontal: 16.w,
                                                                              vertical: 8.h),
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(12.r),
                                                                            side:
                                                                                BorderSide(
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
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                EdgeInsets.all(12.w),
                                                                            child:
                                                                                Row(
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
                                                                                                        : dataOrderPickup.orderPickupStatus == 5
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
                                                                                                        : dataOrderPickup.orderPickupStatus == 4
                                                                                                            ? Icons.check_circle
                                                                                                            : dataOrderPickup.orderPickupStatus == 5
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
                                                                                                        : dataOrderPickup.orderPickupStatus == 4
                                                                                                            ? Colors.blue.shade700
                                                                                                            : dataOrderPickup.orderPickupStatus == 5
                                                                                                                ? Colors.blue.shade800
                                                                                                                : Colors.red.shade700,
                                                                                        size: 32.sp,
                                                                                      ),
                                                                                      SizedBox(height: 8.h),
                                                                                      Container(
                                                                                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                                                                                        decoration: BoxDecoration(
                                                                                          color: dataOrderPickup.orderPickupStatus == 0
                                                                                              ? Colors.grey.shade200
                                                                                              : dataOrderPickup.orderPickupStatus == 1
                                                                                                  ? Colors.amber.shade100
                                                                                                  : dataOrderPickup.orderPickupStatus == 2
                                                                                                      ? Colors.green.shade100
                                                                                                      : dataOrderPickup.orderPickupStatus == 3
                                                                                                          ? Colors.green.shade200
                                                                                                          : dataOrderPickup.orderPickupStatus == 4
                                                                                                              ? Colors.blue.shade100
                                                                                                              : dataOrderPickup.orderPickupStatus == 5
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
                                                                                                      : dataOrderPickup.orderPickupStatus == 3
                                                                                                          ? "Đang lấy"
                                                                                                          : dataOrderPickup.orderPickupStatus == 4
                                                                                                              ? "Đã lấy"
                                                                                                              : dataOrderPickup.orderPickupStatus == 5
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
                                                                                                        : dataOrderPickup.orderPickupStatus == 3
                                                                                                            ? Colors.green.shade900
                                                                                                            : dataOrderPickup.orderPickupStatus == 4
                                                                                                                ? Colors.blue.shade800
                                                                                                                : dataOrderPickup.orderPickupStatus == 5
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
                                                                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
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
                                                                                              dataOrderPickup.orderPickupAddress,
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
                                                                                      if (dataOrderPickup.orderPickupNote != null && dataOrderPickup.orderPickupNote!.isNotEmpty)
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
                                                                                // Drag handle indicator
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Slidable(
                                                                        key: ValueKey(
                                                                            dataOrderPickup),
                                                                        endActionPane:
                                                                            ActionPane(
                                                                          extentRatio: (isEdit == true)
                                                                              ? 1
                                                                              : 0.3,
                                                                          dragDismissible:
                                                                              false,
                                                                          motion:
                                                                              const ScrollMotion(),
                                                                          dismissible:
                                                                              DismissiblePane(onDismissed: () {}),
                                                                          children: [
                                                                            ...[
                                                                              CustomSlidableAction(
                                                                                onPressed: (context) {
                                                                                  onGetDetailsOrderPickup(dataOrderPickup.orderPickupId);
                                                                                },
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
                                                                                      'Chi tiết',
                                                                                      style: TextStyle(color: Colors.white),
                                                                                      textAlign: TextAlign.center,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ]
                                                                          ],
                                                                        ),
                                                                        child:
                                                                            Card(
                                                                          color:
                                                                              Colors.white,
                                                                          elevation:
                                                                              2,
                                                                          margin: EdgeInsets.symmetric(
                                                                              horizontal: 16.w,
                                                                              vertical: 8.h),
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(12.r),
                                                                            side:
                                                                                BorderSide(
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
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                EdgeInsets.all(12.w),
                                                                            child:
                                                                                Row(
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
                                                                                                        : dataOrderPickup.orderPickupStatus == 5
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
                                                                                                        : dataOrderPickup.orderPickupStatus == 4
                                                                                                            ? Icons.check_circle
                                                                                                            : dataOrderPickup.orderPickupStatus == 5
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
                                                                                                        : dataOrderPickup.orderPickupStatus == 4
                                                                                                            ? Colors.blue.shade700
                                                                                                            : dataOrderPickup.orderPickupStatus == 5
                                                                                                                ? Colors.blue.shade800
                                                                                                                : Colors.red.shade700,
                                                                                        size: 32.sp,
                                                                                      ),
                                                                                      SizedBox(height: 8.h),
                                                                                      Container(
                                                                                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                                                                                        decoration: BoxDecoration(
                                                                                          color: dataOrderPickup.orderPickupStatus == 0
                                                                                              ? Colors.grey.shade200
                                                                                              : dataOrderPickup.orderPickupStatus == 1
                                                                                                  ? Colors.amber.shade100
                                                                                                  : dataOrderPickup.orderPickupStatus == 2
                                                                                                      ? Colors.green.shade100
                                                                                                      : dataOrderPickup.orderPickupStatus == 3
                                                                                                          ? Colors.green.shade200
                                                                                                          : dataOrderPickup.orderPickupStatus == 4
                                                                                                              ? Colors.blue.shade100
                                                                                                              : dataOrderPickup.orderPickupStatus == 5
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
                                                                                                      : dataOrderPickup.orderPickupStatus == 3
                                                                                                          ? "Đang lấy"
                                                                                                          : dataOrderPickup.orderPickupStatus == 4
                                                                                                              ? "Đã lấy"
                                                                                                              : dataOrderPickup.orderPickupStatus == 5
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
                                                                                                        : dataOrderPickup.orderPickupStatus == 3
                                                                                                            ? Colors.green.shade900
                                                                                                            : dataOrderPickup.orderPickupStatus == 4
                                                                                                                ? Colors.blue.shade800
                                                                                                                : dataOrderPickup.orderPickupStatus == 5
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
                                                                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
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
                                                                                              dataOrderPickup.orderPickupAddress,
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
                                                                                      if (dataOrderPickup.orderPickupNote != null && dataOrderPickup.orderPickupNote!.isNotEmpty)
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
                                                                                // Drag handle indicator
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )),
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
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is HandleGetListOrderPickupFailure) {
              return ErrorDialog(
                eventConfirm: () {
                  Navigator.pop(context);
                },
                errorText: 'Failed to fetch orders: ${state.message}',
              );
            }
            return const Center(child: NoDataFoundWidget());
          },
        ),
      ),
    );
  }
}
