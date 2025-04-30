import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/sale_manager/home_sale_manager/home_sale_manager_bloc.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/models/sale_leader/sale_leader_model.dart';
import 'package:scan_barcode_app/data/models/sale_manager/home_sale_manager.dart';
import 'package:scan_barcode_app/ui/screen/sale_manager/admin_screen/sale_team_leader_manager.dart';
import 'package:scan_barcode_app/ui/screen/sale_manager/sale_screen/manager_leader_sale.dart';
import 'package:scan_barcode_app/ui/screen/sale_manager/sale_screen/manager_support_fwd.dart';
import 'package:scan_barcode_app/ui/screen/sale_manager/sale_screen/sale_team_manager.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/chart/profit_chart.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:http/http.dart' as http;

class SaleManagerScreen extends StatefulWidget {
  const SaleManagerScreen({super.key});

  @override
  State<SaleManagerScreen> createState() => _SaleManagerScreenState();
}

class _SaleManagerScreenState extends State<SaleManagerScreen> {
  SaleResponse? saleResponse;
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
    init();
    BlocProvider.of<SaleManagerBloc>(context).add(const GetHomeSaleManager());
  }

// Function to map Font Awesome class names to IconData
  IconData getIconFromString(String iconClass) {
    // Split the class name (e.g., "fas fa-user-tie" -> ["fas", "fa-user-tie"])
    final parts = iconClass.split(' ');
    if (parts.length < 2) return FontAwesomeIcons.question; // Fallback icon

    final iconName =
        parts[1].replaceAll('-', ''); // Convert "fa-user-tie" to "faUserTie"

    // Map icon names to FontAwesomeIcons
    switch (iconName) {
      case 'fausertie':
        return FontAwesomeIcons.userTie;
      case 'fausers':
        return FontAwesomeIcons.users;
      case 'fahandshelping':
        return FontAwesomeIcons.handsHelping;
      case 'fafileinvoicedollar':
        return FontAwesomeIcons.fileInvoiceDollar;
      case 'falink':
        return FontAwesomeIcons.link;
      case 'fauserplus':
        return FontAwesomeIcons.userPlus;
      case 'fachartbar':
        return FontAwesomeIcons.chartBar;
      default:
        return FontAwesomeIcons.question; // Fallback icon if not found
    }
  }

  void init() {
    getSaleLeader();
  }

  Future<void> getSaleLeader() async {
    final response = await http.get(
      Uri.parse('$baseUrl$getLeaderSale'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
    );
    final data = jsonDecode(response.body);
    try {
      if (data['status'] == 200) {
        log("getLeaderSale OK");
        mounted
            ? setState(() {
                saleResponse = SaleResponse.fromJson(data);
              })
            : null;
      } else {
        log("getLeaderSale error 1");
        log(data['status'].toString());
      }
    } catch (error) {
      log("getLeaderSale error $error 2");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              errorText: 'Có lỗi xảy ra, vui lòng thử lại sau.',
              eventConfirm: () {
                Navigator.pop(context);
              },
            );
          });
    }
  }

  String _getSubTitle(String? key, HomeSaleManager saleDashboard) {
    String subTitle = '';
    switch (key) {
      case 'manager_leader':
        return subTitle = saleDashboard.dashboard.managerLeader;
      case 'manager_sales':
        return subTitle = saleDashboard.dashboard.managerSales;
      case 'confirm_sale':
        return subTitle = saleDashboard.dashboard.confirmSale;
      case 'cost_fwd':
        return subTitle = saleDashboard.dashboard.costFwd;
      case 'manager_leader_link_fwd':
        return subTitle = saleDashboard.dashboard.managerLeaderLinkFwd;
      case 'manager_sale_link_fwd':
        return subTitle = saleDashboard.dashboard.managerSaleLinkFwd;
      case 'confirm_fwd':
        return subTitle = saleDashboard.dashboard.confirmFwd;
    }
    return subTitle;
  }

  Color _getColorSubTitle(String? key) {
    switch (key) {
      case 'confirm_fwd':
        return Colors.red;
      case 'confirm_sale':
        return Colors.red;
    }
    return Colors.black87;
  }

  Function() _functionKey(BuildContext context, String? key) {
    final int? userId = StorageUtils.instance.getInt(key: 'user_ID');
    final String? saleCode = StorageUtils.instance.getString(key: 'userCode');
    final String? position =
        StorageUtils.instance.getString(key: 'user_position');
    final String normalizedPosition = position!.trim().toLowerCase();

    switch (key) {
      case 'manager_leader':
        return () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SaleTeamLeaderManager(
                      saleResponse: saleResponse,
                    )));
      case 'manager_team':
        return () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SaleTeamManager(
                      saleResponse: saleResponse,
                    )));
