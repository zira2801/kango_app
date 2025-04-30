import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/notification/notification_bloc.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/models/notification/detail_notification.dart';
import 'package:scan_barcode_app/data/models/notification/notificaion.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/html/html_screen.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class NotificationDetail extends StatelessWidget {
  final NotificationItem notificationItem;
  const NotificationDetail({super.key, required this.notificationItem});
  String formatDate(String dateString) {
    DateTime dateTime =
        DateTime.parse(dateString).add(const Duration(hours: 7));
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DetailsNotificationBloc()
        ..add(HandleDetailNotification(
            notificaionID: notificationItem.notificationId)),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: TextApp(
            text: 'Chi tiết thông báo',
            fontsize: 20.w,
            fontWeight: FontWeight.w800,
          ),
        ),
        body: BlocBuilder<DetailsNotificationBloc, GetDetailsNotificationState>(
            builder: (context, state) {
          if (state is HandleGetDetailsNotificationLoading) {
            return Center(
              child: SizedBox(
                width: 100.w,
                height: 100.w,
                child: Lottie.asset('assets/lottie/loading_kango.json'),
              ),
            );
          } else if (state is HandleGetDetailsNotificationSuccess) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2), // Màu bóng
                            blurRadius: 8, // Độ mờ của bóng
                            spreadRadius: 2, // Độ lan rộng của bóng
                            offset:
                                Offset(0, 4), // Điều chỉnh hướng bóng (X, Y)
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Image.network(
                                    httpImage +
                                        notificationItem.user.userLogo
                                            .toString(),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const SizedBox(), // Ẩn nếu lỗi
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/logo_kango_2.png',
                                  fit: BoxFit.contain, // Kích thước gốc
                                ),
                                // Center(
                                //   child: Container(
                                //     height: 200.h,
                                //     width: 200.w,
                                //     child: Image.asset(
                                //       'assets/images/no_image_available.png',
                                //       fit: BoxFit.contain, // Kích thước gốc
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                            SizedBox(
                              height: 10.w,
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: TextApp(
                                textAlign: TextAlign.center,
                                text: notificationItem.user.userCompanyName,
                                color: Colors.black,
                                fontsize: 25.w,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 10.w,
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: TextApp(
                                textAlign: TextAlign.center,
                                text: notificationItem.user.userContactName,
                                color: Colors.black54,
                                fontsize: 20.w,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 15.w,
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.w),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextApp(
                                    text: 'Contact Phone',
                                    color: Colors.black,
                                    fontsize: 16.w,
                                  ),
                                  const Spacer(),
                                  TextApp(
                                    text: notificationItem.user.userPhone,
                                    fontsize: 16.w,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10.w,
                            ),
                            Divider(
                              height: 1.w,
                              color: Colors.black26,
                            ),
                            SizedBox(
                              height: 10.w,
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.w),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextApp(
                                    text: 'Email',
                                    color: Colors.black,
                                    fontsize: 16.w,
                                  ),
                                  SizedBox(
                                      width: 10
                                          .w), // Add some spacing between the label and value
                                  Expanded(
                                    child: TextApp(
                                      text: notificationItem.user.userName,
                                      fontsize: 16.w,
                                      color: Colors.black54,
                                      textAlign: TextAlign
                                          .right, // Align text to the right
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10.w,
                            ),
                            Divider(
                              height: 1.w,
                              color: Colors.black26,
                            ),
                            SizedBox(
                              height: 10.w,
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.w),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextApp(
                                    text: 'Hotline',
                                    color: Colors.black,
                                    fontsize: 16.w,
                                  ),
                                  const Spacer(),
                                  TextApp(
                                    text:
                                        '${notificationItem.user.userPhone} - 0921.44.1111',
                                    fontsize: 16.w,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.w,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10.0, bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2), // Màu bóng
                            blurRadius: 8, // Độ mờ của bóng
                            spreadRadius: 2, // Độ lan rộng của bóng
                            offset:
                                Offset(0, 4), // Điều chỉnh hướng bóng (X, Y)
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: TextApp(
                                textAlign: TextAlign.start,
                                text: notificationItem.notificationTitle,
                                maxLines: 3,
                                fontsize: 18.w,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5.w,
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width -
                                  30.w, // Đảm bảo kích thước phù hợp
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: HtmlViewer(
                                  htmlData: state.data.notificationContent),
                            ),
                          ),
                          SizedBox(
                            height: 20.w,
                          ),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: TextApp(
                                textAlign: TextAlign.start,
                                text:
                                    'Ngày đăng: ${formatDate(state.data.createdAt.toString())}',
                                maxLines: 3,
                                fontsize: 14.w,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.w,
                  )
                ],
              ),
            );
          } else if (state is HandleGetDetailsNotificationFailure) {
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
                    text: "Đã có lỗi xảy ra!.",
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
                      event: () {
                        Navigator.pop(context);
                      },
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
        }),
      ),
    );
  }
}
