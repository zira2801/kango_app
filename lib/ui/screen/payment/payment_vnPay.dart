import 'dart:convert';
import 'dart:developer';
import 'package:scan_barcode_app/data/models/vn_pay/res_status.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/payment/status_payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:url_launcher/url_launcher.dart';

class VnPayScreen extends StatefulWidget {
  const VnPayScreen({super.key});

  @override
  State<VnPayScreen> createState() => _VnPayScreenState();
}

class _VnPayScreenState extends State<VnPayScreen> with WidgetsBindingObserver {
  final _formFieldVNPAY = GlobalKey<FormState>();
  final noteTextController = TextEditingController();
  final moneyTextController = TextEditingController();
  ResStatusVnPayModel? resStatusVnPayModel;
  String currentReChargeCode = '0';
  String statusPayment = "Thất bại";
  void sendRequestVNPAYRechange() async {
    var amout = int.parse(moneyTextController.text.replaceAll(',', ''));
    final response = await http.post(
      Uri.parse('$baseUrl$vnPayApi'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'amount': amout,
        'note': noteTextController.text.isEmpty
            ? ''
            : noteTextController.text.isEmpty,
        'image': null
      }),
    );
    final data = jsonDecode(response.body);
    try {
      if (data['status'] == 200) {
        var urlRes = data['url'];

        var rechargeCode = data['recharge']['code'] ?? 'null';
        log("OK sendRequestVNPAYRechange $rechargeCode");
        setState(() {
          currentReChargeCode = rechargeCode;
        });
        goToUrlVNpay(urlVnPay: urlRes);
      } else {}
    } catch (error) {
      log("sendRequestRechange ERROR 2 $error");
      if (error is http.ClientException) {
        showDialog(
            context: navigatorKey.currentContext!,
            builder: (BuildContext context) {
              return ErrorDialog(
                eventConfirm: () {
                  Navigator.pop(context);
                },
                errorText: "Không thể kết nối đến máy chủ",
              );
            });
      } else {
        showDialog(
            context: navigatorKey.currentContext!,
            builder: (BuildContext context) {
              return ErrorDialog(
                eventConfirm: () {
                  Navigator.pop(context);
                },
              );
            });
      }
    }
  }

  void getCodeVNPAYRechange({required String code}) async {
    log(code.toString());
    final response = await http.post(
      Uri.parse('$baseUrl$checkStatusVNPayApi'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({'code': code}),
    );
    final data = jsonDecode(response.body);
    log("getCodeVNPAYRechange");
    try {
      if (data['status'] == 200) {
        log("getCodeVNPAYRechange OKOK");
        setState(() {
          resStatusVnPayModel = ResStatusVnPayModel.fromJson(data);
          statusPayment = resStatusVnPayModel?.data.recharge.statusLabel ?? '';
        });

        if (resStatusVnPayModel!.data.recharge.activeFlg == 1) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StatusPaymentScreen(
                    icon: Icons.check,
                    statusLabel: statusPayment,
                    resStatusVnPayModel: resStatusVnPayModel)),
          );
        } else {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StatusPaymentScreen(
                    icon: Icons.cancel,
                    statusLabel: "Thất bại",
                    resStatusVnPayModel: resStatusVnPayModel)),
          );
        }
      } else {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StatusPaymentScreen(
                  icon: Icons.cancel,
                  statusLabel: statusPayment,
                  resStatusVnPayModel: resStatusVnPayModel)),
        );
      }
    } catch (error) {
      log("getCodeVNPAYRechange ERROR 2 $error");
    }
  }

  void goToUrlVNpay({required String urlVnPay}) async {
    final Uri url = Uri.parse(urlVnPay);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.hidden:
        print("app in hidden");
        break;
      case AppLifecycleState.resumed:
        print("app in resumed");
        getCodeVNPAYRechange(code: currentReChargeCode);
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: TextApp(
          text: "Nạp tiền",
          fontsize: 20.sp,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Container(
            width: 1.sw,
            margin: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Form(
              key: _formFieldVNPAY,
              child: Column(
                children: [
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
                          offset:
                              const Offset(0, 3), // changes position of shadow
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
                          SizedBox(
                            height: 20.h,
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
                                  SizedBox(
                                    height: 10.h,
                                  ),
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
                                        fontSize: 14.sp, color: Colors.black),
                                    cursorColor:
                                        Theme.of(context).colorScheme.primary,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Số tiền không để trống";
                                      } else {
                                        double inputValue = double.parse(
                                            value.replaceAll(',', ''));
                                        // Check if input is less than 2000000
                                        if (inputValue < 2000000) {
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
                                          selection: TextSelection.collapsed(
                                              offset: value.length),
                                        );
                                      }
                                    },
                                    decoration: InputDecoration(
                                      fillColor:
                                          Theme.of(context).colorScheme.primary,
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
                                  SizedBox(
                                    height: 5.h,
                                  ),
                                  Row(
                                    children: [
                                      TextApp(
                                        text: "* Lưu ý:",
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontsize: 12.sp,
                                      ),
                                      TextApp(
                                        text: " Số tiền nạp vào tối thiểu là",
                                        fontsize: 12.sp,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                      ),
                                      TextApp(
                                        text: " 2.000.000 đ",
                                        fontsize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 20.h,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextApp(
                                    text: " Phương thức nạp tiền",
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  TextFormField(
                                    readOnly: true,
                                    onTap: () {},
                                    keyboardType: TextInputType.number,
                                    onTapOutside: (event) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    style: TextStyle(
                                        fontSize: 14.sp, color: Colors.black),
                                    cursorColor:
                                        Theme.of(context).colorScheme.primary,
                                    decoration: InputDecoration(
                                      fillColor:
                                          Theme.of(context).colorScheme.primary,
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
                                      hintText: "Chuyển khoản",
                                      hintStyle: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                          fontSize: 14.sp),
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(20.w),
                                    ),
                                  ),
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
                                        text: " Ghi chú",
                                        fontsize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  TextFormField(
                                    onTapOutside: (event) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    controller: noteTextController,
                                    style: TextStyle(
                                        fontSize: 14.sp, color: Colors.black),
                                    cursorColor:
                                        Theme.of(context).colorScheme.primary,
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
                                        contentPadding: EdgeInsets.all(20.w)),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20.h,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 160.w,
                                    child: ButtonApp(
                                      event: () {
                                        if (_formFieldVNPAY.currentState!
                                            .validate()) {
                                          sendRequestVNPAYRechange();
                                        }
                                      },
                                      text: "Gửi yêu cầu",
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
          )
        ],
      )),
    );
  }
}
