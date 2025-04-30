import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/sale_manager/home_sale_manager/home_sale_manager_bloc.dart';
import 'package:scan_barcode_app/ui/screen/sale_manager/sale_screen/list_cost_fwd.dart';
import 'package:scan_barcode_app/ui/screen/sale_manager/sale_screen/list_shipment_fwd.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class DetailFwdSupportScreen extends StatefulWidget {
  final String companyCode;
  const DetailFwdSupportScreen({super.key, required this.companyCode});

  @override
  State<DetailFwdSupportScreen> createState() => _DetailFwdSupportState();
}

class _DetailFwdSupportState extends State<DetailFwdSupportScreen> {
  @override
  void initState() {
    _fecthData();
    super.initState();
  }

  void _fecthData() {
    BlocProvider.of<GetDetailFwdSupportBloc>(context)
        .add(GetDetailFwdSupport(companyCode: widget.companyCode));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextApp(
          text: "Thông tin FWD hỗ trợ",
          fontWeight: FontWeight.bold,
          fontsize: 20.sp,
        ),
      ),
      body: BlocConsumer<GetDetailFwdSupportBloc, SaleManagerState>(
        listener: (BuildContext context, state) {},
        builder: (context, state) {
          if (state is GetDetailsFwdSupportLoading) {
            return Center(
              child: SizedBox(
                width: 100.w,
                height: 100.w,
                child: Lottie.asset('assets/lottie/loading_kango.json'),
              ),
            );
          } else if (state is GetDetailsFwdSupportFailure) {
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
          } else if (state is GetDetailsFwdSupportSuccess) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextApp(
                          text: state
                              .responseFwdSupportModel.company!.userCompanyName
                              .toString(),
                          fontsize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextApp(
                              text: 'Nhân viên kinh doanh phụ trách: ',
                              fontsize: 18.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextApp(
                                  text: state.responseFwdSupportModel
                                      .saleManager!.userContactName
                                      .toString(),
                                  fontsize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                                SizedBox(width: 10.h),
                                TextApp(
                                  text:
                                      '[${state.responseFwdSupportModel.saleManager!.userCode.toString()}]',
                                  fontsize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        TextApp(
                          text: 'Thông tin',
                          fontsize: 18.sp,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(
                              width: 5.sp,
                            ),
                            TextApp(
                              text: 'Người đại diện: ',
                              fontsize: 18.sp,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 5.sp,
                        ),
                        Expanded(
                          child: TextApp(
                            text: state.responseFwdSupportModel.company!
                                .userContactName
                                .toString(),
                            fontsize: 18.sp,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(
                              width: 5.sp,
                            ),
                            TextApp(
                              text: 'Mã tài khoản: ',
                              fontsize: 18.sp,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 5.sp,
                        ),
                        Expanded(
                          child: TextApp(
                            text: state
                                .responseFwdSupportModel.company!.userCode
                                .toString(),
                            fontsize: 18.sp,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.phoneSquare,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(
                              width: 5.sp,
                            ),
                            TextApp(
                              text: 'Phone: ',
                              fontsize: 18.sp,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 5.sp,
                        ),
                        Expanded(
                          child: TextApp(
                            text: state
                                .responseFwdSupportModel.company!.userPhone
                                .toString(),
                            fontsize: 18.sp,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_filled,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(
                              width: 5.sp,
                            ),
                            TextApp(
                              text: 'Ngày tạo: ',
                              fontsize: 18.sp,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 5.sp,
                        ),
                        Expanded(
                          child: TextApp(
                            text: formatDateTime(state
                                .responseFwdSupportModel.company!.createdAt
                                .toString()),
                            fontsize: 18.sp,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        TextApp(
                          text: 'Quản lý',
                          fontsize: 18.sp,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 50, right: 50),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ListShipmentFwdScreen(
                                            userID: state
                                                .responseFwdSupportModel
                                                .company!
                                                .userId!
                                                .toInt(),
                                          )));
                            },
                            child: Container(
                              width: double.infinity,
                              height: 50.h,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Center(
                                child: TextApp(
                                  text: "List đơn",
                                  color: Colors.white,
                                  fontsize: 17.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 50, right: 50),
                          child: GestureDetector(
                            onTap: () {
                              final String? position = StorageUtils.instance
                                  .getString(key: 'user_position');
                              final String normalizedPosition =
                                  position!.trim().toLowerCase();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ListCostFwdScreen(
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
                                            companyID: state
                                                .responseFwdSupportModel
                                                .company!
                                                .userId,
                                          )));
                            },
                            child: Container(
                              width: double.infinity,
                              height: 50.h,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Center(
                                child: TextApp(
                                  text: "Bảng giá cost",
                                  color: Colors.white,
                                  fontsize: 17.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          } else {
            return const NoDataFoundWidget();
          }
        },
      ),
    );
  }
}
