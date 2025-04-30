import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/scan/list_scan/list_scan_import/list_scan_import_bloc.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class ListScanImportCodeScreen extends StatefulWidget {
  const ListScanImportCodeScreen({super.key});

  @override
  State<ListScanImportCodeScreen> createState() =>
      _ListScanImportCodeScreenState();
}

class _ListScanImportCodeScreenState extends State<ListScanImportCodeScreen> {
  final textSearchController = TextEditingController();

  final scrollListImportScanController = ScrollController();
  String query = '';
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();

    BlocProvider.of<ListScanImportBloc>(context).add(
        const FetchListScanImport(keyWords: null, overTime: null, status: 1));

    scrollListImportScanController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollListImportScanController.position.maxScrollExtent ==
        scrollListImportScanController.offset) {
      BlocProvider.of<ListScanImportBloc>(context).add(
          LoadMoreListScanImport(keyWords: query, overTime: null, status: 1));
    }
  }

  @override
  void dispose() {
    textSearchController.dispose();
    scrollListImportScanController.dispose();
    super.dispose();
  }

  void onDeleteScanImport(int id) {
    context.read<DeleteScanImportBloc>().add(
          HandleDeleteScanImport(historyID: id),
        );
  }

  void searchProduct(String query) {
    mounted
        ? setState(() {
            this.query = query;
            BlocProvider.of<ListScanImportBloc>(context).add(
                FetchListScanImport(
                    keyWords: query, overTime: null, status: 1));
          })
        : null;
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
            text: "LIST SCAN NHẬP",
            fontsize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        body: MultiBlocListener(
          listeners: [
            BlocListener<DeleteScanImportBloc, DeleteScanImportState>(
              listener: (context, state) {
                if (state is DeleteScanImportStateSuccess) {
                  showCustomDialogModal(
                      context: navigatorKey.currentContext!,
                      textDesc:
                          state.successText ?? "Hủy bỏ đơn hàng thành công",
                      title: "Thông báo",
                      colorButtonOk: Colors.green,
                      btnOKText: "Xác nhận",
                      typeDialog: "success",
                      eventButtonOKPress: () {},
                      isTwoButton: false);
                  BlocProvider.of<ListScanImportBloc>(context).add(
                      const FetchListScanImport(
                          keyWords: null, overTime: null, status: 1));
                } else if (state is DeleteScanImportStateFailure) {
                  showCustomDialogModal(
                      context: navigatorKey.currentContext!,
                      textDesc: state.errorText ?? 'Đã có lỗi xảy ra',
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
          child: BlocBuilder<ListScanImportBloc, ListScanImportState>(
            builder: (context, state) {
              if (state is ListScanImportStateLoading) {
                return Center(
                  child: SizedBox(
                    width: 100.w,
                    height: 100.w,
                    child: Lottie.asset('assets/lottie/loading_kango.json'),
                  ),
                );
              } else if (state is ListScanImportStateSuccess) {
                return SlidableAutoCloseBehavior(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Slidable.of(context)?.close();
                    },
                    child: RefreshIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      onRefresh: () async {
                        BlocProvider.of<ListScanImportBloc>(context).add(
                            const FetchListScanImport(
                                keyWords: null, overTime: null, status: 1));
                      },
                      child: Column(
                        children: [
                          Container(
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
                              onFieldSubmitted: (value) => searchProduct(value),
                              decoration: InputDecoration(
                                  suffixIcon: InkWell(
                                    onTap: () {
                                      searchProduct(textSearchController.text);
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
                          SizedBox(
                            height: 8.h,
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollListImportScanController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                      final dataImportScan =
                                                          state.data[index];
                                                      return Column(
                                                        children: [
                                                          const Divider(
                                                              height: 1),
                                                          Container(
                                                            width: 1.sw,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.1),
                                                                  spreadRadius:
                                                                      1,
                                                                  blurRadius: 3,
                                                                  offset:
                                                                      const Offset(
                                                                          0, 1),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Slidable(
                                                              key: ValueKey(
                                                                  dataImportScan),
                                                              endActionPane:
                                                                  ActionPane(
                                                                extentRatio:
                                                                    0.28,
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
                                                                        (context) {
                                                                      showCustomDialogModal(
                                                                        context:
                                                                            navigatorKey.currentContext!,
                                                                        textDesc:
                                                                            "Bạn có chắc muốn thực hiện tác vụ này?",
                                                                        title:
                                                                            "Thông báo",
                                                                        colorButtonOk:
                                                                            Colors.blue,
                                                                        btnOKText:
                                                                            "Xác nhận",
                                                                        typeDialog:
                                                                            "question",
                                                                        eventButtonOKPress:
                                                                            () {
                                                                          onDeleteScanImport(
                                                                              dataImportScan.historyScanId);
                                                                        },
                                                                        isTwoButton:
                                                                            true,
                                                                      );
                                                                    },
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
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
                                                                          FontAwesomeIcons
                                                                              .xmark,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                4),
                                                                        Text(
                                                                          'Hủy bỏ',
                                                                          style:
                                                                              TextStyle(color: Colors.white),
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical: 12
                                                                            .h,
                                                                        horizontal:
                                                                            8.w),
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    // Status icon column
                                                                    Column(
                                                                      children: [
                                                                        Container(
                                                                          padding:
                                                                              EdgeInsets.all(8.w),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                          child:
                                                                              Icon(
                                                                            Icons.check_circle_rounded,
                                                                            color:
                                                                                Theme.of(context).colorScheme.primary,
                                                                            size:
                                                                                38.sp,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                4.h),
                                                                        TextApp(
                                                                          isOverFlow:
                                                                              false,
                                                                          softWrap:
                                                                              true,
                                                                          text:
                                                                              "Imported",
                                                                          fontsize:
                                                                              12.sp,
                                                                          color:
                                                                              Colors.black87,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                      ],
                                                                    ),

                                                                    SizedBox(
                                                                        width: 16
                                                                            .w),

                                                                    // Package details column
                                                                    Expanded(
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          // Tracking number and date row
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Expanded(
                                                                                child: TextApp(
                                                                                  text: dataImportScan.packageHawbCode.toString(),
                                                                                  fontsize: 18.sp,
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                              TextApp(
                                                                                text: formatDateTime(dataImportScan.scanAt.toString()),
                                                                                fontsize: 12.sp,
                                                                                color: Colors.grey[600] ?? Colors.grey,
                                                                                fontWeight: FontWeight.w500,
                                                                              ),
                                                                            ],
                                                                          ),

                                                                          SizedBox(
                                                                              height: 8.h),

                                                                          // Scanner name
                                                                          TextApp(
                                                                            softWrap:
                                                                                true,
                                                                            isOverFlow:
                                                                                false,
                                                                            text:
                                                                                "N.V Scan: ${dataImportScan.scanByName}",
                                                                            fontsize:
                                                                                14.sp,
                                                                            color:
                                                                                Colors.grey[700] ?? Colors.grey,
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                          ),

                                                                          SizedBox(
                                                                              height: 4.h),

                                                                          // Sender name
                                                                          TextApp(
                                                                            softWrap:
                                                                                true,
                                                                            isOverFlow:
                                                                                false,
                                                                            text:
                                                                                "Sender: ${dataImportScan.receiverContactName}",
                                                                            fontsize:
                                                                                14.sp,
                                                                            color:
                                                                                Colors.grey[700] ?? Colors.grey,
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                          ),

                                                                          SizedBox(
                                                                              height: 8.h),

                                                                          // Service and weight row
                                                                          Row(
                                                                            children: [
                                                                              Expanded(
                                                                                child: Container(
                                                                                  padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.grey[100],
                                                                                    borderRadius: BorderRadius.circular(6.r),
                                                                                  ),
                                                                                  child: TextApp(
                                                                                    softWrap: true,
                                                                                    isOverFlow: false,
                                                                                    text: "Dịch Vụ: ${dataImportScan.serviceName}",
                                                                                    fontsize: 14.sp,
                                                                                    color: Colors.grey[800] ?? Colors.grey,
                                                                                    fontWeight: FontWeight.w500,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 8.w),
                                                                              Expanded(
                                                                                child: Container(
                                                                                  padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.grey[100],
                                                                                    borderRadius: BorderRadius.circular(6.r),
                                                                                  ),
                                                                                  child: TextApp(
                                                                                    softWrap: true,
                                                                                    isOverFlow: false,
                                                                                    text: "Cân Nặng: ${dataImportScan.packageWeight.toInt()} kg",
                                                                                    fontsize: 14.sp,
                                                                                    color: Colors.grey[800] ?? Colors.grey,
                                                                                    fontWeight: FontWeight.w500,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),

                                                                          SizedBox(
                                                                              height: 8.h),

                                                                          // Dimensions
                                                                          Container(
                                                                            padding:
                                                                                EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: Colors.grey[100],
                                                                              borderRadius: BorderRadius.circular(6.r),
                                                                            ),
                                                                            child:
                                                                                TextApp(
                                                                              softWrap: true,
                                                                              isOverFlow: false,
                                                                              text: "Kích Thước: ${dataImportScan.packageLength} x ${dataImportScan.packageWeight} x ${dataImportScan.packageHeight}",
                                                                              fontsize: 14.sp,
                                                                              color: Colors.grey[800] ?? Colors.grey,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 8.h),
                                                        ],
                                                      );
                                                    }
                                                  }),
                                            ),
                                      SizedBox(
                                        height: 15.h,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (state is ListScanImportStateFailure) {
                return ErrorDialog(
                  eventConfirm: () {
                    Navigator.pop(context);
                  },
                  errorText: 'Có lỗi đã xảy ra: ${state.message}',
                );
              }
              return const Center(child: NoDataFoundWidget());
            },
          ),
        ));
  }
}
