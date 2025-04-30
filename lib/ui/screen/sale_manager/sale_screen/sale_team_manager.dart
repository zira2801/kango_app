import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/sale_manager/home_sale_manager/home_sale_manager_bloc.dart';
import 'package:scan_barcode_app/data/models/sale_leader/sale_leader_model.dart';
import 'package:scan_barcode_app/data/models/sale_leader/sale_team_leader.dart';
import 'package:scan_barcode_app/ui/screen/sale_manager/sale_screen/add_user_leader.dart';
import 'package:scan_barcode_app/ui/screen/sale_manager/sale_screen/filter_sale_team_manager.dart';
import 'package:scan_barcode_app/ui/screen/sale_manager/sale_screen/manager_leader_sale.dart';
import 'package:scan_barcode_app/ui/screen/shipment/filter_shipment.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/utils/date_time_picker.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class SaleTeamManager extends StatefulWidget {
  SaleResponse? saleResponse;
  SaleTeamManager({super.key, required this.saleResponse});

  @override
  State<SaleTeamManager> createState() => _SaleTeamManagerState();
}

class _SaleTeamManagerState extends State<SaleTeamManager> {
  final TextEditingController _monthYearController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  String? _endDateError; //text lỗi khi ngày kết thúc nhỏ hơn ngày bắt đầu
  final scrollListSaleLeaderController = ScrollController();
  final textSearchController = TextEditingController();
  final TextEditingController _dateStartController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();
  String query = '';
  final formatter = NumberFormat("#,###", "vi_VN");
  @override
  void initState() {
    BlocProvider.of<GetListSaleTeamLeaderBloc>(context).add(
        const GetSaleTeamLeader(
            startDate: null, endDate: null, keywords: null));
    scrollListSaleLeaderController.addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    final state = BlocProvider.of<GetListSaleTeamLeaderBloc>(context).state;

    // Chỉ load more nếu chưa đạt max và không đang load
    if (state is GetSaleTeamLeaderStateSuccess && !state.hasReachedMax) {
      if (scrollListSaleLeaderController.position.maxScrollExtent ==
          scrollListSaleLeaderController.offset) {
        final String formattedStartDate = formatStartDateForAPI(_startDate);
        final String formattedEndDate = formatEndDateForAPI(_endDate);

        BlocProvider.of<GetListSaleTeamLeaderBloc>(context)
            .add(LoadMoreSaleTeamLeader(
          startDate: formattedStartDate.isNotEmpty ? formattedStartDate : null,
          endDate: formattedEndDate.isNotEmpty ? formattedEndDate : null,
          keywords: query,
        ));
      }
    }
  }

