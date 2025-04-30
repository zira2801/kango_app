import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class FormShipment6 extends StatefulWidget {
  final GlobalKey<FormState> formField;

  final Function() eventBackButton;
  final Function() eventNextButton;
  final Function(int)? onPaymentMethodChanged;
  final int initialPaymentMethod;
  const FormShipment6({
    required this.formField,
    required this.eventBackButton,
    required this.eventNextButton,
    required this.initialPaymentMethod,
    required this.onPaymentMethodChanged,
  });

  @override
  State<FormShipment6> createState() => _FormShipment6State();
}

class _FormShipment6State extends State<FormShipment6> {
  late int selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    selectedPaymentMethod = widget.initialPaymentMethod;
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
        key: widget.formField,
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
                                          text: "Chọn thanh toán",
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
                                    Container(
                                      padding: EdgeInsets.all(16.w),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(8.w)),
                                      child: Column(
                                        children: [
                                          RadioListTile(
                                            title: TextApp(
                                              text:
                                                  "THANH TOÁN NỢ (Dùng hạn mức)",
                                              fontsize: 14.sp,
                                              color: Colors.black,
                                            ),
                                            value: 1,
                                            groupValue: selectedPaymentMethod,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedPaymentMethod = value!;
                                                widget.onPaymentMethodChanged!(
                                                    value);
                                              });
                                            },
                                            contentPadding: EdgeInsets.zero,
                                            activeColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          // THANH TOÁN SAU
                                          RadioListTile<int>(
                                            title: TextApp(
                                              text: "THANH TOÁN SAU",
                                              fontsize: 14.sp,
                                              color: Colors.black,
                                            ),
                                            value: 0,
                                            groupValue: selectedPaymentMethod,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedPaymentMethod = value!;
                                                widget.onPaymentMethodChanged!(
                                                    value);
                                              });
                                            },
                                            contentPadding: EdgeInsets.zero,
                                            activeColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                              SizedBox(
                                height: 20.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: 100.w,
                                      child: ButtonApp(
                                        event: widget.eventBackButton,
                                        text: "Về",
                                        fontsize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        colorText: Colors.white,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        outlineColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      )),
                                  SizedBox(
                                      width: 150.w,
                                      child: ButtonApp(
                                        event: widget.eventNextButton,
                                        /*text: shipmentCode == null
                                      ? "Tạo đơn"
                                      : "Cập nhật",*/
                                        text: "Tiếp",
                                        fontsize: 14.sp,
                                        colorText: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        outlineColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      )),
                                ],
                              )
                            ],
                          ),
                        ]))),
          ],
        ),
      ),
    );
  }
}
