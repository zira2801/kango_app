import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/sale_manager/home_sale_manager/home_sale_manager_bloc.dart';
import 'package:scan_barcode_app/ui/screen/sale_manager/sale_screen/detail_fwd_support.dart';
import 'package:scan_barcode_app/ui/screen/sale_manager/sale_screen/link_sale_to_fwd_screen.dart';
import 'package:scan_barcode_app/ui/screen/transfer_list/filter_transfer.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/utils/date_time_picker.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class ManagerSupportFwd extends StatefulWidget {
  const ManagerSupportFwd({super.key});

  @override
  State<ManagerSupportFwd> createState() => _ManagerSupportFwdState();
}

class _ManagerSupportFwdState extends State<ManagerSupportFwd> {
  String query = '';
  final textSearchController = TextEditingController();

  final TextEditingController _dateStartController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();
  DateTime? _startDate; //type ngày bắt đầu
  DateTime? _endDate; //type ngày kết thúc
  String? _endDateError; //text lỗi khi ngày kết thúc nhỏ hơn ngày bắt đầu
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _fetchSupportFwdData();
    // Thêm listener cho ScrollController
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        final state = BlocProvider.of<GetListSaleSupportFWDBloc>(context).state;
        if (state is GetListSaleSupportFWDStateSuccess &&
            !state.hasReachedMax) {
          BlocProvider.of<GetListSaleSupportFWDBloc>(context).add(
            LoadMoreSaleSupportFWD(
              startDate: _startDate?.toString(),
              endDate: _endDate?.toString(),
              keywords: query,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    textSearchController.clear();
    _dateStartController.clear();
    _dateEndController.clear();
    _scrollController.dispose();
  }

  void _fetchSupportFwdData() {
    BlocProvider.of<GetListSaleSupportFWDBloc>(context).add(
        const GetSaleSupportFWD(
            startDate: null, endDate: null, keywords: null));
  }

  // Hàm định dạng weight
  String formatWeight(double? weight) {
    if (weight == null) return '0';
    if (weight == weight.toInt()) {
      return weight
          .toInt()
          .toString(); // Hiển thị dạng int nếu không có phần thập phân
    }
    return weight.toString(); // Giữ nguyên nếu có phần thập phân
  }

  void searchProduct(String query) {
    mounted
        ? setState(() {
            this.query = query;

            BlocProvider.of<GetListSaleSupportFWDBloc>(context)
                .add(GetSaleSupportFWD(
              startDate: _startDate?.toString(),
              endDate: _endDate?.toString(),
              keywords: query,
            ));
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

    // Nếu cả hai đều có giá trị hoặc cả hai đều null, tiếp tục áp dụng bộ lọc
    log(_startDate.toString());
    log(_endDate.toString());
    Navigator.pop(context);

    BlocProvider.of<GetListSaleSupportFWDBloc>(context).add(GetSaleSupportFWD(
        startDate: _startDate?.toString(),
        endDate: _endDate?.toString(),
        keywords: query));
  }

  Future<void> clearFilterFuntion() async {
    setState(() {
      _endDateError = null;
      _dateStartController.clear();
      _dateEndController.clear();
      _startDate = null;
      _endDate = null;
    });
    Navigator.pop(context);
    BlocProvider.of<GetListSaleSupportFWDBloc>(context).add(
        const GetSaleSupportFWD(
            startDate: null, endDate: null, keywords: null));
  }

  Future<void> _deleteSaleSupportFWD({int? keyID}) async {
    setState(() {
      _isLoading = true;
    });
    context.read<DeleteSaleSupportFWDBloc>().add(
          DeleteSaleSupportFWD(
            keyID: keyID?.toInt() ?? 0,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextApp(
          text: "Quản lý sale hỗ trợ FWD",
          fontWeight: FontWeight.bold,
          fontsize: 20.sp,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child: SizedBox(
              height: 40.w,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.primary)),
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LinkSaleToFwdScreen()));
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.add_circle,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 3.w,
                    ),
                    TextApp(
                      text: 'Link FWD To Sale',
                      color: Colors.white,
                      fontsize: 15.w,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<DeleteSaleSupportFWDBloc, SaleManagerState>(
            listener: (context, state) {
              if (state is DeleteSaleToSupportFWDStateSuccess) {
                setState(() {
                  _isLoading = false;
                });
                showCustomDialogModal(
                    context: context,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.green,
                    btnOKText: "Xác nhận",
                    typeDialog: "success",
                    eventButtonOKPress: () {
                      BlocProvider.of<GetListSaleSupportFWDBloc>(context).add(
                        const GetSaleSupportFWD(
                          startDate: null,
                          endDate: null,
                          keywords: null,
                        ),
                      );
                    },
                    isTwoButton: false);
              } else if (state is DeleteSaleToSupportFWDStateFailure) {
                setState(() {
                  _isLoading = false;
                });
                showCustomDialogModal(
                    context: context,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.red,
                    btnOKText: "Xác nhận",
                    typeDialog: "error",
                    eventButtonOKPress: () {},
                    isTwoButton: false);
              }
            },
          ),
        ],
        child: BlocBuilder<GetListSaleSupportFWDBloc, SaleManagerState>(
          builder: (context, state) {
            if (state is GetListSaleSupportFWDStateLoading) {
              return Center(
                child: SizedBox(
                  width: 100.w,
                  height: 100.w,
                  child: Lottie.asset('assets/lottie/loading_kango.json'),
                ),
              );
            }

            if (state is GetListSaleSupportFWDStateFailure) {
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
                  ],
                ),
              );
            }

            if (state is GetListSaleSupportFWDStateSuccess) {
              return RefreshIndicator(
                color: Theme.of(context).colorScheme.primary,
                onRefresh: () async {
                  // shipmentItemData.clear();
                  _endDateError = null;
                  _dateStartController.clear();
                  _dateEndController.clear();
                  _startDate = null;
                  _endDate = null;
                  _fetchSupportFwdData();
                },
                child: Column(
                  children: [
                    Container(
                      width: 1.sw,
                      padding: EdgeInsets.all(10.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              width: 1.sw,
                              padding: EdgeInsets.all(10.w),
                              child: TextFormField(
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
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
                          FilterTransferWidget(
                              isPakageManger: false,
                              dateStartController: _dateStartController,
                              dateEndController: _dateEndController,
                              selectDayStart: selectDayStart,
                              selectDayEnd: selectDayEnd,
                              getEndDateError: () => _endDateError,
                              clearFliterFunction: clearFilterFuntion,
                              applyFliterFunction: applyFilterFuntion),
                          SizedBox(
                            width: 5.w,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...state.data.map((userFwd) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15.w, vertical: 10.h),
                                    child: Row(
                                      children: [
                                        TextApp(
                                          text: 'Sale Name: ',
                                          fontWeight: FontWeight.bold,
                                          fontsize: 17.sp,
                                          color: Colors.black,
                                        ),
                                        Icon(Icons.person,
                                            size: 20.sp, color: Colors.black),
                                        SizedBox(width: 5.w),
                                        TextApp(
                                          text: userFwd.userContactName,
                                          fontWeight: FontWeight.bold,
                                          fontsize: 16.sp,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 1.sw,
                                    child: DataTable(
                                      columnSpacing: userFwd.companies.isEmpty
                                          ? 100.w
                                          : 10.w,
                                      headingRowColor: WidgetStateProperty.all(
                                          Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      dataRowColor: WidgetStateProperty.all(
                                          Colors.grey[100]),
                                      columns: [
                                        DataColumn(
                                          label: Expanded(
                                            child: TextApp(
                                              text: 'Company Name',
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontsize: 14.sp,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: TextApp(
                                              text: 'Weight',
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontsize: 14.sp,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: TextApp(
                                              text: '',
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontsize: 14.sp,
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: [
                                        // First display main user's companies
                                        ...userFwd.companies.map((company) {
                                          return DataRow(cells: [
                                            DataCell(Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              DetailFwdSupportScreen(
                                                                companyCode:
                                                                    company
                                                                        .userCode,
                                                              )));
                                                },
                                                child: TextApp(
                                                  text: company.userCompanyName,
                                                  maxLines: 3,
                                                  fontsize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                            )),
                                            DataCell(Center(
                                              child: TextApp(
                                                text: formatWeight(
                                                    company.totalWeight),
                                                fontsize: 14.sp,
                                              ),
                                            )),
                                            DataCell(IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: _isLoading
                                                  ? null
                                                  : () async {
                                                      showCustomDialogModal(
                                                          context: context,
                                                          textDesc:
                                                              "Bạn có chắc muốn xóa fwd này khỏi danh sách ?",
                                                          title: "Thông báo",
                                                          colorButtonOk:
                                                              Colors.blue,
                                                          btnOKText: "Xác nhận",
                                                          typeDialog:
                                                              "question",
                                                          eventButtonOKPress:
                                                              () async {
                                                            await _deleteSaleSupportFWD(
                                                                keyID: company
                                                                    .saleLinkFwdId);
                                                          },
                                                          isTwoButton: true);
                                                    },
                                            )),
                                          ]);
                                        }),

                                        // Then for each member, display member info followed immediately by their companies
                                        ...userFwd.members.expand((member) {
                                          // Create a list starting with the member row
                                          List<DataRow> memberRows = [
                                            DataRow(cells: [
                                              DataCell(Row(
                                                children: [
                                                  Icon(Icons.person,
                                                      size: 16.sp,
                                                      color: Colors.black),
                                                  SizedBox(width: 5.w),
                                                  TextApp(
                                                    text:
                                                        member.userContactName,
                                                    fontsize: 14.sp,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ],
                                              )),
                                              DataCell(TextApp(
                                                text: '',
                                                fontsize: 14.sp,
                                              )),
                                              DataCell(Container()),
                                            ])
                                          ];

                                          // Then add company rows for this specific member
                                          memberRows.addAll(
                                              member.companies.map((company) {
                                            return DataRow(cells: [
                                              DataCell(Padding(
                                                padding:
                                                    EdgeInsets.only(left: 20.w),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                DetailFwdSupportScreen(
                                                                  companyCode:
                                                                      company
                                                                          .userCode,
                                                                )));
                                                  },
                                                  child: Container(
                                                    width: 250.w,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.play_arrow,
                                                          color: Colors.black,
                                                          size: 16.sp,
                                                        ),
                                                        SizedBox(width: 5.sp),
                                                        Expanded(
                                                          child: TextApp(
                                                            text: company
                                                                .userCompanyName,
                                                            fontsize: 14.sp,
                                                            maxLines: 3,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )),
                                              DataCell(Center(
                                                child: TextApp(
                                                  text: formatWeight(
                                                      company.totalWeight),
                                                  fontsize: 14.sp,
                                                ),
                                              )),
                                              DataCell(IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: _isLoading
                                                    ? null
                                                    : () async {
                                                        showCustomDialogModal(
                                                            context: context,
                                                            textDesc:
                                                                "Bạn có chắc muốn xóa fwd này khỏi danh sách ?",
                                                            title: "Thông báo",
                                                            colorButtonOk:
                                                                Colors.blue,
                                                            btnOKText:
                                                                "Xác nhận",
                                                            typeDialog:
                                                                "question",
                                                            eventButtonOKPress:
                                                                () async {
                                                              await _deleteSaleSupportFWD(
                                                                  keyID: company
                                                                      .saleLinkFwdId);
                                                            },
                                                            isTwoButton: true);
                                                      },
                                              )),
                                            ]);
                                          }));

                                          return memberRows;
                                        }),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 15.h)
                                ],
                              );
                            }).toList(),

                            // Loading indicator
                            if (!state.hasReachedMax)
                              Center(
                                child: SizedBox(
                                  width: 100.w,
                                  height: 100.w,
                                  child: Lottie.asset(
                                      'assets/lottie/loading_kango.json'),
                                ),
                              ),
                            SizedBox(height: 20.h)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }

            return Center(
              child: Text(
                'Không có dữ liệu',
                style: TextStyle(fontSize: 16.sp),
              ),
            );
          },
        ),
      ),
    );
  }
}
