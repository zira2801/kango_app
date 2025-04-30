import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/scan/list_scan/list_scan_import/list_scan_import_bloc.dart';
import 'package:scan_barcode_app/bloc/wallet_fluctuations/wallet_fluctuations_bloc.dart';
import 'package:scan_barcode_app/data/models/wallet_fluctution/wallet_fluctution.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/shipment/fillter_wallet_fluctuation.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/utils/date_time_picker.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class WalletFluctuationsScreen extends StatefulWidget {
  const WalletFluctuationsScreen({super.key});

  @override
  State<WalletFluctuationsScreen> createState() =>
      _WalletFluctuationsScreenState();
}

class _WalletFluctuationsScreenState extends State<WalletFluctuationsScreen> {
  final textSearchController = TextEditingController();
  final statusTextController = TextEditingController();
  final scrollListWalletFluctuationsController = ScrollController();

  final TextEditingController _dateStartController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();
  DateTime? _startDate; //type ngày bắt đầu
  DateTime? _endDate; //type ngày kết thúc
  String? _endDateError; //text lỗi khi ngày kết thúc nhỏ hơn ngày bắt đầu
  String query = '';
  List<String> listStatus = [
    "Cộng tiền",
    "Trừ tiền",
  ];
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();

    BlocProvider.of<GetListWalletFluctuationsBloc>(context).add(
        const FetchListWalletFluctuations(
            keywords: null, startDate: null, endDate: null, kind: null));

