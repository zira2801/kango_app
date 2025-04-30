import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/data/models/audit_epacket/audit_epacket_service.dart';
import 'package:scan_barcode_app/data/models/utils/list_branchs_model.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/calendar/month_year_picker_widget.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'dart:math' as math;

// ignore: must_be_immutable
class FilterSaleTeamManagerWidget extends StatelessWidget {
  final TextEditingController monthYearController;
  final Function clearFilterFunction;
  final Function applyFilterFunction;
  final Function(DateTime, DateTime) onDateRangeSelected;

  const FilterSaleTeamManagerWidget({
    required this.monthYearController,
    required this.clearFilterFunction,
    required this.applyFilterFunction,
    required this.onDateRangeSelected,
    Key? key,
  }) : super(key: key);

  void showFilter(BuildContext context) {
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
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: scrollControllerFilter,
                          children: [
                            Text(
                              'Lọc dữ liệu',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.w),
                              child: MonthYearPickerWidget(
                                controller: monthYearController,
                                labelText: "Chọn tháng và năm",
                                onDateSelected: (firstDay, lastDay) {
                                  onDateRangeSelected(firstDay, lastDay);
                                },
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
                                        clearFilterFunction();
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
                                        applyFilterFunction();
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showFilter(context),
      child: SizedBox(
        width: 45.w,
        height: 45.w,
        child: Image.asset(
          "assets/images/filter.png",
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
