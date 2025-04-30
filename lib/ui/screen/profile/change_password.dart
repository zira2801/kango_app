import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:scan_barcode_app/bloc/auth/logout_bloc/logout_bloc.dart';
import 'package:scan_barcode_app/bloc/auth/logout_bloc/logout_event.dart';
import 'package:scan_barcode_app/bloc/auth/logout_bloc/logout_state.dart';
import 'package:scan_barcode_app/bloc/profile/change_password/change_password_bloc.dart';
import 'package:scan_barcode_app/bloc/profile/get_infor/get_infor_bloc.dart';
import 'package:scan_barcode_app/bloc/profile/update_account_key/update_account_key_bloc.dart';
import 'package:scan_barcode_app/data/models/infor_account_model.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formField1 = GlobalKey<FormState>();
  final _formField2 = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {};
  InforAccountModel? inforAccountDataRes;
  bool currentPasswordVisible = true;
  bool newPasswordVisible = true;
  bool confirmNewPasswordVisible = true;

  bool controller2FAEnabled = false;

  void initializeControllers(List<String> keys) {
    for (var key in keys) {
      controllers[key] = TextEditingController();
    }
  }

//Đổi mật khẩu
  void handleChangePassword() {
    final int? userID = StorageUtils.instance.getInt(key: 'user_ID');
    context.read<ChangePasswordBloc>().add(HandleChangePassword(
        userID: userID,
        oldPassword: controllers['currentPassword']!.text,
        newPassword: controllers['newPassword']!.text,
        confirmNewPassword: controllers['confirmNewPasword']!.text));
  }

