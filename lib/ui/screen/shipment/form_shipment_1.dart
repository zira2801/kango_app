import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/ui/screen/maps/map_order_pickup.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'dart:math' as math;

class FormShipment1 extends StatefulWidget {
  final GlobalKey<FormState> formField;
  final TextEditingController fwdAccountController;
  final TextEditingController companySenderController;
  final TextEditingController contactNameSenderController;
  final TextEditingController phoneSenderController;
  final TextEditingController cityNameSenderController;
  final TextEditingController districNameSenderController;
  final TextEditingController wardNameSenderController;
  final TextEditingController addressSenderController;
  final TextEditingController longitudeSenderController;
  final TextEditingController latitudeSenderController;
  final List cityListSender;
  final List districListSender;
  final List wardListSender;
  final Function() eventChooseFWD;
  final Function() eventFormCity;
  final Function() eventFormDistric;
  final Function() eventFormWard;
  final Function() eventNextButton;
  const FormShipment1(
      {required this.formField,
      required this.fwdAccountController,
      required this.companySenderController,
      required this.contactNameSenderController,
      required this.phoneSenderController,
      required this.cityNameSenderController,
      required this.districNameSenderController,
      required this.wardNameSenderController,
      required this.addressSenderController,
      required this.cityListSender,
      required this.districListSender,
      required this.wardListSender,
      required this.eventChooseFWD,
      required this.eventFormCity,
      required this.eventFormDistric,
      required this.eventFormWard,
      required this.eventNextButton,
      required this.longitudeSenderController,
      required this.latitudeSenderController,
      super.key});

  @override
  State<FormShipment1> createState() => _FormShipment1State();
}

class _FormShipment1State extends State<FormShipment1> {
  bool isCreateOrderPickup = false;
  final String? position =
      StorageUtils.instance.getString(key: 'user_position');
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        position == 'document'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextApp(
                                    text: " Tài khoản Sale",
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  CustomTextFormField(
                                      readonly: true,
                                      controller: widget.fwdAccountController,
                                      hintText: 'Chọn Sale',
                                      suffixIcon: Transform.rotate(
                                        angle: 90 * math.pi / 180,
                                        child: Icon(
                                          Icons.chevron_right,
                                          size: 32.sp,
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                      ),
                                      onTap: widget.eventChooseFWD),
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                ],
                              )
                            : Container(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                TextApp(
                                  text: " Công ty",
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
                                enabled: false,
                                controller: widget.companySenderController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nội dung không được để trống';
                                  }
                                  return null;
                                },
                                hintText: 'Tên công ty'),
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
                                  text: " Người LH",
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
                                controller: widget.contactNameSenderController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nội dung không được để trống';
                                  }
                                  return null;
                                },
                                hintText: 'Tên người liên hệ'),
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
                                  text: " Số Điện thoại",
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
                                controller: widget.phoneSenderController,
                                textInputFormatter: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[0-9]")),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nội dung không được để trống';
                                  }

                                  bool phoneValid =
                                      RegExp(r'^(?:[+0]9)?[0-9]{10}$')
                                          .hasMatch(value);

                                  if (!phoneValid) {
                                    return "Số điện thoại không hợp lệ";
                                  } else {
                                    return null;
                                  }
                                },
                                hintText: 'Số điện thoại'),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextApp(
                              text: " Tỉnh/Thành phố",
                              fontsize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            CustomTextFormField(
                                readonly: true,
                                controller: widget.cityNameSenderController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nội dung không được để trống';
                                  }
                                  return null;
                                },
                                hintText: 'Chọn tỉnh/thành phố',
                                suffixIcon: Transform.rotate(
                                  angle: 90 * math.pi / 180,
                                  child: Icon(
                                    Icons.chevron_right,
                                    size: 32.sp,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ),
                                onTap: widget.eventFormCity),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        widget.districListSender.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextApp(
                                    text: " Quận/Huyện",
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  CustomTextFormField(
                                      readonly: true,
                                      controller:
                                          widget.districNameSenderController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Nội dung không được để trống';
                                        }
                                        return null;
                                      },
                                      hintText: 'Chọn quận/huyện',
                                      suffixIcon: Transform.rotate(
                                        angle: 90 * math.pi / 180,
                                        child: Icon(
                                          Icons.chevron_right,
                                          size: 32.sp,
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                      ),
                                      onTap: widget.eventFormDistric)
                                ],
                              )
                            : Container(),
                        SizedBox(
                          height: 20.h,
                        ),
                        widget.wardListSender.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextApp(
                                    text: " Phường/Xã",
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  CustomTextFormField(
                                      readonly: true,
                                      controller:
                                          widget.wardNameSenderController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Nội dung không được để trống';
                                        }
                                        return null;
                                      },
                                      hintText: 'Chọn phường/xã',
                                      suffixIcon: Transform.rotate(
                                        angle: 90 * math.pi / 180,
                                        child: Icon(
                                          Icons.chevron_right,
                                          size: 32.sp,
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                      ),
                                      onTap: widget.eventFormWard)
                                ],
                              )
                            : Container(),
                        SizedBox(
                          height: 20.h,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextApp(
                                  text: " Địa chỉ",
                                  fontsize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                InkWell(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MapOrderPickUpScreen()),
                                    );

                                    if (result != null &&
                                        result is Map<String, dynamic>) {
                                      print(
                                          'Selected address: ${result['address']}');
                                      print(
                                          'longitude value: ${result['longitude']}');
                                      print(
                                          'latitude value: ${result['latitude']}');

                                      setState(() {
                                        widget.addressSenderController.text =
                                            result['address'].toString();
                                        widget.longitudeSenderController.text =
                                            result['longitude'].toString();
                                        widget.latitudeSenderController.text =
                                            result['latitude'].toString();
                                      });
                                    }
                                  },
                                  child: TextApp(
                                    text: "Mở bản đồ",
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            CustomTextFormField(
                                readonly: false,
                                controller: widget.addressSenderController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nội dung không được để trống';
                                  }
                                  return null;
                                },
                                hintText: 'Số nhà, đường')
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        SizedBox(
                          width: 1.sw,
                          child: Row(
                            children: [
                              Checkbox(
                                checkColor:
                                    Theme.of(context).colorScheme.background,
                                value: isCreateOrderPickup,
                                onChanged: (bool? value) {
                                  if (!mounted) {
                                    return;
                                  }
                                  setState(() {
                                    isCreateOrderPickup = value!;
                                  });
                                },
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Tạo Order Pickup  ',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14.sp),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 110.w,
                              child: ButtonApp(
                                event: () {
                                  if (widget.formField.currentState!
                                      .validate()) {
                                    // mounted
                                    //     ? setState(() {
                                    //         currentForm = 1;
                                    //       })
                                    //     : null;
                                    widget.eventNextButton();
                                  }
                                },
                                text: "Tiếp",
                                fontWeight: FontWeight.bold,
                                fontsize: 14.sp,
                                colorText: Colors.white,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                outlineColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
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
