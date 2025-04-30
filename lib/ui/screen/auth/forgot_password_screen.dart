import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/auth/forgot_password_bloc/forgot_password_bloc.dart';
import 'package:scan_barcode_app/bloc/auth/forgot_password_bloc/forgot_password_event.dart';
import 'package:scan_barcode_app/bloc/auth/forgot_password_bloc/forgot_password_state.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: BlocProvider(
          create: (context) => ForgotPasswordBloc(),
          child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
            listener: (context, state) {
              if (state is ForgotPasswordSuccess) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  showCustomDialogModal(
                      context: navigatorKey.currentContext!,
                      textDesc: state.messRes ?? 'Thành công',
                      title: "Thông báo",
                      colorButtonOk: Colors.green,
                      btnOKText: "Xác nhận",
                      typeDialog: "success",
                      eventButtonOKPress: () {},
                      isTwoButton: false);
                });
              } else if (state is ForgotPasswordFailure) {
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
            child: BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
              builder: (context, state) {
                if (state is ForgotPasswordLoading) {
                  return Center(
                    child: SizedBox(
                      width: 100.w,
                      height: 100.w,
                      child: Lottie.asset('assets/lottie/loading_kango.json'),
                    ),
                  );
                }
                return const SafeArea(
                    child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: ForgotPassForm(),
                ));
              },
            ),
          ),
        ));
  }
}

class ForgotPassForm extends StatefulWidget {
  const ForgotPassForm({super.key});

  @override
  State<ForgotPassForm> createState() => _ForgotPassFormState();
}

class _ForgotPassFormState extends State<ForgotPassForm> {
  final _formForgotPassKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formForgotPassKey,
        child: Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w),
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
                // color: Colors.amber,
                child: Image.asset('assets/images/logo_kango_2.png'),
              ),
              SizedBox(
                height: 5.h,
              ),
              TextApp(
                text: 'Nhập email của bạn để lấy lại mật khẩu',
                fontsize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              const SizedBox(
                height: 40.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextApp(
                    text: "Email",
                    color: Theme.of(context).colorScheme.onBackground,
                    fontsize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              SizedBox(
                height: 5.h,
              ),
              CustomTextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    bool emailValid = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value);
                    if (!emailValid) {
                      return "Email không hợp lệ";
                    } else {
                      return null;
                    }
                  },
                  hintText: 'Nhập email'),
              SizedBox(
                height: 25.h,
              ),
              SizedBox(
                width: 1.sw,
                height: 50.h,
                child: ButtonApp(
                  text: 'Xác nhận',
                  fontsize: 16.sp,
                  fontWeight: FontWeight.bold,
                  colorText: Theme.of(context).colorScheme.background,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  outlineColor: Theme.of(context).colorScheme.primary,
                  event: () {
                    if (_formForgotPassKey.currentState!.validate()) {
                      context.read<ForgotPasswordBloc>().add(
                            ForgotPasswordButtonPressed(
                              email: emailController.text,
                            ),
                          );
                    }
                  },
                ),
              ),
              SizedBox(
                height: 25.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.go('/');
                    },
                    child: Text(
                      'Quay về đăng nhập',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