//Cập nhật mã kế toán
  void handleUpdateAccountKey() {
    final int? userID = StorageUtils.instance.getInt(key: 'user_ID');
    context.read<UpdateAccountKeyBloc>().add(HandleUpdateAccountKey(
          userID: userID,
          currentPassword: controllers['currentPassworrd_2']!.text,
          user_account_key: controllers['accountantKey']!.text,
          /* userID: userID,
        oldPassword: controllers['currentPassword']!.text,
        newPassword: controllers['newPassword']!.text,
        confirmNewPassword: controllers['confirmNewPasword']!.text)*/
        ));
  }

  @override
  void initState() {
    super.initState();
    initializeControllers([
      'currentPassword',
      'newPassword',
      'confirmNewPasword',
      'accountantKey',
      'currentPassworrd_2'
    ]);
    getInforUser();
  }

  Future<void> getInforUser() async {
    final int? userID = StorageUtils.instance.getInt(key: 'user_ID');
    context
        .read<GetInforProfileBloc>()
        .add(HandleGetInforProfile(userID: userID));
  }

  @override
  void dispose() {
    controllers['currentPassword']!.dispose();
    controllers['newPassword']!.dispose();
    controllers['confirmNewPasword']!.dispose();
    controllers['accountantKey']!.dispose();
    controllers['currentPassworrd_2']!.dispose();
    super.dispose();
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
            text: "Thay đổi mật khẩu",
            fontsize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<GetInforProfileBloc, GetInforProfileState>(
                listener: (context, state) {
              if (state is GetInforProfileStateSuccess) {
                mounted
                    ? setState(() {
                        inforAccountDataRes = state.inforAccountModel;
                        controllers['accountantKey']!.text =
                            inforAccountDataRes?.data.userAccountantKey ?? '';
                      })
                    : null;
              }
            }),
            BlocListener<ChangePasswordBloc, ChangePasswordState>(
              listener: (context, state) {
                if (state is HandleChangePasswordStateSuccess) {
                  showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.green,
                    btnOKText: "Xác nhận",
                    typeDialog: "success",
                    eventButtonOKPress: () {
                      // Clear form fields
                      controllers['currentPassword']!.clear();
                      controllers['newPassword']!.clear();
                      controllers['confirmNewPasword']!.clear();
                      StorageUtils.instance.removeKey(key: 'token');
                      StorageUtils.instance.removeKey(key: 'branch_response');
                      StorageUtils.instance.removeKey(key: 'user_ID');
                      StorageUtils.instance.removeKey(key: 'user_position');
                      StorageUtils.instance.removeKey(key: 'isEditOrderPickup');
                      StorageUtils.instance
                          .removeKey(key: 'isUpdateMotification');
                      StorageUtils.instance.removeKey(key: 'isEditShipment');
                      StorageUtils.instance.removeKey(key: 'isCanScan');
                      StorageUtils.instance.removeKey(key: 'isCreateTicket');
                      StorageUtils.instance.removeKey(key: 'isEditDebit');
                      StorageUtils.instance.removeKey(key: 'isPrintKIKI');
                      navigatorKey.currentContext?.go('/');
                    },
                    isTwoButton: false,
                  );
                } else if (state is HandleChangePasswordStateFailure) {
                  showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.red,
                    btnOKText: "Xác nhận",
                    typeDialog: "error",
                    eventButtonOKPress: () {},
                    isTwoButton: false,
                  );
                }
              },
            ),
            BlocListener<UpdateAccountKeyBloc, UpdateAccountKeyState>(
              listener: (context, state) {
                if (state is HandleUpdateAccountKeyStateSuccess) {
                  showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.green,
                    btnOKText: "Xác nhận",
                    typeDialog: "success",
                    eventButtonOKPress: () {
                      // Clear form fields
                      controllers['currentPassword']!.clear();
                      controllers['newPassword']!.clear();
                      controllers['confirmNewPasword']!.clear();
                      StorageUtils.instance.removeKey(key: 'token');
                      StorageUtils.instance.removeKey(key: 'branch_response');
                      StorageUtils.instance.removeKey(key: 'user_ID');
                      StorageUtils.instance.removeKey(key: 'user_position');
                      StorageUtils.instance.removeKey(key: 'isEditOrderPickup');
                      StorageUtils.instance
                          .removeKey(key: 'isUpdateMotification');
                      StorageUtils.instance.removeKey(key: 'isEditShipment');
                      StorageUtils.instance.removeKey(key: 'isCanScan');
                      StorageUtils.instance.removeKey(key: 'isCreateTicket');
                      StorageUtils.instance.removeKey(key: 'isEditDebit');
                      StorageUtils.instance.removeKey(key: 'isPrintKIKI');
                      navigatorKey.currentContext?.go('/');
                    },
                    isTwoButton: false,
                  );
                } else if (state is HandleUpdateAccountKeyStateFailure) {
                  showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.red,
                    btnOKText: "Xác nhận",
                    typeDialog: "error",
                    eventButtonOKPress: () {},
                    isTwoButton: false,
                  );
                }
              },
            ),
          ],
          child: BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
            builder: (context, state) {
              return SafeArea(
                  child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      Form(
                          key: _formField1,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r),
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "CÀI ĐẶT MẬT KHẨU",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontFamily: "Icomoon",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Expanded(
                                      child: Divider(
                                        height: 1,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
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
                                    TextApp(
                                      text: " Mật khẩu cũ",
                                      fontsize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    CustomTextFormField(
                                      controller:
                                          controllers['currentPassword']!,
                                      hintText: 'Nhập mật khẩu cũ',
                                      isPassword:
                                          true, // Enable password behavior
                                      passwordVisible:
                                          false, // Password visibility initial state
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          return null;
                                        } else {
                                          return "Vui lòng điền mật khẩu hiện tại";
                                        }
                                      },
                                      opacityHintText: 0.5,
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
                                      text: " Mật khẩu mới",
                                      fontsize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    CustomTextFormField(
                                      controller: controllers['newPassword']!,
                                      hintText: 'Nhập mật khẩu mới',
                                      isPassword:
                                          true, // Enable password behavior
                                      passwordVisible:
                                          false, // Password visibility initial state
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          if (value.length < 8) {
                                            return "Mật khẩu phải ít nhất 8 kí tự";
                                          }
                                          return null;
                                        } else {
                                          return "Mật khẩu không được để trống";
                                        }
                                      },
                                      opacityHintText: 0.5,
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
                                      text: " Xác nhận mật khẩu mới",
                                      fontsize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    CustomTextFormField(
                                      controller:
                                          controllers['confirmNewPasword']!,
                                      hintText: 'Nhập mật lại khẩu mới',
                                      isPassword:
                                          true, // Enable password behavior
                                      passwordVisible:
                                          false, // Password visibility initial state
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          if (value !=
                                              controllers['newPassword']!
                                                  .text) {
                                            return "Mật khẩu xác nhận không khớp!";
                                          } else {
                                            return null;
                                          }
                                        } else {
                                          return "Xác nhận mật khẩu không được để trống";
                                        }
                                      },
                                      opacityHintText: 0.5,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ButtonApp(
                                      text: 'Đổi Mật Khẩu',
                                      fontsize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      outlineColor:
                                          Theme.of(context).colorScheme.primary,
                                      event: () {
                                        if (_formField1.currentState!
                                            .validate()) {
                                          handleChangePassword();
                                        }
                                      },
                                    )
                                  ],
                                )
                              ],
                            ),
                          )),
                      SizedBox(
                        height: 10.h,
                      ),
                      Form(
                          key: _formField2,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r),
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "CÀI ĐẶT MÃ KẾT TOÁN",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontFamily: "Icomoon",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Expanded(
                                      child: Divider(
                                        height: 1,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.h,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextApp(
                                      text: " Mã kế toán",
                                      fontsize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    CustomTextFormField(
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Vui lòng nhập mã kế toán';
                                          }
                                          String pattern =
                                              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{10,}$';
                                          RegExp regex = RegExp(pattern);
                                          if (!regex.hasMatch(value)) {
                                            return 'Ít nhất 10 ký tự gồm chữ thường, chữ hoa, số';
                                          }

                                          return null;
                                        },
                                        controller:
                                            controllers['accountantKey']!,
                                        hintText: 'Nhập mã kế toán')
                                  ],
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextApp(
                                      text: " Mật khẩu hiện tại",
                                      fontsize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    CustomTextFormField(
                                      controller:
                                          controllers['currentPassworrd_2']!,
                                      hintText: 'Nhập mật khẩu hiện tại',
                                      isPassword:
                                          true, // Enable password behavior
                                      passwordVisible:
                                          false, // Password visibility initial state
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          return null;
                                        } else {
                                          return "Vui lòng điền mật khẩu hiện tại";
                                        }
                                      },
                                      opacityHintText: 0.5,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ButtonApp(
                                      text: 'Cập nhật',
                                      fontsize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      outlineColor:
                                          Theme.of(context).colorScheme.primary,
                                      event: () {
                                        if (_formField2.currentState!
                                            .validate()) {
                                          handleUpdateAccountKey();
                                        }
                                      },
                                    )
                                  ],
                                )
                              ],
                            ),
                          )),
                      SizedBox(
                        height: 10.h,
                      ),
                      Row(
                        children: [
                          Text(
                            "BẢO MẬT BỔ SUNG",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontFamily: "Icomoon",
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            ),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Expanded(
                            child: Divider(
                              height: 1,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Row(
                        children: [
                          Text(
                            "Xác minh 2 bước (2FA)",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Icomoon",
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Xác minh 2 bước làm giảm đáng kể khả năng thông tin cá nhân trong tài khoản Google của bạn bị người khác đánh cắp. Tại sao? Bởi vì tin tặc không chỉ phải lấy được mật khẩu và tên người dùng của bạn mà còn phải lấy được điện thoại của bạn. Mã gồm 6 chữ số có thể được gửi đến email của bạn.",
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: "Icomoon",
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Transform.scale(
                            scale: 0.8, // Adjust the scale factor as needed
                            child: Switch(
                              value: controller2FAEnabled,
                              onChanged: (value) {
                                setState(() {
                                  controller2FAEnabled = value;
                                });

                                if (controller2FAEnabled == true) {
                                } else {}
                              },
                            ),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Text(
                            "Bật/Tắt mã xác thực lớp",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Icomoon",
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ));
            },
          ),
        ));
  }
}
