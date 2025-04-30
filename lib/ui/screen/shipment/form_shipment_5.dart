import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/data/models/shipment/all_unit_shipment.dart';
import 'package:scan_barcode_app/data/models/shipment/details_shipment_to_update.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'dart:math' as math;

class FormShipment5 extends StatelessWidget {
  final GlobalKey<FormState> formField;
  final TextEditingController exportAsTextController;
  final TextEditingController stateNameReceiverController;
  AllUnitShipmentModel? allUnitShipmentModel;
  List<Invoice>? invoiceList = [];
  final Function() eventExportAs;
  final Function() eventAddInvoice;
  final Function() eventBackButton;
  final Function() eventNextButton;
  final bool isLoadingButtonCreateShipment;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final String? shipmentCode;
  final bool? isSale;
  FormShipment5(
      {required this.formField,
      required this.exportAsTextController,
      required this.stateNameReceiverController,
      required this.allUnitShipmentModel,
      required this.invoiceList,
      required this.eventExportAs,
      required this.eventAddInvoice,
      required this.isLoadingButtonCreateShipment,
      required this.itemCount,
      required this.itemBuilder,
      required this.shipmentCode,
      required this.eventNextButton,
      required this.eventBackButton,
      this.isSale,
      super.key});
  String getButtonText() {
    if (shipmentCode == null) {
      return isSale == true ? "Tiếp" : "Tạo đơn";
    }
    return "Cập nhật";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      margin: EdgeInsets.only(right: 20.w, left: 20.w, bottom: 20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Form(
        key: formField,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                TextApp(
                                  text: " Export as",
                                  fontsize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                TextApp(
                                  text: " *",
                                  fontsize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            CustomTextFormField(
                                readonly: true,
                                controller: exportAsTextController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nội dung không được để trống';
                                  }
                                  return null;
                                },
                                hintText: '',
                                suffixIcon: Transform.rotate(
                                  angle: 90 * math.pi / 180,
                                  child: Icon(
                                    Icons.chevron_right,
                                    size: 32.sp,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ),
                                onTap: eventExportAs)
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextApp(
                              text: "Danh sách Invoices",
                              fontsize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        invoiceList!.isEmpty
                            ? Container()
                            : Column(
                                children: [
                                  ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: itemCount,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: itemBuilder)
                                ],
                              ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 35.h,
                              child: ButtonApp(
                                event: eventAddInvoice,
                                text: "+ Thêm Invoice",
                                fontWeight: FontWeight.bold,
                                fontsize: 12.sp,
                                colorText: Colors.white,
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                outlineColor:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 100.w,
                          child: !isLoadingButtonCreateShipment
                              ? ButtonApp(
                                  event: eventBackButton,
                                  text: "Về",
                                  fontsize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  colorText: Colors.white,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  outlineColor:
                                      Theme.of(context).colorScheme.primary,
                                )
                              : Container(),
                        ),
                        SizedBox(
                          width: 150.w,
                          /* child: !isLoadingButtonCreateShipment
                             ?*/
                          child: !isLoadingButtonCreateShipment
                              ? ButtonApp(
                                  event: eventNextButton,
                                  text: getButtonText(),
                                  fontsize: 14.sp,
                                  colorText: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  outlineColor:
                                      Theme.of(context).colorScheme.primary,
                                )
                              : const Center(
                                  child: CircularProgressIndicator()),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
