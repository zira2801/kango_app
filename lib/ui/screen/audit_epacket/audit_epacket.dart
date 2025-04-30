import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/audit_epacket/audit_epacket_bloc.dart';
import 'package:scan_barcode_app/bloc/shipment/details_tracking_shipment/details_tracking_shipment_bloc.dart';
import 'package:scan_barcode_app/bloc/shipment/list_shipment_bloc.dart';
import 'package:scan_barcode_app/data/models/audit_epacket/audit_epacket_service.dart';
import 'package:scan_barcode_app/data/models/shipment/all_unit_shipment.dart';
import 'package:scan_barcode_app/data/models/shipment/delivery_service.dart';
import 'package:scan_barcode_app/data/models/shipment/details_shipment.dart';
import 'package:scan_barcode_app/data/models/utils/list_branchs_model.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/shipment/create_new_shipment.dart';
import 'package:scan_barcode_app/ui/screen/shipment/filter_shipment.dart';
import 'package:scan_barcode_app/ui/screen/shipment/package_info_tab1_widget.dart';
import 'package:scan_barcode_app/ui/screen/shipment/package_info_tab2_widget.dart';
import 'package:scan_barcode_app/ui/screen/shipment/details_shipment_screen/tracking_shipment.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/utils/date_time_picker.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'dart:math' as math;

enum MethodPayCharater { bank, cash }

class AuditEpacketScreen extends StatefulWidget {
  final String? userPosition;
  final bool? canUploadLabel;
  final bool? canUploadPayment;
  const AuditEpacketScreen({
    super.key,
    this.userPosition,
    this.canUploadLabel,
    this.canUploadPayment,
  });

  @override
  State<AuditEpacketScreen> createState() => _AuditEpacketScreenState();
}

