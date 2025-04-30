import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/shipment/details_tracking_shipment/details_tracking_shipment_bloc.dart';
import 'package:scan_barcode_app/bloc/shipment/list_shipment_bloc.dart';
import 'package:scan_barcode_app/data/models/audit_epacket/audit_epacket_service.dart';
import 'package:scan_barcode_app/data/models/shipment/all_unit_shipment.dart';
import 'package:scan_barcode_app/data/models/shipment/delivery_service.dart';
import 'package:scan_barcode_app/data/models/shipment/details_shipment.dart';
import 'package:scan_barcode_app/data/models/shipment/list_shipment.dart';
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
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';

import '../../../data/models/method_pay_character.dart/method_pay_character.dart';

class PackageManagerScreen extends StatefulWidget {
  final String? userPosition;
  final bool? canUploadLabel;
  final bool? canUploadPayment;
  const PackageManagerScreen({
    super.key,
    this.userPosition,
    this.canUploadLabel,
    this.canUploadPayment,
  });

  @override
  State<PackageManagerScreen> createState() => _PackageManagerScreenState();
}

class _PackageManagerScreenState extends State<PackageManagerScreen>
    with SingleTickerProviderStateMixin {
  List<ExpansionTileController> expansionTileControllers = [];
  final scrollListBillController = ScrollController();
  final textSearchController = TextEditingController();
  final statusTextController = TextEditingController();
  final branchTextController = TextEditingController();
  final searchTypeTextController = TextEditingController();
  final statusPaymentTextController = TextEditingController();
  final TextEditingController _dateStartController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();
  AuditEpacketService? servicesAuditEpacket;
  final serviceTextController = TextEditingController();
  bool isMoreDetailShipment = false;
  int? serviceID;
  String query = '';
  List<IconData> iconStatus = [
    Icons.all_inbox,
    Icons.add,
    Icons.create,
    Icons.outbond,
    Icons.refresh
  ];
  bool _isExpanded = false; // Trạng thái mở rộng
  DetailsShipmentModel? detailsShipment;
  DeliveryServiceModel? deliveryServiceMode;
  AllUnitShipmentModel? allUnitShipmentModel;

  List<String> listStatus = [
    "Create Bill",
    "Imported",
    "Exported",
    "Returned",
    "Hold"
  ];

  List<String> listStatusPayment = [
    "Đang nợ",
    "Đã thanh toán",
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
    context.read<DetailsShipmentBloc>().add(
          HanldeDetailsShipment(
              shipmentCode: shipmentCode, isMoreDetail: isMoreDetail),
        );
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
                                methodPay: _methodPay,
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

  void _updateServiceID(int newServiceID) {
    setState(() {
      serviceID = newServiceID;
    });
  }

//Lấy danh sách dịch vụ
  Future<void> getAllServicePackageManager() async {
    final response = await http.get(
      Uri.parse('$baseUrl$getListServicePackageManager'),
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
        log("getAllServicePackageManager error 1");
      }
    } catch (error) {
      log("getAllServicePackageManager error $error 2");
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

  String _getPositionName(int positionID) {
    const statusMap = {
      1: 'ADMIN',
      2: 'Kế toán',
      3: 'OPS/Pickup',
      4: 'Sale',
      5: 'Fwd',
      7: 'Chứng từ',
      8: 'OPS trưởng',
      9: 'Tài xế'
    };
    return statusMap[positionID] ?? 'Unknown';
  }

  Color _getPositionColor(int positionID) {
    const statusMap = {
      1: Colors.black,
      // 2: 'Kế toán',
      // 3: 'OPS/Pickup',
      4: Color.fromRGBO(0, 214, 127, 1),
      5: Color.fromRGBO(24, 221, 239, 1),
      // 7: 'Chứng từ',
      // 8: 'OPS trưởng',
      // 9: 'Tài xế'
    };
    return statusMap[positionID] ?? const Color.fromRGBO(24, 221, 239, 1);
  }

  String _getStatusName(int statusID) {
    const statusMap = {
      0: 'Create Bill',
      1: 'Imported',
      2: 'Exported',
      3: 'Returned',
      4: 'Hold',
    };
    return statusMap[statusID] ?? 'Unknown';
  }

  Color _getStatusColor(int statusID) {
    const statusMap = {
      0: Colors.grey,
      1: Color.fromRGBO(24, 221, 239, 1),
      2: Color.fromRGBO(0, 214, 127, 1),
      3: Colors.red,
      4: Colors.red,
    };
    return statusMap[statusID] ?? Colors.grey;
  }

  void showDialogMoreDetailShipment({
    required DetailsShipmentModel shipmentdetail,
  }) {
    final bool? isShipper = StorageUtils.instance.getBool(key: 'is_shipper');
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          maxChildSize: 0.8,
          initialChildSize: 0.6,
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
                    child: TextApp(
                      text: 'Thông tin thêm',
                      fontsize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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
                            title: 'Địa chỉ nhận',
                            value: shipmentdetail.shipment.receiverAddress1
                                .toString(),
                            icon: Icons.location_on_rounded,
                          ),
                          _buildInfoCard(
                            title: 'Tài khoản tạo',
                            value: shipmentdetail.shipment.user.userContactName,
                            icon: Icons.person_rounded,
                            badge: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: _getPositionColor(
                                    shipmentdetail.shipment.user.positionId),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                _getPositionName(
                                    shipmentdetail.shipment.user.positionId),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          _buildInfoCard(
                            title: 'Ref Code',
                            value:
                                shipmentdetail.shipment.shipmentReferenceCode ??
                                    'Không có',
                            icon: Icons.code_rounded,
                          ),
                          SizedBox(height: 16.h),
                          _buildSectionTitle('Trạng thái'),
                          _buildStatusCard(
                            title: 'Trạng thái đơn hàng',
                            value: _getStatusName(
                                shipmentdetail.shipment.shipmentStatus),
                            color: _getStatusColor(
                                shipmentdetail.shipment.shipmentStatus),
                            icon: _getStatusIcon(
                                shipmentdetail.shipment.shipmentStatus),
                          ),
                          _buildStatusCard(
                            title: 'Thanh toán',
                            value:
                                shipmentdetail.shipment.shipmentPaymentStatus ==
                                        0
                                    ? 'Chưa thanh toán'
                                    : 'Đã thanh toán',
                            color:
                                shipmentdetail.shipment.shipmentPaymentStatus ==
                                        0
                                    ? Colors.red
                                    : const Color.fromRGBO(0, 214, 127, 1),
                            icon: Icons.payment_rounded,
                          ),
                          _buildStatusCard(
                            title: 'Duyệt xuất',
                            value: shipmentdetail.shipment.accountantStatus == 0
                                ? 'Đang chờ xác nhận'
                                : 'Đã xác nhận',
                            color: shipmentdetail.shipment.accountantStatus == 0
                                ? Colors.grey[600]!
                                : const Color.fromRGBO(0, 214, 127, 1),
                            icon: Icons.verified_rounded,
                          ),
                          if (!isShipper! &&
                              !(shipmentdetail.shipment.service.serviceName
                                      ?.startsWith("EP-") ??
                                  false))
                            _buildStatusCard(
                              title: 'Admin duyệt',
                              value: shipmentdetail.shipment
                                          .shipmentCheckedPaymentStatus ==
                                      0
                                  ? 'Chưa duyệt'
                                  : 'Đã duyệt',
                              color: shipmentdetail.shipment
                                          .shipmentCheckedPaymentStatus ==
                                      0
                                  ? const Color.fromRGBO(255, 196, 0, 1)
                                  : const Color.fromRGBO(0, 214, 127, 1),
                              icon: Icons.admin_panel_settings_rounded,
                            ),
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

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    Widget? badge,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextApp(
                  text: title,
                  fontsize: 14.sp,
                  color: Colors.grey[600] ?? Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Expanded(
                      child: TextApp(
                        text: value,
                        fontsize: 16.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (badge != null) ...[
                      SizedBox(width: 8.w),
                      badge,
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildStatusCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              size: 20.sp,
              color: color,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextApp(
                  text: title,
                  fontsize: 14.sp,
                  color: Colors.grey[600] ?? Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 4.h),
                TextApp(
                  text: value,
                  fontsize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  Future<void> getBranchKango() async {
    String? branchResponseJson =
        StorageUtils.instance.getString(key: 'branch_response');
    if (branchResponseJson != null) {
      branchResponse = BranchResponse.fromJson(jsonDecode(branchResponseJson));
      log("GET BRANCH OK LIST");
    }
  }

  void init() async {
    BlocProvider.of<ListShipmentBloc>(context).add(FetchListShipment(
        status: null,
        statusPayment: null,
        startDate: null,
        endDate: null,
        branchId: null,
        shipmentServiceId: null,
        keywords: query,
        searchMethod: currentSearchMethod));
    await getBranchKango();
    await getAllUnitShipment();

    await getAllServicePackageManager();
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
      BlocProvider.of<ListShipmentBloc>(context).add(LoadMoreListShipment(
          status: listStatus.indexOf(statusTextController.text) == -1
              ? null
              : listStatus.indexOf(statusTextController.text),
          statusPayment:
              !listStatusPayment.contains(statusPaymentTextController.text)
                  ? null
                  : listStatusPayment.indexOf(statusPaymentTextController.text),
          startDate: _startDate?.toString(),
          endDate: _endDate?.toString(),
          branchId: branchID,
          keywords: query,
          searchMethod: currentSearchMethod));
    }
  }

  @override
  void dispose() {
    super.dispose();
    textSearchController.clear();
    statusTextController.clear();
    searchTypeTextController.clear();
    serviceTextController.clear();
    _dateStartController.clear();
    _dateEndController.clear();
    statusTextController.clear();
  }

  void searchProduct(String query) {
    mounted
        ? setState(() {
            this.query = query;

            BlocProvider.of<ListShipmentBloc>(context).add(FetchListShipment(
                status: !listStatus.contains(statusTextController.text)
                    ? null
                    : listStatus.indexOf(statusTextController.text),
                statusPayment: !listStatusPayment
                        .contains(statusPaymentTextController.text)
                    ? null
                    : listStatusPayment
                        .indexOf(statusPaymentTextController.text),
                startDate: _startDate?.toString(),
                endDate: _endDate?.toString(),
                branchId: branchID,
                shipmentServiceId: serviceID,
                keywords: query,
                searchMethod: currentSearchMethod));
          })
        : null;
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

    log(_startDate.toString());
    log(_endDate.toString());
    Navigator.pop(context);

    BlocProvider.of<ListShipmentBloc>(context).add(FetchListShipment(
        status: listStatus.indexOf(statusTextController.text) == -1
            ? null
            : listStatus.indexOf(statusTextController.text),
        statusPayment:
            !listStatusPayment.contains(statusPaymentTextController.text)
                ? null
                : listStatusPayment.indexOf(statusPaymentTextController.text),
        startDate: _startDate?.toString(),
        endDate: _endDate?.toString(),
        branchId: branchID,
        shipmentServiceId: serviceID,
        keywords: query,
        searchMethod: currentSearchMethod));
  }

  Future<void> clearFilterFuntion() async {
    setState(() {
      _endDateError = null;
      statusTextController.clear();
      statusPaymentTextController.clear();
      searchTypeTextController.clear();
      serviceTextController.clear();
      _dateStartController.clear();
      _dateEndController.clear();
      _startDate = null;
      _endDate = null;
      branchID = null;
    });
    Navigator.pop(context);
    BlocProvider.of<ListShipmentBloc>(context).add(FetchListShipment(
        status: null,
        statusPayment: null,
        startDate: null,
        endDate: null,
        branchId: null,
        shipmentServiceId: null,
        keywords: query,
        searchMethod: currentSearchMethod));
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

  String _getNameBranch(int brandId) {
    final branch = branchResponse?.branchs.firstWhere(
      (branch) => branch.branchId == brandId,
    );
    if (branch != null) {
      return branch.branchName;
    } else {
      throw Exception('Branch not found');
    }
  }

// Hàm xây dựng dòng thông tin
  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey[700]),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[800],
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  double _getExtentRatio(int? positionID, bool isShipper, int shipmentStatus) {
    if (isShipper) return 0.3; // Shipper chỉ có nút "Thêm"
    switch (positionID) {
      case 1: // Admin
      case 2: // Kế toán
      case 7: // Chứng từ
        return 0.9; // 3 nút: Thêm, Sửa, Xóa
      case 4: // Sale
      case 5: // Fwd
        return shipmentStatus == 0
            ? 0.6
            : 0.3; // Sửa + Thêm nếu status != 1, ngược lại chỉ Thêm
      case 8: // OPS trưởng
        return 0.3; // Chỉ Thêm
      default:
        return 0.3; // Mặc định chỉ Thêm
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool? isShipper = StorageUtils.instance.getBool(key: 'is_shipper');
    final int? positionID = StorageUtils.instance.getInt(key: 'positionID');
    return Scaffold(
        resizeToAvoidBottomInset: false,
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
            text: "Package Manager",
            fontsize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: MultiBlocListener(
            listeners: [
              BlocListener<ListShipmentBloc, ListShipmentState>(
                listener: (context, state) {
                  if (state is ListShipmentStateSuccess) {}
                },
              ),
              BlocListener<DetailsShipmentBloc, DetailsShipmentState>(
                listener: (context, state) {
                  if (state is DetailsShipmentStateSuccess) {
                    detailsShipment = state.detailsShipmentModel;
                    Navigator.pop(context);
                    if (state.isMoreDetail) {
                      showDialogMoreDetailShipment(
                          shipmentdetail: detailsShipment!);
                    } else {
                      showDialogDetailsShipment(
                          shipmentCode:
                              state.detailsShipmentModel.shipment.shipmentCode);
                    }
                  }
                },
              ),
              BlocListener<DeleteShipmentBloc, DeleteShipmentState>(
                listener: (context, state) {
                  if (state is DeleteShipmentStateSuccess) {
                    showCustomDialogModal(
                        context: navigatorKey.currentContext!,
                        textDesc: "Xóa shipment thành công",
                        title: "Thông báo",
                        colorButtonOk: Colors.green,
                        btnOKText: "Xác nhận",
                        typeDialog: "success",
                        eventButtonOKPress: () {},
                        isTwoButton: false);
                    init();
                  } else if (state is DeleteShipmentStateFailure) {
                    showDialog(
                        context: navigatorKey.currentContext!,
                        builder: (BuildContext context) {
                          return ErrorDialog(
                            eventConfirm: () {
                              Navigator.pop(context);
                            },
                            errorText: state.message,
                          );
                        });
                  }
                },
              ),
            ],
            child: BlocBuilder<ListShipmentBloc, ListShipmentState>(
              builder: (context, state) {
                if (state is ListShipmentStateLoading) {
                  return Center(
                    child: SizedBox(
                      width: 100.w,
                      height: 100.w,
                      child: Lottie.asset('assets/lottie/loading_kango.json'),
                    ),
                  );
                } else if (state is ListShipmentStateSuccess) {
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
                          statusPaymentTextController.clear();
                          _dateStartController.clear();
                          searchTypeTextController.clear();
                          _dateEndController.clear();
                          _startDate = null;
                          _endDate = null;
                          branchID = null;
                          BlocProvider.of<ListShipmentBloc>(context).add(
                              FetchListShipment(
                                  status: null,
                                  startDate: null,
                                  statusPayment: null,
                                  endDate: null,
                                  branchId: null,
                                  shipmentServiceId: null,
                                  keywords: query,
                                  searchMethod: currentSearchMethod));
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
                                        serviceTextController:
                                            serviceTextController,
                                        auditEpacketService:
                                            servicesAuditEpacket,
                                        onServiceIDChanged: _updateServiceID,
                                        isPakageManger: false,
                                        searchTypeTextController:
                                            searchTypeTextController,
                                        listSearchMethod: listSearchMethod,
                                        listKeyType: listKeyType,
                                        listStatusPayment: listStatusPayment,
                                        dateStartController:
                                            _dateStartController,
                                        dateEndController: _dateEndController,
                                        statusTextController:
                                            statusTextController,
                                        branchTextController:
                                            branchTextController,
                                        currentSearchMethod:
                                            currentSearchMethod,
                                        statusPaymentTextController:
                                            statusPaymentTextController,
                                        currentSearchString: searchMethod,
                                        onSeachStringChanged:
                                            _updateSearchStringChanged,
                                        onSeachTypeChanged:
                                            _updateSearchTypeChanged,
                                        listStatus: listStatus,
                                        brandIDParam: branchID,
                                        onBrandIDChanged: _updateBrandID,
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 1.sw,
                                      child: state.data.isEmpty
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Center(
                                                  child: SizedBox(
                                                    width: 200.w,
                                                    height: 200.w,
                                                    child: Lottie.asset(
                                                        'assets/lottie/empty_box.json',
                                                        fit: BoxFit.contain),
                                                  ),
                                                ),
                                                TextApp(
                                                  text:
                                                      "Không tìm thấy đơn hàng !",
                                                  fontsize: 18.sp,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ],
                                            )
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
                                                } else {
                                                  final dataShipment =
                                                      state.data[index];
                                                  return Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            vertical: 8.h,
                                                            horizontal: 16.w),
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
                                                          offset: const Offset(
                                                              0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.r),
                                                      child: Slidable(
                                                        key: ValueKey(
                                                            dataShipment),
                                                        endActionPane:
                                                            ActionPane(
                                                          extentRatio:
                                                              _getExtentRatio(
                                                                  positionID,
                                                                  isShipper!,
                                                                  dataShipment
                                                                      .shipmentStatus),
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
                                                                      Icons
                                                                          .info,
                                                                      size: 24,
                                                                      color: Colors
                                                                          .white),
                                                                  SizedBox(
                                                                      height:
                                                                          4.h),
                                                                  TextApp(
                                                                    text:
                                                                        'Thêm',
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
                                                            if (!isShipper &&
                                                                (positionID ==
                                                                        1 ||
                                                                    positionID ==
                                                                        2 ||
                                                                    positionID ==
                                                                        7))
                                                              CustomSlidableAction(
                                                                onPressed:
                                                                    (context) async {
                                                                  editShipment(
                                                                      shipmentCode: dataShipment
                                                                          .shipmentCode
                                                                          .toString());
                                                                },
                                                                backgroundColor:
                                                                    Colors.blue,
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    const Icon(
                                                                        Icons
                                                                            .edit,
                                                                        size:
                                                                            24,
                                                                        color: Colors
                                                                            .white),
                                                                    SizedBox(
                                                                        height:
                                                                            4.h),
                                                                    TextApp(
                                                                      text:
                                                                          'Sửa',
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
                                                            if (!isShipper &&
                                                                (positionID ==
                                                                        1 ||
                                                                    positionID ==
                                                                        2 ||
                                                                    positionID ==
                                                                        7))
                                                              CustomSlidableAction(
                                                                onPressed:
                                                                    (context) {
                                                                  showCustomDialogModal(
                                                                    context:
                                                                        navigatorKey
                                                                            .currentContext!,
                                                                    textDesc:
                                                                        "Bạn có chắc muốn thực hiện tác vụ này?",
                                                                    title:
                                                                        "Thông báo",
                                                                    colorButtonOk:
                                                                        Colors
                                                                            .blue,
                                                                    btnOKText:
                                                                        "Xác nhận",
                                                                    typeDialog:
                                                                        "question",
                                                                    eventButtonOKPress:
                                                                        () {
                                                                      handleDeleteShipment(
                                                                          shipmentCode:
                                                                              dataShipment.shipmentCode);
                                                                    },
                                                                    isTwoButton:
                                                                        true,
                                                                  );
                                                                },
                                                                backgroundColor:
                                                                    Colors.red,
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    const Icon(
                                                                        Icons
                                                                            .delete,
                                                                        size:
                                                                            24,
                                                                        color: Colors
                                                                            .white),
                                                                    SizedBox(
                                                                        height:
                                                                            4.h),
                                                                    TextApp(
                                                                      text:
                                                                          'Xóa',
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
                                                            if (!isShipper &&
                                                                (positionID ==
                                                                        4 ||
                                                                    positionID ==
                                                                        5) &&
                                                                (dataShipment
                                                                        .shipmentStatus ==
                                                                    0))
                                                              CustomSlidableAction(
                                                                onPressed:
                                                                    (context) async {
                                                                  editShipment(
                                                                      shipmentCode: dataShipment
                                                                          .shipmentCode
                                                                          .toString());
                                                                },
                                                                backgroundColor:
                                                                    Colors.blue,
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    const Icon(
                                                                        Icons
                                                                            .edit,
                                                                        size:
                                                                            24,
                                                                        color: Colors
                                                                            .white),
                                                                    SizedBox(
                                                                        height:
                                                                            4.h),
                                                                    TextApp(
                                                                      text:
                                                                          'Sửa',
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
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              // Status Icon
                                                              Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(8
                                                                            .r),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: _getStatusColor(
                                                                          dataShipment
                                                                              .shipmentStatus)
                                                                      .withOpacity(
                                                                          0.1),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.r),
                                                                ),
                                                                child: Icon(
                                                                  _getStatusIcon(
                                                                      dataShipment
                                                                          .shipmentStatus),
                                                                  color: _getStatusColor(
                                                                      dataShipment
                                                                          .shipmentStatus),
                                                                  size: 36.sp,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 12.w),

                                                              // Main Content
                                                              Expanded(
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
                                                                        InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            showDialog(
                                                                              context: context,
                                                                              barrierDismissible: false,
                                                                              builder: (context) => Center(
                                                                                child: SizedBox(
                                                                                  width: 100.w,
                                                                                  height: 100.w,
                                                                                  child: Lottie.asset('assets/lottie/loading_kango.json'),
                                                                                ),
                                                                              ),
                                                                            );
                                                                            await Future.delayed(Duration.zero);
                                                                            getDetailsShipment(
                                                                              shipmentCode: dataShipment.shipmentCode,
                                                                              isMoreDetail: false,
                                                                            );
                                                                          },
                                                                          child:
                                                                              TextApp(
                                                                            text:
                                                                                dataShipment.shipmentCode,
                                                                            fontsize:
                                                                                18.sp,
                                                                            color:
                                                                                Theme.of(context).colorScheme.primary,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                        TextApp(
                                                                          text: formatDateTime(dataShipment
                                                                              .createdAt
                                                                              .toString()),
                                                                          fontsize:
                                                                              12.sp,
                                                                          color:
                                                                              Colors.grey,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            8.h),

                                                                    // Details
                                                                    _buildInfoRow(
                                                                        icon: Icons
                                                                            .person,
                                                                        text:
                                                                            "Người nhận: ${dataShipment.receiverContactName}"),
                                                                    SizedBox(
                                                                        height:
                                                                            6.h),
                                                                    _buildInfoRow(
                                                                        icon: Icons
                                                                            .store,
                                                                        text:
                                                                            "Chi nhánh: ${_getNameBranch(dataShipment.shipmentBranchId)}"),

                                                                    SizedBox(
                                                                        height:
                                                                            6.h),

                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Expanded(
                                                                          child: _buildInfoRow(
                                                                              icon: Icons.local_shipping_rounded,
                                                                              text: "Dịch vụ: ${dataShipment.service.serviceName}"),
                                                                        ),
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            if (dataShipment.packageOfShipmentItemData.isEmpty) {}
                                                                            if (dataShipment.packageOfShipmentItemData.isNotEmpty) {}
                                                                            dataShipment.shipmentCode.isNotEmpty
                                                                                ? Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                      builder: (context) => TrackingShipmentStatusScreen(
                                                                                        packageHawbCode: dataShipment.shipmentCode,
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                                : showCustomDialogModal(
                                                                                    context: navigatorKey.currentContext!,
                                                                                    textDesc: "Mã này không tồn tại",
                                                                                    title: "Thông báo",
                                                                                    colorButtonOk: Colors.red,
                                                                                    btnOKText: "Xác nhận",
                                                                                    typeDialog: "error",
                                                                                    eventButtonOKPress: () {},
                                                                                    isTwoButton: false,
                                                                                  );
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            Icons.location_on,
                                                                            size:
                                                                                36.sp,
                                                                            color:
                                                                                Theme.of(context).colorScheme.primary,
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
                                                  );
                                                }
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
                } else if (state is ListShipmentStateFailure) {
                  return ErrorDialog(
                    eventConfirm: () {
                      Navigator.pop(context);
                    },
                    errorText: 'Lỗi khi tải dữ liệu: ${state.message}',
                  );
                }
                return const Center(child: NoDataFoundWidget());
              },
            )));
  }
}
