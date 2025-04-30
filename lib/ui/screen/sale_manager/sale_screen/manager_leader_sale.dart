import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/sale_manager/home_sale_manager/home_sale_manager_bloc.dart';
import 'package:scan_barcode_app/bloc/shipment/list_shipment_bloc.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/models/method_pay_character.dart/method_pay_character.dart';
import 'package:scan_barcode_app/data/models/sale_leader/shipment_sale.dart';
import 'package:scan_barcode_app/data/models/shipment/all_unit_shipment.dart';
import 'package:scan_barcode_app/data/models/shipment/delivery_service.dart';
import 'package:scan_barcode_app/data/models/shipment/details_shipment.dart';
import 'package:scan_barcode_app/data/models/utils/list_branchs_model.dart';
import 'package:scan_barcode_app/ui/screen/shipment/package_info_tab1_widget.dart';
import 'package:scan_barcode_app/ui/screen/shipment/package_info_tab2_widget.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:http/http.dart' as http;

class ManagerLeaderSale extends StatefulWidget {
  final String? saleCode;
  final String? userPosition;
  final bool? canUploadLabel;
  final bool? canUploadPayment;
  int? userId;
  ManagerLeaderSale(
      {super.key,
      this.saleCode,
      this.userPosition,
      this.canUploadLabel,
      this.canUploadPayment,
      this.userId});

  @override
  State<ManagerLeaderSale> createState() => _ManagerLeaderSaleState();
}