    scrollListWalletFluctuationsController.addListener(_onScroll);
  }

  void _onScroll() {
    final String formattedStartDate = formatStartDateForAPI(_startDate);
    final String formattedEndDate = formatEndDateForAPI(_endDate);

    log('Start date formatted: $formattedStartDate');
    log('End date formatted: $formattedEndDate');

    if (scrollListWalletFluctuationsController.position.maxScrollExtent ==
        scrollListWalletFluctuationsController.offset) {
      BlocProvider.of<GetListWalletFluctuationsBloc>(context)
          .add(LoadMoreListWalletFluctuations(
        keywords: query,
        startDate: formattedStartDate.isNotEmpty ? formattedStartDate : null,
        endDate: formattedEndDate.isNotEmpty ? formattedEndDate : null,
        kind: listStatus.indexOf(statusTextController.text) == -1
            ? null
            : listStatus.indexOf(statusTextController.text),
      ));
    }
  }

  @override
  void dispose() {
    textSearchController.dispose();
    scrollListWalletFluctuationsController.dispose();
    super.dispose();
  }

  String formatCurrency(num amount) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '');
    return format.format(amount);
  }

  void searchProduct(String query) {
    final String formattedStartDate = formatStartDateForAPI(_startDate);
    final String formattedEndDate = formatEndDateForAPI(_endDate);

    log('Start date formatted: $formattedStartDate');
    log('End date formatted: $formattedEndDate');

    mounted
        ? setState(() {
            this.query = query;
            BlocProvider.of<GetListWalletFluctuationsBloc>(context)
                .add(FetchListWalletFluctuations(
              keywords: query,
              startDate:
                  formattedStartDate.isNotEmpty ? formattedStartDate : null,
              endDate: formattedEndDate.isNotEmpty ? formattedEndDate : null,
              kind: listStatus.indexOf(statusTextController.text) == -1
                  ? null
                  : listStatus.indexOf(statusTextController.text),
            ));
          })
        : null;
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

  String _getStatusName(int kind) {
    const statusMap = {
      0: 'Cộng tiền',
      1: 'Trừ tiền',
    };
    return statusMap[kind] ?? 'Unknown';
  }

  Color _getStatusColor(int kind) {
    const statusMap = {
      0: Color.fromRGBO(0, 214, 127, 1),
      1: Colors.red,
    };
    return statusMap[kind] ?? Colors.grey;
  }

  IconData _getIconStatus(int kind) {
    const statusMap = {
      0: Icons.add_circle_sharp,
      1: Icons.remove_circle,
    };
    return statusMap[kind] ?? Icons.question_mark;
  }

  Color _getStatusColorIcon(int kind) {
    const statusMap = {
      0: Color.fromRGBO(0, 214, 127, 1),
      1: Colors.red,
    };
    return statusMap[kind] ?? Colors.grey;
  }

  void showDialogMoreDetailWalletFluctuation(
      {required WalletFluctuation data}) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20.r),
          topLeft: Radius.circular(20.r),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          maxChildSize: 0.85,
          initialChildSize: 0.7,
          minChildSize: 0.3,
          expand: false,
          builder: (BuildContext context,
              ScrollController scrollControllerMoreInfor) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15.r),
                            bottomRight: Radius.circular(15.r),
                          ),
                        ),
                        child: Column(
                          children: [
                            TextApp(
                              text: 'Thông tin chi tiết',
                              fontsize: 18.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: TextApp(
                                text: data.secureHash,
                                fontsize: 14.sp,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollControllerMoreInfor,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoCard(
                                context,
                                children: [
                                  _buildInfoRow(
                                    icon: Icons.account_circle_outlined,
                                    title: 'Tài khoản',
                                    value:
                                        "${data.userContactName} [${data.userCode}]",
                                  ),
                                  SizedBox(height: 16.h),
                                  _buildInfoRow(
                                    icon: Icons.account_balance_wallet_outlined,
                                    title: 'Loại TK',
                                    customValue: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w, vertical: 6.h),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        color:
                                            _getPositionColor(data.positionId),
                                      ),
                                      child: TextApp(
                                        fontsize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        text: _getPositionName(data.positionId),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  _buildInfoRow(
                                    icon: Icons.info_outline,
                                    title: 'Trạng thái',
                                    customValue: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w, vertical: 6.h),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        color: _getStatusColor(data.kind),
                                      ),
                                      child: TextApp(
                                        fontsize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        text: _getStatusName(data.kind),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              _buildInfoCard(
                                context,
                                children: [
                                  _buildInfoRow(
                                    icon: Icons.payments_outlined,
                                    title: 'Số tiền',
                                    value: formatCurrency(data.amount),
                                    valueColor: data.kind == 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  SizedBox(height: 16.h),
                                  _buildInfoRow(
                                    icon: Icons.account_balance_outlined,
                                    title: 'Số dư ví',
                                    value: formatCurrency(data.walletAmount),
                                  ),
                                  SizedBox(height: 16.h),
                                  _buildInfoRow(
                                    icon: Icons.calendar_today_outlined,
                                    title: 'Ngày tạo',
                                    value: formatDateTime(
                                        data.createdAt.toString()),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              _buildInfoCard(
                                context,
                                children: [
                                  TextApp(
                                    text: "Nội dung",
                                    fontsize: 16.sp,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  SizedBox(height: 12.h),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: TextApp(
                                      text: data.content,
                                      fontsize: 15.sp,
                                      color: Colors.black87,
                                      maxLines: 50,
                                      isOverFlow: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Bottom padding
                      SizedBox(height: 20.h),
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

// Helper function to build info cards
  Widget _buildInfoCard(BuildContext context,
      {required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

// Helper function to build info rows
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    String? value,
    Widget? customValue,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 25.sp,
            color: Colors.black54,
          ),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextApp(
              text: title,
              fontsize: 14.sp,
              color: Colors.black54,
            ),
            SizedBox(height: 4.h),
            customValue ??
                TextApp(
                  text: value ?? "",
                  fontsize: 16.sp,
                  color: valueColor ?? Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
          ],
        ),
      ],
    );
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

    BlocProvider.of<GetListWalletFluctuationsBloc>(context)
        .add(FetchListWalletFluctuations(
      kind: listStatus.indexOf(statusTextController.text) == -1
          ? null
          : listStatus.indexOf(statusTextController.text),
      startDate: formattedStartDate.isNotEmpty ? formattedStartDate : null,
      endDate: formattedEndDate.isNotEmpty ? formattedEndDate : null,
      keywords: query,
    ));
  }

  Future<void> clearFilterFuntion() async {
    setState(() {
      _endDateError = null;
      statusTextController.clear();
      _dateStartController.clear();
      _dateEndController.clear();
      _startDate = null;
      _endDate = null;
    });
    Navigator.pop(context);
    BlocProvider.of<GetListWalletFluctuationsBloc>(context)
        .add(FetchListWalletFluctuations(
      kind: null,
      startDate: null,
      endDate: null,
      keywords: query,
    ));
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

  @override
  Widget build(BuildContext context) {
    final bool? isShipper = StorageUtils.instance.getBool(key: 'is_shipper');
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          shadowColor: Colors.white,
          surfaceTintColor: Colors.white,
          iconTheme: const IconThemeData(
            color: Colors.black, //change your color here
          ),
          title: TextApp(
            text: "Biến động số dư ví",
            fontsize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        body: BlocBuilder<GetListWalletFluctuationsBloc,
            HandleGetWalletFluctuationState>(
          builder: (context, state) {
            if (state is HandleGetWalletFluctuationStateloading) {
              return Center(
                child: SizedBox(
                  width: 100.w,
                  height: 100.w,
                  child: Lottie.asset('assets/lottie/loading_kango.json'),
                ),
              );
            } else if (state is HandleGetWalletFluctuationStateSuccess) {
              return SlidableAutoCloseBehavior(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Slidable.of(context)?.close();
                  },
                  child: RefreshIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    onRefresh: () async {
                      _dateStartController.clear();
                      _dateEndController.clear();
                      _startDate = null;
                      _endDate = null;
                      statusTextController.clear();
                      BlocProvider.of<GetListWalletFluctuationsBloc>(context)
                          .add(const FetchListWalletFluctuations(
                              keywords: null,
                              startDate: null,
                              endDate: null,
                              kind: null));
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                width: 1.sw,
                                padding: EdgeInsets.all(10.w),
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
                                  onFieldSubmitted: (value) =>
                                      searchProduct(value),
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
                            ),
                            SizedBox(
                              width: 15.w,
                            ),
                            FilterWalletFluctuationWidget(
                                isPakageManger: false,
                                dateStartController: _dateStartController,
                                dateEndController: _dateEndController,
                                statusTextController: statusTextController,
                                listStatus: listStatus,
                                selectDayStart: selectDayStart,
                                selectDayEnd: selectDayEnd,
                                getEndDateError: () => _endDateError,
                                clearFliterFunction: clearFilterFuntion,
                                applyFliterFunction: applyFilterFuntion),
                            SizedBox(
                              width: 15.w,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollListWalletFluctuationsController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                state.data.isEmpty
                                    ? const NoDataFoundWidget()
                                    : ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: state.hasReachedMax
                                            ? state.data.length
                                            : state.data.length + 1,
                                        itemBuilder: (context, index) {
                                          if (index >= state.data.length) {
                                            return Center(
                                              child: SizedBox(
                                                width: 60.w,
                                                height: 60.w,
                                                child: Lottie.asset(
                                                    'assets/lottie/loading_kango.json'),
                                              ),
                                            );
                                          } else {
                                            final walletData =
                                                state.data[index];
                                            return Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16.w,
                                                  vertical: 8.h),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.r),
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 8,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.r),
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: () {
                                                        showDialogMoreDetailWalletFluctuation(
                                                            data: walletData);
                                                      },
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            16.w),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            // Icon transaction type
                                                            Container(
                                                              width: 50.w,
                                                              height: 50.w,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: _getStatusColorIcon(
                                                                        walletData
                                                                            .kind)
                                                                    .withOpacity(
                                                                        0.15),
                                                              ),
                                                              child: Center(
                                                                child: Icon(
                                                                  _getIconStatus(
                                                                      walletData
                                                                          .kind),
                                                                  color: _getStatusColorIcon(
                                                                      walletData
                                                                          .kind),
                                                                  size: 24.sp,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: 16.w),

                                                            // Transaction details
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  // Transaction ID and status
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            TextApp(
                                                                          text:
                                                                              walletData.secureHash,
                                                                          fontsize:
                                                                              15.sp,
                                                                          color: Colors
                                                                              .black
                                                                              .withOpacity(0.85),
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          maxLines:
                                                                              1,
                                                                          isOverFlow:
                                                                              true,
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        padding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                8.w,
                                                                            vertical: 4.h),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              _getStatusColorIcon(walletData.kind).withOpacity(0.1),
                                                                          borderRadius:
                                                                              BorderRadius.circular(12.r),
                                                                        ),
                                                                        child:
                                                                            TextApp(
                                                                          text:
                                                                              _getStatusName(walletData.kind),
                                                                          fontsize:
                                                                              13.sp,
                                                                          color:
                                                                              _getStatusColorIcon(walletData.kind),
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          6.h),

                                                                  // User info
                                                                  Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .person_outline_rounded,
                                                                        size: 16
                                                                            .sp,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade600,
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              4.w),
                                                                      Expanded(
                                                                        child:
                                                                            TextApp(
                                                                          text:
                                                                              "${walletData.userContactName} [${walletData.userCode}]",
                                                                          fontsize:
                                                                              13.sp,
                                                                          color: Colors
                                                                              .grey
                                                                              .shade700,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                          maxLines:
                                                                              1,
                                                                          isOverFlow:
                                                                              true,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          4.h),

                                                                  // Account type
                                                                  Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .account_balance_wallet_outlined,
                                                                        size: 16
                                                                            .sp,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade600,
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              4.w),
                                                                      Expanded(
                                                                        child:
                                                                            TextApp(
                                                                          text:
                                                                              _getPositionName(walletData.positionId),
                                                                          fontsize:
                                                                              13.sp,
                                                                          color: Colors
                                                                              .grey
                                                                              .shade700,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                          maxLines:
                                                                              1,
                                                                          isOverFlow:
                                                                              true,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          8.h),

                                                                  // Amount and date in separate rows
                                                                  Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal: 10
                                                                            .w,
                                                                        vertical:
                                                                            6.h),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade100,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.r),
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .payments_outlined,
                                                                          size:
                                                                              16.sp,
                                                                          color:
                                                                              _getStatusColorIcon(walletData.kind),
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                4.w),
                                                                        TextApp(
                                                                          text:
                                                                              formatCurrency(walletData.amount),
                                                                          fontsize:
                                                                              14.sp,
                                                                          color:
                                                                              _getStatusColorIcon(walletData.kind),
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          6.h),

                                                                  // Date information
                                                                  Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .access_time_rounded,
                                                                        size: 14
                                                                            .sp,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade500,
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              4.w),
                                                                      TextApp(
                                                                        text: formatDateTime(walletData
                                                                            .createdAt
                                                                            .toString()),
                                                                        fontsize:
                                                                            12.sp,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade500,
                                                                        fontWeight:
                                                                            FontWeight.w400,
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
                                              ),
                                            );
                                          }
                                        },
                                      ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is HandleGetWalletFluctuationStateFailure) {
              return ErrorDialog(
                eventConfirm: () {
                  Navigator.pop(context);
                },
                errorText: 'Failed to fetch orders: ${state.message}',
              );
            }
            return const Center(child: NoDataFoundWidget());
          },
        ));
  }
}
