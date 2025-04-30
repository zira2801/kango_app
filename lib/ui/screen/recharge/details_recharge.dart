import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/models/recharge/details_recharge_model.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/button/status_box.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class DetailsReChargeBottom extends StatefulWidget {
  final DetailsDataRechargeModel detailsDataRechargeModel;
  const DetailsReChargeBottom(
      {super.key, required this.detailsDataRechargeModel});

  @override
  State<DetailsReChargeBottom> createState() => _DetailsReChargeBottomState();
}

class _DetailsReChargeBottomState extends State<DetailsReChargeBottom> {
  @override
  void initState() {
    log(httpImage + widget.detailsDataRechargeModel.data.recharge!.image);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 0.8,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50.w,
                  height: 5.w,
                  margin: EdgeInsets.only(top: 15.h, bottom: 15.h),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: Colors.grey),
                ),
                Expanded(
                    child: ListView(
                  padding: EdgeInsets.all(10.w),
                  controller: scrollController,
                  children: [
                    Row(
                      children: [
                        Text(
                          "TÀI KHOẢN YÊU CẦU",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontFamily: "Icomoon",
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Expanded(
                          child: Divider(
                            height: 1,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 60.w,
                          height: 60.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.w),
                              border: Border.all(width: 2, color: Colors.white),
                              color: Colors.black),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30.w),
                            child: widget.detailsDataRechargeModel.data.user
                                        ?.userLogo ==
                                    null
                                ? Image.asset(
                                    'assets/images/user_avatar.png',
                                    fit: BoxFit.contain,
                                  )
                                : Container(
                                    width: 60.w,
                                    height: 60.w,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30.w),
                                      child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl: httpImage +
                                              widget.detailsDataRechargeModel
                                                  .data.user!.userLogo,
                                          placeholder: (context, url) =>
                                              SizedBox(
                                                height: 20.w,
                                                width: 20.w,
                                                child: const Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                                'assets/images/user_avatar.png',
                                                fit: BoxFit.contain,
                                              )),
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(
                          width: 15.w,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                TextApp(
                                  text: (widget.detailsDataRechargeModel.data
                                                  .admin ==
                                              null ||
                                          widget.detailsDataRechargeModel.data
                                              .admin!.isEmpty)
                                      ? ''
                                      : widget.detailsDataRechargeModel.data
                                          .admin![0].userContactName,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontsize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5.w,
                            ),
                            TextApp(
                              text:
                                  (widget.detailsDataRechargeModel.data.admin ==
                                              null ||
                                          widget.detailsDataRechargeModel.data
                                              .admin!.isEmpty)
                                      ? ''
                                      : widget.detailsDataRechargeModel.data
                                          .admin![0].userCode,
                              color: Colors.black,
                              fontsize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Row(
                      children: [
                        TextApp(
                          text: 'Email:',
                          fontWeight: FontWeight.bold,
                          fontsize: 14.sp,
                          textAlign: TextAlign.center,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        TextApp(
                          isOverFlow: false,
                          softWrap: true,
                          text: widget
                              .detailsDataRechargeModel.data.user!.userName,
                          fontsize: 14.sp,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Row(
                      children: [
                        TextApp(
                          text: 'Công ty:',
                          fontWeight: FontWeight.bold,
                          fontsize: 14.sp,
                          textAlign: TextAlign.center,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        TextApp(
                          isOverFlow: false,
                          softWrap: true,
                          text: widget.detailsDataRechargeModel.data.user!
                              .userCompanyName,
                          fontsize: 14.sp,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Row(
                      children: [
                        Text(
                          "NỘI DUNG YÊU CẦU",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontFamily: "Icomoon",
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Expanded(
                          child: Divider(
                            height: 1,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Row(
                      children: [
                        TextApp(
                          text: 'Mã giao dịch :',
                          fontWeight: FontWeight.bold,
                          fontsize: 14.sp,
                          textAlign: TextAlign.center,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        TextApp(
                          isOverFlow: false,
                          softWrap: true,
                          text: widget
                              .detailsDataRechargeModel.data.recharge!.code,
                          fontsize: 14.sp,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Divider(
                      height: 25.h,
                    ),
                    Row(
                      children: [
                        TextApp(
                          text: "Phương thức :",
                          fontWeight: FontWeight.bold,
                          fontsize: 14.sp,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        TextApp(
                          softWrap: true,
                          isOverFlow: false,
                          text: widget.detailsDataRechargeModel.data.recharge!
                              .typeLabel,
                          fontWeight: FontWeight.normal,
                          fontsize: 14.sp,
                        ),
                      ],
                    ),
                    Divider(
                      height: 25.h,
                    ),
                    Row(
                      children: [
                        TextApp(
                          text: 'Số tiền giao dịch :',
                          fontWeight: FontWeight.bold,
                          fontsize: 14.sp,
                          textAlign: TextAlign.center,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        TextApp(
                          isOverFlow: false,
                          softWrap: true,
                          text:
                              "${MoneyFormatter(amount: (widget.detailsDataRechargeModel.data.recharge!.amount).toDouble()).output.withoutFractionDigits.toString()} đ",
                          fontsize: 14.sp,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Divider(
                      height: 25.h,
                    ),
                    Row(
                      children: [
                        TextApp(
                          text: 'Trạng thái :',
                          fontWeight: FontWeight.bold,
                          fontsize: 14.sp,
                          textAlign: TextAlign.center,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        SizedBox(
                            width: 100.w,
                            height: 20.h,
                            child: StatusBox(
                              icon: Icon(
                                widget.detailsDataRechargeModel.data.recharge!
                                            .status ==
                                        0
                                    ? Icons.replay_circle_filled
                                    : widget.detailsDataRechargeModel.data
                                                .recharge!.status ==
                                            1
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                color: Colors.white,
                                size: 14.sp,
                              ),
                              textStatus: widget.detailsDataRechargeModel.data
                                  .recharge!.statusLabel,
                              colorBoxStatus: widget.detailsDataRechargeModel
                                          .data.recharge!.status ==
                                      0
                                  ? const Color.fromARGB(255, 243, 219, 8)
                                  : widget.detailsDataRechargeModel.data
                                              .recharge!.status ==
                                          1
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.red,
                            )),
                      ],
                    ),
                    Divider(
                      height: 25.h,
                    ),
                    Row(
                      children: [
                        TextApp(
                          text: 'Nội dung :',
                          fontWeight: FontWeight.bold,
                          fontsize: 14.sp,
                          textAlign: TextAlign.center,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        SizedBox(
                          width: 180.w,
                          child: TextApp(
                            isOverFlow: false,
                            softWrap: true,
                            text: widget.detailsDataRechargeModel.data.recharge!
                                    .note ??
                                '',
                            fontsize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: 25.h,
                    ),
                    widget.detailsDataRechargeModel.data.recharge!.image == null
                        ? Container()
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 300.h,
                                  child: SizedBox(
                                    width: 60.w,
                                    height: 60.w,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.contain,
                                      imageUrl: httpImage +
                                          widget.detailsDataRechargeModel.data
                                              .recharge!.image,
                                      placeholder: (context, url) => SizedBox(
                                        height: 20.w,
                                        width: 20.w,
                                        child: const Center(
                                            child: CircularProgressIndicator()),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                    SizedBox(
                      height: 10.h,
                    ),
                    widget.detailsDataRechargeModel.data.recharge!.status != 0
                        ? Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "ADMIN XÁC NHẬN",
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontFamily: "Icomoon",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Expanded(
                                    child: Divider(
                                      height: 1,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 60.w,
                                    height: 60.w,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(30.w),
                                        border: Border.all(
                                            width: 2, color: Colors.white),
                                        color: Colors.black),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30.w),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(30.w),
                                        child: (widget.detailsDataRechargeModel
                                                        .data.admin ==
                                                    null ||
                                                widget.detailsDataRechargeModel
                                                    .data.admin!.isEmpty)
                                            ? Image.asset(
                                                'assets/images/user_avatar.png',
                                                fit: BoxFit.contain,
                                              )
                                            : Container(
                                                width: 60.w,
                                                height: 60.w,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.r),
                                                  child: CachedNetworkImage(
                                                    fit: BoxFit.cover,
                                                    imageUrl: httpImage +
                                                        widget
                                                            .detailsDataRechargeModel
                                                            .data
                                                            .admin![0]
                                                            .userLogo,
                                                    placeholder:
                                                        (context, url) =>
                                                            SizedBox(
                                                      height: 20.w,
                                                      width: 20.w,
                                                      child: const Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                    ),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        const Icon(Icons.error),
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15.w,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          TextApp(
                                            text: (widget.detailsDataRechargeModel
                                                            .data.admin ==
                                                        null ||
                                                    widget
                                                        .detailsDataRechargeModel
                                                        .data
                                                        .admin!
                                                        .isEmpty)
                                                ? ''
                                                : widget
                                                    .detailsDataRechargeModel
                                                    .data
                                                    .admin![0]
                                                    .userContactName,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontsize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5.w,
                                      ),
                                      TextApp(
                                        text: (widget.detailsDataRechargeModel
                                                        .data.admin ==
                                                    null ||
                                                widget.detailsDataRechargeModel
                                                    .data.admin!.isEmpty)
                                            ? ''
                                            : widget.detailsDataRechargeModel
                                                .data.admin![0].userCode,
                                        color: Colors.black,
                                        fontsize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Row(
                                children: [
                                  TextApp(
                                    text: 'Email:',
                                    fontWeight: FontWeight.bold,
                                    fontsize: 14.sp,
                                    textAlign: TextAlign.center,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  TextApp(
                                    isOverFlow: false,
                                    softWrap: true,
                                    text: (widget.detailsDataRechargeModel.data
                                                    .admin ==
                                                null ||
                                            widget.detailsDataRechargeModel.data
                                                .admin!.isEmpty)
                                        ? ''
                                        : widget.detailsDataRechargeModel.data
                                            .admin![0].userName,
                                    fontsize: 14.sp,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Row(
                                children: [
                                  TextApp(
                                    text: 'Ngày cập nhật:',
                                    fontWeight: FontWeight.bold,
                                    fontsize: 14.sp,
                                    textAlign: TextAlign.center,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  TextApp(
                                    isOverFlow: false,
                                    softWrap: true,
                                    text: (widget.detailsDataRechargeModel.data
                                                    .admin ==
                                                null ||
                                            widget.detailsDataRechargeModel.data
                                                .admin!.isEmpty)
                                        ? ''
                                        : formatDateTime(widget
                                            .detailsDataRechargeModel
                                            .data
                                            .admin![0]
                                            .updatedAt
                                            .toString()),
                                    fontsize: 14.sp,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Row(
                                children: [
                                  TextApp(
                                    text: 'Ghi chú:',
                                    fontWeight: FontWeight.bold,
                                    fontsize: 14.sp,
                                    textAlign: TextAlign.center,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  TextApp(
                                    isOverFlow: false,
                                    softWrap: true,
                                    text: widget.detailsDataRechargeModel.data
                                            .recharge!.adminNote ??
                                        '',
                                    fontsize: 14.sp,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: 40.h,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          // width: 120.w,
                          height: 40.h,
                          child: ButtonApp(
                            text: 'Đóng',
                            fontsize: 14.sp,
                            fontWeight: FontWeight.bold,
                            colorText: Colors.white,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            outlineColor: Theme.of(context).colorScheme.primary,
                            event: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                  ],
                ))
              ],
            ));
      },
    );
  }
}
