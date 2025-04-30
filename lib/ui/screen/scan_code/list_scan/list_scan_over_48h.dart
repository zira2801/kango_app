import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/scan/list_scan/list_scan_over_48h/list_scan_import_bloc.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:timeago/timeago.dart' as timeago;

class ListScanOver48HCodeScreen extends StatefulWidget {
  const ListScanOver48HCodeScreen({super.key});

  @override
  State<ListScanOver48HCodeScreen> createState() =>
      _ListScanOver48HCodeScreenState();
}

class _ListScanOver48HCodeScreenState extends State<ListScanOver48HCodeScreen> {
  final textSearchController = TextEditingController();

  final scrollListOver48HScanController = ScrollController();
  String query = '';
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();

    BlocProvider.of<ListScanOver48HBloc>(context)
        .add(const FetchListScanOver48H(keyWords: null, status: 1));

    scrollListOver48HScanController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollListOver48HScanController.position.maxScrollExtent ==
        scrollListOver48HScanController.offset) {
      BlocProvider.of<ListScanOver48HBloc>(context)
          .add(LoadMoreListScanOver48H(keyWords: query, status: 1));
    }
  }

  @override
  void dispose() {
    textSearchController.dispose();
    scrollListOver48HScanController.dispose();
    super.dispose();
  }

  String getTimeAgo(String dateString) {
    final dateTime = DateTime.parse(dateString);
    return timeago.format(dateTime, locale: 'vi');
  }

  void searchProduct(String query) {
    mounted
        ? setState(() {
            this.query = query;
            BlocProvider.of<ListScanOver48HBloc>(context)
                .add(FetchListScanOver48H(keyWords: query, status: 1));
          })
        : null;
  }

// Helper function to build info row
  Widget _buildInfoRow(
      {required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: Colors.black54,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: "$label ",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

// Helper function to build detail item
  Widget _buildDetailItem(
      {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: Colors.black54,
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextApp(
                text: label,
                fontsize: 12.sp,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
              TextApp(
                text: value,
                fontsize: 14.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                softWrap: true,
                isOverFlow: false,
              ),
            ],
          ),
        ),
      ],
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
            text: "LIST SCAN QUÁ 48H",
            fontsize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        body: MultiBlocListener(
          listeners: [
            BlocListener<ListScanOver48HBloc, ListScanOver48HState>(
              listener: (context, state) {
                if (state is ListScanOver48HStateSuccess) {
                } else if (state is ListScanOver48HStateFailure) {}
              },
            ),
          ],
          child: BlocBuilder<ListScanOver48HBloc, ListScanOver48HState>(
            builder: (context, state) {
              if (state is ListScanOver48HStateLoading) {
                return Center(
                  child: SizedBox(
                    width: 100.w,
                    height: 100.w,
                    child: Lottie.asset('assets/lottie/loading_kango.json'),
                  ),
                );
              } else if (state is ListScanOver48HStateSuccess) {
                return RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  onRefresh: () async {
                    BlocProvider.of<ListScanOver48HBloc>(context).add(
                        const FetchListScanOver48H(keyWords: null, status: 1));
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
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: scrollListOver48HScanController,
                          child: Column(
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
                                                  width: 100.w,
                                                  height: 100.w,
                                                  child: Lottie.asset(
                                                      'assets/lottie/loading_kango.json'),
                                                ),
                                              );
                                            } else {
                                              final dataOver48H =
                                                  state.data[index];
                                              return Card(
                                                elevation: 8,
                                                color: Colors.white,
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 12.w,
                                                    vertical: 8.h),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.r),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(16.w),
                                                      width: 1.sw,
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Left status section
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary
                                                                  .withOpacity(
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12.r),
                                                            ),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10.w),
                                                            child: Column(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .check_circle_rounded,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary,
                                                                  size: 42.sp,
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
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(width: 16.w),

                                                          // Right content section
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                // Header section with tracking number and date
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          TextApp(
                                                                        text: dataOver48H
                                                                            .packageHawbCode
                                                                            .toString(),
                                                                        fontsize:
                                                                            18.sp,
                                                                        color: Colors
                                                                            .black87,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal: 8
                                                                              .w,
                                                                          vertical:
                                                                              4.h),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .grey
                                                                            .withOpacity(0.1),
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.r),
                                                                      ),
                                                                      child:
                                                                          TextApp(
                                                                        text: formatDateTime(dataOver48H
                                                                            .scanAt
                                                                            .toString()),
                                                                        fontsize:
                                                                            12.sp,
                                                                        color: Colors
                                                                            .black54,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),

                                                                SizedBox(
                                                                    height:
                                                                        12.h),

                                                                // Info section
                                                                _buildInfoRow(
                                                                  icon: Icons
                                                                      .person,
                                                                  label:
                                                                      "N.V Scan:",
                                                                  value: dataOver48H
                                                                      .scanByName,
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        6.h),
                                                                _buildInfoRow(
                                                                  icon: Icons
                                                                      .person_outline,
                                                                  label:
                                                                      "Người gửi:",
                                                                  value: dataOver48H
                                                                      .senderContactName,
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        6.h),
                                                                _buildInfoRow(
                                                                  icon: Icons
                                                                      .person_pin_circle_outlined,
                                                                  label:
                                                                      "Người nhận:",
                                                                  value: dataOver48H
                                                                      .receiverContactName,
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        6.h),
                                                                _buildInfoRow(
                                                                  icon: Icons
                                                                      .public,
                                                                  label:
                                                                      "Quốc gia:",
                                                                  value: dataOver48H
                                                                      .countryName,
                                                                ),

                                                                SizedBox(
                                                                    height:
                                                                        12.h),

                                                                // Package details section
                                                                Container(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(10
                                                                              .w),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.05),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.r),
                                                                  ),
                                                                  child: Column(
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                _buildDetailItem(
                                                                              icon: Icons.local_shipping_outlined,
                                                                              label: "Dịch Vụ",
                                                                              value: dataOver48H.serviceName,
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                _buildDetailItem(
                                                                              icon: Icons.monitor_weight_outlined,
                                                                              label: "Cân Nặng",
                                                                              value: "${dataOver48H.packageWeight.toInt()} kg",
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              8.h),
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                _buildDetailItem(
                                                                              icon: Icons.straighten,
                                                                              label: "Kích Thước",
                                                                              value: "${dataOver48H.packageLength} x ${dataOver48H.packageWeight} x ${dataOver48H.packageHeight}",
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                _buildDetailItem(
                                                                              icon: Icons.access_time,
                                                                              label: "Time",
                                                                              value: getTimeAgo(dataOver48H.scanAt.toString()),
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
                                                        ],
                                                      ),
                                                    ),
                                                  ],
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
                );
              } else if (state is ListScanOver48HStateFailure) {
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
