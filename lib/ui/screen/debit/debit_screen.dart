import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/debit/debit_bloc.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/debit/detail_debit_screen.dart';
import 'package:scan_barcode_app/ui/screen/shipment/fillter_wallet_fluctuation.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/utils/date_time_picker.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class DebitScreen extends StatefulWidget {
  const DebitScreen({super.key});

  @override
  State<DebitScreen> createState() => _DebitScreenState();
}

class _DebitScreenState extends State<DebitScreen> {
  final textSearchController = TextEditingController();
  final statusTextController = TextEditingController();
  final scrollListDebitsController = ScrollController();

  final TextEditingController keyController = TextEditingController();
  final TextEditingController _dateStartController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();
  DateTime? _startDate; //type ngày bắt đầu
  DateTime? _endDate; //type ngày kết thúc
  String? _endDateError; //text lỗi khi ngày kết thúc nhỏ hơn ngày bắt đầu
  String query = '';
  List<String> listStatus = [
    "Chưa thanh toán",
    "Đã thanh toán",
    "Quá hạn",
    "Đang chờ duyệt"
  ];
  bool isAuthenticated = false;
  bool isLoading = false;
  // Thời gian hết hạn 3 giờ = 3 * 60 * 60 = 10800 giây
  final int authenticationExpiryDuration = 10800; // 3 giờ tính bằng giây
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();

    final String? userAccountKeyText =
        StorageUtils.instance.getString(key: 'userAccountantKey');

    keyController.text = userAccountKeyText ?? '';
// Check if user is already authenticated
    checkAuthentication();
    // BlocProvider.of<GetListDebitBloc>(context).add(const FetchListDebit(
    //     keywords: null, startDate: null, endDate: null, debitStatus: null));