class _ManagerLeaderSaleState extends State<ManagerLeaderSale>
    with TickerProviderStateMixin {
  late String monthDate;
  late TabController _tabController;
  late TabController _tabControllerDetailShipment;
  final textSearchController = TextEditingController();
  final formatter = NumberFormat("#,###", "vi_VN");
  final TextEditingController _monthYearController = TextEditingController();
  DateTime? _selectedDate; // Temporary storage for picker selection
  final scrollListShipmentSaleController = ScrollController();
  final scrollDetailSale = ScrollController();
  final scrollKpiSale = ScrollController();
  List<ShipmentSaleData> _shipmentsSaleData = [];
  BranchResponse? branchResponse;
  DetailsShipmentModel? detailsShipment;
  DeliveryServiceModel? deliveryServiceMode;
  AllUnitShipmentModel? allUnitShipmentModel;
  String? selectedFile;
  File? selectedImage;
  MethodPayCharater? _methodPay = MethodPayCharater.bank;
  String query = '';
  bool _isLoading = false;
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _tabControllerDetailShipment = TabController(length: 2, vsync: this);
    init();

    scrollListShipmentSaleController.addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    final state = BlocProvider.of<GetListShipmentSaleBloc>(context).state;

    // Chỉ load more nếu chưa đạt max và không đang load
    if (state is GetShipmentsSaleLeaderStateSuccess && !state.hasReachedMax) {
      if (scrollListShipmentSaleController.position.maxScrollExtent ==
          scrollListShipmentSaleController.offset) {
        BlocProvider.of<GetListShipmentSaleBloc>(context).add(
          LoadMoreShipmentSale(userId: widget.userId, keywords: null),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabControllerDetailShipment.dispose();
    widget.userId = null;
    textSearchController.clear();
    _monthYearController.dispose();
    super.dispose();
  }

  void searchProduct(String query) {
    mounted
        ? setState(() {
            this.query = query;
            _reloadList(keywords: query);
          })
        : null;
  }

  void init() {
    final int? userId = StorageUtils.instance.getInt(key: 'user_ID');

    getBranchKango();
    final now = DateTime.now();
    _selectedDate = now;
    monthDate = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    _monthYearController.text = _formatMonthYear(now);

    // Lấy ngày đầu tiên và ngày cuối cùng của tháng hiện tại
    final startDate = DateTime(now.year, now.month, 1);
    final endDate =
        DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1));

    // Định dạng nếu cần
    final formatter = DateFormat('yyyy-MM-dd');
    final formattedStartDate = formatter.format(startDate);
    final formattedEndDate = formatter.format(endDate);

    BlocProvider.of<GetListShipmentSaleBloc>(context).add(
      GetShipmentSale(
        userId: widget.userId,
        keywords: null,
        startDate: formattedStartDate, // "2025-03-01"
        endDate: formattedEndDate, // "2025-03-31"
      ),
    );

    _reloadList();
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
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              eventConfirm: () {
                Navigator.pop(context);
              },
            );
          });
    }
  }

  String _formatMonthYear(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return 'Tháng $month ${date.year}';
  }

  Future<void> getBranchKango() async {
    String? branchResponseJson =
        StorageUtils.instance.getString(key: 'branch_response');
    if (branchResponseJson != null) {
      branchResponse = BranchResponse.fromJson(jsonDecode(branchResponseJson));
      log("GET BRANCH OK LIST");
    }
  }

  // Cupertino picker for iOS (month and year only)
  void _buildCupertinoMonthPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250.h,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child:
                        const Text('Hủy', style: TextStyle(color: Colors.red)),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        monthDate =
                            '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}';
                        _monthYearController.text =
                            _formatMonthYear(_selectedDate!);
                      });
                      _reloadList(); // Load lại danh sách với startDate và endDate mới
                      Navigator.pop(context);
                    },
                    child: Text('Xác nhận',
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.monthYear,
                  initialDateTime: _selectedDate ?? DateTime.now(),
                  minimumYear: DateTime.now().year - 5,
                  maximumYear: DateTime.now().year + 5,
                  onDateTimeChanged: (DateTime picked) {
                    _selectedDate = picked; // Update temporary selection
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Material picker for Android (month and year only)
  void _buildCustomMonthPicker(BuildContext context) {
    int selectedMonth = _selectedDate!.month;
    int selectedYear = _selectedDate!.year;
    final years = List.generate(11, (index) => DateTime.now().year - 5 + index);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300.h,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Hủy', style: TextStyle(color: Colors.red)),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(selectedYear, selectedMonth);
                        monthDate =
                            '$selectedYear-${selectedMonth.toString().padLeft(2, '0')}';
                        _monthYearController.text =
                            _formatMonthYear(_selectedDate!);
                      });
                      _reloadList(); // Load lại danh sách với startDate và endDate mới
                      Navigator.pop(context);
                    },
                    child: Text('Xác nhận',
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32.0,
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedMonth - 1,
                        ),
                        onSelectedItemChanged: (index) {
                          selectedMonth = index + 1;
                        },
                        children: List<Widget>.generate(12, (index) {
                          return Center(child: Text('Tháng ${index + 1}'));
                        }),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32.0,
                        scrollController: FixedExtentScrollController(
                          initialItem: years.indexOf(selectedYear),
                        ),
                        onSelectedItemChanged: (index) {
                          selectedYear = years[index];
                        },
                        children: years.map((year) {
                          return Center(child: Text('$year'));
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Platform-specific month picker trigger
  Future<void> _selectMonthYear(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return _buildCustomMonthPicker(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return _buildCupertinoMonthPicker(context);
    }
  }

  // Reload the list with the updated monthDate
  void _reloadList({String? keywords}) {
    final int? userId = StorageUtils.instance.getInt(key: 'user_ID');

    // Tính startDate và endDate dựa trên _selectedDate
    final startDate = DateTime(_selectedDate!.year, _selectedDate!.month, 1);
    final endDate = DateTime(_selectedDate!.year, _selectedDate!.month + 1, 1)
        .subtract(Duration(days: 1));

    // Định dạng nếu cần
    final formatter = DateFormat('yyyy-MM-dd');
    final formattedStartDate = formatter.format(startDate);
    final formattedEndDate = formatter.format(endDate);

    BlocProvider.of<GetSaleLeaderStatisticBloc>(context).add(
      GetDetailSaleLeader(saleCode: widget.saleCode, monthDate: monthDate),
    );
    // Gọi GetShipmentSale với startDate và endDate
    BlocProvider.of<GetListShipmentSaleBloc>(context).add(
      GetShipmentSale(
        userId: widget.userId,
        keywords: keywords,
        startDate: formattedStartDate,
        endDate: formattedEndDate,
      ),
    );
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

  Future<void> getDetailsShipment(
      {required String? shipmentCode, required bool isMoreDetail}) async {
    context.read<DetailsShipmentBloc>().add(
          HanldeDetailsShipment(
              shipmentCode: shipmentCode, isMoreDetail: isMoreDetail),
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

  Future<void> showDialogDetailsShipment({required String shipmentCode}) async {
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
                          controller: _tabControllerDetailShipment,
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
                            controller: _tabControllerDetailShipment,
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

  Future<void> showDialogMoreDetailShipment({
    required DetailsShipmentModel shipmentdetail,
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
                          physics: const BouncingScrollPhysics(),
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
                                      value: formatter.format(shipmentdetail
                                              .shipment.shipmentFinalAmount ??
                                          0),
                                      valueColor: Colors.green[800],
                                      isBold: true,
                                    ),
                                    _buildInfoRow(
                                      label: 'Thu khách',
                                      value: formatter.format(shipmentdetail
                                              .shipment.shipmentFinalAmount ??
                                          0),
                                    ),
                                    _buildInfoRow(
                                      label: 'Lợi nhuận',
                                      value: formatter.format(shipmentdetail
                                              .shipment.shipmentAmountProfit ??
                                          0),
                                      valueColor: shipmentdetail.shipment
                                                  .shipmentAmountProfit >
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
                                      value: shipmentdetail.shipment.packages
                                          .first.packageQuantity
                                          .toString(),
                                    ),
                                    _buildInfoRow(
                                      label: 'Charge Weight',
                                      value: shipmentdetail.shipment.packages
                                          .first.packageChargedWeight
                                          .toString(),
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
                                              .shipment
                                              .shipmentAmountSurcharge ??
                                          0),
                                    ),
                                    _buildInfoRow(
                                      label: 'Bảo hiểm',
                                      value: formatter.format(shipmentdetail
                                              .shipment
                                              .shipmentAmountInsurance ??
                                          0),
                                    ),
                                    _buildInfoRow(
                                      label: 'Cước gốc',
                                      value: formatter.format(shipmentdetail
                                              .shipment.shipmentAmountService ??
                                          0),
                                    ),
                                    _buildInfoRow(
                                      label: 'Nội địa',
                                      value: formatter.format(shipmentdetail
                                              .shipment
                                              .shipmentDomesticCharges ??
                                          0),
                                    ),
                                    _buildInfoRow(
                                      label: 'VAT',
                                      value: formatter.format(shipmentdetail
                                              .shipment.shipmentAmountVat ??
                                          0),
                                    ),
                                    _buildInfoRow(
                                      label: 'Thu hộ',
                                      value: formatter.format(shipmentdetail
                                              .shipment.shipmentCollectionFee ??
                                          0),
                                    ),
                                    _buildInfoRow(
                                      label: 'CPVH',
                                      value: formatter.format(shipmentdetail
                                              .shipment
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
                                                shipmentdetail
                                                    .shipment.shipmentStatus),
                                          ),
                                          child: Center(
                                            child: TextApp(
                                              fontsize: 14.w,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              text: _getStatusName(
                                                  shipmentdetail
                                                      .shipment.shipmentStatus),
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
                                            color: shipmentdetail.shipment
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
                                              text: shipmentdetail.shipment
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

  Widget _buildInfoRowItem({required IconData icon, required String text}) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextApp(
          text: "Thông tin tài khoản sale",
          fontWeight: FontWeight.bold,
          fontsize: 20.sp,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: GestureDetector(
              onTap: () => _selectMonthYear(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8.r),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextApp(
                      text: _monthYearController.text,
                      fontsize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.calendar_today,
                        size: 16.sp, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<DetailsShipmentBloc, DetailsShipmentState>(
            listener: (context, state) async {
              if (state is DetailsShipmentStateSuccess) {
                detailsShipment = state.detailsShipmentModel;
                Navigator.pop(context);
                if (state.isMoreDetail) {
                  await showDialogMoreDetailShipment(
                      shipmentdetail: detailsShipment!);
                } else {
                  await showDialogDetailsShipment(
                      shipmentCode:
                          state.detailsShipmentModel.shipment.shipmentCode);
                }
              }
            },
          ),
        ],
        child: BlocBuilder<GetSaleLeaderStatisticBloc, SaleManagerState>(
          builder: (context, state) {
            if (state is GetDetailsSaleLeaderLoading) {
              return Center(
                child: SizedBox(
                  width: 100.w,
                  height: 100.w,
                  child: Lottie.asset('assets/lottie/loading_kango.json'),
                ),
              );
            } else if (state is GetDetailsSaleLeaderSuccess) {
              final saleData = state.saleStatisticsResponse;
              final infoSale = saleData.infoSale;
              final saleStatistic = saleData.saleStatistic;

              return Column(
                children: [
                  // TabBar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom:
                            BorderSide(color: Colors.grey.shade100, width: 1),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.black87,
                      indicatorColor: Theme.of(context).primaryColor,
                      indicatorWeight: 3,
                      labelPadding: EdgeInsets.symmetric(
                          horizontal: 8.w), // Reduce padding to fit more text
                      labelStyle: TextStyle(
                        fontFamily: 'OpenSans',
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp, // Reduce font size slightly if needed
                        overflow:
                            TextOverflow.visible, // Prevent text truncation
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontFamily: 'OpenSans',
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        overflow: TextOverflow.visible,
                      ),
                      tabs: const [
                        Tab(text: 'Thống kê'),
                        Tab(text: 'Thưởng KPI'),
                        Tab(text: 'Danh sách\n đơn hàng'),
                      ],
                    ),
                  ),

                  // TabBarView
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Thống kê
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            // Close any open slidable when tapping outside
                            Slidable.of(context)?.close();
                          },
                          child: RefreshIndicator(
                            onRefresh: () async {
                              _reloadList();
                            },
                            child: Container(
                              color: Colors.white,
                              child: SingleChildScrollView(
                                controller: scrollDetailSale,
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  children: [
                                    // User info card
                                    Card(
                                      color: Colors.white,
                                      margin: EdgeInsets.all(16.w),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        side: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // User name header
                                          Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12.h,
                                                horizontal: 16.w),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8.r),
                                                topRight: Radius.circular(8.r),
                                              ),
                                            ),
                                            child: TextApp(
                                              text: infoSale?.userContactName ??
                                                  "",
                                              fontsize: 18.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          // User info details
                                          Padding(
                                            padding: EdgeInsets.all(16.w),
                                            child: Column(
                                              children: [
                                                _buildInfoRow1("Mã account:",
                                                    infoSale?.userCode ?? ""),
                                                SizedBox(height: 8.h),
                                                _buildInfoRow1("Email:",
                                                    infoSale?.userName ?? ""),
                                                SizedBox(height: 8.h),
                                                _buildInfoRow1("Số điện thoại:",
                                                    infoSale?.userPhone ?? ""),
                                                SizedBox(height: 8.h),
                                                _buildInfoRow1("Ngày tạo:",
                                                    infoSale?.createdAt ?? ""),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Statistics card
                                    Card(
                                      color: Colors.white,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 16.w),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        side: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Statistics header
                                          Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12.h,
                                                horizontal: 16.w),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF008080),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8.r),
                                                topRight: Radius.circular(8.r),
                                              ),
                                            ),
                                            child: TextApp(
                                              text: "Thống kê",
                                              fontsize: 18.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          // Statistics details
                                          Padding(
                                            padding: EdgeInsets.all(16.w),
                                            child: Column(
                                              children: [
                                                _buildInfoRow2(
                                                    "Tổng số đơn hàng:",
                                                    "${saleStatistic?.totalShipment ?? 0}"),
                                                SizedBox(height: 12.h),
                                                _buildInfoRow2("Tổng số C.W:",
                                                    "${saleStatistic?.totalChargedWeight ?? 0}"),
                                                SizedBox(height: 12.h),
                                                _buildInfoRow2("Doanh thu:",
                                                    "${formatter.format(saleStatistic?.totalAmountCustomer ?? 0)} đ",
                                                    valueColor:
                                                        const Color.fromRGBO(
                                                            86, 228, 241, 1)),
                                                SizedBox(height: 12.h),
                                                _buildInfoRow2(
                                                    "Lợi nhuận thực tế:",
                                                    "${formatter.format(saleStatistic?.totalAmountProfit ?? 0)} đ",
                                                    valueColor:
                                                        const Color.fromRGBO(
                                                            51, 221, 152, 1)),
                                                SizedBox(height: 12.h),
                                                _buildInfoRow2("Tổng C.W FWD:",
                                                    "${saleStatistic?.weightFwd ?? 0}kg"),
                                                SizedBox(height: 12.h),
                                                _buildInfoRow2(
                                                    "Thưởng FWD Cost:",
                                                    "+${formatter.format(saleStatistic?.costFwdAmount ?? 0)} đ"),
                                                SizedBox(height: 12.h),
                                                infoSale?.rangeKPI != null
                                                    ? Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          _buildInfoRow2(
                                                              "Mức KPI hiện tại:",
                                                              saleStatistic
                                                                      ?.rangeKpiName ??
                                                                  "",
                                                              valueColor:
                                                                  Colors.red),
                                                          SizedBox(
                                                              height: 12.h),
                                                          _buildInfoRow2(
                                                              "Mức lương hiện tại:",
                                                              "${formatter.format(saleStatistic?.salary ?? 0)} đ"),
                                                          SizedBox(
                                                              height: 12.h),
                                                          _buildInfoRow2(
                                                              "Hóa đơn hoa hồng theo KPI:",
                                                              "${saleStatistic?.ratioCommission.toString() ?? 0}%"),
                                                          SizedBox(
                                                              height: 12.h),
                                                          _buildInfoRow2(
                                                              "Mức thưởng KPI tháng Cá nhân:",
                                                              "+${saleStatistic?.commissionAmount.toString() ?? 0} đ"),
                                                          SizedBox(
                                                              height: 12.h),
                                                          saleData.isLeader ==
                                                                  false
                                                              ? Container()
                                                              : _buildInfoRow2(
                                                                  "Thưởng KPI từ Team:",
                                                                  "+${saleStatistic?.commissionLeaderTeam.toString() ?? 0} đ"),
                                                          SizedBox(
                                                              height: 12.h),
                                                          _buildInfoRow2(
                                                              "Thưởng FWD Cost từ Team:",
                                                              "+${saleStatistic?.amountFwd.toString() ?? 0} đ"),
                                                          SizedBox(
                                                              height: 12.h),
                                                          _buildInfoRow2(
                                                              "Total mức lương thực nhận:",
                                                              "+${formatter.format(saleStatistic?.finalSalarySale ?? 0)} đ"),
                                                        ],
                                                      )
                                                    : Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            width: 180.w,
                                                            child: TextApp(
                                                              text: saleStatistic
                                                                      ?.rangeKpiName ??
                                                                  "",
                                                              fontsize: 15.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 16.h),
                                    saleData.isLeader == false
                                        ? Container()
                                        : Card(
                                            color: Colors.white,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 16.w),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              side: BorderSide(
                                                  color: Colors.grey.shade300),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Header with expandable functionality
                                                Container(
                                                  width: double.infinity,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 12.h,
                                                      horizontal: 16.w),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(8.r),
                                                      topRight:
                                                          Radius.circular(8.r),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      TextApp(
                                                        text:
                                                            "Team member (${saleData.saleTeam?.length ?? 0} thành viên)",
                                                        fontsize: 18.sp,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      const Icon(
                                                          Icons
                                                              .keyboard_arrow_up,
                                                          color: Colors.white)
                                                    ],
                                                  ),
                                                ),

                                                // // Table header
                                                // Padding(
                                                //   padding: EdgeInsets.symmetric(
                                                //       vertical: 12.h, horizontal: 8.w),
                                                //   child: SingleChildScrollView(
                                                //     scrollDirection: Axis.horizontal,
                                                //     child: Row(
                                                //       children: [
                                                //         _buildHeaderCell(
                                                //             "Tên Thành Viên", 160.w),
                                                //         _buildHeaderCell("KPI", 140.w),
                                                //         _buildHeaderCell(
                                                //             "Lợi Nhuận Thực Tế", 110.w),
                                                //         _buildHeaderCell(
                                                //             "FWD Weight", 100.w),
                                                //         _buildHeaderCell("FWD Cost", 100.w),
                                                //       ],
                                                //     ),
                                                //   ),
                                                // ),

                                                // Team members list
                                                ListView.separated(
                                                  shrinkWrap: true,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  itemCount: saleData
                                                          .saleTeam?.length ??
                                                      0,
                                                  separatorBuilder: (context,
                                                          index) =>
                                                      const Divider(height: 1),
                                                  itemBuilder:
                                                      (context, index) {
                                                    final member = saleData
                                                        .saleTeam![index];
                                                    return ListTile(
                                                        onTap: () {
                                                          // _slidableController
                                                          //     .openCurrentActionPane();
                                                        },
                                                        title: Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 10.w,
                                                            ),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    TextApp(
                                                                      text: member
                                                                          .userContactName
                                                                          .toString(),
                                                                      fontsize:
                                                                          17.sp,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .primary,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ],
                                                                ),
                                                                member.note ==
                                                                        null
                                                                    ? Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              SizedBox(
                                                                                child: TextApp(
                                                                                  softWrap: true,
                                                                                  isOverFlow: false,
                                                                                  text: "KPI: ",
                                                                                  fontsize: 15.sp,
                                                                                  color: Colors.black87,
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 10.w),
                                                                              SizedBox(
                                                                                child: TextApp(
                                                                                  softWrap: true,
                                                                                  isOverFlow: false,
                                                                                  text: "${member.rangeKpiName ?? ''} ",
                                                                                  fontsize: 15.sp,
                                                                                  color: Colors.black87,
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              SizedBox(
                                                                                child: TextApp(
                                                                                  softWrap: true,
                                                                                  isOverFlow: false,
                                                                                  text:
                                                                                      // "Địa chỉ: ${dataShipment.receiverAddress1}",
                                                                                      "Lợi nhuận thực tế: ",
                                                                                  maxLines: 3,
                                                                                  fontsize: 15.sp,
                                                                                  color: Colors.black87,
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 10.w),
                                                                              SizedBox(
                                                                                child: TextApp(
                                                                                  softWrap: true,
                                                                                  isOverFlow: false,
                                                                                  text:
                                                                                      // "Địa chỉ: ${dataShipment.receiverAddress1}",
                                                                                      "${formatter.format(member.totalProfit ?? 0)} vnđ",
                                                                                  maxLines: 3,
                                                                                  fontsize: 15.sp,
                                                                                  color: Colors.black87,
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              SizedBox(
                                                                                child: TextApp(
                                                                                  softWrap: true,
                                                                                  isOverFlow: false,
                                                                                  text: "FWD Weight: ",
                                                                                  fontsize: 15.sp,
                                                                                  color: Colors.black87,
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 10.w),
                                                                              SizedBox(
                                                                                child: TextApp(
                                                                                  softWrap: true,
                                                                                  isOverFlow: false,
                                                                                  text: "${member.totalWeight ?? 0} kg",
                                                                                  fontsize: 15.sp,
                                                                                  color: Colors.black87,
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              SizedBox(
                                                                                child: TextApp(
                                                                                  softWrap: true,
                                                                                  isOverFlow: false,
                                                                                  text: "FWD Cost: ",
                                                                                  fontsize: 15.sp,
                                                                                  color: Colors.black87,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 10.w,
                                                                              ),
                                                                              SizedBox(
                                                                                child: TextApp(
                                                                                  softWrap: true,
                                                                                  isOverFlow: false,
                                                                                  text: "${member.fwdCost ?? 0} vnđ",
                                                                                  fontsize: 15.sp,
                                                                                  color: Colors.black87,
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                320.w,
                                                                            child:
                                                                                TextApp(
                                                                              softWrap: true,
                                                                              isOverFlow: false,
                                                                              text: '*${member.note.toString()}',
                                                                              fontsize: 15.sp,
                                                                              color: Colors.red,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                              ],
                                                            )
                                                          ],
                                                        ));
                                                  },
                                                ),

                                                // Summary cards
                                                Padding(
                                                  padding: EdgeInsets.all(16.w),
                                                  child: Column(
                                                    children: [
                                                      SizedBox(height: 8.h),
                                                      Column(
                                                        children: [
                                                          _buildSummaryCard(
                                                              "Lợi nhuận",
                                                              "${saleData.totalTeam?.teamProfit ?? 0} VND"),
                                                          SizedBox(
                                                              height: 12.h),
                                                          _buildSummaryCard(
                                                              "FWD Weight",
                                                              "${saleData.totalTeam?.teamFwdWeight ?? 0} KG"),
                                                          SizedBox(
                                                              height: 12.h),
                                                          _buildSummaryCard(
                                                            "FWD Cost",
                                                            "${saleData.totalTeam?.teamFwdCost ?? 0} VND",
                                                            valueColor:
                                                                Colors.green,
                                                          ),
                                                        ],
                                                      )
                                                      //  Column(
                                                      //     children: [
                                                      //       _buildSummaryCard(
                                                      //           "Lợi nhuận",
                                                      //           "${saleData.totalTeam?.teamProfit ?? 0} VND"),
                                                      //       SizedBox(height: 12.h),
                                                      //       _buildSummaryCard(
                                                      //           "FWD Weight",
                                                      //           "${saleData.totalTeam?.teamFwdWeight ?? 0} KG"),
                                                      //       SizedBox(height: 12.h),
                                                      //       _buildSummaryCard(
                                                      //         "FWD Cost",
                                                      //         "${saleData.totalTeam?.teamFwdCost ?? 0} VND",
                                                      //         valueColor: Colors.green,
                                                      //       ),
                                                      //     ],
                                                      //   ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                    SizedBox(height: 16.h),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Tab 2: Thưởng KPI

                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            // Close any open slidable when tapping outside
                            Slidable.of(context)?.close();
                          },
                          child: RefreshIndicator(
                            onRefresh: () async {
                              _reloadList();
                            },
                            child: saleData.infoSale?.rangeKPI == null
                                ? Container(
                                    child: Center(
                                      child: TextApp(
                                        text: 'Sale chưa được gắn KPI',
                                        fontsize: 16.sp,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: Colors.white,
                                    child: SingleChildScrollView(
                                      controller: scrollKpiSale,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      child: Column(
                                        children: [
                                          SizedBox(height: 16.h),
                                          saleData.kpi?.rangeKpis?.isNotEmpty ??
                                                  false
                                              ? Card(
                                                  color: Colors.white,
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 16.w),
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.r),
                                                    side: BorderSide(
                                                        color: Colors
                                                            .grey.shade300),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Header with expandable functionality
                                                      Container(
                                                        width: double.infinity,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 12.h,
                                                                horizontal:
                                                                    16.w),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    8.r),
                                                            topRight:
                                                                Radius.circular(
                                                                    8.r),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                              width: 350.w,
                                                              child: TextApp(
                                                                text: saleData
                                                                        .kpi
                                                                        ?.kpiName ??
                                                                    "",
                                                                maxLines: 2,
                                                                fontsize: 18.sp,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      // Team members list
                                                      ListView.separated(
                                                        shrinkWrap: true,
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        itemCount: saleData
                                                                .kpi
                                                                ?.rangeKpis!
                                                                .length ??
                                                            0,
                                                        separatorBuilder:
                                                            (context, index) =>
                                                                const Divider(
                                                                    height: 1),
                                                        itemBuilder:
                                                            (context, index) {
                                                          final kpi = saleData
                                                                  .kpi
                                                                  ?.rangeKpis![
                                                              index];
                                                          return ListTile(
                                                              onTap: () {
                                                                // _slidableController
                                                                //     .openCurrentActionPane();
                                                              },
                                                              title: Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: 10.w,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          TextApp(
                                                                            text:
                                                                                kpi?.rangeKpiName ?? "",
                                                                            fontsize:
                                                                                17.sp,
                                                                            color:
                                                                                Theme.of(context).colorScheme.primary,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          SizedBox(
                                                                            child:
                                                                                TextApp(
                                                                              softWrap: true,
                                                                              isOverFlow: false,
                                                                              text: "Mức lương: ",
                                                                              fontsize: 15.sp,
                                                                              color: Colors.black87,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              width: 10.w),
                                                                          SizedBox(
                                                                            child:
                                                                                TextApp(
                                                                              softWrap: true,
                                                                              isOverFlow: false,
                                                                              text: "${formatter.format(kpi?.salary ?? 0)} đ",
                                                                              fontsize: 15.sp,
                                                                              color: Colors.black87,
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          SizedBox(
                                                                            child:
                                                                                TextApp(
                                                                              softWrap: true,
                                                                              isOverFlow: false,
                                                                              text:
                                                                                  // "Địa chỉ: ${dataShipment.receiverAddress1}",
                                                                                  "Hạn mức: ",
                                                                              maxLines: 3,
                                                                              fontsize: 15.sp,
                                                                              color: Colors.black87,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              width: 10.w),
                                                                          SizedBox(
                                                                            child:
                                                                                TextApp(
                                                                              softWrap: true,
                                                                              isOverFlow: false,
                                                                              text:
                                                                                  // "Địa chỉ: ${dataShipment.receiverAddress1}",
                                                                                  "${formatter.format(kpi?.profitStart ?? 0)} - ${formatter.format(kpi?.profitEnd ?? 0)}",
                                                                              maxLines: 3,
                                                                              fontsize: 15.sp,
                                                                              color: Colors.black87,
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          SizedBox(
                                                                            child:
                                                                                TextApp(
                                                                              softWrap: true,
                                                                              isOverFlow: false,
                                                                              text: "Hoa hồng: ",
                                                                              fontsize: 15.sp,
                                                                              color: Colors.black87,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              width: 10.w),
                                                                          SizedBox(
                                                                            child:
                                                                                TextApp(
                                                                              softWrap: true,
                                                                              isOverFlow: false,
                                                                              text: "${kpi?.ratioCommission ?? 0}%",
                                                                              fontsize: 15.sp,
                                                                              color: Colors.black87,
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              ));
                                                        },
                                                      ),

                                                      // Summary cards
                                                    ],
                                                  ),
                                                )
                                              : Column(
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
                                                            fit:
                                                                BoxFit.contain),
                                                      ),
                                                    ),
                                                    TextApp(
                                                      text:
                                                          "Không tìm thấy KPI !",
                                                      fontsize: 18.sp,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ],
                                                ),
                                          SizedBox(height: 16.h),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ),

                        // Tab 3: Danh sách đơn hàng
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            // Close any open slidable when tapping outside
                            Slidable.of(context)?.close();
                          },
                          child: RefreshIndicator(
                            color: Theme.of(context).colorScheme.primary,
                            onRefresh: () async {
                              _reloadList();
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
                                                fontSize: 12,
                                                color: Colors.black),
                                            cursorColor: Colors.black,
                                            onFieldSubmitted: (value) {
                                              searchProduct(
                                                  textSearchController.text);
                                            },
                                            decoration: InputDecoration(
                                                suffixIcon: InkWell(
                                                  onTap: () {
                                                    searchProduct(
                                                        textSearchController
                                                            .text);
                                                  },
                                                  child:
                                                      const Icon(Icons.search),
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
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
                                                isDense: true,
                                                hintText: "Tìm kiếm...",
                                                contentPadding:
                                                    const EdgeInsets.all(15)),
                                          ),
                                        ),
                                      ],
                                    )),
                                Expanded(
                                  child: SingleChildScrollView(
                                    controller:
                                        scrollListShipmentSaleController,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                            width: 1.sw,
                                            child: BlocBuilder<
                                                    GetListShipmentSaleBloc,
                                                    SaleManagerState>(
                                                builder: (context, state) {
                                              if (state
                                                  is GetShipmentsSaleLeaderStateLoading) {
                                                return Center(
                                                  child: SizedBox(
                                                    width: 100.w,
                                                    height: 100.w,
                                                    child: Lottie.asset(
                                                        'assets/lottie/loading_kango.json'),
                                                  ),
                                                );
                                              } else if (state
                                                  is GetShipmentsSaleLeaderStateSuccess) {
                                                // Cập nhật _shipmentsSaleData từ state.data
                                                _shipmentsSaleData = state.data;

                                                if (_shipmentsSaleData
                                                    .isEmpty) {
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Center(
                                                        child: SizedBox(
                                                          width: 200.w,
                                                          height: 200.w,
                                                          child: Lottie.asset(
                                                              'assets/lottie/empty_box.json',
                                                              fit: BoxFit
                                                                  .contain),
                                                        ),
                                                      ),
                                                      TextApp(
                                                        text:
                                                            "Không tìm thấy đơn hàng !",
                                                        fontsize: 18.sp,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ],
                                                  );
                                                }
                                                return ListView.builder(
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    itemCount: state
                                                            .hasReachedMax
                                                        ? state.data.length
                                                        : state.data.length + 1,
                                                    itemBuilder:
                                                        (context, index) {
                                                      if (index >=
                                                          _shipmentsSaleData
                                                              .length) {
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
                                                            _shipmentsSaleData[
                                                                index];
                                                        return Column(
                                                          children: [
                                                            const Divider(
                                                              height: 1,
                                                            ),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          8.h,
                                                                      horizontal:
                                                                          16.w),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
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
                                                                    spreadRadius:
                                                                        1,
                                                                    blurRadius:
                                                                        4,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            2),
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
                                                                          showDialog(
                                                                            context:
                                                                                context,
                                                                            barrierDismissible:
                                                                                false,
                                                                            builder: (context) =>
                                                                                Center(
                                                                              child: SizedBox(
                                                                                width: 100.w,
                                                                                height: 100.w,
                                                                                child: Lottie.asset('assets/lottie/loading_kango.json'),
                                                                              ),
                                                                            ),
                                                                          );
                                                                          await Future.delayed(
                                                                              Duration.zero);
                                                                          getDetailsShipment(
                                                                              shipmentCode: dataShipment.shipmentCode,
                                                                              isMoreDetail: true);
                                                                        },
                                                                        backgroundColor: Theme.of(context)
                                                                            .colorScheme
                                                                            .primary,
                                                                        foregroundColor:
                                                                            Colors.white,
                                                                        child:
                                                                            const Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
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
                                                                    ],
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    width: double
                                                                        .infinity,
                                                                    padding: EdgeInsets
                                                                        .all(16
                                                                            .r),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
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
                                                                              EdgeInsets.all(8.r),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                _getStatusColor(dataShipment.shipmentStatus!).withOpacity(0.1),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.r),
                                                                          ),
                                                                          child:
                                                                              Icon(
                                                                            _getStatusIcon(dataShipment.shipmentStatus!),
                                                                            color:
                                                                                _getStatusColor(dataShipment.shipmentStatus!),
                                                                            size:
                                                                                36.sp,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                12.w),

                                                                        // Main Content
                                                                        Expanded(
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              // Header
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  InkWell(
                                                                                    onTap: () async {
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
                                                                              SizedBox(height: 8.h),

                                                                              // Details
                                                                              _buildInfoRowItem(icon: Icons.person, text: "Người nhận: ${dataShipment.receiverContactName}"),
                                                                              SizedBox(height: 6.h),
                                                                              _buildInfoRowItem(icon: Icons.store, text: "Chi nhánh: ${_getNameBranch(dataShipment.shipmentBranchId ?? 0)}"),

                                                                              SizedBox(height: 6.h),
                                                                              SizedBox(height: 6.h),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Expanded(
                                                                                    child: _buildInfoRowItem(icon: Icons.local_shipping_rounded, text: "Dịch vụ: ${dataShipment.service.serviceName}"),
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
                                                    });
                                              } else if (state
                                                  is GetShipmentsSaleLeaderStateFailure) {
                                                return Center(
                                                  child: TextApp(
                                                    text: state.message,
                                                    fontsize: 16.sp,
                                                    color: Colors.red,
                                                  ),
                                                );
                                              }
                                              return Column(
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
                                              );
                                            }))
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            } else if (state is GetDetailsSaleLeaderFailure) {
              return AlertDialog(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.w),
                ),
                actionsPadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.only(
                    top: 35.w, bottom: 30.w, left: 35.w, right: 35.w),
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
                        width: 250.w,
                        height: 250.w,
                        child: Lottie.asset('assets/lottie/error_dialog.json',
                            fit: BoxFit.contain),
                      ),
                    ),
                    TextApp(
                      text: state.message,
                      fontsize: 18.sp,
                      softWrap: true,
                      isOverFlow: false,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    // Container(
                    //   width: 150.w,
                    //   height: 50.h,
                    //   child: ButtonApp(
                    //     event: () {},
                    //     text: "Xác nhận",
                    //     fontsize: 14.sp,
                    //     colorText: Colors.white,
                    //     backgroundColor: Colors.black,
                    //     outlineColor: Colors.black,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SizedBox(
                    width: 200.w,
                    height: 200.w,
                    child: Lottie.asset('assets/lottie/empty_box.json',
                        fit: BoxFit.contain),
                  ),
                ),
                TextApp(
                  text: "Không tìm thấy đơn hàng !",
                  fontsize: 18.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, {Color? valueColor}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextApp(
            text: title,
            fontsize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          SizedBox(height: 8.h),
          TextApp(
            text: value,
            fontsize: 15.sp,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow1(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140.w,
          child: TextApp(
            text: label,
            fontsize: 15.sp,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: TextApp(
            text: value,
            fontsize: 15.sp,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow2(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 180.w,
          child: TextApp(
            text: label,
            fontsize: 15.sp,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: TextApp(
            text: value,
            fontsize: 15.sp,
            color: valueColor ?? Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