class _AuditEpacketScreenState extends State<AuditEpacketScreen>
    with SingleTickerProviderStateMixin {
  List<ExpansionTileController> expansionTileControllers = [];
  final scrollListBillController = ScrollController();
  final textSearchController = TextEditingController();
  final statusTextController = TextEditingController();
  final branchTextController = TextEditingController();
  final searchTypeTextController = TextEditingController();
  final statusPaymentTextController = TextEditingController();
  final serviceTextController = TextEditingController();
  final noteController = TextEditingController();
  final TextEditingController _dateStartController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();
  String query = '';
  bool isLoadingButton = false;
  List<IconData> iconStatus = [
    Icons.all_inbox,
    Icons.add,
    Icons.create,
    Icons.outbond,
    Icons.refresh
  ];

  DetailsShipmentModel? detailsShipment;
  DeliveryServiceModel? deliveryServiceMode;
  AllUnitShipmentModel? allUnitShipmentModel;
  AuditEpacketService? servicesAuditEpacket;

  List<String> listStatus = [
    "Create Bill",
    "Imported",
    "Exported",
    "Returned",
    "Hold"
  ];
  List<String> listSearchMethod = [
    "Mã shipment",
    "Mã referance",
    "Tên người nhận",
    "Tên công ty người gửi", // Fixed the duplicate
    "Địa chỉ người nhận",
    "Mã kiện hàng",
    "Mã vận đơn"
  ];
  List<String> listKeyType = [
    "shipment_code",
    "shipment_reference_code",
    "receiver_contact_name",
    "sender_company_name",
    "receiver_address_1",
    "package_code",
    "package_tracking_code"
  ];
  String searchMethod = 'Mã shipment';
  String currentSearchMethod = "shipment_code";
  DateTime? _startDate; //type ngày bắt đầu
  DateTime? _endDate; //type ngày kết thúc
  String? _endDateError; //text lỗi khi ngày kết thúc nhỏ hơn ngày bắt đầu
  int? branchID;
  int? serviceID;
  BranchResponse? branchResponse;
  File? selectedImage;
  bool hasMore = false;
  final ImagePicker picker = ImagePicker();
  MethodPayCharater? _methodPay = MethodPayCharater.bank;
  String? selectedFile;
  late TabController _tabController;
  // late SlidableController _slidableController;
  void editShipment({
    required String shipmentCode,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              CreateShipmentScreen(shipmentCode: shipmentCode)),
    );
  }

  void handleDeleteShipment({required String? shipmentCode}) {
    context
        .read<DeleteShipmentBloc>()
        .add(HanldeDeleteShipment(shipmentCode: shipmentCode));
  }

  void getDetailsShipment(
      {required String? shipmentCode, required bool isMoreDetail}) {
    context.read<DetailsAuditEpacketBloc>().add(
          HanldeDetailsAuditEpacket(
              shipmentCode: shipmentCode, isMoreDetail: isMoreDetail),
        );
  }

  String formatCurrency(num amount) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '');
    return format.format(amount);
  }

  void showDialogDetailsShipment({required String shipmentCode}) {
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
            initialChildSize: 0.8,
            expand: false,
            builder: (BuildContext context,
                ScrollController scrollControllerMoreInfor) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          tabs: [
                            Tab(
                              child: TextApp(
                                text: 'Thông tin lô hàng',
                                fontsize: 16.sp,
                                color: Colors.black,
                              ),
                            ),
                            Tab(
                              child: TextApp(
                                text: 'Thông tin kiện hàng',
                                fontsize: 16.sp,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              PackageInfoWidgetTab1(
                                shipmentCode: shipmentCode,
                                scrollController: scrollControllerMoreInfor,
                                detailsShipment: detailsShipment,
                                selectedPDFLabelString: selectedFile,
                                selectedImage: selectedImage,
                                methodPay: null,
                                userPosition: widget.userPosition,
                                canUploadLabel: widget.canUploadLabel,
                                canUploadPayment: widget.canUploadPayment,
                              ),
                              PackageInfoWidgetTab2(
                                scrollController: scrollControllerMoreInfor,
                                detailsShipment: detailsShipment,
                                allUnitShipmentModel: allUnitShipmentModel,
                              )
                            ],
                          ),
                        ),
                      ],
                    ));
              });
            },
          );
        });
  }

  Future<void> getAllUnitShipment() async {
    final response = await http.post(
      Uri.parse('$baseUrl$typeAndUnitShpment'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
    );
    final data = jsonDecode(response.body);
    try {
      if (data['status'] == 200) {
        log("getAllUnitShipment OK");
        mounted
            ? setState(() {
                allUnitShipmentModel = AllUnitShipmentModel.fromJson(data);
              })
            : null;
      } else {
        log("getAllUnitShipment error 1");
      }
    } catch (error) {
      log("getAllUnitShipment error $error 2");
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

//Lấy danh sách dịch vụ
  Future<void> getAllServiceAuditEpacket() async {
    final response = await http.get(
      Uri.parse('$baseUrl$getListServiceAuditEpacket'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
    );
    final data = jsonDecode(response.body);
    try {
      if (data['status'] == 200) {
        log("getAllServiceAuditEpacket OK");
        mounted
            ? setState(() {
                servicesAuditEpacket = AuditEpacketService.fromJson(data);
              })
            : null;
      } else {
        log("getAllServiceAuditEpacket error 1");
      }
    } catch (error) {
      log("getAllServiceAuditEpacket error $error 2");
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

  Future<void> getBranchKango() async {
    String? branchResponseJson =
        StorageUtils.instance.getString(key: 'branch_response');
    if (branchResponseJson != null) {
      branchResponse = BranchResponse.fromJson(jsonDecode(branchResponseJson));
      log("GET BRANCH OK LIST");
    }
  }

  void init() async {
    BlocProvider.of<GetListAuditEpacketBloc>(context).add(FetchListAuditEpacket(
        shipmentStatus: null,
        shipmentServiceId: null,
        startDate: null,
        endDate: null,
        shipmentBranchId: null,
        keywords: query,
        filterBy: currentSearchMethod));
    await getBranchKango();
    await getAllUnitShipment();
    await getAllServiceAuditEpacket();
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // _slidableController = SlidableController(vsync: this);
    init();
    for (int i = 0; i < 5; i++) {
      expansionTileControllers.add(ExpansionTileController());
    }
    scrollListBillController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollListBillController.position.maxScrollExtent ==
        scrollListBillController.offset) {
      BlocProvider.of<GetListAuditEpacketBloc>(context).add(
          LoadMoreListAuditEpacket(
              shipmentStatus:
                  listStatus.indexOf(statusTextController.text) == -1
                      ? null
                      : listStatus.indexOf(statusTextController.text),
              startDate: _startDate?.toString(),
              endDate: _endDate?.toString(),
              shipmentBranchId: branchID,
              shipmentServiceId: serviceID,
              keywords: query,
              filterBy: currentSearchMethod));
    }
  }

  @override
  void dispose() {
    super.dispose();
    textSearchController.clear();
    _dateStartController.clear();
    _dateEndController.clear();
    statusTextController.clear();
    searchTypeTextController.clear();
    serviceTextController.clear;
    noteController.clear();
  }

  void searchProduct(String query) {
    mounted
        ? setState(() {
            this.query = query;

            BlocProvider.of<GetListAuditEpacketBloc>(context).add(
                FetchListAuditEpacket(
                    shipmentStatus:
                        listStatus.indexOf(statusTextController.text) == -1
                            ? null
                            : listStatus.indexOf(statusTextController.text),
                    startDate: _startDate?.toString(),
                    endDate: _endDate?.toString(),
                    shipmentBranchId: branchID,
                    shipmentServiceId: serviceID,
                    keywords: query,
                    filterBy: currentSearchMethod));
          })
        : null;
  }

  String formatStartDateForAPI(DateTime? date) {
    if (date == null) return '';
    // Format as DD-MM-YYYY with beginning of day
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String formatEndDateForAPI(DateTime? date) {
    if (date == null) return '';
    // Format as DD-MM-YYYY with end of day (same format but conceptually representing end of day)
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Future<void> applyFilterFuntion() async {
    // Kiểm tra nếu một trong hai ngày bị thiếu
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

    final String formattedStartDate = formatStartDateForAPI(_startDate);
    final String formattedEndDate = formatEndDateForAPI(_endDate);

    log('Start date formatted: $formattedStartDate');
    log('End date formatted: $formattedEndDate');

    Navigator.pop(context);

    BlocProvider.of<GetListAuditEpacketBloc>(context).add(FetchListAuditEpacket(
      shipmentStatus: listStatus.indexOf(statusTextController.text) == -1
          ? null
          : listStatus.indexOf(statusTextController.text),
      startDate: formattedStartDate.isNotEmpty ? formattedStartDate : null,
      endDate: formattedEndDate.isNotEmpty ? formattedEndDate : null,
      shipmentBranchId: branchID,
      keywords: query,
      shipmentServiceId: serviceID,
      filterBy: currentSearchMethod,
    ));
  }

  Future<void> clearFilterFuntion() async {
    setState(() {
      _endDateError = null;
      statusTextController.clear();
      searchTypeTextController.clear();
      serviceTextController.clear();
      _dateStartController.clear();
      _dateEndController.clear();
      _startDate = null;
      _endDate = null;
      branchID = null;
    });
    Navigator.pop(context);
    BlocProvider.of<GetListAuditEpacketBloc>(context).add(FetchListAuditEpacket(
        shipmentStatus: null,
        startDate: null,
        endDate: null,
        shipmentBranchId: null,
        shipmentServiceId: null,
        keywords: query,
        filterBy: currentSearchMethod));
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
      // return buildMaterialDateStartPicker(context);
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
      // return buildMaterialDateEndPicker(context);
    }
  }

  void _updateBrandID(int newBrandID) {
    setState(() {
      branchID = newBrandID;
    });
  }

  void _updateServiceID(int newServiceID) {
    setState(() {
      serviceID = newServiceID;
    });
  }

  void _updateSearchTypeChanged(String newTypeSearch) {
    setState(() {
      currentSearchMethod = newTypeSearch;
    });
  }

  void _updateSearchStringChanged(String newStringSearch) {
    setState(() {
      searchMethod = newStringSearch;
    });
  }

  String _getStatusName(int statusID) {
    const statusMap = {
      0: 'Chưa duyệt',
      1: 'Đã duyệt',
    };
    return statusMap[statusID] ?? 'Unknown';
  }

  Color _getStatusColor(int statusID) {
    const statusMap = {
      0: Colors.grey,
      1: Color.fromRGBO(0, 214, 127, 1),
    };
    return statusMap[statusID] ?? Colors.grey;
  }

  void showDialogMoreDetailAuditEpacket({
    required DetailsShipmentModel shipmentdetail,
  }) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          maxChildSize: 0.9,
          initialChildSize: 0.65,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),

                  // Header
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    child: Text(
                      'Chi tiết',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoCard(
                            title: 'HAWB Kango',
                            value: shipmentdetail
                                .shipment.packages.first.packageHawbCode
                                .toString(),
                            icon: Icons.local_shipping_rounded,
                          ),
                          _buildInfoCard(
                            title: 'Người tạo',
                            value: shipmentdetail.shipment.user.userContactName,
                            icon: Icons.person_rounded,
                          ),
                          _buildInfoCard(
                            title: 'Nhân viên xử lý',
                            value: shipmentdetail.shipment.packages.first
                                    .processingStaffId ??
                                '-',
                            icon: Icons.person_rounded,
                          ),
                          _buildStatusCard(
                            status: shipmentdetail
                                .shipment.packages.first.packageApprove,
                          ),
                          SizedBox(height: 16.h),
                          _buildSectionTitle('Kích thước ban đầu'),
                          _buildDimensionCard(
                            length: shipmentdetail
                                .shipment.packages.first.packageLength
                                .toString(),
                            width: shipmentdetail
                                .shipment.packages.first.packageWidth
                                .toString(),
                            height: shipmentdetail
                                .shipment.packages.first.packageHeight
                                .toString(),
                          ),
                          _buildWeightCard(
                            grossWeight: shipmentdetail
                                .shipment.packages.first.packageWeight
                                .toString(),
                            chargeableWeight: shipmentdetail
                                .shipment.packages.first.packageChargedWeight
                                .toString(),
                          ),
                          SizedBox(height: 16.h),
                          _buildSectionTitle('Kích thước thực tế'),
                          _buildDimensionCard(
                            length: shipmentdetail
                                    .shipment.packages.first.packageLengthActual
                                    ?.toString() ??
                                '0',
                            width: shipmentdetail
                                    .shipment.packages.first.packageWidthActual
                                    ?.toString() ??
                                '0',
                            height: shipmentdetail
                                    .shipment.packages.first.packageHeightActual
                                    ?.toString() ??
                                '0',
                          ),
                          _buildWeightCard(
                            grossWeight: shipmentdetail
                                    .shipment.packages.first.packageWeightActual
                                    ?.toString() ??
                                '0',
                            chargeableWeight: shipmentdetail.shipment.packages
                                    .first.packageChargedWeightActual
                                    ?.toString() ??
                                '0',
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

// Helper Widgets
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: TextApp(
        text: title,
        fontsize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700] ?? Colors.grey,
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title, required String value, required IconData icon}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon,
                size: 20.sp, color: Theme.of(context).colorScheme.primary),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextApp(
                text: title,
                fontsize: 15.sp,
                color: Colors.grey[600] ?? Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 4.h),
              TextApp(
                text: value,
                fontsize: 16.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionCard({
    required String length,
    required String width,
    required String height,
  }) {
    return Container(
      padding: EdgeInsets.all(12.r),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDimensionItem('L', length, Colors.blue[400]!),
          _buildDimensionItem('H', width, Colors.green[400]!),
          _buildDimensionItem('R', height, Colors.orange[400]!),
        ],
      ),
    );
  }

  Widget _buildDimensionItem(String label, String value, Color color) {
    return Column(
      children: [
        TextApp(
          text: label,
          fontsize: 14.sp,
          color: Colors.grey[600] ?? Colors.grey,
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Container(
              width: 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4.w),
            TextApp(
              text: value,
              fontsize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeightCard({
    required String grossWeight,
    required String chargeableWeight,
  }) {
    return Container(
      padding: EdgeInsets.all(12.r),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextApp(
                text: 'GW Created',
                fontsize: 14.sp,
                color: Colors.grey[600] ?? Colors.grey,
              ),
              SizedBox(height: 4.h),
              TextApp(
                text: grossWeight,
                fontsize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextApp(
                text: 'CW Created',
                fontsize: 14.sp,
                color: Colors.grey[600] ?? Colors.grey,
              ),
              SizedBox(height: 4.h),
              TextApp(
                text: chargeableWeight,
                fontsize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaffProcess({required int status}) {
    return Container(
      padding: EdgeInsets.all(12.r),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              _getStatusIcon(status),
              size: 20.sp,
              color: _getStatusColor(status),
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextApp(
                text: 'Nhân viên xử lý',
                fontsize: 14.sp,
                color: Colors.grey[600] ?? Colors.grey,
              ),
              SizedBox(height: 4.h),
              TextApp(
                text: _getStatusName(status),
                fontsize: 15.sp,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(status),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({required int status}) {
    return Container(
      padding: EdgeInsets.all(12.r),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              _getStatusIcon(status),
              size: 20.sp,
              color: _getStatusColor(status),
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextApp(
                text: 'Trạng thái',
                fontsize: 14.sp,
                color: Colors.grey[600] ?? Colors.grey,
              ),
              SizedBox(height: 4.h),
              TextApp(
                text: _getStatusName(status),
                fontsize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showDialogNoteAuditEpacket(String shipmentCode) {
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
            initialChildSize: 0.7,
            minChildSize: 0.5,
            expand: false,
            builder: (BuildContext context,
                ScrollController scrollControllerMoreInfor) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setStateModel) {
                return Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 50.w,
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0)),
                              color: Theme.of(context).colorScheme.primary),
                          child: Align(
                            alignment: Alignment.center,
                            child: TextApp(
                              text: 'Chỉnh sửa Note',
                              fontsize: 18.w,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15.w,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: SizedBox(
                              width: 1.sw,
                              child: CustomTextFormField(
                                readonly: false,
                                controller: noteController,
                                hintText: '',
                              )),
                        ),
                        SizedBox(height: 30.h),

                        // Submit button
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isLoadingButton == true
                                      ? null
                                      : () async {
                                          setStateModel(() {
                                            isLoadingButton = true;
                                          });
                                          await _submitNoteAuditEpacket(
                                              shipmentCode);
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 12.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  child: isLoadingButton == true
                                      ? SizedBox(
                                          height: 20.h,
                                          width: 20.w,
                                          child:
                                              const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : TextApp(
                                          text: 'Cập nhật',
                                          fontsize: 16.w,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ));
              });
            },
          );
        });
  }

  Future<void> _submitNoteAuditEpacket(String shipmentCode) async {
    setState(() {
      isLoadingButton = true;
    });

    BlocProvider.of<UpdateAuditEpacketBloc>(context).add(
      HandleUpdateAuditEpacket(
          shipmentCode: shipmentCode, shipmentNote: noteController.text),
    );
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icons.circle_notifications;
      case 1:
        return Icons.check_circle_rounded;
      case 2:
        return Icons.outbound_rounded;
      default:
        return Icons.history;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool? isShipper = StorageUtils.instance.getBool(key: 'is_shipper');
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
            text: "Audit E-Packet",
            fontsize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: MultiBlocListener(
            listeners: [
              BlocListener<DetailsAuditEpacketBloc, DetailsAuditEpacketState>(
                listener: (context, state) {
                  if (state is DetailsAuditEpacketStateSuccess) {
                    detailsShipment = state.detailsShipmentModel;
                    noteController.text =
                        state.detailsShipmentModel.shipment.shipmentNote;
                    Navigator.pop(context);
                    if (state.isMoreDetail) {
                      showDialogMoreDetailAuditEpacket(
                          shipmentdetail: detailsShipment!);
                    } else {
                      showDialogDetailsShipment(
                          shipmentCode:
                              state.detailsShipmentModel.shipment.shipmentCode);
                    }
                  }
                },
              ),
              BlocListener<UpdateAuditEpacketBloc, UpdateNoteAuditEpacketState>(
                listener: (context, state) async {
                  if (state is UpdateNoteAuditEpacketStateSuccess) {
                    if (mounted) {
                      setState(() {
                        isLoadingButton = false;
                      });
                    }
                    showCustomDialogModal(
                      context: context,
                      textDesc: state.message,
                      title: "Thông báo",
                      colorButtonOk: Colors.green,
                      btnOKText: "Xác nhận",
                      typeDialog: "success",
                      eventButtonOKPress: () {
                        BlocProvider.of<GetListAuditEpacketBloc>(context).add(
                            FetchListAuditEpacket(
                                shipmentStatus: null,
                                shipmentServiceId: null,
                                startDate: null,
                                endDate: null,
                                shipmentBranchId: null,
                                keywords: query,
                                filterBy: currentSearchMethod));
                        Navigator.pop(context); // Close dialog
                      },
                      isTwoButton: false,
                    );
                  } else if (state is UpdateNoteAuditEpacketStateFailure) {
                    if (mounted) {
                      setState(() {
                        isLoadingButton = false;
                      });
                    }
                    showCustomDialogModal(
                      context: context,
                      textDesc: state.message ?? "Đã có lỗi xảy ra",
                      title: "Thông báo",
                      colorButtonOk: Colors.red,
                      btnOKText: "Xác nhận",
                      typeDialog: "error",
                      eventButtonOKPress: () {},
                      isTwoButton: false,
                    );
                  }
                },
              ),
            ],
            child: BlocBuilder<GetListAuditEpacketBloc,
                HandleGetAuditEpacketState>(
              builder: (context, state) {
                if (state is HandleGetAuditEpacketStateloading) {
                  return Center(
                    child: SizedBox(
                      width: 100.w,
                      height: 100.w,
                      child: Lottie.asset('assets/lottie/loading_kango.json'),
                    ),
                  );
                } else if (state is HandleGetAuditEpacketStateSuccess) {
                  return SlidableAutoCloseBehavior(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // Close any open slidable when tapping outside
                        Slidable.of(context)?.close();
                      },
                      child: RefreshIndicator(
                        color: Theme.of(context).colorScheme.primary,
                        onRefresh: () async {
                          // shipmentItemData.clear();
                          _endDateError = null;
                          statusTextController.clear();
                          searchTypeTextController.clear();
                          serviceTextController.clear();
                          _dateStartController.clear();
                          _dateEndController.clear();
                          _startDate = null;
                          _endDate = null;
                          branchID = null;
                          BlocProvider.of<GetListAuditEpacketBloc>(context).add(
                              FetchListAuditEpacket(
                                  shipmentStatus: null,
                                  shipmentServiceId: null,
                                  startDate: null,
                                  endDate: null,
                                  shipmentBranchId: null,
                                  keywords: query,
                                  filterBy: currentSearchMethod));
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
                                        // onChanged: searchProduct,
                                        controller: textSearchController,
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.black),
                                        cursorColor: Colors.black,
                                        onFieldSubmitted: (value) {
                                          searchProduct(
                                              textSearchController.text);
                                        },
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
                                                  BorderRadius.circular(8.r),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            isDense: true,
                                            hintText:
                                                "Tìm kiếm theo: $searchMethod",
                                            contentPadding:
                                                const EdgeInsets.all(15)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15.w,
                                    ),
                                    FileterShipmentWidget(
                                        listStatusPayment: [],
                                        isPakageManger: false,
                                        auditEpacketService:
                                            servicesAuditEpacket,
                                        serviceTextController:
                                            serviceTextController,
                                        statusPaymentTextController:
                                            statusPaymentTextController,
                                        searchTypeTextController:
                                            searchTypeTextController,
                                        listSearchMethod: listSearchMethod,
                                        listKeyType: listKeyType,
                                        dateStartController:
                                            _dateStartController,
                                        dateEndController: _dateEndController,
                                        statusTextController:
                                            statusTextController,
                                        branchTextController:
                                            branchTextController,
                                        currentSearchMethod:
                                            currentSearchMethod,
                                        currentSearchString: searchMethod,
                                        onSeachStringChanged:
                                            _updateSearchStringChanged,
                                        onSeachTypeChanged:
                                            _updateSearchTypeChanged,
                                        listStatus: listStatus,
                                        brandIDParam: branchID,
                                        onBrandIDChanged: _updateBrandID,
                                        onServiceIDChanged: _updateServiceID,
                                        branchResponse: branchResponse,
                                        selectDayStart: selectDayStart,
                                        selectDayEnd: selectDayEnd,
                                        getEndDateError: () => _endDateError,
                                        clearFliterFunction: clearFilterFuntion,
                                        applyFliterFunction:
                                            applyFilterFuntion),
                                  ],
                                )),
                            SizedBox(
                              height: 15.h,
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: scrollListBillController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 1.sw,
                                      child: state.data.isEmpty
                                          ? const NoDataFoundWidget()
                                          : ListView.builder(
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
                                                }

                                                final dataShipment =
                                                    state.data[index];

                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.r),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black54
                                                            .withOpacity(0.2),
                                                        spreadRadius: 1,
                                                        blurRadius: 4,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 8.h,
                                                      horizontal: 16.w),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.r),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.r),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors
                                                                .black54
                                                                .withOpacity(
                                                                    0.2),
                                                            spreadRadius: 1,
                                                            blurRadius: 4,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Slidable(
                                                        key: ValueKey(
                                                            dataShipment),
                                                        endActionPane:
                                                            ActionPane(
                                                          extentRatio: 0.7,
                                                          motion:
                                                              const ScrollMotion(),
                                                          children: [
                                                            CustomSlidableAction(
                                                              onPressed:
                                                                  (context) async {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  barrierDismissible:
                                                                      false,
                                                                  builder:
                                                                      (context) =>
                                                                          Center(
                                                                    child:
                                                                        SizedBox(
                                                                      width:
                                                                          100.w,
                                                                      height:
                                                                          100.w,
                                                                      child: Lottie
                                                                          .asset(
                                                                              'assets/lottie/loading_kango.json'),
                                                                    ),
                                                                  ),
                                                                );
                                                                await Future
                                                                    .delayed(
                                                                        Duration
                                                                            .zero);
                                                                getDetailsShipment(
                                                                  shipmentCode:
                                                                      dataShipment
                                                                          .shipmentCode,
                                                                  isMoreDetail:
                                                                      true,
                                                                );
                                                              },
                                                              backgroundColor:
                                                                  Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary,
                                                              foregroundColor:
                                                                  Colors.white,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const Icon(
                                                                    Icons.info,
                                                                    size: 20,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          4.h),
                                                                  TextApp(
                                                                    text:
                                                                        'Chi\ntiết',
                                                                    fontsize:
                                                                        14.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            CustomSlidableAction(
                                                              onPressed:
                                                                  (context) async {
                                                                noteController
                                                                        .text =
                                                                    dataShipment
                                                                            .shipmentNote ??
                                                                        '';
                                                                showDialogNoteAuditEpacket(
                                                                    dataShipment
                                                                        .shipmentCode);
                                                              },
                                                              backgroundColor:
                                                                  Colors.blue,
                                                              foregroundColor:
                                                                  Colors.white,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const Icon(
                                                                    Icons.note,
                                                                    size: 20,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          4.h),
                                                                  TextApp(
                                                                    text:
                                                                        'Ghi\nchú',
                                                                    fontsize:
                                                                        14.sp,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  16.r),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.r),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              // Header
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap:
                                                                        () async {
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        barrierDismissible:
                                                                            false,
                                                                        builder:
                                                                            (context) =>
                                                                                Center(
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                100.w,
                                                                            height:
                                                                                100.w,
                                                                            child:
                                                                                Lottie.asset('assets/lottie/loading_kango.json'),
                                                                          ),
                                                                        ),
                                                                      );
                                                                      await Future.delayed(
                                                                          Duration
                                                                              .zero);
                                                                      getDetailsShipment(
                                                                        shipmentCode:
                                                                            dataShipment.shipmentCode,
                                                                        isMoreDetail:
                                                                            false,
                                                                      );
                                                                    },
                                                                    child:
                                                                        TextApp(
                                                                      text: dataShipment
                                                                          .shipmentCode,
                                                                      fontsize:
                                                                          18.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .primary,
                                                                    ),
                                                                  ),
                                                                  TextApp(
                                                                    text: formatDateTime(dataShipment
                                                                        .createdAt
                                                                        .toString()),
                                                                    fontsize:
                                                                        12.sp,
                                                                    color: Colors.grey[
                                                                            600] ??
                                                                        Colors
                                                                            .grey,
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height: 12.h),

                                                              // Main content
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  // Status Icon
                                                                  Container(
                                                                    padding: EdgeInsets
                                                                        .all(8
                                                                            .r),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: _getStatusColor(dataShipment
                                                                              .shipmentStatus)
                                                                          .withOpacity(
                                                                              0.1),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.r),
                                                                    ),
                                                                    child: Icon(
                                                                      _getStatusIcon(
                                                                          dataShipment
                                                                              .shipmentStatus),
                                                                      color: _getStatusColor(
                                                                          dataShipment
                                                                              .shipmentStatus),
                                                                      size:
                                                                          30.sp,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          12.w),

                                                                  // Details
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        _buildInfoRow(
                                                                          'Người tạo',
                                                                          dataShipment
                                                                              .senderContactName,
                                                                          Colors
                                                                              .grey[800]!,
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                8.h),
                                                                        _buildInfoRow(
                                                                          'Price Create',
                                                                          formatCurrency(
                                                                              dataShipment.shipmentAmountOperatingCosts),
                                                                          Colors
                                                                              .green[700]!,
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                8.h),
                                                                        _buildInfoRow(
                                                                          'Price Actual',
                                                                          formatCurrency(
                                                                              dataShipment.shipmentTotalAmountActual),
                                                                          Colors
                                                                              .blue[700]!,
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                8.h),
                                                                        _buildInfoRow(
                                                                          'Price Diff',
                                                                          formatCurrency(
                                                                              dataShipment.shipmentFinalAmount),
                                                                          Colors
                                                                              .orange[700]!,
                                                                        ),
                                                                        if (dataShipment.shipmentNote !=
                                                                                null &&
                                                                            dataShipment.shipmentNote!.isNotEmpty) ...[
                                                                          SizedBox(
                                                                              height: 8.h),
                                                                          _buildInfoRow(
                                                                            'Ghi chú',
                                                                            dataShipment.shipmentNote!,
                                                                            Colors.grey[600]!,
                                                                          ),
                                                                        ],
                                                                      ],
                                                                    ),
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
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (state is HandleGetAuditEpacketStateFailure) {
                  return ErrorDialog(
                    eventConfirm: () {
                      Navigator.pop(context);
                    },
                    errorText: 'Failed to fetch orders: ${state.message}',
                  );
                }
                return const Center(child: NoDataFoundWidget());
              },
            )));
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: TextApp(
            text: '$label:',
            fontsize: 14.sp,
            color: Colors.grey[600] ?? Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: TextApp(
            text: value,
            fontsize: 14.sp,
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
