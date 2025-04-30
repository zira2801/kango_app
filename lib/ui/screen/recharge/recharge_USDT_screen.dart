import 'dart:convert';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scan_barcode_app/bloc/recharge/content_payment/content_payment_bloc.dart';
import 'package:scan_barcode_app/bloc/recharge/content_payment/content_payment_state.dart';
import 'package:scan_barcode_app/bloc/recharge/recharge_USDT/rechargeUSDT_bloc.dart';
import 'package:scan_barcode_app/bloc/wallet/wallet_bloc.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/order/faq_screen.dart';
import 'package:scan_barcode_app/ui/screen/recharge/recharge_history.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/html/html_screen.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';

class RechargeUSDTScreen extends StatefulWidget {
  const RechargeUSDTScreen({super.key});

  @override
  State<RechargeUSDTScreen> createState() => _RechargeUSDTScreenState();
}

class _RechargeUSDTScreenState extends State<RechargeUSDTScreen> {
  final _formField = GlobalKey<FormState>();
  final noteTextController = TextEditingController();
  final moneyTextController = TextEditingController();
  final usdtTextController = TextEditingController();
  File? selectedImage;
  String selectedFile = '';
  String bankNumberCompany = '1234557679';
  bool showFieldBank = false;
  bool moneyVisible = true;
  bool isLoading = false;
  final double usdtToVndRate = 24500;
  final ImagePicker picker = ImagePicker();
  double amount = 0.0;
  void getWalletUser() async {
    BlocProvider.of<WalletBloc>(context).add(const GetWallet());
  }

  bool isNumeric(String? str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  void pickImage() async {
    final returndImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returndImage == null) return;
    setState(() {
      selectedImage = File(returndImage.path);
    });
  }

  void deleteImage() {
    setState(() {
      selectedImage = null;
    });
  }

