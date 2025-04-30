import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/auth/confirm_otp_login_bloc/confirm_otp_login_bloc.dart';
import 'package:scan_barcode_app/bloc/auth/confirm_otp_login_bloc/confirm_otp_login_event.dart';
import 'package:scan_barcode_app/bloc/auth/confirm_otp_login_bloc/confirm_otp_login_state.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class ManagerConfirmOTP extends StatefulWidget {
  final String? verificationId;
  const ManagerConfirmOTP({super.key, this.verificationId});

  @override
  State<ManagerConfirmOTP> createState() => _ManagerConfirmOTPState();
}

class _ManagerConfirmOTPState extends State<ManagerConfirmOTP> {
  String otp = "";
  bool showButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color.fromRGBO(248, 249, 250, 1),
        body: BlocProvider(
          create: (context) => ConfirmOTPLoginBloc(),
          child: BlocListener<ConfirmOTPLoginBloc, ConfirmOTPLoginState>(
            listener: (context, state) async {
              if (state is ConfirmOTPLoginSuccess) {
                navigatorKey.currentContext?.go('/home');
                Future.delayed(const Duration(milliseconds: 300), () {
                  showCustomDialogModal(
                      context: navigatorKey.currentContext!,
                      textDesc: "Đăng nhập thành công",
                      title: "Thông báo",
                      colorButtonOk: Colors.green,
                      btnOKText: "Xác nhận",
                      typeDialog: "success",
                      eventButtonOKPress: () {},
                      isTwoButton: false);
                });
              } else if (state is ConfirmOTPLoginFailure) {
                showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc:
                        state.errorText ?? 'Không thể kết nối đến máy chủ',
                    title: "Thông báo",
                    colorButtonOk: Colors.red,
                    btnOKText: "Xác nhận",
                    typeDialog: "error",
                    eventButtonOKPress: () {},
                    isTwoButton: false);
              }
            },
            child: BlocBuilder<ConfirmOTPLoginBloc, ConfirmOTPLoginState>(
              builder: (context, state) {
                if (state is ConfirmOTPLoginLoading) {
                  return Center(
                    child: SizedBox(
                      width: 100.w,
                      height: 100.w,
                      child: Lottie.asset('assets/lottie/loading_kango.json'),
                    ),
                  );
                }
                return Stack(
                  children: [
                    SafeArea(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 150.h,
                            ),
                            SizedBox(
                              width: 280.w,
                              height: 80.w,
                              child:
                                  Image.asset('assets/images/logo_kango_2.png'),
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            TextApp(
                              text: 'Nhập OTP được gửi về email của bạn',
                              fontsize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            const SizedBox(
                              height: 40.0,
                            ),
                            Column(
                              children: [
                                OtpTextField(
                                  fieldWidth: 50.w,
                                  numberOfFields: 4,
                                  borderColor: Colors.green,
                                  focusedBorderColor: Colors.green,
                                  cursorColor: Colors.black,
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.1),
                                  showFieldAsBox: true,
                                  onCodeChanged: (String code) {
                                    if (!mounted) {
                                      return;
                                    }
                                    setState(() {
                                      showButton = false;
                                    });
                                  },
                                  onSubmit: (String verificationCode) {
                                    if (!mounted) {
                                      return;
                                    }
                                    setState(() {
                                      showButton = true;
                                      otp = verificationCode;
                                    });
                                  },
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                CountdownTimer(
                                  duration: const Duration(minutes: 5),
                                  onFinish: () {
                                    showExpiredOtpDialog(context);
                                  },
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                Visibility(
                                  visible: showButton,
                                  child: Container(
                                    width: 1.sw,
                                    height: 50.h,
                                    padding: EdgeInsets.only(
                                        left: 50.w, right: 50.w),
                                    child: ButtonApp(
                                      text: 'Xác nhận',
                                      fontsize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      outlineColor:
                                          Theme.of(context).colorScheme.primary,
                                      event: () {
                                        context.read<ConfirmOTPLoginBloc>().add(
                                              ConfirmOTPLoginButtonPressed(
                                                  otp: otp),
                                            );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40.w, // Adjust the position as needed
                      left: 10.w, // Adjust the position as needed
                      child: CustomBackButton(),
                    ),
                  ],
                );
              },
            ),
          ),
        ));
  }
}

class CountdownTimer extends StatefulWidget {
  final Duration duration;
  final Function? onFinish;
  const CountdownTimer({required this.duration, this.onFinish});

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
    _startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel(); // Cancel the timer when the widget is disposed
  }

  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (_remainingTime > Duration.zero) {
          _remainingTime -= const Duration(seconds: 1);
        } else {
          _timer?.cancel();
          widget.onFinish?.call(); // Call the optional callback
        }
      });
    });
  }

  void _resetTimer() {
    if (!mounted) {
      return;
    }
    setState(() {
      _remainingTime =
          widget.duration; // Reset the remaining time to the original duration
      _timer?.cancel(); // Cancel the existing timer
      _startTimer(); // Start a new timer from the reset duration
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = formatDuration(_remainingTime);
    return Column(
      children: [
        TextApp(
          text: formattedTime,
          color: Theme.of(context).colorScheme.primary,
          fontsize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(
          height: 10.h,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextApp(
              text: "Chưa nhận được mã OTP ? ",
              fontsize: 12.sp,
            ),
            InkWell(
              onTap: () {
                _resetTimer();
              },
              child: TextApp(
                text: "Gửi lại",
                color: const Color.fromRGBO(52, 71, 103, 1),
                fontWeight: FontWeight.bold,
                fontFamily: "OpenSans",
                fontsize: 12.sp,
              ),
            )
          ],
        )
      ],
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes % 60)} : ${twoDigits(duration.inSeconds % 60)}";
  }
}

class CustomBackButton extends StatelessWidget {
  final Color color;
  final double size;

  CustomBackButton({this.color = Colors.black, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.chevron_left, color: color, size: size),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
