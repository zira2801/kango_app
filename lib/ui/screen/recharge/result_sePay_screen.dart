import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:lottie/lottie.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:scan_barcode_app/bloc/recharge/check_payment_bank/check_payment_bank_bloc.dart';
import 'package:scan_barcode_app/bloc/recharge/get_infor_sepay/get_infor_sepay_bloc.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ResultSePayScreen extends StatefulWidget {
  final int rechargeID;
  const ResultSePayScreen({
    super.key,
    required this.rechargeID,
  });

  @override
  State<ResultSePayScreen> createState() => _ResultSePayScreenState();
}

class _ResultSePayScreenState extends State<ResultSePayScreen> {
  Future<void> getInforSePayRechange() async {
    BlocProvider.of<GetInforSePayBloc>(context)
        .add(HanldeGetInforSePayEvent(rechargeID: widget.rechargeID));
  }

  Future<void> checkPaymentStatusSePay() async {
    BlocProvider.of<CheckPaymentBankBloc>(context)
        .add(HandleCheckPaymentBank(orderId: widget.rechargeID.toString()));
  }

  Duration _remainingTime = Duration.zero;

  Timer? _timer;

  void startTimer({required Function? onFinish}) {
    // Run the callback function every second to update the remaining time
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > Duration.zero) {
          _remainingTime -= const Duration(seconds: 1);
          checkPaymentStatusSePay();
        } else {
          _timer?.cancel();
          onFinish?.call();
        }
      });
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes % 60)} : ${twoDigits(duration.inSeconds % 60)}";
  }

  // To stop the timer
  void stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      print("Timer stopped");
    }
  }

  @override
  void initState() {
    super.initState();
    getInforSePayRechange();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  Future<void> downloadImage(
      {required String imageUrl, required BuildContext context}) async {
    final response = await http.get(Uri.parse(imageUrl));
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      var filename = '${dir.path}/QRcode.png';
      final File file = File(filename);
      await file.writeAsBytes(response.bodyBytes);
      final params = SaveFileDialogParams(sourceFilePath: file.path);
      final finalPath = await FlutterFileDialog.saveFile(params: params);
      if (finalPath != null) {
        scaffoldMessenger.showSnackBar(SnackBar(
          content: TextApp(
            text: "Đã lưu ảnh vào thiết bị",
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontsize: 14.sp,
          ),
          backgroundColor: Colors.black,
        ));
      }
    } else {
      scaffoldMessenger.showSnackBar(SnackBar(
        content: TextApp(
          text: "Lưu ảnh không thành công",
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontsize: 14.sp,
        ),
        backgroundColor: Colors.black,
      ));
    }
  }

  int flgPaySe = 0;
  bool isFinishPaymentSePay = false;
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
            text: "Thông tin chuyển khoản",
            fontsize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          leading: InkWell(
              onTap: () => {
                    isFinishPaymentSePay
                        ? Navigator.pop(context)
                        : showCustomDialogModal(
                            context: navigatorKey.currentContext!,
                            textDesc:
                                "Bạn chưa hoàn thành việc thanh toán. \n Bạn có chắc muốn thoát ?",
                            title: "Thông báo",
                            colorButtonOk: Colors.green,
                            colorButtonCancle: Colors.red,
                            btnOKText: "Xác nhận",
                            btnCancleText: "Đóng",
                            typeDialog: "question",
                            eventButtonOKPress: () {
                              Navigator.pop(context);
                            },
                            eventButtonCanclePress: () {},
                            isTwoButton: true)
                  },
              child: Container(
                // margin: EdgeInsets.only(right: 15.w),
                width: 50.w,
                height: 50.w,
                child: Icon(
                  Icons.chevron_left,
                  color: Colors.black,
                  size: 32.sp,
                ),
              )),
        ),
        body: MultiBlocListener(
            listeners: [
              BlocListener<GetInforSePayBloc, GetInforSePayState>(
                listener: (context, state) {
                  if (state is GetInforSePayStateSuccess) {
                    int minutes =
                        state.getDataDetailsSePayModel!.timeExpiredPayment;
                    String timePaymentExpiredAt = state
                        .getDataDetailsSePayModel!.recharge.createdAt
                        .add(Duration(minutes: minutes))
                        .toString();
                    // Get the expiration time from the response
                    String expirationString = timePaymentExpiredAt;
                    DateTime paymentExpiredAt = DateTime.parse(
                        expirationString); // Parse the string into DateTime
                    DateTime currentTime = DateTime.now(); // Get current time

                    // Calculate remaining time
                    _remainingTime = paymentExpiredAt.difference(currentTime);

                    if (_remainingTime > Duration.zero) {
                      // Start countdown timer
                      startTimer(onFinish: () {
                        showExpiredPaymentSePay(
                            context: context,
                            eventButtonCanclePress: () {
                              Navigator.pop(context);
                            });
                      });
                    } else {
                      // If the remaining time is already 0 or negative, show the expired dialog
                      showExpiredPaymentSePay(
                          context: context,
                          eventButtonCanclePress: () {
                            Navigator.pop(context);
                          });
                    }
                  }
                },
              ),
              BlocListener<CheckPaymentBankBloc, CheckPaymentBankState>(
                listener: (context, state) {
                  if (state is CheckPaymentBankStateSuccess) {
                    stopTimer();
                    isFinishPaymentSePay = true;
                    showSuccesPaymentSePay(
                        context: context,
                        eventButtonCanclePress: () {
                          Navigator.pop(context);
                        });
                  } else if (state is CheckPaymentBankStateFailure) {}
                },
              ),
            ],
            child: BlocBuilder<GetInforSePayBloc, GetInforSePayState>(
              builder: (context, state) {
                if (state is GetInforSePayStateLoading) {
                  return Container();
                } else if (state is GetInforSePayStateSuccess) {
                  return SafeArea(
                      child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        Container(
                            width: 1.sw,
                            // height: 300.h,
                            // color: Colors.amber,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        flgPaySe = 0;
                                      });
                                    },
                                    child: Container(
                                      width: 1.sw,
                                      color: flgPaySe == 0
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.white,
                                      child: TextApp(
                                        textAlign: TextAlign.center,
                                        text: "QR Code",
                                        fontsize: 18.sp,
                                        color: flgPaySe == 0
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        flgPaySe = 1;
                                      });
                                    },
                                    child: Container(
                                      width: 1.sw,
                                      color: flgPaySe == 1
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.white,
                                      child: TextApp(
                                          textAlign: TextAlign.center,
                                          text: "Thủ công",
                                          fontsize: 18.sp,
                                          color: flgPaySe == 1
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        const Divider(
                          height: 1,
                          color: Colors.grey,
                        ),
                        BlocBuilder<GetInforSePayBloc, GetInforSePayState>(
                          builder: (context, state) {
                            if (state is GetInforSePayStateLoading) {
                              return Center(
                                child: SizedBox(
                                  width: 200.w,
                                  height: 200.w,
                                  child: Lottie.asset(
                                      'assets/lottie/loading_7_color.json'),
                                ),
                              );
                            } else if (state is GetInforSePayStateSuccess) {
                              var bankAccount = state.getDataDetailsSePayModel!
                                  .bankAccountDetail.accountNumber;
                              var amount = state
                                  .getDataDetailsSePayModel!.recharge.amount
                                  .toString();
                              var amountDouble = state
                                  .getDataDetailsSePayModel!.recharge.amount
                                  .toDouble();
                              var bankCode = state.getDataDetailsSePayModel!
                                  .bankAccountDetail.bankCode;
                              var bankName = state.getDataDetailsSePayModel!
                                  .bankAccountDetail.bankShortName;
                              var accountHolderName = state
                                  .getDataDetailsSePayModel!
                                  .bankAccountDetail
                                  .accountHolderName;
                              var idReChange = state
                                  .getDataDetailsSePayModel!.recharge.rechargeId
                                  .toString();
                              var timeExpired = state
                                  .getDataDetailsSePayModel!.timeExpiredPayment;
                              var codeSePay =
                                  state.getDataDetailsSePayModel!.code;
                              if (flgPaySe == 0) {
                                return Column(
                                  children: [
                                    Container(
                                      width: 1.sw,
                                      // height: 100.h,
                                      color: Colors.white,
                                      child: CachedNetworkImage(
                                        fit: BoxFit.fill,
                                        imageUrl:
                                            "https://qr.sepay.vn/img?bank=MBBank&acc=${bankAccount}&template=compact&amount=${amount}&des=$codeSePay",
                                        placeholder: (context, url) => SizedBox(
                                          height: 30.w,
                                          width: 30.w,
                                          child: const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                    ButtonApp(
                                        event: () {
                                          downloadImage(
                                              imageUrl:
                                                  "https://qr.sepay.vn/img?bank=MBBank&acc=${bankAccount}&template=compact&amount=${amount}&des=$codeSePay",
                                              context: context);
                                        },
                                        text: "Tải ảnh QR",
                                        colorText: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        backgroundColor: Colors.white,
                                        outlineColor: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    SizedBox(
                                      height: 15.h,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextApp(
                                          text: "Trạng thái: ",
                                          fontsize: 16.sp,
                                          color: Colors.black,
                                        ),
                                        BlocBuilder<CheckPaymentBankBloc,
                                                CheckPaymentBankState>(
                                            builder: (context, state) {
                                          if (state
                                              is CheckPaymentBankStateSuccess) {
                                            return Row(
                                              children: [
                                                TextApp(
                                                  text: "Thanh toán thành công",
                                                  fontsize: 16.sp,
                                                  color: Colors.black,
                                                ),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Icon(
                                                  Icons.check_circle_outline,
                                                  color: Colors.green,
                                                  size: 18.sp,
                                                )
                                              ],
                                            );
                                          }
                                          return Row(
                                            children: [
                                              TextApp(
                                                text: "Chờ thanh toán",
                                                fontsize: 16.sp,
                                                color: Colors.black,
                                              ),
                                              Center(
                                                child: SizedBox(
                                                  width: 50.w,
                                                  height: 50.w,
                                                  child: Lottie.asset(
                                                      'assets/lottie/loading_kango.json'),
                                                ),
                                              )
                                            ],
                                          );
                                        })
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        TextApp(
                                          text: formatDuration(_remainingTime),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontsize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              } else {
                                return Column(
                                  children: [
                                    Container(
                                      width: 150.w,
                                      height: 75.w,
                                      child: CachedNetworkImage(
                                        fit: BoxFit.fill,
                                        imageUrl:
                                            "https://qr.sepay.vn/assets/img/banklogo/${bankCode}.png",
                                        placeholder: (context, url) => SizedBox(
                                          height: 10.w,
                                          width: 10.w,
                                          child: const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                    TextApp(
                                      text: bankName,
                                      fontsize: 16.sp,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      height: 15.h,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        TextApp(
                                          text: "Chủ tài khoản: ",
                                          fontsize: 18.sp,
                                          color: Colors.grey,
                                        ),
                                        TextApp(
                                          text: accountHolderName,
                                          fontsize: 18.sp,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        TextApp(
                                          text: "Số TK: ",
                                          fontsize: 18.sp,
                                          color: Colors.grey,
                                        ),
                                        TextApp(
                                          text: bankAccount,
                                          fontsize: 18.sp,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(
                                                    text: bankAccount))
                                                .then(
                                              (value) {
                                                //only if ->
                                                MotionToast(
                                                  primaryColor: Colors.green,
                                                  secondaryColor:
                                                      Colors.green[700],
                                                  // Theme.of(context)
                                                  //     .colorScheme
                                                  //     .primary,
                                                  icon: Icons.check_circle,
                                                  title: TextApp(
                                                    text: "Thành công",
                                                    color: Colors.white,
                                                    fontsize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  description: TextApp(
                                                    text: "Đã copy !",
                                                    color: Colors.white,
                                                    fontsize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  position:
                                                      MotionToastPosition.top,
                                                  animationType:
                                                      AnimationType.fromTop,
                                                ).show(context);
                                              },
                                            );
                                          },
                                          child: Icon(
                                            Icons.copy,
                                            size: 24.sp,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        TextApp(
                                          text: "Số tiền: ",
                                          fontsize: 18.sp,
                                          color: Colors.grey,
                                        ),
                                        TextApp(
                                          text:
                                              "${MoneyFormatter(amount: (amountDouble)).output.withoutFractionDigits.toString()} đ",
                                          fontsize: 18.sp,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        TextApp(
                                          text: "Nội dung CK: ",
                                          fontsize: 18.sp,
                                          color: Colors.grey,
                                        ),
                                        TextApp(
                                          text: codeSePay,
                                          fontsize: 18.sp,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(
                                                    text: codeSePay))
                                                .then(
                                              (value) {
                                                //only if ->
                                                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã copy !")));

                                                MotionToast(
                                                  primaryColor: Colors.green,
                                                  secondaryColor:
                                                      Colors.green[700],
                                                  icon: Icons.check_circle,
                                                  title: TextApp(
                                                    text: "Thành công",
                                                    color: Colors.white,
                                                    fontsize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  description: TextApp(
                                                    text: "Đã copy !",
                                                    color: Colors.white,
                                                    fontsize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  position:
                                                      MotionToastPosition.top,
                                                  animationType:
                                                      AnimationType.fromTop,
                                                ).show(context);
                                              },
                                            );
                                          },
                                          child: Icon(
                                            Icons.copy,
                                            size: 24.sp,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    Container(
                                      color: Colors.grey[300],
                                      padding: EdgeInsets.all(20),
                                      child: TextApp(
                                        text:
                                            "Lưu ý: Vui lòng giữ nguyên nội dung chuyển khoản để hệ thống tự động xác nhận thanh toán",
                                        isOverFlow: false,
                                        softWrap: true,
                                        maxLines: 3,
                                      ),
                                    )
                                  ],
                                );
                              }
                            } else if (state is GetInforSePayStateFailure) {
                              return ErrorDialog(
                                eventConfirm: () {},
                                errorText:
                                    'Failed to fetch orders: ${state.message}',
                              );
                            }
                            return const Center(child: NoDataFoundWidget());
                          },
                        )
                      ],
                    ),
                  ));
                } else if (state is GetInforSePayStateFailure) {
                  return ErrorDialog(
                    eventConfirm: () {
                      Navigator.pop(context);
                    },
                    errorText: 'Failed to fetch orders: ${state.message}',
                  );
                }
                return const Center(child: NoDataFoundWidget());
              },
            )));
  }
}
