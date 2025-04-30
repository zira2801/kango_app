import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/data/models/audit_epacket/audit_epacket_service.dart';
import 'package:scan_barcode_app/data/models/utils/list_branchs_model.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'dart:math' as math;

// ignore: must_be_immutable
class FilterTransferWidget extends StatelessWidget {
  final TextEditingController dateStartController;
  final TextEditingController dateEndController;
  final bool isPakageManger;
  final Function selectDayStart;
  final Function selectDayEnd;
  final Function clearFliterFunction;
  final Function applyFliterFunction;
  final String? Function() getEndDateError;
  FilterTransferWidget(
      {required this.dateStartController,
      required this.dateEndController,
      required this.selectDayStart,
      required this.selectDayEnd,
      required this.getEndDateError,
      required this.clearFliterFunction,
      required this.applyFliterFunction,
      super.key,
      required this.isPakageManger});
  void showFliter(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15.r),
            topLeft: Radius.circular(15.r),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return DraggableScrollableSheet(
              maxChildSize: 0.8,
              expand: false,
              builder: (BuildContext context,
                  ScrollController scrollControllerFilter) {
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
                          controller: scrollControllerFilter,
                          children: [
                            TextApp(
                              text: 'Lọc dữ liệu',
                              fontWeight: FontWeight.bold,
                              fontsize: 16.sp,
                              textAlign: TextAlign.center,
                              color: Colors.black,
                            ),
                            Container(
                              padding: EdgeInsets.all(10.w),
                              child: Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: " Từ ngày",
                                          fontsize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        TextField(
                                          onTapOutside: (event) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          readOnly: true,
                                          controller: dateStartController,
                                          onTap: () {
                                            selectDayStart();
                                          },
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.black),
                                          cursorColor: Colors.black,
                                          decoration: InputDecoration(
                                              suffixIcon: const Icon(
                                                  Icons.calendar_month),
                                              fillColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    width: 2.0),
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              hintText: 'dd/mm/yy',
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.all(20.w)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10.w),
                              child: Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: " Đến ngày",
                                          fontsize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        TextField(
                                          onTapOutside: (event) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          readOnly: true,
                                          controller: dateEndController,
                                          onTap: () {
                                            selectDayEnd();
                                          },
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.black),
                                          cursorColor: Colors.black,
                                          decoration: InputDecoration(
                                            suffixIcon: const Icon(
                                                Icons.calendar_month),
                                            fillColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  width: 2.0),
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            hintText: 'dd/mm/yy',
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.all(20.w),
                                            errorText: getEndDateError(),
                                            errorStyle: TextStyle(
                                              color: Colors.red,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(15.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    // width: 140.w,
                                    height: 40.h,
                                    child: ButtonApp(
                                      text: 'Xoá bộ lọc',
                                      fontsize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      colorText: Colors.white,
                                      backgroundColor: Colors.red,
                                      outlineColor: Colors.red,
                                      event: () {
                                        clearFliterFunction();
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  SizedBox(
                                    // width: 140.w,
                                    height: 40.h,
                                    child: ButtonApp(
                                      text: 'Áp dụng',
                                      fontsize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      colorText: Colors.white,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      outlineColor:
                                          Theme.of(context).colorScheme.primary,
                                      event: () {
                                        applyFliterFunction();
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showFliter(context),
      child: SizedBox(
          width: 45.w,
          height: 45.w,
          child: Image.asset(
            "assets/images/filter.png",
            fit: BoxFit.contain,
          )),
    );
  }
}
