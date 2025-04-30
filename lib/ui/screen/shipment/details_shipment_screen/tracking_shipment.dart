import 'dart:developer';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/shipment/details_tracking_shipment/details_tracking_shipment_bloc.dart';
import 'package:scan_barcode_app/data/models/shipment/details_tracking.dart';
import 'package:scan_barcode_app/ui/screen/shipment/details_shipment_screen/details_tracking_shipment.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TrackingShipmentStatusScreen extends StatefulWidget {
  final String packageHawbCode;
  const TrackingShipmentStatusScreen({
    super.key,
    required this.packageHawbCode,
  });

  @override
  State<TrackingShipmentStatusScreen> createState() =>
      _TrackingShipmentStatusScreenState();
}

class _TrackingShipmentStatusScreenState
    extends State<TrackingShipmentStatusScreen> {
  int currentForm = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getDetailsTrackingShipment();
    BlocProvider.of<DetailsTrackingShipmentBloc>(context).add(
        GetDetailsTrackingShipmentEvent(
            packageHawbCode: widget.packageHawbCode));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          surfaceTintColor: Theme.of(context).colorScheme.primary,
          shadowColor: Theme.of(context).colorScheme.primary,
          title: TextApp(
            text: "Tóm tắt theo dõi",
            fontsize: 20.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        body: MultiBlocListener(
            listeners: [
              BlocListener<DetailsTrackingShipmentBloc,
                  DetailsTrackingShipmentState>(listener: (context, state) {
                if (state is DetailsTrackingShipmentStateSuccess) {
                  log("DetailsTrackingShipmentStateSuccess");
                } else if (state is DetailsTrackingShipmentStateFailure) {
                  log("DetailsTrackingShipmentStateFailure");
                }
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20.h,
                        ),
                        // TextApp(
                        //   text: "Ngày giao hàng".toUpperCase(),
                        //   fontWeight: FontWeight.bold,
                        //   fontsize: 14.sp,
                        // ),
                        // TextApp(
                        //   textAlign: TextAlign.center,
                        //   text: "Th2, 16thg 9, 2024 trước 8:00 CH",
                        //   // text: state.data.data.shipment.senderAddress,
                        //   fontsize: 18.sp,
                        // ),
                        // TextApp(
                        //   text: "Dự kiến: 10:40 - 14:40",
                        //   fontsize: 18.sp,
                        // ),
                        // SizedBox(
                        //   height: 30.h,
                        // ),
                        // TextApp(
                        //   text: "Đang được vận chuyển".toUpperCase(),
                        //   fontWeight: FontWeight.bold,
                        //   fontsize: 14.sp,
                        // ),
                        // TextApp(
                        //   text: "Tại cơ sở phân loại của nơi nhận hàng",
                        //   fontsize: 18.sp,
                        // ),
                        // TextApp(
                        //   text: "ORLANDO, FL",
                        //   fontsize: 18.sp,
                        // ),
                        TextApp(
                          text: "Thông tin gửi".toUpperCase(),
                          fontWeight: FontWeight.bold,
                          fontsize: 14.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        TextApp(
                          textAlign: TextAlign.center,
                          text: state.data.data.shipment.senderContactName,
                          fontsize: 16.sp,
                        ),
                        TextApp(
                          text: state.data.data.shipment.senderTelephone,
                          fontsize: 16.sp,
                        ),
                        SizedBox(
                          width: 1.sw,
                          child: TextApp(
                            textAlign: TextAlign.center,
                            text: state.data.data.shipment.senderAddress,
                            fontsize: 16.sp,
                            softWrap: true,
                            isOverFlow: false,
                            maxLines: 3,
                          ),
                        ),
                        SizedBox(
                          height: 30.h,
                        ),
                        TextApp(
                          text: "Thông tin nhận".toUpperCase(),
                          fontWeight: FontWeight.bold,
                          fontsize: 14.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        TextApp(
                          text: state.data.data.shipment.receiverContactName,
                          fontsize: 16.sp,
                        ),
                        TextApp(
                          text: state.data.data.shipment.receiverTelephone,
                          fontsize: 16.sp,
                        ),
                        TextApp(
                          text: state.data.data.shipment.receiverAddress1,
                          fontsize: 16.sp,
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Container(
                            height: 480.h,
                            child: _AppTimeline(
                              detailsTrackingModel: state.data,
                            )),
                        SizedBox(
                          height: 10.h,
                        ),
                        ButtonApp(
                            event: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DetailsTrackingShipment(
                                          packageCode: widget.packageHawbCode,
                                        )),
                              );
                            },
                            text: "Chi tiết",
                            colorText: Colors.white,
                            fontWeight: FontWeight.bold,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            outlineColor: Theme.of(context).colorScheme.primary)
                      ],
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
            )));
  }
}

const appSteps = [
  'Configure',
  'Code',
  'Test',
  'Deploy',
  'Scale',
  'Something',
];

class _AppTimeline extends StatelessWidget {
  final DetailsTrackingModel detailsTrackingModel;
  _AppTimeline({Key? key, required this.detailsTrackingModel})
      : super(key: key);