// Thay vì Navigator.pushNamed
      case 'manager_support_fwd':
        return () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ManagerSupportFwd()));
      case 'manager_leader_sale':
        return () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ManagerLeaderSale(
                      // Pass user position as parameter
                      userPosition: normalizedPosition,
                      // Pass permissions as boolean flags
                      canUploadLabel: normalizedPosition != 'sale' &&
                          normalizedPosition != 'fwd' &&
                          normalizedPosition != 'ops-leader' &&
                          normalizedPosition != 'ops_pickup',
                      canUploadPayment: normalizedPosition != 'fwd',
                      saleCode: saleCode,
                      userId: userId,
                    )));
      default:
        return () async {
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel:
                MaterialLocalizations.of(context).modalBarrierDismissLabel,
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (context, animation, secondaryAnimation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1), // Hiển thị từ trên xuống
                  end: Offset.zero,
                ).animate(animation),
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  title: const Text('Thông báo',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  content: const Text(
                      'Chức năng đang được cập nhật, vui lòng quay lại sau.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đóng',
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
              );
            },
          );
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool? isSale = StorageUtils.instance.getBool(key: 'isSale');
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
            text: "Sale Manager",
            fontsize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: BlocBuilder<SaleManagerBloc, SaleManagerState>(
          builder: (context, state) {
            if (state is GetHomeSaleManagerStateLoading) {
              return Center(
                child: SizedBox(
                  width: 100.w,
                  height: 100.w,
                  child: Lottie.asset('assets/lottie/loading_kango.json'),
                ),
              );
            } else if (state is GetHomeSaleManagerStateSuccess) {
              return SlidableAutoCloseBehavior(
                child: RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  onRefresh: () async {
                    BlocProvider.of<SaleManagerBloc>(context)
                        .add(const GetHomeSaleManager());
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        ProfitRevenueChart(
                          chartData: (state
                                      .saleDashboard.charts.month.isEmpty &&
                                  state.saleDashboard.charts.price.isEmpty &&
                                  state.saleDashboard.charts.profit.isEmpty)
                              ? Charts(
                                  month: [],
                                  price: [0],
                                  profit: [0],
                                )
                              : state.saleDashboard.charts,
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        SalesDataTable(chartData: state.saleDashboard.charts),
                        SizedBox(
                          height: 10.h,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: Column(
                            children: [
                              saleResponse?.isLeader == null
                                  ? Container()
                                  : Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: 'Quản lý Sale',
                                          fontsize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        )
                                      ],
                                    ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Container(
                                child: ListView.builder(
                                  itemCount: state.saleDashboard.menus.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final menu =
                                        state.saleDashboard.menus[index];
                                    // Check both is_only_sale condition and leader_id condition
                                    bool shouldShowItem =
                                        menu.isOnlySale == isSale;
                                    // For specific menu items that should hide when leader_id is null
                                    if (menu.key == 'manager_team' ||
                                        menu.key == 'manager_support_fwd') {
                                      shouldShowItem = shouldShowItem &&
                                          saleResponse?.isLeader != null;
                                    }
                                    return shouldShowItem
                                        ? Column(
                                            children: [
                                              Container(
                                                height: 100.h,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Container(
                                                        height: 50.h,
                                                        width: 50.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color
                                                              .fromRGBO(
                                                              235, 245, 245, 1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Center(
                                                          child: FaIcon(
                                                            getIconFromString(menu
                                                                .icon), // Convert icon string to IconData
                                                            size:
                                                                18, // Matches the previous width/height
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary, // Customize color if needed
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        TextApp(
                                                          text: menu.name,
                                                          fontsize: 17.sp,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black54,
                                                        ),
                                                        SizedBox(
                                                          height: 10.sp,
                                                        ),
                                                        TextApp(
                                                          text: _getSubTitle(
                                                              menu.key,
                                                              state
                                                                  .saleDashboard),
                                                          fontsize: 15.sp,
                                                          color:
                                                              _getColorSubTitle(
                                                                  menu.key),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ],
                                                    ),
                                                    Spacer(),
                                                    GestureDetector(
                                                      onTap: _functionKey(
                                                          context, menu.key),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Container(
                                                          height: 50.h,
                                                          width: 50.w,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color
                                                                .fromRGBO(235,
                                                                245, 245, 1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: Center(
                                                            child: FaIcon(
                                                              Icons
                                                                  .arrow_forward, // Convert icon string to IconData
                                                              size:
                                                                  18, // Matches the previous width/height
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary, // Customize color if needed
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 15.h,
                                              )
                                            ],
                                          )
                                        : Container();
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is GetHomeSaleManagerStateFailure) {
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
                    Container(
                      width: 150.w,
                      height: 50.h,
                      child: ButtonApp(
                        event: () {},
                        text: "Xác nhận",
                        fontsize: 14.sp,
                        colorText: Colors.white,
                        backgroundColor: Colors.black,
                        outlineColor: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Center(
              child: NoDataFoundWidget(),
            );
          },
        ));
  }
}

// Add this widget below ProfitRevenueChart in your SaleManagerScreen
class SalesDataTable extends StatelessWidget {
  final Charts chartData;

  const SalesDataTable({
    Key? key,
    required this.chartData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.r),
                topRight: Radius.circular(8.r),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextApp(
                      text: "Tháng",
                      fontsize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: TextApp(
                      text: "Doanh Thu",
                      fontsize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: TextApp(
                      text: "Lợi Nhuận",
                      fontsize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: TextApp(
                      text: "% Rate",
                      fontsize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Data rows
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: chartData.month.length,
            itemBuilder: (context, index) {
              // Calculate % Rate for price (revenue)
              double percentageRate = 0.0;
              bool isIncreasing = true;

              if (index > 0) {
                // Compare with previous month
                int currentPrice = chartData.price[index];
                int previousPrice = chartData.price[index - 1];
                if (previousPrice != 0) {
                  percentageRate =
                      ((currentPrice - previousPrice) / previousPrice.abs()) *
                          100;
                }
                isIncreasing = currentPrice >= previousPrice;
              }

              return Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color:
                      index % 2 == 0 ? const Color(0xFFF5F5F5) : Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextApp(
                        text: chartData.month[index],
                        fontsize: 13.sp,
                        color: Colors.black87,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextApp(
                        text: "${_formatCurrency(chartData.price[index])} VND",
                        fontsize: 13.sp,
                        color: Colors.black87,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextApp(
                        text: "${_formatCurrency(chartData.profit[index])} VND",
                        fontsize: 13.sp,
                        color: chartData.profit[index] < 0
                            ? Colors.red
                            : Colors.green,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            percentageRate >= 0
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color:
                                percentageRate >= 0 ? Colors.green : Colors.red,
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          TextApp(
                            text:
                                "${percentageRate.round().abs()}%", // Display as integer
                            fontsize: 13.sp,
                            color:
                                percentageRate >= 0 ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int value) {
    return value.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}
