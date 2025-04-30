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
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/sale_manager/home_sale_manager/home_sale_manager_bloc.dart';
import 'package:scan_barcode_app/bloc/shipment/list_shipment_bloc.dart';
import 'package:scan_barcode_app/data/models/audit_epacket/audit_epacket_service.dart';
import 'package:scan_barcode_app/data/models/method_pay_character.dart/method_pay_character.dart';
import 'package:scan_barcode_app/data/models/sale_leader/shipment_fwd_model.dart';
import 'package:scan_barcode_app/data/models/shipment/all_unit_shipment.dart';
import 'package:scan_barcode_app/data/models/shipment/delivery_service.dart';
import 'package:scan_barcode_app/data/models/shipment/details_shipment.dart';
import 'package:scan_barcode_app/data/models/utils/list_branchs_model.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/shipment/package_info_tab1_widget.dart';
import 'package:scan_barcode_app/ui/screen/shipment/package_info_tab2_widget.dart';
import 'package:scan_barcode_app/ui/screen/transfer_list/filter_transfer.dart';
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

class ListShipmentFwdScreen extends StatefulWidget {
  final String? userPosition;
  final bool? canUploadLabel;
  final bool? canUploadPayment;
  final int userID;
  const ListShipmentFwdScreen(
      {super.key,
      this.userPosition,
      this.canUploadLabel,
      this.canUploadPayment,
      required this.userID});

  @override
  State<ListShipmentFwdScreen> createState() => _ListShipmentFwdScreenState();
}