  String formatEndDateForAPI(DateTime? date) {
    if (date == null) return '';
    // Format as DD-MM-YYYY with end of day (same format but conceptually representing end of day)
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String formatStartDateForAPI(DateTime? date) {
    if (date == null) return '';
    // Format as DD-MM-YYYY with beginning of day
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Future<void> applyFilterFuntion() async {
    final String formattedStartDate = formatStartDateForAPI(_startDate);
    final String formattedEndDate = formatEndDateForAPI(_endDate);

    log('Start date formatted: $formattedStartDate');
    log('End date formatted: $formattedEndDate');

    Navigator.pop(context);

    BlocProvider.of<GetListSaleTeamLeaderBloc>(context).add(GetSaleTeamLeader(
      startDate: formattedStartDate.isNotEmpty ? formattedStartDate : null,
      endDate: formattedEndDate.isNotEmpty ? formattedEndDate : null,
      keywords: query,
    ));
  }

  void searchProduct(String query) {
    mounted
        ? setState(() {
            this.query = query;

            BlocProvider.of<GetListSaleTeamLeaderBloc>(context)
                .add(GetSaleTeamLeader(
              startDate: _startDate?.toString(),
              endDate: _endDate?.toString(),
              keywords: query,
            ));
          })
        : null;
  }

  Future<void> clearFilterFuntion() async {
    setState(() {
      _endDateError = null;
      _monthYearController.clear();
      _dateStartController.clear();
      _dateEndController.clear();
      _startDate = null;
      _endDate = null;
    });
    Navigator.pop(context);
    BlocProvider.of<GetListSaleTeamLeaderBloc>(context).add(GetSaleTeamLeader(
      startDate: null,
      endDate: null,
      keywords: query,
    ));
  }

  void onDateRangeSelected(DateTime firstDay, DateTime lastDay) {
    setState(() {
      _startDate = firstDay;
      _endDate = lastDay;
    });
  }

  /// This builds cupertion date picker in iOS
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
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: TextApp(
            text: "SALE LEADER MANAGER",
            fontWeight: FontWeight.bold,
            fontsize: 20.sp,
          ),
        ),
        body: BlocBuilder<GetListSaleTeamLeaderBloc, SaleManagerState>(
          builder: (context, state) {
            if (state is GetSaleTeamLeaderStateLoading) {
              return Center(
                child: SizedBox(
                  width: 100.w,
                  height: 100.w,
                  child: Lottie.asset('assets/lottie/loading_kango.json'),
                ),
              );
            } else if (state is GetSaleTeamLeaderStateSuccess) {
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
                            _endDateError = null;
                            _dateStartController.clear();
                            _dateEndController.clear();
                            _startDate = null;
                            _endDate = null;
                            BlocProvider.of<GetListSaleTeamLeaderBloc>(context)
                                .add(const GetSaleTeamLeader(
                                    startDate: null,
                                    endDate: null,
                                    keywords: null));
                          },
                          child: Column(children: [
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
                                            hintText: "Tìm kiếm:...",
                                            contentPadding:
                                                const EdgeInsets.all(15)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15.w,
                                    ),
                                    FilterSaleTeamManagerWidget(
                                        monthYearController:
                                            _monthYearController,
                                        onDateRangeSelected:
                                            onDateRangeSelected,
                                        clearFilterFunction: clearFilterFuntion,
                                        applyFilterFunction:
                                            applyFilterFuntion),
                                  ],
                                )),
                            SizedBox(
                              height: 8.h,
                            ),
                            Expanded(
                                child: SingleChildScrollView(
                              controller: scrollListSaleLeaderController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  widget.saleResponse?.leaderId != null
                                      ? Align(
                                          alignment: Alignment.center,
                                          child: SizedBox(
                                            width: 300.w,
                                            height: 50.w,
                                            child: ButtonApp(
                                                event: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              AddSaleLeaderScreen(
                                                                leaderId: widget
                                                                        .saleResponse!
                                                                        .leaderId ??
                                                                    0,
                                                              )));
                                                },
                                                text: "Thêm Member sale",
                                                colorText: Colors.white,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                outlineColor: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontWeight: FontWeight.bold,
                                                fontsize: 14.sp),
                                          ),
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: 15.w,
                                  ),
                                  widget.saleResponse?.leaderId == null
                                      ? Container(
                                          child: Center(
                                            child: TextApp(
                                              text:
                                                  'Bạn hiện tại chưa phải là leader',
                                              fontsize: 16.sp,
                                            ),
                                          ),
                                        )
                                      : SizedBox(
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
                                                            fit:
                                                                BoxFit.contain),
                                                      ),
                                                    ),
                                                    TextApp(
                                                      text:
                                                          "Không tìm thấy team!",
                                                      fontsize: 18.sp,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ],
                                                )
                                              : ListView.builder(
                                                  itemCount: state.data.length,
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
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
                                                      final dataTeamLeader =
                                                          state.data[index];

                                                      return _itemSaleTeamLeader(
                                                          dataTeamLeader);
                                                    }
                                                  }),
                                        )
                                ],
                              ),
                            ))
                          ]))));
            } else if (state is GetSaleTeamLeaderStateFailure) {
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
                  text: "Không tìm thấy dữ liệu!",
                  fontsize: 18.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ],
            );
          },
        ));
  }

  Widget _itemSaleTeamLeader(SaleTeamLeader dataTeamLeader) {
    final String? position =
        StorageUtils.instance.getString(key: 'user_position');
    final String normalizedPosition = position!.trim().toLowerCase();

    final int? userId = StorageUtils.instance.getInt(key: 'user_ID');
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with creator info
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24.sp,
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ManagerLeaderSale(
                                          // Pass user position as parameter
                                          userPosition: normalizedPosition,
                                          // Pass permissions as boolean flags
                                          canUploadLabel:
                                              normalizedPosition != 'sale' &&
                                                  normalizedPosition != 'fwd' &&
                                                  normalizedPosition !=
                                                      'ops-leader' &&
                                                  normalizedPosition !=
                                                      'ops_pickup',
                                          canUploadPayment:
                                              normalizedPosition != 'fwd',
                                          saleCode: dataTeamLeader.userCode,
                                          userId: userId,
                                        )));
                          },
                          child: TextApp(
                            text: dataTeamLeader.userContactName ?? "",
                            fontsize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(
                    //   width: 20.w,
                    // ),
                    // IconButton(
                    //   icon: const Icon(Icons.settings, size: 20),
                    //   onPressed: () {
                    //     // Handle settings action
                    //   },
                    // ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Date info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    TextApp(
                      text: "Ngày tạo: ",
                      fontsize: 14.sp,
                      color: Colors.black54,
                    ),
                    TextApp(
                      text: _formatDate(dataTeamLeader.createdAt),
                      fontsize: 14.sp,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Table header
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: const Border(
                    bottom: BorderSide(color: Colors.black12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextApp(
                        text: "Tên",
                        fontWeight: FontWeight.w500,
                        fontsize: 14.sp,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextApp(
                        text: "Mã",
                        fontWeight: FontWeight.w500,
                        fontsize: 14.sp,
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: TextApp(
                        text: "Lợi nhuận",
                        fontWeight: FontWeight.w500,
                        fontsize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              // Team members list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dataTeamLeader.members?.length ?? 0,
                itemBuilder: (context, index) {
                  final member = dataTeamLeader.members![index];
                  final isEven = index % 2 == 0;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isEven ? Colors.white : Colors.grey[50],
                      border: const Border(
                        bottom: BorderSide(color: Colors.black12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ManagerLeaderSale(
                                            // Pass user position as parameter
                                            userPosition: normalizedPosition,
                                            // Pass permissions as boolean flags
                                            canUploadLabel:
                                                normalizedPosition != 'sale' &&
                                                    normalizedPosition !=
                                                        'fwd' &&
                                                    normalizedPosition !=
                                                        'ops-leader' &&
                                                    normalizedPosition !=
                                                        'ops_pickup',
                                            canUploadPayment:
                                                normalizedPosition != 'fwd',
                                            saleCode: member.userCode,
                                            userId: member.userId,
                                          )));
                            },
                            child: Row(
                              children: [
                                member.memberKind == 1
                                    ? Icon(
                                        FontAwesomeIcons.userTie,
                                        size: 16.sp,
                                        color: Theme.of(context).primaryColor,
                                      )
                                    : const SizedBox(),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: TextApp(
                                    text: member.userContactName ?? "",
                                    fontsize: 13.sp,
                                    maxLines: 3,
                                    fontWeight: member.memberKind == 1
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: TextApp(
                            text: member.userCode ?? "",
                            fontsize: 13.sp,
                            color: Colors.black87,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: TextApp(
                            text:
                                "${formatter.format(member.memberProfit ?? 0)} VND",
                            fontsize: 13.sp,
                            maxLines: 3,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 15.h),
      ],
    );
  }

// Helper function to format date
  String _formatDate(String? dateString) {
    if (dateString == null) return "";
    try {
      final dateTime = DateTime.parse(dateString);
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }
}
