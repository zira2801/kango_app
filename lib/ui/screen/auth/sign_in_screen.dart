import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/auth/sign_in_bloc/sign_in_bloc.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/auth/confirm_otp_login.dart';
import 'package:scan_barcode_app/ui/screen/policy/policy_html.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // final BranchService _branchService = BranchService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocProvider(
        create: (context) => SignInBloc(),
        child: BlocListener<SignInBloc, SignInState>(
          listener: (context, state) async {
            if (state is SignInSuccess) {
              final bool? isShipper =
                  StorageUtils.instance.getBool(key: 'is_shipper');
              log("isShipper $isShipper");
              // await _branchService.getBranchsKango();
              if (isShipper == true) {
                log("NAVIGATOR SHIPPER ");
                navigatorKey.currentContext?.go('/home_shipper');
              } else {
                navigatorKey.currentContext?.go('/home');
              }

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
            } else if (state is SignInFailure) {
              showCustomDialogModal(
                  context: navigatorKey.currentContext!,
                  textDesc: state.errorText ?? 'Không thể kết nối đến máy chủ',
                  title: "Thông báo",
                  colorButtonOk: Colors.red,
                  btnOKText: "Xác nhận",
                  typeDialog: "error",
                  eventButtonOKPress: () {},
                  isTwoButton: false);
            } else if (state is SignIn2Authen) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ManagerConfirmOTP()),
              );
            }
          },
          child: BlocBuilder<SignInBloc, SignInState>(
            builder: (context, state) {
              if (state is SignInLoading) {
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
                child: SignInForm(),
              ));
            },
          ),
        ),
      ),
    );
  }
}

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formSignInKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passworldController = TextEditingController();
  bool rememberPassword = true;
  bool agreeWithCondition = true;
  bool passwordVisible = true;
  String imageBiometric = 'assets/svg/face_ID.svg';
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  String _authorized = 'Chưa xác thực';
  bool _isAuthenticating = false;

  @override
  void dispose() {
    super.dispose();
    emailController.clear();
    passworldController.clear();
  }

  @override
  void initState() {
    super.initState();
    checkDevice();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );
    // Kiểm tra xem có thông tin đăng nhập đã lưu không
    _loadSavedLoginInfo();
  }

  // Hàm load thông tin đăng nhập đã lưu
  Future<void> _loadSavedLoginInfo() async {
    final bool? remembered =
        StorageUtils.instance.getBool(key: 'remember_login');
    if (remembered == true) {
      final String? savedEmail =
          StorageUtils.instance.getString(key: 'saved_email');
      final String? savedPassword =
          StorageUtils.instance.getString(key: 'saved_password');

      if (savedEmail != null && savedPassword != null) {
        setState(() {
          emailController.text = savedEmail;
          passworldController.text = savedPassword;
          rememberPassword = true;
        });
      }
    }
  }

  // Hàm lưu thông tin đăng nhập
  Future<void> _saveLoginInfo() async {
    if (rememberPassword) {
      await StorageUtils.instance.setBool(key: 'remember_login', val: true);
      await StorageUtils.instance
          .setString(key: 'saved_email', val: emailController.text);
      await StorageUtils.instance
          .setString(key: 'saved_password', val: passworldController.text);
    } else {
      await StorageUtils.instance.setBool(key: 'remember_login', val: false);
      await StorageUtils.instance.removeKey(key: 'saved_email');
      await StorageUtils.instance.removeKey(key: 'saved_password');
    }
  }

  void checkDevice() {
    if (!mounted) {
      return;
    }
    if (Platform.isAndroid) {
      setState(() {
        imageBiometric = 'assets/svg/android_fingerprint.svg';
      });
    } else if (Platform.isIOS) {
      setState(() {
        imageBiometric = 'assets/svg/face_ID.svg';
      });
    }
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    final List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    if (availableBiometrics.isNotEmpty) {
      // Some biometrics are enrolled.
      log("TYPE Biometric isNotEmpty");
    }
    if (availableBiometrics.contains(BiometricType.strong)) {
      log("TYPE Biometric strong");
    }
    if (availableBiometrics.contains(BiometricType.face)) {
      log("TYPE Biometric face");
      if (!mounted) {
        return;
      }
      if (Platform.isAndroid) {
        setState(() {
          imageBiometric = 'assets/svg/android_face.svg';
        });
      } else if (Platform.isIOS) {
        setState(() {
          imageBiometric = 'assets/svg/face_ID.svg';
        });
      }
    }
    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      log("TYPE Biometric fingerprint");
      if (!mounted) {
        return;
      }
      if (Platform.isAndroid) {
        setState(() {
          imageBiometric = 'assets/svg/android_fingerprint.svg';
        });
      } else if (Platform.isIOS) {
        setState(() {
          imageBiometric = 'assets/svg/touch_ID.svg';
        });
      }
    }
    try {
      mounted
          ? setState(() {
              _isAuthenticating = true;
              _authorized = 'Đang xác thực';
            })
          : null;
      authenticated = await auth.authenticate(
        localizedReason: 'Xác thực danh tính của bạn',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      mounted
          ? setState(() {
              _isAuthenticating = false;
              _authorized = 'Error - ${e.message}';
            })
          : null;
      return;
    }
    if (!mounted) {
      return;
    }

    setState(() =>
        _authorized = authenticated ? 'Đã xác thực' : 'Xác thực thất bại');
    if (authenticated) {
      final String emailSaved =
          StorageUtils.instance.getString(key: 'email_login_autofill')!;
      final String passwordSaved =
          StorageUtils.instance.getString(key: 'password_login_autofill')!;

      context.read<SignInBloc>().add(
            SignInButtonPressed(
              email: emailSaved,
              password: passwordSaved,
            ),
          );
    } else {
      log("Authentication failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formSignInKey,
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
              text: 'Nhập thông tin tài khoản để đăng nhập',
              fontsize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground, //nen xanh
            ),
            SizedBox(
              height: 40.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextApp(
                  text: "Tài khoản",
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
                    return 'Vui lòng nhập tài khoản';
                  }
                  return null;
                },
                hintText: 'Nhập tài khoản'),
            SizedBox(
              height: 25.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextApp(
                  text: "Mật khẩu",
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
              controller: passworldController,
              hintText: 'Nhập mật khẩu',
              isPassword: true, // Enable password behavior
              passwordVisible: false, // Password visibility initial state
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu';
                }
                return null;
              },
              opacityHintText: 0.5,
            ),
            SizedBox(
              height: 25.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      checkColor: Theme.of(context).colorScheme.background,
                      value: rememberPassword,
                      onChanged: (bool? value) {
                        if (!mounted) {
                          return;
                        }
                        setState(() {
                          rememberPassword = value!;
                        });
                        // Nếu bỏ chọn checkbox, xóa thông tin đã lưu
                        if (!value!) {
                          StorageUtils.instance.removeKey(key: 'saved_email');
                          StorageUtils.instance
                              .removeKey(key: 'saved_password');
                          StorageUtils.instance
                              .setBool(key: 'remember_login', val: false);
                        }
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    Text(
                      'Ghi nhớ đăng nhập',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 14.sp),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    context.go('/forgot_password');
                  },
                  child: Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14.sp),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 1.sw,
              child: Row(
                children: [
                  Checkbox(
                    checkColor: Theme.of(context).colorScheme.background,
                    value: agreeWithCondition,
                    onChanged: (bool? value) {
                      if (!mounted) {
                        return;
                      }
                      setState(() {
                        agreeWithCondition = value!;
                      });
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tuân thủ  ',
                        style: TextStyle(color: Colors.black, fontSize: 14.sp),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const TermsOfService()),
                          );
                        },
                        child: SizedBox(
                          width: 250.w,
                          child: TextApp(
                            fontsize: 14.sp,
                            isOverFlow: false,
                            softWrap: true,
                            text: 'Điều Khoản Của KANGO EXPRESS',
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 25.h,
            ),
            _supportState == _SupportState.supported
                ? SizedBox(
                    width: 1.sw,
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                              height: 50.h,
                              child: ButtonApp(
                                text: 'Đăng nhập',
                                fontsize: 16.sp,
                                fontWeight: FontWeight.bold,
                                colorText:
                                    Theme.of(context).colorScheme.background,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                outlineColor:
                                    Theme.of(context).colorScheme.primary,
                                event: () {
                                  if (_formSignInKey.currentState!.validate() &&
                                      agreeWithCondition) {
                                    final username = emailController.text;
                                    final password = passworldController.text;
                                    context.read<SignInBloc>().add(
                                          SignInButtonPressed(
                                            email: username,
                                            password: password,
                                          ),
                                        );
                                  } else if (!agreeWithCondition) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Vui lòng tuân thủ điều khoản của Kango Express')),
                                    );
                                  }
                                },
                              )),
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        InkWell(
                          onTap: () {
                            final String? emailSaved = StorageUtils.instance
                                .getString(key: 'email_login_autofill');
                            final String? passwordSaved = StorageUtils.instance
                                .getString(key: 'password_login_autofill');
                            if (emailSaved != null && passwordSaved != null) {
                              _authenticate();
                            } else {
                              showCustomDialogModal(
                                  context: navigatorKey.currentContext!,
                                  textDesc:
                                      "Bạn cần đăng nhập trước để có thể mở tính năng này",
                                  title: "Thông báo",
                                  colorButtonOk: Colors.blue,
                                  btnOKText: "Xác nhận",
                                  typeDialog: "info",
                                  eventButtonOKPress: () {},
                                  isTwoButton: false);
                            }
                          },
                          child: SizedBox(
                            width: 50.h,
                            height: 50.h,
                            child: SvgPicture.asset(
                              imageBiometric,
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : SizedBox(
                    width: 1.sw,
                    height: 50.h,
                    child: ButtonApp(
                      text: 'Đăng nhập',
                      fontsize: 16.sp,
                      fontWeight: FontWeight.bold,
                      colorText: Theme.of(context).colorScheme.background,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      outlineColor: Theme.of(context).colorScheme.primary,
                      event: () {
                        if (_formSignInKey.currentState!.validate() &&
                            agreeWithCondition) {
                          final username = emailController.text;
                          final password = passworldController.text;
                          _saveLoginInfo();
                          context.read<SignInBloc>().add(
                                SignInButtonPressed(
                                  email: username,
                                  password: password,
                                ),
                              );
                        } else if (!agreeWithCondition) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Vui lòng tuân thủ điều khoản của Kango Express')),
                          );
                        }
                      },
                    )),
            SizedBox(
              height: 20.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bạn chưa có tài khoản? ',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 16.sp),
                ),
                GestureDetector(
                  onTap: () {
                    context.go('/sign_up_customer');
                  },
                  child: Text(
                    'Đăng kí',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16.sp),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