class _ListShipmentFwdScreenState extends State<ListShipmentFwdScreen>
    with SingleTickerProviderStateMixin {
  List<ExpansionTileController> expansionTileControllers = [];
  final scrollListShipmentFWDController = ScrollController();
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
  final formatter = NumberFormat("#,###", "vi_VN");
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

  List<String> listStatus = [
    "Create Bill",
    "Imported",
    "Exported",
    "Returned",
    "Hold"
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

  Future<void> showDialogMoreDetailShipment({
    required ShipmentFwdModel shipmentdetail,
  }) async {
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
          maxChildSize: 0.85,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          expand: false,
          builder: (BuildContext context,
              ScrollController scrollControllerMoreInfor) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        height: 55.w,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: TextApp(
                            text: 'THÔNG TIN THÊM',
                            fontsize: 16.w,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollControllerMoreInfor,
                          physics: BouncingScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 16.w),

                                // Main information
                                _buildSection(
                                  title: "THÔNG TIN CHÍNH",
                                  children: [
                                    _buildInfoRow(
                                      label: 'Tổng đơn',
                                      value: formatter.format(
                                          shipmentdetail.shipmentFinalAmount ??
                                              0),
                                      valueColor: Colors.green[800],
                                      isBold: true,
                                    ),
                                    _buildInfoRow(
                                      label: 'Thu khách',
                                      value: formatter.format(
                                          shipmentdetail.shipmentFinalAmount ??
                                              0),
                                    ),
                                    _buildInfoRow(
                                      label: 'Lợi nhuận',
                                      value: formatter.format(
                                          shipmentdetail.shipmentAmountProfit ??
                                              0),
                                      valueColor:
                                          shipmentdetail.shipmentAmountProfit! >
                                                  0
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ],
                                ),

                                SizedBox(height: 16.w),

                                // Package information
                                _buildSection(
                                  title: "THÔNG TIN KIỆN HÀNG",
                                  children: [
                                    _buildInfoRow(
                                      label: 'Số kiện',
                                      value: shipmentdetail
                                              .packages?.first.packageQuantity
                                              .toString() ??
                                          '',
                                    ),
                                    _buildInfoRow(
                                      label: 'Charge Weight',
                                      value: shipmentdetail.packages?.first
                                              .packageChargedWeight
                                              .toString() ??
                                          '',
                                    ),
                                  ],
                                ),

                                SizedBox(height: 16.w),

                                // Fees information
                                _buildSection(
                                  title: "CHI PHÍ & PHỤ THU",
                                  children: [
                                    _buildInfoRow(
                                      label: 'Phụ thu',
                                      value: formatter.format(shipmentdetail
                                              .shipmentAmountSurcharge ??
                                          0),
                                    ),
                                    _buildInfoRow(
                                      label: 'Bảo hiểm',
                                      value: formatter.format(shipmentdetail
                                              .shipmentAmountInsurance ??
                                          0),
                                    ),
                                    _buildInfoRow(
                                      label: 'Cước gốc',
                                      value: formatter.format(shipmentdetail
                                              .shipmentAmountService ??
                                          0),
                                    ),
                                    _buildInfoRow(
                                      label: 'Nội địa',
                                      value: formatter.format(shipmentdetail
                                              .shipmentDomesticCharges ??
                                          0),
                                    ),
                                    _buildInfoRow(
                                      label: 'VAT',
                                      value: formatter.format(
                                          shipmentdetail.shipmentAmountVat ??
                                              0),
                                    ),
                                    _buildInfoRow(
                                      label: 'Thu hộ',
                                      value: formatter.format(shipmentdetail
                                              .shipmentCollectionFee ??
                                          0),
                                    ),
                                    _buildInfoRow(
                                      label: 'CPVH',
                                      value: formatter.format(shipmentdetail
                                              .shipmentAmountOperatingCosts ??
                                          0),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 16.w),

                                // Status information
                                _buildSection(
                                  title: "TRẠNG THÁI",
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Vận chuyển:',
                                          style: TextStyle(
                                            fontSize: 16.w,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Container(
                                          height: 36.w,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12.w),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(18.w),
                                            color: _getStatusColor(
                                                shipmentdetail.shipmentStatus ??
                                                    0),
                                          ),
                                          child: Center(
                                            child: TextApp(
                                              fontsize: 14.w,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              text: _getStatusName(
                                                  shipmentdetail
                                                          .shipmentStatus ??
                                                      0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12.w),
                                    Row(
                                      children: [
                                        Text(
                                          'Thanh toán:',
                                          style: TextStyle(
                                            fontSize: 16.w,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Container(
                                          height: 36.w,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12.w),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(18.w),
                                            color: shipmentdetail
                                                        .shipmentPaymentStatus ==
                                                    0
                                                ? Colors.red
                                                : const Color.fromRGBO(
                                                    0, 214, 127, 1),
                                          ),
                                          child: Center(
                                            child: TextApp(
                                              fontsize: 14.w,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              text: shipmentdetail
                                                          .shipmentPaymentStatus ==
                                                      0
                                                  ? 'Chưa thanh toán'
                                                  : 'Đã thanh toán',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                SizedBox(height: 24.w),
                              ],
                            ),
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
      },
    );
  }

// Helper method to build a section with title
  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 8.w, horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8.w),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Container(
                width: 4.w,
                height: 16.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.w,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.w),
        ...children,
      ],
    );
  }

// Helper method to build info row
  Widget _buildInfoRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.w),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label + ':',
              style: TextStyle(
                fontSize: 15.w,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isBold ? 16.w : 15.w,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: valueColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
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

  void init() async {
    BlocProvider.of<GetListShipmentFwdBloc>(context).add(GetShipmentFWD(
        startDate: null,
        endDate: null,
        keywords: query,
        userID: widget.userID));
    getBranchKango();
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
    scrollListShipmentFWDController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollListShipmentFWDController.position.maxScrollExtent ==
        scrollListShipmentFWDController.offset) {
      BlocProvider.of<GetListShipmentFwdBloc>(context).add(GetShipmentFWD(
        startDate: _startDate?.toString(),
        endDate: _endDate?.toString(),
        keywords: query,
      ));
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

            BlocProvider.of<GetListShipmentFwdBloc>(context).add(GetShipmentFWD(
                startDate: _startDate?.toString(),
                endDate: _endDate?.toString(),
                keywords: query,
                userID: widget.userID));
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

    BlocProvider.of<GetListShipmentFwdBloc>(context).add(GetShipmentFWD(
        startDate: _startDate?.toString(),
        endDate: _endDate?.toString(),
        keywords: query,
        userID: widget.userID));
  }

  Future<void> clearFilterFuntion() async {
    setState(() {
      _endDateError = null;
      statusTextController.clear();
      statusPaymentTextController.clear();
      searchTypeTextController.clear();
      _dateStartController.clear();
      _dateEndController.clear();
      _startDate = null;
      _endDate = null;
      branchID = null;
    });
    Navigator.pop(context);
    BlocProvider.of<GetListShipmentFwdBloc>(context).add(GetShipmentFWD(
        startDate: null, endDate: null, keywords: null, userID: widget.userID));
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
            text: "Danh sách đơn",
            fontsize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: MultiBlocListener(
            listeners: [
              BlocListener<DetailsShipmentBloc, DetailsShipmentState>(
                listener: (context, state) {
                  if (state is DetailsShipmentStateSuccess) {
                    detailsShipment = state.detailsShipmentModel;

                    showDialogDetailsShipment(
                        shipmentCode:
                            state.detailsShipmentModel.shipment.shipmentCode);
                  } else if (state is DetailsShipmentStateFailure) {
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
            child: BlocBuilder<GetListShipmentFwdBloc, SaleManagerState>(
              builder: (context, state) {
                if (state is GetListShipmentFWDStateLoading) {
                  return Center(
                    child: SizedBox(
                      width: 100.w,
                      height: 100.w,
                      child: Lottie.asset('assets/lottie/loading_kango.json'),
                    ),
                  );
                } else if (state is GetListShipmentFWDStateSuccess) {
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
                          BlocProvider.of<GetListShipmentFwdBloc>(context).add(
                              GetShipmentFWD(
                                  startDate: null,
                                  endDate: null,
                                  keywords: null,
                                  userID: widget.userID));
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
                                            hintText: "Tìm kiếm...",
                                            contentPadding:
                                                const EdgeInsets.all(15)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15.w,
                                    ),
                                    FilterTransferWidget(
                                        isPakageManger: false,
                                        dateStartController:
                                            _dateStartController,
                                        dateEndController: _dateEndController,
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
                                controller: scrollListShipmentFWDController,
                                physics: AlwaysScrollableScrollPhysics(),
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
                                                        "Không tìm thấy đơn hàng!",
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
                                                    return Column(
                                                      children: [
                                                        const Divider(
                                                          height: 1,
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 8.h,
                                                                  horizontal:
                                                                      16.w),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.r),
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
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.r),
                                                            child: Slidable(
                                                              // controller:
                                                              //     _slidableController,
                                                              key: ValueKey(
                                                                  dataShipment),
                                                              endActionPane:
                                                                  ActionPane(
                                                                extentRatio:
                                                                    0.3,
                                                                dragDismissible:
                                                                    false,
                                                                motion:
                                                                    const ScrollMotion(),
                                                                dismissible:
                                                                    DismissiblePane(
                                                                        onDismissed:
                                                                            () {}),
                                                                children: [
                                                                  CustomSlidableAction(
                                                                    onPressed:
                                                                        (context) async {
                                                                      // getDetailsShipment(
                                                                      //     shipmentCode:
                                                                      //         dataShipment
                                                                      //             .shipmentCode,
                                                                      //     isMoreDetail:
                                                                      //         true);

                                                                      showDialogMoreDetailShipment(
                                                                          shipmentdetail:
                                                                              dataShipment);
                                                                    },
                                                                    backgroundColor: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .primary,
                                                                    foregroundColor:
                                                                        Colors
                                                                            .white,
                                                                    child:
                                                                        const Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .info,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                4),
                                                                        Text(
                                                                          'Thêm',
                                                                          style:
                                                                              TextStyle(color: Colors.white),
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(16
                                                                            .r),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
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
                                                                      padding: EdgeInsets
                                                                          .all(8
                                                                              .r),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: _getStatusColor(dataShipment.shipmentStatus!)
                                                                            .withOpacity(0.1),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.r),
                                                                      ),
                                                                      child:
                                                                          Icon(
                                                                        _getStatusIcon(
                                                                            dataShipment.shipmentStatus!),
                                                                        color: _getStatusColor(
                                                                            dataShipment.shipmentStatus!),
                                                                        size: 36
                                                                            .sp,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        width: 12
                                                                            .w),

                                                                    // Main Content
                                                                    Expanded(
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          // Header
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  getDetailsShipment(
                                                                                    shipmentCode: dataShipment.shipmentCode,
                                                                                    isMoreDetail: false,
                                                                                  );
                                                                                },
                                                                                child: TextApp(
                                                                                  text: dataShipment.shipmentCode.toString(),
                                                                                  fontsize: 18.sp,
                                                                                  color: Theme.of(context).colorScheme.primary,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                              TextApp(
                                                                                text: formatDateTime(dataShipment.createdAt.toString()),
                                                                                fontsize: 12.sp,
                                                                                color: Colors.grey,
                                                                                fontWeight: FontWeight.w600,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          SizedBox(
                                                                              height: 8.h),

                                                                          // Details
                                                                          TextApp(
                                                                            softWrap:
                                                                                true,
                                                                            isOverFlow:
                                                                                false,
                                                                            text:
                                                                                "Người nhận: ${dataShipment.receiverContactName}",
                                                                            fontsize:
                                                                                16.sp,
                                                                            color:
                                                                                Colors.grey[800] ?? Colors.grey,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                          SizedBox(
                                                                              height: 6.h),
                                                                          TextApp(
                                                                            softWrap:
                                                                                true,
                                                                            isOverFlow:
                                                                                false,
                                                                            text:
                                                                                "Chi nhánh: ${_getNameBranch(dataShipment.shipmentBranchId!.toInt())}",
                                                                            fontsize:
                                                                                15.sp,
                                                                            color:
                                                                                Colors.grey[600] ?? Colors.grey,
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                          ),
                                                                          SizedBox(
                                                                              height: 6.h),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Expanded(
                                                                                child: TextApp(
                                                                                  softWrap: true,
                                                                                  isOverFlow: false,
                                                                                  text: "Dịch vụ: ${dataShipment.service?.serviceName ?? ''}",
                                                                                  fontsize: 15.sp,
                                                                                  color: Colors.grey[600] ?? Colors.grey,
                                                                                  fontWeight: FontWeight.normal,
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
                                                        ),
                                                      ],
                                                    );
                                                  }
                                                }))
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (state is GetListShipmentFWDStateFailure) {
                  return AlertDialog(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.w),
                    ),
                    actionsPadding: EdgeInsets.zero,
                    contentPadding: EdgeInsets.only(
                        top: 0.w, bottom: 30.w, left: 35.w, right: 35.w),
                    titlePadding: EdgeInsets.all(15.w),
                    surfaceTintColor: Colors.white,
                    backgroundColor: Colors.white,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextApp(
                          text: "CÓ LỖI XẢY RA !",
                          fontsize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: SizedBox(
                            width: 300.w,
                            height: 150.w,
                            child: Lottie.asset(
                                'assets/lottie/error_dialog.json',
                                fit: BoxFit.fill),
                          ),
                        ),
                        // Center(
                        //     child: Icon(
                        //   Icons.cancel,
                        //   size: 150.w,
                        //   color: Colors.red,
                        // )),
                        TextApp(
                          text: state.message ??
                              "Đã có lỗi xảy ra! \nVui lòng liên hệ quản trị viên.",
                          fontsize: 18.sp,
                          softWrap: true,
                          isOverFlow: false,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: NoDataFoundWidget());
              },
            )));
  }
}
