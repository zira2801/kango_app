import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:scan_barcode_app/data/models/shipment/all_unit_shipment.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/shipment/details_shipment_screen/details_tracking_shipment.dart';
import 'package:scan_barcode_app/ui/screen/shipment/details_shipment_screen/tracking_shipment.dart';
import 'package:scan_barcode_app/ui/widgets/button/status_box.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:scan_barcode_app/data/models/shipment/details_shipment.dart';

class PackageInfoWidgetTab2 extends StatelessWidget {
  final ScrollController scrollController;
  final DetailsShipmentModel? detailsShipment;
  final AllUnitShipmentModel? allUnitShipmentModel;
  const PackageInfoWidgetTab2(
      {required this.scrollController,
      required this.detailsShipment,
      required this.allUnitShipmentModel,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
            child: ListView(
          padding: EdgeInsets.all(10.w),
          controller: scrollController,
          children: [
            Container(
              width: 1.sw,
              // height: 200.h,
              margin: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 1.sw,
                    height: 30.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.r),
                          topRight: Radius.circular(15.r)),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outlined,
                          size: 18.sp,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        TextApp(
                          text: "Thông tin Packages",
                          color: Colors.white,
                          fontsize: 16.sp,
                          fontWeight: FontWeight.bold,
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.w),
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: detailsShipment?.shipment.packages.length,
                        itemBuilder: (context, index) {
                          final packageInfo =
                              detailsShipment?.shipment.packages;
                          final serviceInfo = detailsShipment?.shipment.service;
                          return Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40.w,
                                    height: 40.w,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20.w),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    child: Center(
                                      child: TextApp(
                                        text: (index + 1).toString(),
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontsize: 18.sp,
                                        textAlign: TextAlign.center,
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
                                      // Row(
                                      //   children: [
                                      //     TextApp(
                                      //       text: 'MÃ PACKAGE :',
                                      //       fontWeight: FontWeight.bold,
                                      //       fontsize: 14.sp,
                                      //       textAlign: TextAlign.center,
                                      //       color: Colors.black,
                                      //     ),
                                      //     SizedBox(
                                      //       width: 10.w,
                                      //     ),
                                      //     TextApp(
                                      //       colorDecoration: Theme.of(context)
                                      //           .colorScheme
                                      //           .primary,
                                      //       isOverFlow: false,
                                      //       softWrap: true,
                                      //       text: packageInfo?[index]
                                      //               .packageCode ??
                                      //           '',
                                      //       fontsize: 14.sp,
                                      //       fontWeight: FontWeight.bold,
                                      //       textAlign: TextAlign.center,
                                      //       color: Colors.black,
                                      //     ),
                                      //   ],
                                      // ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Row(
                                        children: [
                                          TextApp(
                                            text: 'MÃ HAWB :',
                                            fontWeight: FontWeight.bold,
                                            fontsize: 14.sp,
                                            textAlign: TextAlign.center,
                                            color: Colors.black,
                                          ),
                                          SizedBox(
                                            width: 10.w,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              packageInfo?[index]
                                                          .packageHawbCode !=
                                                      null
                                                  ? /*Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              DetailsTrackingShipment(
                                                                packageCode:
                                                                    packageInfo![
                                                                            index]
                                                                        .packageHawbCode!,
                                                              )),
                                                    )*/
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              TrackingShipmentStatusScreen(
                                                                packageHawbCode:
                                                                    packageInfo![
                                                                            index]
                                                                        .packageHawbCode!, //dataShipment.packageOfShipmentItemData[0].packageHawbCode!,
                                                                // packageCode: dataShipment.shipmentHawbCode.,
                                                              )),
                                                    )
                                                  : showCustomDialogModal(
                                                      context: navigatorKey
                                                          .currentContext!,
                                                      textDesc:
                                                          "Mã này không tồn tại",
                                                      title: "Thông báo",
                                                      colorButtonOk: Colors.red,
                                                      btnOKText: "Xác nhận",
                                                      typeDialog: "error",
                                                      eventButtonOKPress: () {},
                                                      isTwoButton: false);
                                            },
                                            child: TextApp(
                                              isUnderLine: true,
                                              isOverFlow: false,
                                              softWrap: true,
                                              text: packageInfo?[index]
                                                      .packageHawbCode ??
                                                  '',
                                              fontsize: 14.sp,
                                              textAlign: TextAlign.center,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Row(
                                        children: [
                                          TextApp(
                                            text: 'TYPE :',
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
                                            text: allUnitShipmentModel
                                                        ?.data.packageTypes[
                                                    packageInfo![index]
                                                        .packageType] ??
                                                '',
                                            fontsize: 14.sp,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Row(
                                        children: [
                                          TextApp(
                                            text: 'WEIGHT(KG) :',
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
                                                "${packageInfo?[index].packageWeight.toString()}kg",
                                            fontsize: 14.sp,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Row(
                                        children: [
                                          TextApp(
                                            text: 'CONVERTED WEIGHT :',
                                            fontWeight: FontWeight.bold,
                                            fontsize: 14.sp,
                                            textAlign: TextAlign.center,
                                            color: Colors.black,
                                          ),
                                          SizedBox(
                                            width: 10.w,
                                          ),
                                          Container(
                                            width: 150.w,
                                            child: TextApp(
                                              isOverFlow: false,
                                              softWrap: true,
                                              maxLines: 3,
                                              text:
                                                  "${packageInfo?[index].packageLength}(L) x ${packageInfo?[index].packageWidth}(W) x ${packageInfo?[index].packageHeight}(H) / ${serviceInfo?.serviceVolumetricMass} = ${packageInfo?[index].packageConvertedWeight}kg",
                                              fontsize: 14.sp,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Row(
                                        children: [
                                          TextApp(
                                            text: 'STATUS :',
                                            fontWeight: FontWeight.bold,
                                            fontsize: 14.sp,
                                            textAlign: TextAlign.center,
                                            color: Colors.black,
                                          ),
                                          SizedBox(
                                            width: 10.w,
                                          ),
                                          SizedBox(
                                              // width: 150.w,
                                              height: 25.h,
                                              child: StatusBox(
                                                icon: Icon(
                                                  Icons.history,
                                                  color: Colors.white,
                                                  size: 14.sp,
                                                ),
                                                textStatus: packageInfo?[index]
                                                            .packageStatus ==
                                                        "0"
                                                    ? "Created"
                                                    : packageInfo?[index]
                                                                .packageStatus ==
                                                            "1"
                                                        ? "Imported"
                                                        : packageInfo?[index]
                                                                    .packageStatus ==
                                                                "2"
                                                            ? "Exported"
                                                            : "Returned",
                                                colorBoxStatus: packageInfo?[
                                                                index]
                                                            .packageStatus ==
                                                        "0"
                                                    ? Colors.grey
                                                    : packageInfo?[index]
                                                                .packageStatus ==
                                                            "1"
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                        : packageInfo?[index]
                                                                    .packageStatus ==
                                                                "2"
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                            : Colors.red,
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Row(
                                        children: [
                                          TextApp(
                                            text: 'TRACKING CODE :',
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
                                            text: packageInfo?[index]
                                                    .packageTrackingCode ??
                                                '',
                                            fontsize: 14.sp,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Divider()
                            ],
                          );
                        }),
                  )
                ],
              ),
            ),
            Container(
              width: 1.sw,
              // height: 200.h,
              margin: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 1.sw,
                    height: 30.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.r),
                          topRight: Radius.circular(15.r)),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outlined,
                          size: 18.sp,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        TextApp(
                          text: "Thông tin Invoices",
                          color: Colors.white,
                          fontsize: 16.sp,
                          fontWeight: FontWeight.bold,
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.w),
                    child: detailsShipment!.shipment.invoices.isEmpty
                        ? const NoDataFoundWidget()
                        : ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount:
                                detailsShipment?.shipment.invoices.length,
                            itemBuilder: (context, index) {
                              final invoiceInfo =
                                  detailsShipment?.shipment.invoices;
                              return Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40.w,
                                        height: 40.w,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20.w),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                        child: Center(
                                          child: TextApp(
                                            text: (index + 1).toString(),
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontsize: 18.sp,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15.w,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: 1.sw - 120.w,
                                              maxHeight: 1.sw - 50.h,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextApp(
                                                  text: 'Tên Mặt Hàng :',
                                                  fontWeight: FontWeight.bold,
                                                  fontsize: 14.sp,
                                                  textAlign: TextAlign.center,
                                                  color: Colors.black,
                                                ),
                                                SizedBox(width: 10.w),
                                                Flexible(
                                                  child: TextApp(
                                                    text: invoiceInfo?[index]
                                                            .invoiceGoodsDetails ??
                                                        '',
                                                    fontsize: 14.sp,
                                                    textAlign: TextAlign.left,
                                                    softWrap:
                                                        true, // Cho phép xuống dòng
                                                    maxLines:
                                                        2, // Tùy chỉnh số dòng tối đa
                                                    isOverFlow:
                                                        false, // Không cần cắt bớt văn bản
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Row(
                                            children: [
                                              TextApp(
                                                text: 'Unit Type :',
                                                fontWeight: FontWeight.bold,
                                                fontsize: 14.sp,
                                                textAlign: TextAlign.center,
                                                color: Colors.black,
                                              ),
                                              SizedBox(
                                                width: 10.w,
                                              ),
                                              TextApp(
                                                isOverFlow: true,
                                                softWrap: true,
                                                text: allUnitShipmentModel
                                                            ?.data.invoiceUnits[
                                                        invoiceInfo![index]
                                                            .invoiceUnit] ??
                                                    '',
                                                maxLines: 1,
                                                fontsize: 14.sp,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Row(
                                            children: [
                                              TextApp(
                                                text: 'Unit :',
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
                                                text: invoiceInfo?[index]
                                                        .invoiceQuantity
                                                        .toString() ??
                                                    '',
                                                fontsize: 14.sp,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Row(
                                            children: [
                                              TextApp(
                                                text: 'Unit Price :',
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
                                                    "${MoneyFormatter(amount: (invoiceInfo?[index].invoicePrice ?? 0).toDouble()).output.withoutFractionDigits.toString()} đ",
                                                fontsize: 14.sp,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Row(
                                            children: [
                                              TextApp(
                                                text: 'Total :',
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
                                                    "${MoneyFormatter(amount: (invoiceInfo?[index].invoiceTotalPrice ?? 0).toDouble()).output.withoutFractionDigits.toString()} đ",
                                                fontsize: 14.sp,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  Divider()
                                ],
                              );
                            }),
                  )
                ],
              ),
            ),
          ],
        ))
      ],
    );
  }
}
