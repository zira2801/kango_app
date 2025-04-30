import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/ui/screen/policy/policy_html.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'dart:math' as math;

class FormShipment3 extends StatelessWidget {
  final GlobalKey<FormState> formField;
  final TextEditingController serviceTypeTextController;
  final TextEditingController serviceTextController;
  final TextEditingController branchTextController;
  final TextEditingController referenceCodeController;
  final Function() eventTypeService;
  final Function() eventService;
  final Function() eventBranchText;
  final Checkbox signatureServiceReceiverCheckBox;
  final Checkbox agreePersonalDataCheckBox;
  final Function() eventBackButton;
  final Function() eventNextButton;
  FormShipment3(
      {required this.formField,
      required this.serviceTypeTextController,
      required this.serviceTextController,
      required this.branchTextController,
      required this.referenceCodeController,
      required this.eventTypeService,
      required this.eventService,
      required this.eventBranchText,
      required this.signatureServiceReceiverCheckBox,
      required this.agreePersonalDataCheckBox,
      required this.eventBackButton,
      required this.eventNextButton,
      super.key});
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
                            Row(
                              children: [
                                TextApp(
                                  text: " Loại dịch vụ",
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
                                controller: serviceTypeTextController,
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
                                onTap: eventTypeService),
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
                                  text: " Dịch vụ vận chuyển",
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
                                controller: serviceTextController,
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
                                onTap: eventService)
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Row(
                          children: [
                            signatureServiceReceiverCheckBox,
                            Text(
                              'Dịch vụ chữ ký người nhận',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontSize: 14.sp),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextApp(
                                text: " Chọn chi nhánh",
                                fontsize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              CustomTextFormField(
                                  readonly: true,
                                  controller: branchTextController,
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
                                  onTap: eventBranchText),
                            ]),
                      ],
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextApp(
                          text: " Mã giới thiệu",
                          fontsize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        CustomTextFormField(
                            controller: referenceCodeController, hintText: '')
                      ],
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    SizedBox(
                      width: 1.sw,
                      child: Row(
                        children: [
                          agreePersonalDataCheckBox,
                          InkWell(
                            onTap: () {},
                            child: SizedBox(
                              width: 250.w,
                              child: RichText(
                                  text: TextSpan(children: [
                                TextSpan(
                                    text: 'Đồng Ý ',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                        fontSize: 14.sp)),
                                TextSpan(
                                    onEnter: (event) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const TermsOfService()),
                                      );
                                    },
                                    text:
                                        'Điều Khoản Sử Dụng Dịch Vụ \ncủa KANGO EXPRESS!',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontSize: 14.sp)),
                              ])),
                            ),
                          )
                        ],
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
                            fontsize: 14.sp,
                            fontWeight: FontWeight.bold,
                            colorText: Colors.white,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
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
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            outlineColor: Theme.of(context).colorScheme.primary,
                          ),
                        ),
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