  void captureImage() async {
    final XFile? capturedImage =
        await picker.pickImage(source: ImageSource.camera);
    if (capturedImage != null) {
      setState(() {
        selectedImage = File(capturedImage.path);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    noteTextController.dispose();
    moneyTextController.dispose();
    usdtTextController.dispose();
  }

  void sendRequestRechange() async {
    String? selectedImageString;
    Uint8List imagebytes = await selectedImage!.readAsBytes();
    selectedImageString = base64Encode(imagebytes);
    var amout = int.parse(moneyTextController.text.replaceAll(',', ''));
    context.read<ReChargeUSDTBloc>().add(HandleReChargeUSDT(
        amount: amout,
        note: noteTextController.text,
        type: 2,
        image: selectedImageString,
        usdt_price: double.tryParse(usdtTextController.text)));
  }

  //Chuyển USDT sang VNĐ
  void _onUsdtChanged(double price) {
    if (usdtTextController.text.isNotEmpty) {
      try {
        double usdtAmount =
            double.parse(usdtTextController.text.replaceAll(',', ''));
        int vndAmount = (usdtAmount * price).round();
        String formattedVnd = formatNumber(vndAmount.toString());

        // Update VND amount without triggering the listener
        moneyTextController.text = formattedVnd;
      } catch (e) {
        // Handle parsing error
        moneyTextController.text = '';
      }
    } else {
      moneyTextController.text = '';
    }
  }

  @override
  void initState() {
    getWalletUser();
    super.initState();
    // The price will come from the API response
    usdtTextController.addListener(() {
      if (context.read<PaymentContentBloc>().state is PaymentContentLoaded) {
        final state =
            context.read<PaymentContentBloc>().state as PaymentContentLoaded;
        _onUsdtChanged(double.parse(state.content.data!['price']));
      }
    });
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
            text: "Thanh toán bằng USDT",
            fontsize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<WalletBloc, WalletState>(listener: (context, state) {
              if (state is WalletStateSuccess) {
                setState(() {
                  amount = state.walletModel!.wallet!.amount!;
                });
              } else if (state is WalletStateFailure) {
                showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: state.errorText!,
                    title: "Thông báo",
                    colorButtonOk: Colors.red,
                    btnOKText: "Xác nhận",
                    typeDialog: "error",
                    eventButtonOKPress: () {},
                    isTwoButton: false);
              }
            }),
            BlocListener<ReChargeUSDTBloc, ReChargeUSDTState>(
                listener: (context, state) {
              if (state is RequestReChargeUSDTStateSuccess) {
                showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.green,
                    btnOKText: "Xác nhận",
                    typeDialog: "success",
                    eventButtonOKPress: () {},
                    isTwoButton: false);
                moneyTextController.clear();
                noteTextController.clear();
                usdtTextController.clear();
                deleteImage();
                mounted
                    ? setState(() {
                        isLoading = false;
                      })
                    : null;
              } else if (state is RequestReChargeUSDTFailure) {
                mounted
                    ? setState(() {
                        isLoading = false;
                      })
                    : null;
                showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.red,
                    btnOKText: "Xác nhận",
                    typeDialog: "error",
                    eventButtonOKPress: () {},
                    isTwoButton: false);
              }
            }),
            BlocListener<PaymentContentBloc, PaymentContentState>(
              listener: (context, state) {
                if (state is PaymentContentError) {
                  // Handle error state
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
            ),
          ],
          child: BlocBuilder<PaymentContentBloc, PaymentContentState>(
            builder: (context, state) {
              if (state is PaymentContentLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is PaymentContentError) {
                return Center(child: TextApp(text: state.message));
              }
              if (state is PaymentContentLoaded) {
                return SingleChildScrollView(
                    child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.w),
                      margin: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextApp(
                                text: "Số dư của bạn: ",
                                fontWeight: FontWeight.bold,
                                fontsize: 16.sp,
                                color: Colors.white,
                              ),
                              Row(
                                children: [
                                  moneyVisible
                                      ? TextApp(
                                          text: "***********",
                                          fontWeight: FontWeight.bold,
                                          fontsize: 16.sp,
                                          color: Colors.white,
                                        )
                                      : TextApp(
                                          text:
                                              "${MoneyFormatter(amount: (amount).toDouble()).output.withoutFractionDigits.toString()} đ",
                                          fontsize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                  IconButton(
                                      onPressed: () {
                                        mounted
                                            ? setState(
                                                () {
                                                  moneyVisible = !moneyVisible;
                                                },
                                              )
                                            : null;
                                      },
                                      color: Colors.white,
                                      icon: Icon(moneyVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility))
                                ],
                              )
                            ],
                          ),
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const FAQScreen()),
                                  );
                                },
                                child: Container(
                                  width: 150.w,
                                  height: 30.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.r),
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                      child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextApp(
                                        textAlign: TextAlign.center,
                                        text: "FAQ",
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.bold,
                                        fontsize: 12.sp,
                                      ),
                                    ],
                                  )),
                                ),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const TransactionHistoryScreen()),
                                  );
                                },
                                child: Container(
                                  width: 150.w,
                                  height: 30.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.r),
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                      child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.history,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        size: 16.sp,
                                      ),
                                      SizedBox(
                                        width: 5.w,
                                      ),
                                      TextApp(
                                        textAlign: TextAlign.center,
                                        text: "Lịch sử giao dịch",
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.bold,
                                        fontsize: 12.sp,
                                      ),
                                    ],
                                  )),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: 1.sw,
                      margin: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Form(
                        key: _formField,
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
                                          htmlData: state.content.content),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.w,
                            ),
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
                                    offset: const Offset(
                                        0, 3), // changes position of shadow
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
                                      color:
                                          const Color.fromRGBO(52, 71, 103, 1),
                                      fontFamily: "OpenSans",
                                      fontWeight: FontWeight.bold,
                                      fontsize: 20.sp,
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
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
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            CustomTextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                controller: usdtTextController,
                                                textInputFormatter: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp("[0-9]")),
                                                ],
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Số tiền tạp không để trống";
                                                  } else {
                                                    double inputValue =
                                                        double.parse(
                                                            value.replaceAll(
                                                                ',', ''));
                                                    // Check if input is less than 2000000
                                                    if (inputValue == 0) {
                                                      return "Số tiền nạp phải lớn hơn 0";
                                                    }
                                                    return null;
                                                  }
                                                },
                                                onChange: (value) {
                                                  if (value.isNotEmpty) {
                                                    value = formatNumber(value
                                                        .replaceAll(',', ''));

                                                    usdtTextController.value =
                                                        TextEditingValue(
                                                      text: value,
                                                      selection: TextSelection
                                                          .collapsed(
                                                              offset:
                                                                  value.length),
                                                    );
                                                  }
                                                },
                                                hintText: ''),
                                            SizedBox(
                                              height: 20.h,
                                            ),

                                            /*Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                          CustomTextFormField(
                                              enabled: true,
                                              readonly: false,
                                              controller: methodTextController,
                                              hintText: 'Chuyển khoản')
                                        ],
                                      ),*/
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextApp(
                                                  text:
                                                      " Tiền quy đổi (2,000VND/USDT)",
                                                  fontsize: 14.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                SizedBox(
                                                  height: 10.h,
                                                ),
                                                CustomTextFormField(
                                                  enabled: true,
                                                  readonly: true,
                                                  suffixText: "VND",
                                                  controller:
                                                      moneyTextController,
                                                  hintText: '0',
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return "Số tiền không để trống";
                                                    } else {
                                                      double inputValue =
                                                          double.parse(
                                                              value.replaceAll(
                                                                  ',', ''));
                                                      // Check if input is less than 2000000
                                                      if (inputValue < 10000) {
                                                        return "Chưa đủ số tiền tối thiểu";
                                                      }
                                                      return null;
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5.w,
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
                                        SizedBox(
                                          height: 20.h,
                                        ),
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
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            CustomTextFormField(
                                                controller: noteTextController,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
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
                                        /*Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          DottedBorder(
                                            dashPattern: const [3, 1, 0, 2],
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            strokeWidth: 1.5,
                                            padding: const EdgeInsets.all(3),
                                            child: Container(
                                              width: 1.sw,
                                              // height: 100.w,
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 10.h, 0, 10.h),
                                              color: const Color.fromRGBO(
                                                  241, 250, 255, 1),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  TextApp(
                                                    text:
                                                        "THÔNG TIN CHUYỂN KHOẢN",
                                                    fontsize: 18.sp,
                                                    color: Colors.orange,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  SizedBox(
                                                    height: 5.h,
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        width: 15.w,
                                                      ),
                                                      SizedBox(
                                                        width: 120.w,
                                                        child: TextApp(
                                                          text: "Ngân hàng: ",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontsize: 14.sp,
                                                        ),
                                                      ),
                                                      TextApp(
                                                        text: "Techcombank",
                                                        fontsize: 14.sp,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 5.h,
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        width: 15.w,
                                                      ),
                                                      SizedBox(
                                                        width: 120.w,
                                                        child: TextApp(
                                                            text:
                                                                "Số tài khoản: ",
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontsize: 14.sp),
                                                      ),
                                                      TextApp(
                                                        text: bankNumberCompany,
                                                        fontsize: 14.sp,
                                                      ),
                                                      SizedBox(
                                                        width: 15.w,
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          Clipboard.setData(
                                                                  ClipboardData(
                                                                      text:
                                                                          bankNumberCompany))
                                                              .then(
                                                            (value) {
                                                              //only if ->
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      SnackBar(
                                                                          content:
                                                                              Text("Đã copy số tài khoản !"))); // -> show a notification
                                                            },
                                                          );
                                                        },
                                                        child: Icon(
                                                          Icons.copy,
                                                          size: 18.sp,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 5.h,
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        width: 15.w,
                                                      ),
                                                      SizedBox(
                                                        width: 120.w,
                                                        child: TextApp(
                                                            text:
                                                                "Tên tài khoản: ",
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontsize: 14.sp),
                                                      ),
                                                      TextApp(
                                                        text:
                                                            "Công ty THHH THV",
                                                        fontsize: 14.sp,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 5.h,
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        width: 15.w,
                                                      ),
                                                      SizedBox(
                                                        width: 120.w,
                                                        child: TextApp(
                                                            text: "Chi nhánh: ",
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontsize: 14.sp),
                                                      ),
                                                      TextApp(
                                                        text: "Hồ Chí Minh",
                                                        fontsize: 14.sp,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 15.h,
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        width: 15.w,
                                                      ),
                                                      SizedBox(
                                                        width: 120.w,
                                                        child: TextApp(
                                                            text: "QR Code: ",
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontsize: 14.sp),
                                                      ),
                                                      SizedBox(
                                                        width: 150.w,
                                                        height: 150.w,
                                                        child: Image.asset(
                                                          "assets/images/qr_code.png",
                                                          fit: BoxFit.contain,
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20.h,
                                          ),
                                        ],
                                      ),*/
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextApp(
                                              text: "Ảnh chuyển khoản",
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                              fontsize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        selectedImage == null
                                            ? DottedBorder(
                                                dashPattern: const [3, 1, 0, 2],
                                                color: Colors.black
                                                    .withOpacity(0.6),
                                                strokeWidth: 1.5,
                                                padding:
                                                    const EdgeInsets.all(3),
                                                child: SizedBox(
                                                  width: 1.sw,
                                                  height: 200.h,
                                                  child: Center(
                                                      child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          pickImage();
                                                        },
                                                        child: Container(
                                                            width: 120.w,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.r),
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
                                                            ),
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(8
                                                                            .w),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .collections,
                                                                      size:
                                                                          24.sp,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          5.w,
                                                                    ),
                                                                    TextApp(
                                                                      fontsize:
                                                                          14.sp,
                                                                      text:
                                                                          "Chọn ảnh",
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ],
                                                                ))),
                                                      ),
                                                      SizedBox(
                                                        height: 10.h,
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          captureImage();
                                                        },
                                                        child: Container(
                                                            width: 120.w,
                                                            // height: 50.h,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.r),
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.w),
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .camera,
                                                                    size: 24.sp,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5.w,
                                                                  ),
                                                                  TextApp(
                                                                    fontsize:
                                                                        14.sp,
                                                                    text:
                                                                        "Chụp ảnh",
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ],
                                                              ),
                                                            )),
                                                      ),
                                                    ],
                                                  )),
                                                ),
                                              )
                                            : Stack(
                                                children: [
                                                  SizedBox(
                                                      width: 1.sw,
                                                      // height: 250.w,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.r),
                                                        child: Image.file(
                                                          selectedImage!,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )),
                                                  Positioned(
                                                    top: 5.w,
                                                    right: 5.w,
                                                    child: InkWell(
                                                      onTap: () {
                                                        deleteImage();
                                                      },
                                                      child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          color: Colors.white
                                                              .withOpacity(0.8),
                                                        ),
                                                        child: Center(
                                                            child: Icon(
                                                          Icons.close,
                                                          size: 20.sp,
                                                          color: Colors.black,
                                                        )),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              child: !isLoading
                                                  ? ButtonApp(
                                                      event: () {
                                                        if (_formField
                                                                .currentState!
                                                                .validate() &&
                                                            selectedImage !=
                                                                null) {
                                                          sendRequestRechange();
                                                        } else if (selectedImage ==
                                                            null) {
                                                          showCustomDialogModal(
                                                              context: navigatorKey
                                                                  .currentContext!,
                                                              textDesc:
                                                                  "Thêm hình ảnh bạn đã chuyển khoản !",
                                                              title:
                                                                  "Thông báo",
                                                              colorButtonOk:
                                                                  Colors.blue,
                                                              btnOKText:
                                                                  "Xác nhận",
                                                              typeDialog:
                                                                  "info",
                                                              eventButtonOKPress:
                                                                  () {},
                                                              isTwoButton:
                                                                  false);
                                                        }
                                                      },
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      text: "Gửi yêu cầu",
                                                      fontsize: 14.sp,
                                                      colorText: Colors.white,
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                      outlineColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                    )
                                                  : const Center(
                                                      child:
                                                          CircularProgressIndicator()),
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
                ));
              } else {
                return Center(
                    child: TextApp(
                  text: 'Đã xảy ra lỗi, vui lòng thử lại sao!',
                  fontsize: 16.sp,
                ));
              }
            },
          ),
        ));
  }
  //chỉnh style HTML

  Map<String, String> parseStyleAttribute(String style) {
    Map<String, String> result = {};
    final pairs = style.split(';');

    for (var pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        result[parts[0].trim()] = parts[1].trim();
      }
    }

    return result;
  }

// Hàm phụ trợ để chuyển đổi giá trị pixel
  double? parsePixelValue(String value) {
    if (value.endsWith('px')) {
      return double.tryParse(value.substring(0, value.length - 2));
    }
    return double.tryParse(value);
  }
}