    scrollListDebitsController.addListener(_onScroll);
  }

  void checkAuthentication() {
    final bool? userAccountKey =
        StorageUtils.instance.getBool(key: 'userAccountKey');
    final int? authTimestamp =
        StorageUtils.instance.getInt(key: 'authTimestamp');
    final int currentTime =
        DateTime.now().millisecondsSinceEpoch ~/ 1000; // Đổi ra giây

    // Kiểm tra xem người dùng đã xác thực và thời gian xác thực còn hiệu lực không
    if (userAccountKey == true && authTimestamp != null) {
      if (currentTime - authTimestamp < authenticationExpiryDuration) {
        // Thời gian xác thực vẫn còn hiệu lực
        setState(() {
          isAuthenticated = true;
        });
        loadData();
      } else {
        // Thời gian xác thực đã hết hạn, xóa dữ liệu xác thực
        StorageUtils.instance.setBool(key: 'userAccountKey', val: false);
        StorageUtils.instance.removeKey(key: 'authTimestamp');
        setState(() {
          isAuthenticated = false;
        });
      }
    }
  }

  void loadData() {
    BlocProvider.of<GetListDebitBloc>(context).add(const FetchListDebit(
        keywords: null, startDate: null, endDate: null, debitStatus: null));
  }

  void authenticateUser() {
    // Simulate authentication check
    Future.delayed(const Duration(seconds: 1), () {
      // Gửi sự kiện đến CheckAccountainCodeDebitBloc
      BlocProvider.of<CheckAccountainCodeDebitBloc>(context)
          .add(CheckAccountainCodeDebit(key: keyController.text));
    });
  }

  void _onScroll() {
    final String formattedStartDate = formatStartDateForAPI(_startDate);
    final String formattedEndDate = formatEndDateForAPI(_endDate);

    log('Start date formatted: $formattedStartDate');
    log('End date formatted: $formattedEndDate');

    if (scrollListDebitsController.position.maxScrollExtent ==
        scrollListDebitsController.offset) {
      BlocProvider.of<GetListDebitBloc>(context).add(LoadMoreListDebit(
        keywords: query,
        startDate: formattedStartDate.isNotEmpty ? formattedStartDate : null,
        endDate: formattedEndDate.isNotEmpty ? formattedEndDate : null,
        debitStatus: listStatus.indexOf(statusTextController.text) == -1
            ? null
            : listStatus.indexOf(statusTextController.text),
      ));
    }
  }

  @override
  void dispose() {
    textSearchController.dispose();
    scrollListDebitsController.dispose();
    keyController.dispose();
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
            BlocProvider.of<GetListDebitBloc>(context).add(FetchListDebit(
              keywords: query,
              startDate:
                  formattedStartDate.isNotEmpty ? formattedStartDate : null,
              endDate: formattedEndDate.isNotEmpty ? formattedEndDate : null,
              debitStatus: listStatus.indexOf(statusTextController.text) == -1
                  ? null
                  : listStatus.indexOf(statusTextController.text),
            ));
          })
        : null;
  }

  Color _getStatusColor(int status) {
    const statusMap = {
      0: Colors.grey,
      1: Color.fromRGBO(0, 214, 127, 1),
      2: Colors.red,
      3: Colors.amber
    };
    return statusMap[status] ?? Colors.grey;
  }

  IconData _getIconStatus(int status) {
    const statusMap = {
      0: Icons.access_time_rounded,
      1: Icons.check_circle,
      2: Icons.timer_off_outlined,
      3: Icons.safety_check_sharp
    };
    return statusMap[status] ?? Icons.question_mark;
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
    final String formattedStartDate = formatStartDateForAPI(_startDate);
    final String formattedEndDate = formatEndDateForAPI(_endDate);

    log('Start date formatted: $formattedStartDate');
    log('End date formatted: $formattedEndDate');

    Navigator.pop(context);

    BlocProvider.of<GetListDebitBloc>(context).add(FetchListDebit(
      debitStatus: listStatus.indexOf(statusTextController.text) == -1
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
    BlocProvider.of<GetListDebitBloc>(context).add(FetchListDebit(
      debitStatus: null,
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

// Authentication form widget
  Widget _buildAuthenticationForm() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16.w),
        width: 0.8.sw,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.h),
            TextApp(
              text: "Xác thực tài khoản",
              fontsize: 22.sp,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 30.h),
            TextApp(
              text: "Vui lòng nhập mã kế toán để tiếp tục",
              fontsize: 16.sp,
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
            SizedBox(height: 20.h),
            TextFormField(
              obscureText: true,
              style: TextStyle(fontSize: 16.w, fontFamily: "OpenSans"),
              controller: keyController,
              decoration: InputDecoration(
                label: TextApp(
                  text: "Mã kế toán",
                  fontsize: 15.w,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 30.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : authenticateUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : TextApp(
                        text: "Xác thực",
                        fontsize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            text: "Debit Chuyên tuyến",
            fontsize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        body: MultiBlocListener(
          listeners: [
            BlocListener<CheckAccountainCodeDebitBloc,
                CheckAccountainCodeDebitState>(
              listener: (context, state) {
                if (state is CheckAccountainCodeDebitloading) {
                  setState(() {
                    isLoading = true;
                  });
                } else if (state is CheckAccountainCodeDebitSuccess) {
                  showCustomDialogModal(
                      context: context,
                      textDesc: state.message,
                      title: "Thông báo",
                      colorButtonOk: Colors.green,
                      btnOKText: "Đóng",
                      typeDialog: "success",
                      eventButtonOKPress: () {},
                      isTwoButton: false);

                  setState(() {
                    isLoading = false;
                    isAuthenticated = true;
                  });
                  StorageUtils.instance
                      .setBool(key: 'userAccountKey', val: true);
                  StorageUtils.instance.setString(
                      key: 'userAccountantKey', val: keyController.text);
                  final int currentTimestamp =
                      DateTime.now().millisecondsSinceEpoch ~/ 1000;
                  StorageUtils.instance
                      .setInt(key: 'authTimestamp', val: currentTimestamp);
                  loadData();
                } else if (state is CheckAccountainCodeDebitFailure) {
                  setState(() {
                    isLoading = false;
                  });
                  showCustomDialogModal(
                      context: context,
                      textDesc: state.message,
                      title: "Lỗi xác thực",
                      colorButtonOk: Colors.red,
                      btnOKText: "Đóng",
                      typeDialog: "error",
                      eventButtonOKPress: () {},
                      isTwoButton: false);
                }
              },
            ),
          ],
          child: !isAuthenticated
              ? _buildAuthenticationForm()
              : BlocBuilder<GetListDebitBloc, HandleGetDebitState>(
                  builder: (context, state) {
                    if (state is HandleGetDebitStateloading) {
                      return Center(
                        child: SizedBox(
                          width: 100.w,
                          height: 100.w,
                          child:
                              Lottie.asset('assets/lottie/loading_kango.json'),
                        ),
                      );
                    } else if (state is HandleGetDebitStateSuccess) {
                      return SlidableAutoCloseBehavior(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Slidable.of(context)?.close();
                          },
                          child: RefreshIndicator(
                            color: Theme.of(context).colorScheme.primary,
                            onRefresh: () async {
                              // Reset tất cả các trạng thái
                              setState(() {
                                statusTextController.clear();
                                textSearchController.clear(); // Thêm dòng này
                                _dateStartController.clear(); // Thêm dòng này
                                _dateEndController.clear(); // Thêm dòng này
                                _startDate = null; // Thêm dòng này
                                _endDate = null; // Thêm dòng này
                                query =
                                    ''; // Thêm dòng này - đặt lại trạng thái search
                              });

                              // Gọi event với tất cả tham số là null
                              BlocProvider.of<GetListDebitBloc>(context).add(
                                  const FetchListDebit(
                                      keywords: null,
                                      startDate: null,
                                      endDate: null,
                                      debitStatus: null));
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
                                              fontSize: 12,
                                              color: Colors.black),
                                          cursorColor: Colors.black,
                                          onFieldSubmitted: (value) =>
                                              searchProduct(value),
                                          decoration: InputDecoration(
                                              suffixIcon: InkWell(
                                                onTap: () {
                                                  searchProduct(
                                                      textSearchController
                                                          .text);
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
                                    ),
                                    SizedBox(
                                      width: 15.w,
                                    ),
                                    FilterWalletFluctuationWidget(
                                        isPakageManger: false,
                                        dateStartController:
                                            _dateStartController,
                                        dateEndController: _dateEndController,
                                        statusTextController:
                                            statusTextController,
                                        listStatus: listStatus,
                                        selectDayStart: selectDayStart,
                                        selectDayEnd: selectDayEnd,
                                        getEndDateError: () => _endDateError,
                                        clearFliterFunction: clearFilterFuntion,
                                        applyFliterFunction:
                                            applyFilterFuntion),
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
                                    controller: scrollListDebitsController,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        state.data.isEmpty
                                            ? const NoDataFoundWidget()
                                            : SizedBox(
                                                width: 1.sw,
                                                child: ListView.builder(
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
                                                        final dataDebit =
                                                            state.data[index];
                                                        return Card(
                                                          elevation: 2,
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      12.w,
                                                                  vertical:
                                                                      8.w),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12.r)),
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  const LinearGradient(
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                                colors: [
                                                                  Colors.white,
                                                                  Color(
                                                                      0xFFF9FAFC)
                                                                ],
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12.r),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          14.w),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  // Status indicator with enhanced visual design
                                                                  Container(
                                                                    width: 56.w,
                                                                    height:
                                                                        56.w,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: _getStatusColor(dataDebit
                                                                              .debitStatus)
                                                                          .withOpacity(
                                                                              0.12),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Icon(
                                                                        _getIconStatus(
                                                                            dataDebit.debitStatus),
                                                                        color: _getStatusColor(
                                                                            dataDebit.debitStatus),
                                                                        size: 34
                                                                            .sp,
                                                                      ),
                                                                    ),
                                                                  ),

                                                                  SizedBox(
                                                                      width:
                                                                          16.w),

                                                                  // Content section with improved layout
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        // Top row with debit number and status label
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            InkWell(
                                                                              onTap: () {
                                                                                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailDebitScreen(debitCode: dataDebit.debitNo)));
                                                                              },
                                                                              child: Container(
                                                                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                                                                decoration: BoxDecoration(
                                                                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                                                  borderRadius: BorderRadius.circular(8.r),
                                                                                ),
                                                                                child: TextApp(
                                                                                  text: dataDebit.debitNo,
                                                                                  fontsize: 16.sp,
                                                                                  color: Theme.of(context).colorScheme.primary,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            // Status Label now placed at top right
                                                                            Container(
                                                                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                                                              decoration: BoxDecoration(
                                                                                color: _getStatusColor(dataDebit.debitStatus).withOpacity(0.15),
                                                                                borderRadius: BorderRadius.circular(8.r),
                                                                              ),
                                                                              child: TextApp(
                                                                                isOverFlow: false,
                                                                                softWrap: true,
                                                                                text: dataDebit.statusLabel,
                                                                                fontsize: 13.sp,
                                                                                color: _getStatusColor(dataDebit.debitStatus),
                                                                                fontWeight: FontWeight.w600,
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),

                                                                        SizedBox(
                                                                            height:
                                                                                12.h),

                                                                        // Price with money color icon
                                                                        Container(
                                                                          margin:
                                                                              EdgeInsets.only(left: 2.w),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(
                                                                                FontAwesomeIcons.creditCard,
                                                                                size: 16.sp,
                                                                                color: const Color(0xFF2E7D32), // Green money color
                                                                              ),
                                                                              SizedBox(width: 8.w),
                                                                              TextApp(
                                                                                text: "Tổng tiền: ${formatCurrency(dataDebit.totalPrice)}",
                                                                                fontsize: 14.sp,
                                                                                color: Colors.black87,
                                                                                fontWeight: FontWeight.w600,
                                                                                isOverFlow: false,
                                                                                softWrap: true,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),

                                                                        SizedBox(
                                                                            height:
                                                                                6.h),

                                                                        // Date info with icon
                                                                        Container(
                                                                          margin:
                                                                              EdgeInsets.only(left: 2.w),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(Icons.access_time_rounded, size: 16.sp, color: Colors.grey[600]),
                                                                              SizedBox(width: 8.w),
                                                                              TextApp(
                                                                                text: "Ngày tạo: ${formatDateTime(dataDebit.createdAt.toString())}",
                                                                                fontsize: 13.sp,
                                                                                color: Colors.grey[700] ?? Colors.grey,
                                                                                fontWeight: FontWeight.normal,
                                                                                isOverFlow: false,
                                                                                softWrap: true,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
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
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else if (state is HandleGetDebitStateFailure) {
                      return ErrorDialog(
                        eventConfirm: () {},
                        errorText: 'Có lỗi đã xảy ra: ${state.message}',
                      );
                    }
                    return const Center(child: NoDataFoundWidget());
                  },
                ),
        ));
  }
}
