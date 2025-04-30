import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/data/models/shipment/list_old_receiver.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'dart:math' as math;

class FormShipment2 extends StatelessWidget {
  final GlobalKey<FormState> formField;
  final TextEditingController chooseOldReciverController;
  final TextEditingController companyReciverController;
  final TextEditingController contactNameReciverController;
  final TextEditingController phoneReciverController;
  final TextEditingController countryNameReceiverController;
  final TextEditingController stateNameReceiverController;
  final TextEditingController cityNameReceiverController;
  final TextEditingController postalCodeReciverController;
  final TextEditingController address1ReciverController;
  final TextEditingController address2ReciverController;
  final TextEditingController address3ReciverController;
  final List countryListReciver;
  final List countryFlagList;
  final List stateListReciver;
  final List cityListReciver;
  final Function() eventFormCountry;
  final Function() eventFormState;
  final Function() eventFormCity;
  final Function() eventBackButton;
  final Function() eventNextButton;
  final Checkbox checkBoxSaveInforReceiver;
  ListOldReceiverModel? listOldReceiverModel;
  final Function() eventChooseOldReciver;
  final Function(String) onReceiverNameChanged;
  FormShipment2(
      {required this.formField,
      required this.chooseOldReciverController,
      required this.companyReciverController,
      required this.contactNameReciverController,
      required this.phoneReciverController,
      required this.countryNameReceiverController,
      required this.stateNameReceiverController,
      required this.cityNameReceiverController,
      required this.postalCodeReciverController,
      required this.address1ReciverController,
      required this.address2ReciverController,
      required this.address3ReciverController,
      required this.countryListReciver,
      required this.countryFlagList,
      required this.stateListReciver,
      required this.cityListReciver,
      required this.eventFormCountry,
      required this.eventFormState,
      required this.eventFormCity,
      required this.eventBackButton,
      required this.eventNextButton,
      required this.checkBoxSaveInforReceiver,
      required this.listOldReceiverModel,
      required this.eventChooseOldReciver,
      required this.onReceiverNameChanged,
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextApp(
                              text: " Người nhận cũ",
                              fontsize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            CustomTextFormField(
                                readonly: true,
                                controller: chooseOldReciverController,
                                hintText: 'Chọn người nhận cũ',
                                onTap: eventChooseOldReciver),
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
                                controller: companyReciverController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nội dung không được để trống';
                                  }
                                  return null;
                                },
                                hintText: 'Tên công ty')
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
                                controller: contactNameReciverController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nội dung không được để trống';
                                  }
                                  return null;
                                },
                                hintText: 'Tên người liên hệ')
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
                                textInputFormatter: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[0-9]")),
                                ],
                                controller: phoneReciverController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nội dung không được để trống';
                                  }
                                  if (value.isEmpty) {
                                    // return phoneIsRequied;
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
                                hintText: 'Số điện thoại')
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
                                  text: " Quốc gia",
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
                              controller: countryNameReceiverController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nội dung không được để trống';
                                }
                                return null;
                              },
                              hintText: 'Chọn quốc gia',
                              onTap: eventFormCountry,
                              suffixIcon: Transform.rotate(
                                angle: 90 * math.pi / 180,
                                child: Icon(
                                  Icons.chevron_right,
                                  size: 32.sp,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextApp(
                              text: " Tỉnh/Bang",
                              fontsize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            CustomTextFormField(
                              readonly: false,
                              controller: stateNameReceiverController,
                              onChange: onReceiverNameChanged,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nội dung không được để trống';
                                }
                                return null;
                              },
                              hintText: 'Chọn tỉnh/bang',
                              onTap:
                                  eventFormState, // Sẽ chỉ được gọi khi tap vào mũi tên
                              suffixIcon: Transform.rotate(
                                angle: 90 * math.pi / 180,
                                child: Icon(
                                  Icons.chevron_right,
                                  size: 32.sp,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextApp(
                              text: " Thành phố",
                              fontsize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            CustomTextFormField(
                              readonly: true,
                              controller: cityNameReceiverController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nội dung không được để trống';
                                }
                                return null;
                              },
                              hintText: 'Chọn thành phố',
                              onTap: eventFormCity,
                              suffixIcon: Transform.rotate(
                                angle: 90 * math.pi / 180,
                                child: Icon(
                                  Icons.chevron_right,
                                  size: 32.sp,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                TextApp(
                                  text: " Mã bưu chính",
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
                                controller: postalCodeReciverController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nội dung không được để trống';
                                  }
                                  return null;
                                },
                                hintText: 'Mã bưu chính')
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextApp(
                              text: " Địa chỉ 1",
                              fontsize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            CustomTextFormField(
                                controller: address1ReciverController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nội dung không được để trống';
                                  }
                                  return null;
                                },
                                hintText: '')
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextApp(
                              text: " Địa chỉ 2",
                              fontsize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            CustomTextFormField(
                                controller: address2ReciverController,
                                hintText: '')
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextApp(
                              text: " Địa chỉ 3",
                              fontsize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            CustomTextFormField(
                                controller: address3ReciverController,
                                hintText: '')
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Row(
                          children: [
                            checkBoxSaveInforReceiver,
                            Text(
                              'Lưu thông tin người nhận',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontSize: 16.sp),
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
                              child: ButtonApp(
                                event: () {
                                  eventBackButton();
                                },
                                text: "Về",
                                fontWeight: FontWeight.bold,
                                colorText: Colors.white,
                                fontsize: 14.sp,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                outlineColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            SizedBox(
                              width: 110.w,
                              child: ButtonApp(
                                event: eventNextButton,
                                text: "Tiếp",
                                fontsize: 14.sp,
                                colorText: Colors.white,
                                fontWeight: FontWeight.bold,
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
            )
          ],
        ),
      ),
    );
  }
}
