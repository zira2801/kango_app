import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/recharge/recharge_history/recharge_history_bloc.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/recharge/details_recharge.dart';
import 'package:scan_barcode_app/ui/screen/recharge/filter_recharge.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/utils/date_time_picker.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:money_formatter/money_formatter.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final scrollListBillController = ScrollController();
  final textSearchController = TextEditingController();
  final searchTypeTextController = TextEditingController();
  final TextEditingController _dateStartController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _endDateError;
  final statusTextController = TextEditingController();
  String currentMethodSerach = "code";

  String query = '';
  List<String> listStatus = [
    "Chờ xác nhận",
    "Thành công",
    "Thất bại",
  ];
  List<String> listKeyType = ["code", "note"];
  List<String> listSearchMethod = ["Tìm mã đơn", "Tìm ghi chú"];
  String searchMethod = 'Tìm mã đơn';
  List<IconData> iconStatus = [
    Icons.history,
    Icons.check,
    Icons.cancel,
  ];

  @override
  void dispose() {
    scrollListBillController.dispose();
    textSearchController.clear();
    _dateStartController.clear();
    _dateEndController.clear();
    super.dispose();
  }

  void searchProduct(String query) {
    mounted
        ? setState(() {
            this.query = query;
            BlocProvider.of<ReChargeHistoryBloc>(context).add(
                FetchListReChargeHistory(
                    status: listStatus.indexOf(statusTextController.text) == -1
                        ? null
                        : listStatus.indexOf(statusTextController.text),
                    startDate: _startDate?.toString(),
                    endDate: _endDate?.toString(),
                    keyType: currentMethodSerach,
                    keywords: query));
          })
        : null;
  }

  void _updateSearchTypeChanged(String newTypeSearch) {
    setState(() {
      currentMethodSerach = newTypeSearch;
    });
  }

  void _updateSearchStringChanged(String newStringSearch) {
    setState(() {
      searchMethod = newStringSearch;
    });
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

    BlocProvider.of<ReChargeHistoryBloc>(context).add(
        const FetchListReChargeHistory(
            status: null,
            startDate: null,
            endDate: null,
            keyType: null,
            keywords: null));
  }

  Future<void> applyFilterFuntion() async {
    setState(() {
      Navigator.pop(context);
      BlocProvider.of<ReChargeHistoryBloc>(context).add(
          FetchListReChargeHistory(
              status: listStatus.indexOf(statusTextController.text) == -1
                  ? null
                  : listStatus.indexOf(statusTextController.text),
              startDate: _startDate?.toString(),
              endDate: _endDate?.toString(),
              keyType: currentMethodSerach,
              keywords: query));
    });
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

  Future<void> onHanldeGetDetails(int chanrgeID) async {
    context.read<DetailsReChargeHistoryBloc>().add(
          HandleGetDetailsReChargeHistory(chanrgeID: chanrgeID),
        );
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
    BlocProvider.of<ReChargeHistoryBloc>(context).add(FetchListReChargeHistory(
        status: null,
        startDate: null,
        endDate: null,
        keyType: currentMethodSerach,
        keywords: null));
    scrollListBillController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollListBillController.position.maxScrollExtent ==
        scrollListBillController.offset) {
      BlocProvider.of<ReChargeHistoryBloc>(context).add(
          LoadMoreListReChargeHistory(
              status: listStatus.indexOf(statusTextController.text) == -1
                  ? null
                  : listStatus.indexOf(statusTextController.text),
              startDate: _startDate?.toString(),
              endDate: _endDate?.toString(),
              keyType: currentMethodSerach,
              keywords: query));
    }
  }

  Color _getStatusColor(int status) {
    if (status == 0) {
      return const Color(0xFFFFC107); // Pending/Yellow
    } else if (status == 1) {
      return Theme.of(context).colorScheme.primary; // Success/Green
    } else {
      return const Color(0xFFF44336); // Failed/Red
    }
  }

// Helper method to get status icon
  IconData _getStatusIcon(int status) {
    if (status == 0) {
      return Icons.hourglass_top;
    } else if (status == 1) {
      return Icons.check_circle;
    } else {
      return Icons.cancel;
    }
  }