  List<Map<String, dynamic>> _getTrackingSteps() {
    final steps = <Map<String, dynamic>>[];
    final rightLocation = detailsTrackingModel.data.rightLocation;

    if (rightLocation?.labelCreated != null) {
      steps.add({
        'title': 'FROM',
        'address': rightLocation!.labelCreated!.packageTrackingAddress,
        'dateTime': rightLocation.labelCreated!.packageTrackingDate,
        'note': rightLocation.labelCreated!.packageTrackingNote,
        'isFirst': true, // Đánh dấu item đầu tiên
      });
    }

    if (rightLocation?.weHaveYourParcel != null) {
      steps.add({
        'title': rightLocation!.weHaveYourParcel!.packageTrackingNote,
        'address': rightLocation.weHaveYourParcel!.packageTrackingAddress,
        'dateTime': rightLocation.weHaveYourParcel!.packageTrackingDate,
        'note': rightLocation.weHaveYourParcel!.packageTrackingNote,
        'isFirst': false,
      });
    }

    if (rightLocation?.inTransit != null) {
      steps.add({
        'title': rightLocation!.inTransit!.packageTrackingNote,
        'address': rightLocation.inTransit!.packageTrackingAddress,
        'dateTime': rightLocation.inTransit!.packageTrackingDate,
        'note': rightLocation.inTransit!.packageTrackingNote,
        'isFirst': false,
      });
    }

    if (rightLocation?.ortherLocal != null) {
      steps.add({
        'title': rightLocation!.ortherLocal!.packageTrackingNote,
        'address': rightLocation.ortherLocal!.packageTrackingAddress,
        'dateTime': rightLocation.ortherLocal!.packageTrackingDate,
        'note': rightLocation.ortherLocal!.packageTrackingNote,
        'isFirst': false,
      });
    }

    if (rightLocation?.checkDelivered != null) {
      steps.add({
        'title': rightLocation!.checkDelivered!.packageTrackingNote,
        'address': rightLocation.checkDelivered!.packageTrackingAddress,
        'dateTime': rightLocation.checkDelivered!.packageTrackingDate,
        'note': rightLocation.checkDelivered!.packageTrackingNote,
        'isFirst': false,
      });
    }

    return steps;
  }

  @override
  Widget build(BuildContext context) {
    final trackingSteps = _getTrackingSteps();
    final currentStep = trackingSteps.length - 1;

    return Container(
      margin: EdgeInsets.all(8.w),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: trackingSteps.length,
        itemBuilder: (BuildContext context, int index) {
          var beforeLineStyle = LineStyle(
            thickness: 15.w,
            color: const Color(0xFFD4D4D4),
          );
          var afterLineStyle = LineStyle(
            thickness: 15.w,
            color: Color(0xFFD4D4D4),
          );

          if (index <= currentStep) {
            beforeLineStyle = LineStyle(
              thickness: 15.w,
              color: Theme.of(context).colorScheme.primary,
            );
            afterLineStyle = LineStyle(
              thickness: 15.w,
              color: Theme.of(context).colorScheme.primary,
            );
          }

          if (index == currentStep) {
            afterLineStyle = LineStyle(
              thickness: 15.w,
              color: Color(0xFFD4D4D4),
            );
          }

          final isFirst = index == 0;
          final isLast = index == trackingSteps.length - 1;
          var indicatorX = 0.5;
          if (isFirst) {
            indicatorX = 0.3;
          } else if (isLast) {
            indicatorX = 0.7;
          }

          final step = trackingSteps[index];

          return TimelineTile(
            axis: TimelineAxis.vertical,
            alignment: TimelineAlign.start,
            lineXY: 0.8,
            isFirst: isFirst,
            isLast: isLast,
            beforeLineStyle: beforeLineStyle,
            afterLineStyle: afterLineStyle,
            hasIndicator: true,
            indicatorStyle: IndicatorStyle(
              width: 50.w,
              height: index == currentStep ? 50.w : 15.w,
              indicatorXY: indicatorX,
              color: const Color(0xFFD4D4D4),
              indicator: index == currentStep
                  ? _IndicatorCurrentApp()
                  : index <= currentStep
                      ? const _IndicatorApp()
                      : _IndicatorUnselectedApp(),
            ),
            endChild: Container(
              constraints: BoxConstraints(minWidth: 120.w),
              margin: EdgeInsets.all(8.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 8.w),
                  _buildTimelineTile(
                    title: step['title'].toString().toUpperCase(),
                    subtitle: step['isFirst'] == true
                        ? '${step['address']}\n${step['note']}'
                        : step['address'],
                    dateTime: formatDateTime(step['dateTime']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _IndicatorCurrentApp extends StatelessWidget {
  const _IndicatorCurrentApp();

  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      startDelay: const Duration(milliseconds: 1000),
      glowColor: Theme.of(context).colorScheme.primary,
      glowShape: BoxShape.circle,
      animate: true,
      glowRadiusFactor: 0.3,
      curve: Curves.fastOutSlowIn,
      child: Material(
          elevation: 1.0,
          shape: CircleBorder(),
          color: Colors.transparent,
          child: Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              // shape: BoxShape.circle,
              borderRadius: BorderRadius.circular(25.w),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Icon(
              Icons.arrow_right_alt_rounded,
              color: Colors.white,
              size: 36.sp,
            ),
          )),
    );
  }
}

class _IndicatorApp extends StatelessWidget {
  const _IndicatorApp();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Center(
        child: Container(
          width: 10.w,
          height: 10.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _IndicatorUnselectedApp extends StatelessWidget {
  const _IndicatorUnselectedApp();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFD4D4D4),
      ),
      child: Center(
        child: Container(
          width: 10.w,
          height: 10.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

Widget _buildTimelineTile({
  required String title,
  required String subtitle,
  required String dateTime,
}) {
  return ConstrainedBox(
    constraints: BoxConstraints(maxWidth: 1.sw - 100.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextApp(
          text: title,
          fontsize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        if (subtitle.isNotEmpty)
          TextApp(
            text: subtitle,
            fontsize: 14.sp,
            fontWeight: FontWeight.normal,
            isOverFlow: false,
            softWrap: true,
            maxLines: 3,
            color: Colors.black,
          ),
        if (dateTime.isNotEmpty)
          TextApp(
            text: dateTime,
            fontsize: 12.sp,
            fontWeight: FontWeight.normal,
            color: Colors.grey,
          )
      ],
    ),
  );
}
