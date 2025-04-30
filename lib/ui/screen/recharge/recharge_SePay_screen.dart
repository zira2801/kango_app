import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/bloc/recharge/content_payment/content_payment_bloc.dart';
import 'package:scan_barcode_app/bloc/recharge/content_payment/content_payment_event.dart';
import 'package:scan_barcode_app/bloc/recharge/content_payment/content_payment_state.dart';
import 'package:scan_barcode_app/bloc/recharge/create_sepay/create_sepay_bloc.dart';
import 'package:scan_barcode_app/data/models/content_payment/content_payment_model.dart';
import 'package:scan_barcode_app/ui/screen/recharge/result_sePay_screen.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/html/html_screen.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';

class RechargeSePayScreen extends StatefulWidget {
  const RechargeSePayScreen({super.key});

  @override
  State<RechargeSePayScreen> createState() => _RechargeSePayScreenState();
}

class _RechargeSePayScreenState extends State<RechargeSePayScreen>
    with WidgetsBindingObserver {
  final _formField = GlobalKey<FormState>();
  final noteTextController = TextEditingController();
  final moneyTextController = TextEditingController();
  final methodTextController = TextEditingController();
  double doubleAmount = 0;
  bool moneyVisible = true;

  @override
  initState() {
    super.initState();
    context.read<PaymentContentBloc>().add(LoadPaymentContent('vnpay'));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    noteTextController.dispose();
    moneyTextController.dispose();
  }

  Future<void> createSePayRechange(
      {required double amount, required String note}) async {
    BlocProvider.of<CreateSePayBloc>(context)
        .add(HanldeCreateSePayEvent(amount: amount, type: "1", note: note));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: TextApp(
          text: "Chuyển Khoản Ngân Hàng (QRcode)",
          fontsize: 20.sp,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CreateSePayBloc, CreateSePayState>(
            listener: (context, state) {
              if (state is CreateSePayStateSuccess) {
                noteTextController.clear();
                moneyTextController.clear();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultSePayScreen(
                      rechargeID:
                          state.inforPaymentSePayModel!.recharge.rechargeId,
                    ),
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<PaymentContentBloc, PaymentContentState>(
          builder: (context, paymentState) {
            if (paymentState is PaymentContentLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (paymentState is PaymentContentError) {
              return Center(child: Text(paymentState.message));
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: 1.sw,
                    margin: EdgeInsets.all(20.w),
                    child: Form(
                      key: _formField,
                      child: Column(
                        children: [
                          // Payment Content Section
                          if (paymentState is PaymentContentLoaded)
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.r),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextApp(
                                      text: 'Nội dung thanh toán',
                                      color:
                                          const Color.fromRGBO(52, 71, 103, 1),
                                      fontFamily: "OpenSans",
                                      fontWeight: FontWeight.bold,
                                      fontsize: 20.sp,
                                    ),
                                    SizedBox(height: 15.h),
                                    Container(
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                              .size
                                              .width),
                                      child: HtmlViewer(
                                          htmlData:
                                              paymentState.content.content),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          SizedBox(height: 20.h),
                          // Form Section
                          Container(
                            margin: EdgeInsets.only(bottom: 20.h),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(20.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextApp(
                                    text: "Thông tin nạp tiền",
                                    color: const Color.fromRGBO(52, 71, 103, 1),
                                    fontFamily: "OpenSans",
                                    fontWeight: FontWeight.bold,
                                    fontsize: 20.sp,
                                  ),
                                  SizedBox(height: 20.h),
                                  // Money Input Field
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          TextApp(
                                            text: " Số tiền nạp",
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
                                      SizedBox(height: 10.h),
                                      TextFormField(
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp("[0-9]")),
                                        ],
                                        onTapOutside: (event) {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        controller: moneyTextController,
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.black),
                                        cursorColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Số tiền không để trống";
                                          } else {
                                            double inputValue = double.parse(
                                                value.replaceAll(',', ''));
                                            if (inputValue < 10000) {
                                              return "Chưa đủ số tiền tối thiểu";
                                            }
                                            return null;
                                          }
                                        },
                                        onChanged: (value) {
                                          if (value.isNotEmpty) {
                                            value = formatNumber(
                                                value.replaceAll(',', ''));
                                            moneyTextController.value =
                                                TextEditingValue(
                                              text: value,
                                              selection:
                                                  TextSelection.collapsed(
                                                      offset: value.length),
                                            );
                                          }
                                        },
                                        decoration: InputDecoration(
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
                                          hintText: '',
                                          hintStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground
                                                  .withOpacity(0.5),
                                              fontSize: 14.sp),
                                          isDense: true,
                                          contentPadding: EdgeInsets.all(20.w),
                                        ),
                                      ),
                                      SizedBox(height: 5.h),
                                      Row(
                                        children: [
                                          TextApp(
                                            text: "* Lưu ý:",
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontsize: 12.sp,
                                          ),
                                          TextApp(
                                            text:
                                                " Số tiền nạp vào tối thiểu là",
                                            fontsize: 12.sp,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                          ),
                                          TextApp(
                                            text: " 10.000 đ",
                                            fontsize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 20.h),
                                  // Note Input Field
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          TextApp(
                                            text: " Ghi chú",
                                            fontsize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.h),
                                      TextFormField(
                                        onTapOutside: (event) {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        controller: noteTextController,
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.black),
                                        cursorColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                          } else {
                                            return null;
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
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
                                          hintText: '',
                                          hintStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground
                                                  .withOpacity(0.5),
                                              fontSize: 14.sp),
                                          isDense: true,
                                          contentPadding: EdgeInsets.all(20.w),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20.h),
                                  // Submit Button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ButtonApp(
                                        event: () {
                                          if (_formField.currentState!
                                              .validate()) {
                                            log(moneyTextController.text);
                                            double value = double.parse(
                                                moneyTextController.text
                                                    .replaceAll(",", ""));
                                            createSePayRechange(
                                                amount: value,
                                                note: noteTextController.text);
                                          }
                                        },
                                        fontWeight: FontWeight.bold,
                                        text: "Gửi yêu cầu",
                                        fontsize: 14.sp,
                                        colorText: Colors.white,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        outlineColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
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
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
