import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/data/models/shipment/all_unit_shipment.dart';
import 'package:scan_barcode_app/data/models/shipment/details_shipment_to_update.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class FormShipment4 extends StatelessWidget {
  final GlobalKey<FormState> formField;
  final TextEditingController goodsNameTextController;
  final TextEditingController goodsInvoiceValueController;
  final Function() eventAddProduct;
  AllUnitShipmentModel? allUnitShipmentModel;
  List<Package>? packageList = [];
  final Function() eventBackButton;
  final Function() eventNextButton;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  FormShipment4(
      {required this.formField,
      required this.goodsNameTextController,
      required this.goodsInvoiceValueController,
      required this.itemCount,
      required this.itemBuilder,
      required this.eventAddProduct,
      required this.allUnitShipmentModel,
      required this.packageList,
      required this.eventNextButton,
      required this.eventBackButton,
      super.key});

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TextApp(
                        text: " Tên hàng hóa",
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
                      controller: goodsNameTextController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nội dung không được để trống';
                        }
                        return null;
                      },
                      hintText: ''),
                ],
              ),
              SizedBox(
                height: 20.h,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TextApp(
                        text: " Invoice Value ",
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
                      suffixText: "VND",
                      keyboardType: TextInputType.number,
                      textInputFormatter: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nội dung không được để trống';
                        }
                        return null;
                      },
                      controller: goodsInvoiceValueController,
                      hintText: ''),
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
                    text: "Danh sách kiện hàng",
                    fontsize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              packageList!.isEmpty
                  ? Container()
                  : Column(
                      children: [
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: itemCount,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: itemBuilder)
                      ],
                    ),
              SizedBox(
                height: 20.h,
              ),
              SizedBox(
                // width: 180.w,
                height: 35.h,
                child: ButtonApp(
                  event: eventAddProduct,
                  text: "+ Thêm sản phẩm",
                  fontWeight: FontWeight.bold,
                  fontsize: 12.sp,
                  colorText: Colors.white,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  outlineColor: Theme.of(context).colorScheme.secondary,
                ),
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
                    child: ButtonApp(
                      event: eventBackButton,
                      text: "Về",
                      fontWeight: FontWeight.bold,
                      fontsize: 14.sp,
                      colorText: Colors.white,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      outlineColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(
                    width: 110.w,
                    child: ButtonApp(
                      event: eventNextButton,
                      text: "Tiếp",
                      fontsize: 14.sp,
                      fontWeight: FontWeight.bold,
                      colorText: Colors.white,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      outlineColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
