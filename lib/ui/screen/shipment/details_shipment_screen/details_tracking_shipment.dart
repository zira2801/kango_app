import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/shipment/details_tracking_shipment/details_tracking_shipment_bloc.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:timeline_tile/timeline_tile.dart';

class DetailsTrackingShipment extends StatefulWidget {
  final String packageCode;
  const DetailsTrackingShipment({Key? key, required this.packageCode})
      : super(key: key);

  @override
  State<DetailsTrackingShipment> createState() =>
      _DetailsTrackingShipmentState();
}

class _DetailsTrackingShipmentState extends State<DetailsTrackingShipment> {
  void getDetailsTrackingShipment() {
    BlocProvider.of<DetailsTrackingShipmentBloc>(context).add(
        GetDetailsTrackingShipmentEvent(packageHawbCode: widget.packageCode));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getDetailsTrackingShipment();
    getDetailsTrackingShipment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          surfaceTintColor: Theme.of(context).colorScheme.primary,
          shadowColor: Theme.of(context).colorScheme.primary,
          title: TextApp(
            text: "Chi tiết theo dõi",
            fontsize: 20.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        body: MultiBlocListener(
          listeners: [
            BlocListener<DetailsTrackingShipmentBloc,
                DetailsTrackingShipmentState>(listener: (context, state) async {
              if (state is DetailsTrackingShipmentStateSuccess) {
              } else if (state is DetailsTrackingShipmentStateFailure) {}
            }),
          ],
          child: BlocBuilder<DetailsTrackingShipmentBloc,
              DetailsTrackingShipmentState>(
            builder: (context, state) {
              if (state is DetailsTrackingShipmentStateLoading) {
                return Center(
                  child: SizedBox(
                    width: 100.w,
                    height: 100.w,
                    child: Lottie.asset('assets/lottie/loading_kango.json'),
                  ),
                );
              } else if (state is DetailsTrackingShipmentStateSuccess) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(15.w),
                    child: Column(
                      children: [
                        TextApp(
                          text: "Shipment Information".toUpperCase(),
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontsize: 22.sp,
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.card_giftcard,
                              size: 32.sp,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            TextApp(
                              text: "SHIPMENT OVERVIEW",
                              color: Colors.black,
                              fontsize: 16.sp,
                              fontWeight: FontWeight.normal,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.w,
                        ),
                        Column(
                          children: [
                            Container(
                              color: Colors.grey.withOpacity(0.5),
                              padding: EdgeInsets.all(5.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextApp(
                                    text: "TRACKING NUMBER",
                                    color: Colors.black,
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  Row(
                                    children: [
                                      TextApp(
                                        text:
                                            state.data.data.package.packageCode,
                                        color: Colors.black,
                                        fontsize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        textAlign: TextAlign.end,
                                      ),
                                      SizedBox(
                                        width: 10.w,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(
                                                  text: state.data.data.package
                                                      .packageCode))
                                              .then(
                                            (value) {
                                              //only if ->
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          "Đã copy tracking ID !"))); // -> show a notification
                                            },
                                          );
                                        },
                                        child: Icon(
                                          Icons.copy,
                                          size: 18.sp,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              // color: Colors.grey.withOpacity(0.5),
                              padding: EdgeInsets.all(5.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextApp(
                                    text: "FROM",
                                    color: Colors.black,
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  SizedBox(
                                    width: 200.w,
                                  ),
                                  Expanded(
                                    child: TextApp(
                                      maxLines: 3,
                                      isOverFlow: false,
                                      softWrap: true,
                                      textAlign: TextAlign.end,
                                      text: state
                                          .data.data.shipment.senderAddress,
                                      color: Colors.black,
                                      fontsize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.grey.withOpacity(0.5),
                              padding: EdgeInsets.all(5.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextApp(
                                    text: "TO",
                                    color: Colors.black,
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  SizedBox(
                                    width: 200.w,
                                  ),
                                  Expanded(
                                    child: TextApp(
                                      maxLines: 3,
                                      isOverFlow: false,
                                      softWrap: true,
                                      textAlign: TextAlign.end,
                                      text: state
                                          .data.data.shipment.receiverAddress1,
                                      color: Colors.black,
                                      fontsize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              // color: Colors.grey.withOpacity(0.5),
                              padding: EdgeInsets.all(5.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextApp(
                                    text: "DATE SEND",
                                    color: Colors.black,
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  TextApp(
                                    text: formatDateTime(state
                                        .data.data.shipment.createdAt
                                        .toString()),
                                    color: Colors.black,
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    textAlign: TextAlign.end,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.grey.withOpacity(0.5),
                              padding: EdgeInsets.all(5.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextApp(
                                    text: "SHIPMENT NAME",
                                    color: Colors.black,
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  Expanded(
                                    child: TextApp(
                                      text: state
                                          .data.data.shipment.shipmentGoodsName,
                                      color: Colors.black,
                                      fontsize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.w,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.car_crash,
                              size: 32.sp,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            TextApp(
                              text: "SERVICES",
                              color: Colors.black,
                              fontsize: 16.sp,
                              fontWeight: FontWeight.normal,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.w,
                        ),
                        Column(
                          children: [
                            Container(
                              color: Colors.grey.withOpacity(0.5),
                              padding: EdgeInsets.all(5.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextApp(
                                    text: "SERVICES",
                                    color: Colors.black,
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  TextApp(
                                    text: state
                                        .data.data.shipment.service!.serviceName
                                        .toString(),
                                    color: Colors.black,
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    textAlign: TextAlign.end,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.w,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.menu_book,
                              size: 32.sp,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            TextApp(
                              text: "SHIPMENT INFORMATION",
                              color: Colors.black,
                              fontsize: 16.sp,
                              fontWeight: FontWeight.normal,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.w,
                        ),
                        Column(
                          children: [
                            Container(
                              color: Colors.grey.withOpacity(0.5),
                              padding: EdgeInsets.all(5.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextApp(
                                    text: "Đóng gói".toUpperCase(),
                                    color: Colors.black,
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  Row(
                                    children: [
                                      TextApp(
                                        text: state.data.data.packageTypes[state
                                            .data.data.package.packageType],
                                        color: Colors.black,
                                        fontsize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        textAlign: TextAlign.end,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              // color: Colors.grey.withOpacity(0.5),
                              padding: EdgeInsets.all(5.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextApp(
                                    text: "Tổng lô hàng".toUpperCase(),
                                    color: Colors.black,
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  SizedBox(
                                    width: 200.w,
                                  ),
                                  Expanded(
                                    child: TextApp(
                                      maxLines: 3,
                                      isOverFlow: false,
                                      softWrap: true,
                                      textAlign: TextAlign.end,
                                      text: state
                                          .data.data.shipment.packages.length
                                          .toString(),
                                      color: Colors.black,
                                      fontsize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.grey.withOpacity(0.5),
                              padding: EdgeInsets.all(5.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextApp(
                                    text: "Giá trị đơn hàng".toUpperCase(),
                                    color: Colors.black,
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  SizedBox(
                                    width: 200.w,
                                  ),
                                  Expanded(
                                    child: TextApp(
                                      textAlign: TextAlign.end,
                                      maxLines: 3,
                                      isOverFlow: false,
                                      softWrap: true,
                                      text:
                                          "${state.data.data.shipment.shipmentValue} đ",
                                      color: Colors.black,
                                      fontsize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              // color: Colors.grey.withOpacity(0.5),
                              padding: EdgeInsets.all(5.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextApp(
                                    text: "Phí giao hàng".toUpperCase(),
                                    color: Colors.black,
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  TextApp(
                                    textAlign: TextAlign.end,
                                    text:
                                        "${state.data.data.shipment.shipmentAmountTransport} đ",
                                    color: Colors.black,
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.grey.withOpacity(0.5),
                              padding: EdgeInsets.all(5.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextApp(
                                    text: "Phí dịch vụ".toUpperCase(),
                                    color: Colors.black,
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  TextApp(
                                    textAlign: TextAlign.end,
                                    text:
                                        "${state.data.data.shipment.shipmentAmountService} đ",
                                    color: Colors.black,
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.w,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.task,
                              size: 32.sp,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            TextApp(
                              text: "PACKAGE DETAILS",
                              color: Colors.black,
                              fontsize: 16.sp,
                              fontWeight: FontWeight.normal,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.w,
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: state.data.data.shipment.packages.length,
                          itemBuilder: (context, index) {
                            var subPackageData =
                                state.data.data.shipment.packages[index];
                            return Column(
                              children: [
                                Container(
                                  color: Colors.grey.withOpacity(0.5),
                                  padding: EdgeInsets.all(5.w),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      TextApp(
                                        text: "Mã kiện hàng".toUpperCase(),
                                        color: Colors.black,
                                        fontsize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      TextApp(
                                        textAlign: TextAlign.end,
                                        text: subPackageData.packageCode,
                                        color: Colors.black,
                                        fontsize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  // color: Colors.grey.withOpacity(0.5),
                                  padding: EdgeInsets.all(5.w),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      TextApp(
                                        text: "Số lượng".toUpperCase(),
                                        color: Colors.black,
                                        fontsize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      TextApp(
                                        textAlign: TextAlign.end,
                                        text: subPackageData.packageQuantity
                                            .toString(),
                                        color: Colors.black,
                                        fontsize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  // color: Colors.grey.withOpacity(0.5),
                                  padding: EdgeInsets.all(5.w),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      TextApp(
                                        text: "Cân nặng".toUpperCase(),
                                        color: Colors.black,
                                        fontsize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      TextApp(
                                        textAlign: TextAlign.end,
                                        text: subPackageData.packageWeight
                                            .toString(),
                                        color: Colors.black,
                                        fontsize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  // color: Colors.grey.withOpacity(0.5),
                                  padding: EdgeInsets.all(5.w),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      TextApp(
                                        text: "	Mô tả".toUpperCase(),
                                        color: Colors.black,
                                        fontsize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      Expanded(
                                        child: TextApp(
                                          textAlign: TextAlign.end,
                                          text: subPackageData
                                                  .packageDescription ??
                                              '',
                                          color: Colors.black,
                                          fontsize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          maxLines: 3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        TextApp(
                          text: "TRAVEL HISTORY",
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontsize: 22.sp,
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        state.data.data.tracking?.tracktry.length != null
                            ? Container(
                                width: 1.sw,
                                height: 500.h,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: // Ví dụ
                                        state.data.data.trackingLocal!.length,
                                    itemBuilder: (context, index) {
                                      var itemCheckpoints =
                                          state.data.data.trackingLocal![index];
                                      return _buildTimelineTile(
                                          // indicator: const _IconIndicator(
                                          //   iconData: WeatherIcons.cloudy,
                                          //   size: 20,
                                          // ),
                                          hour: formatDateTime(itemCheckpoints
                                              .packageTrackingDate
                                              .toString()),
                                          title: itemCheckpoints
                                              .packageTrackingNote
                                              .toUpperCase(),
                                          colorTitle: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          content: itemCheckpoints
                                              .packageTrackingAddress,
                                          colorContent: Theme.of(context)
                                              .colorScheme
                                              .secondary);
                                    }))
                            : Container()
                      ],
                    ),
                  ),
                );
              } else if (state is DetailsTrackingShipmentStateFailure) {
                return ErrorDialog(
                  eventConfirm: () {
                    Navigator.pop(context);
                  },
                  errorText: 'Failed to fetch orders: ${state.message}',
                );
              }
              return const Center(child: NoDataFoundWidget());
            },
          ),
        ));
  }
}

TimelineTile _buildTimelineTile({
  String hour = '',
  String title = '',
  String content = '',
  bool isLast = false,
  Color colorTitle = Colors.black,
  Color colorContent = Colors.black,
}) {
  return TimelineTile(
    alignment: TimelineAlign.manual,
    lineXY: 0.3,
    beforeLineStyle: LineStyle(color: Colors.grey.withOpacity(0.7)),
    indicatorStyle: IndicatorStyle(
        indicatorXY: 0.3,
        drawGap: true,
        width: 20.w,
        height: 20.w,
        color: Colors.black),
    isLast: isLast,
    startChild: Center(
      child: Container(
        alignment: const Alignment(0.0, -0.50),
        child: Text(
          hour,
        ),
      ),
    ),
    endChild: Padding(
      padding: EdgeInsets.only(left: 16, right: 10.w, top: 10.w, bottom: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextApp(
            text: title,
            fontWeight: FontWeight.bold,
            fontsize: 16.sp,
            color: colorTitle,
          ),
          SizedBox(height: 5.h),
          TextApp(
            text: content,
            fontWeight: FontWeight.normal,
            fontsize: 14.sp,
            color: colorContent,
            maxLines: 5,
          ),
          SizedBox(height: 5.h),
        ],
      ),
    ),
  );
}