// Helper method to build detail rows
  Widget _buildDetailRow(IconData icon, String text, double fontSize,
      {bool isBold = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: fontSize,
          color: Colors.grey,
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: TextApp(
            text: text,
            fontsize: fontSize,
            color: isBold ? Colors.black87 : Colors.grey.shade700,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            softWrap: true,
            isOverFlow: false,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
            text: "Lịch sử giao dịch",
            fontsize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: MultiBlocListener(
            listeners: [
              BlocListener<DetailsReChargeHistoryBloc,
                  GetDetailsReChargeHistoryState>(listener: (context, state) {
                if (state is HandleGetDetailsReChargeSuccess) {
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
                        return DetailsReChargeBottom(
                            detailsDataRechargeModel: state.data);
                      });
                }
              }),
              BlocListener<ReChargeHistoryBloc, ReChargeHistoryState>(
                  listener: (context, state) {
                if (state is HandleGetListReChargeStateSuccess) {}
              })
            ],
            child: BlocBuilder<ReChargeHistoryBloc, ReChargeHistoryState>(
              builder: (context, state) {
                if (state is HandleGetListReChargeStateSuccess) {
                  return SlidableAutoCloseBehavior(
                    child: SafeArea(
                        child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // Close any open slidable when tapping outside
                        Slidable.of(context)?.close();
                      },
                      child: RefreshIndicator(
                        color: Theme.of(context).colorScheme.primary,
                        onRefresh: () async {
                          statusTextController.clear();
                          textSearchController.clear();
                          _dateStartController.clear();
                          _dateEndController.clear();

                          _startDate = null;
                          _endDate = null;
                          _endDateError = null;
                          BlocProvider.of<ReChargeHistoryBloc>(context).add(
                              FetchListReChargeHistory(
                                  status: null,
                                  startDate: null,
                                  endDate: null,
                                  keyType: currentMethodSerach,
                                  keywords: query));
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: scrollListBillController,
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
                                            searchProduct(
                                                textSearchController.text);
                                          },
                                          controller: textSearchController,
                                          onFieldSubmitted: (value) {
                                            searchProduct(
                                                textSearchController.text);
                                          },
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                          cursorColor: Colors.black,
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
                                      FileterRechangeWidget(
                                        dateStartController:
                                            _dateStartController,
                                        dateEndController: _dateEndController,
                                        statusTextController:
                                            statusTextController,
                                        searchTypeTextController:
                                            searchTypeTextController,
                                        listStatus: listStatus,
                                        listSearchMethod: listSearchMethod,
                                        listKeyType: listKeyType,
                                        currentSearchMethod:
                                            currentMethodSerach,
                                        currentSearchString: searchMethod,
                                        onSeachTypeChanged:
                                            _updateSearchTypeChanged,
                                        onSeachStringChanged:
                                            _updateSearchStringChanged,
                                        selectDayStart: selectDayStart,
                                        selectDayEnd: selectDayEnd,
                                        getEndDateError: () => _endDateError,
                                        clearFliterFunction: clearFilterFuntion,
                                        applyFliterFunction: applyFilterFuntion,
                                      ),
                                    ],
                                  )),
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
                                              if (index >= state.data.length) {
                                                return Center(
                                                  child: SizedBox(
                                                    width: 80.w,
                                                    height: 80.w,
                                                    child: Lottie.asset(
                                                        'assets/lottie/loading_kango.json'),
                                                  ),
                                                );
                                              } else {
                                                final data = state.data[index];
                                                return Container(
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 4.h,
                                                      horizontal: 8.w),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.r),
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        spreadRadius: 1,
                                                        blurRadius: 4,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Slidable(
                                                    key: ValueKey(data),
                                                    endActionPane: ActionPane(
                                                      extentRatio: 0.25,
                                                      motion:
                                                          const ScrollMotion(),
                                                      children: [
                                                        CustomSlidableAction(
                                                          onPressed:
                                                              (context) async {
                                                            await onHanldeGetDetails(
                                                                data.rechargeId);
                                                          },
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          foregroundColor:
                                                              Colors.white,
                                                          borderRadius: BorderRadius
                                                              .horizontal(
                                                                  right: Radius
                                                                      .circular(
                                                                          12.r)),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .visibility_outlined,
                                                                color: Colors
                                                                    .white,
                                                                size: 22.sp,
                                                              ),
                                                              SizedBox(
                                                                  height: 4.h),
                                                              TextApp(
                                                                text:
                                                                    'Chi tiết',
                                                                fontsize: 12.sp,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12.h,
                                                              horizontal: 16.w),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          // Status indicator
                                                          Container(
                                                            width: 50.w,
                                                            height: 50.w,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: _getStatusColor(
                                                                      data
                                                                          .status)
                                                                  .withOpacity(
                                                                      0.1),
                                                            ),
                                                            child: Center(
                                                              child: Icon(
                                                                _getStatusIcon(
                                                                    data.status),
                                                                color: _getStatusColor(
                                                                    data.status),
                                                                size: 28.sp,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 16.w),
                                                          // Content
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                // Header with code and date
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    TextApp(
                                                                      text: data
                                                                          .code,
                                                                      fontsize:
                                                                          16.sp,
                                                                      color: Colors
                                                                          .black87,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                    TextApp(
                                                                      text: formatDateTime(data
                                                                          .createdAt
                                                                          .toString()),
                                                                      fontsize:
                                                                          12.sp,
                                                                      color: Colors
                                                                          .grey,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        4.h),
                                                                // Status label
                                                                Container(
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          8.w,
                                                                      vertical:
                                                                          2.h),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: _getStatusColor(data
                                                                            .status)
                                                                        .withOpacity(
                                                                            0.1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            4.r),
                                                                  ),
                                                                  child:
                                                                      TextApp(
                                                                    text:
                                                                        data.statusLabel ??
                                                                            '',
                                                                    fontsize:
                                                                        12.sp,
                                                                    color: _getStatusColor(
                                                                        data.status),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        8.h),
                                                                // Details
                                                                _buildDetailRow(
                                                                    Icons
                                                                        .payments_outlined,
                                                                    "Phương thức: Chuyển khoản",
                                                                    14.sp),
                                                                SizedBox(
                                                                    height:
                                                                        4.h),
                                                                _buildDetailRow(
                                                                  Icons
                                                                      .attach_money,
                                                                  "Số tiền: ${MoneyFormatter(amount: data.amount.toDouble()).output.withoutFractionDigits} đ",
                                                                  14.sp,
                                                                  isBold: false,
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        4.h),
                                                                _buildDetailRow(
                                                                    Icons
                                                                        .description_outlined,
                                                                    "Nội dung: ${data.note ?? ''}",
                                                                    14.sp),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    )),
                  );
                } else if (state is HandleGetListReChargeStateFailure) {
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
}
