import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/auth/logout_bloc/logout_bloc.dart';
import 'package:scan_barcode_app/bloc/auth/logout_bloc/logout_event.dart';
import 'package:scan_barcode_app/bloc/auth/logout_bloc/logout_state.dart';
import 'package:scan_barcode_app/bloc/profile/get_infor/get_infor_bloc.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/models/infor_account_model.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/profile/change_password.dart';
import 'package:scan_barcode_app/ui/screen/profile/edit_profile.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:go_router/go_router.dart';

class EditProfileShipper extends StatefulWidget {
  const EditProfileShipper({super.key});

  @override
  State<EditProfileShipper> createState() => _EditProfileShipperState();
}

class _EditProfileShipperState extends State<EditProfileShipper> {
  InforAccountModel? dataUser;
  List<String> menuMyAccountTitle = [
    "Thông tin tài khoản",
    "Bảo mật",
    "Face ID",
  ];

  List menuMyAccountIcon = [
    Icons.document_scanner,
    Icons.lock,
    Icons.face,
  ];

  final List<void Function(BuildContext)> menuMyAccountActions = [
    (context) {
      // Action for "Shipping Preferences"
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
      );
      print("Thông tin tài khoản tapped");
    },
    (context) {
      // Action for "Notification"
      print("Đổi mật khẩu tapped");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const ChangePasswordScreen()));
    },
    (context) {
      // Action for "Announcement"

      print("Face ID tapped");
    },
  ];

  void turnOnFaceID() async {
    final String? emailSaved =
        StorageUtils.instance.getString(key: 'saved_email');
    final String? passwordSaved =
        StorageUtils.instance.getString(key: 'save_password');
    if (emailSaved != null && passwordSaved != null) {
      await StorageUtils.instance
          .setString(key: 'email_login_autofill', val: emailSaved);
      await StorageUtils.instance
          .setString(key: 'password_login_autofill', val: passwordSaved);
    }
  }

  void turnOffFaceID() async {
    await StorageUtils.instance.removeKey(key: 'email_login_autofill');
    await StorageUtils.instance.removeKey(key: 'password_login_autofill');
    await StorageUtils.instance.removeKey(key: 'saved_email');
    await StorageUtils.instance.removeKey(key: 'save_password');
  }

  bool faceIdEnabled = false;

  Future<void> getInforUser() async {
    final int? userID = StorageUtils.instance.getInt(key: 'user_ID');
    context
        .read<GetInforProfileBloc>()
        .add(HandleGetInforProfile(userID: userID));
  }

  void init() async {
    await getInforUser();
  }

  @override
  void initState() {
    init();
    super.initState();
    final bool? enableFaceID =
        StorageUtils.instance.getBool(key: 'enable_faceID');
    if (enableFaceID != null) {
      faceIdEnabled = enableFaceID;
    } else {
      faceIdEnabled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: TextApp(
          text: "Thông tin cá nhân",
          fontsize: 20.sp,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      body: MultiBlocListener(
        listeners: [
          BlocListener<GetInforProfileBloc, GetInforProfileState>(
              listener: (context, state) {
            if (state is GetInforProfileStateSuccess) {
              setState(() {
                dataUser = state.inforAccountModel;
              });
            }
          })
        ],
        child: BlocBuilder<GetInforProfileBloc, GetInforProfileState>(
          builder: (context, state) {
            if (state is GetInforProfileStateSuccess) {
              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 1.sw,
                        color: Theme.of(context).colorScheme.background,
                        child: Padding(
                          padding: EdgeInsets.all(10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 60.w,
                                    height: 60.w,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                            width: 2,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30.w),
                                      child: dataUser?.data.userLogo == null
                                          ? Image.asset(
                                              'assets/images/user_avatar.png',
                                              fit: BoxFit.contain,
                                            )
                                          : Container(
                                              width: 60.w,
                                              height: 60.w,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30.r),
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl: httpImage +
                                                      dataUser!.data.userLogo!,
                                                  placeholder: (context, url) =>
                                                      SizedBox(
                                                    height: 20.w,
                                                    width: 20.w,
                                                    child: const Center(
                                                        child:
                                                            CircularProgressIndicator()),
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15.w,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          TextApp(
                                            text: dataUser
                                                    ?.data.userContactName ??
                                                '',
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                          ),
                                          TextApp(
                                            text: " | ",
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                          ),
                                          TextApp(
                                            text: dataUser?.data.userCode ?? '',
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                          ),
                                        ],
                                      ),
                                      TextApp(
                                        text: dataUser?.data.userName ?? '',
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.w),
                        child: TextApp(text: "MY ACCOUNT"),
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: menuMyAccountTitle.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              menuMyAccountActions[index](context);
                            },
                            child: Container(
                              width: 1.sw,
                              // height: 100.h,
                              color: Theme.of(context).colorScheme.background,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    bottom: 10.w, left: 10.w, right: 10.w),
                                child: Column(
                                  children: [
                                    index == 0
                                        ? SizedBox(
                                            height: 10.h,
                                          )
                                        : Container(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              menuMyAccountIcon[index],
                                              size: 30.w,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                            ),
                                            SizedBox(
                                              width: 15.w,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    TextApp(
                                                      text: menuMyAccountTitle[
                                                          index],
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        index ==
                                                menuMyAccountTitle
                                                    .indexOf("Face ID")
                                            ? Transform.scale(
                                                scale:
                                                    0.8, // Adjust the scale factor as needed
                                                child: Switch(
                                                  activeColor: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  value: faceIdEnabled,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      faceIdEnabled = value;
                                                    });

                                                    if (faceIdEnabled == true) {
                                                      StorageUtils.instance
                                                          .setBool(
                                                              key:
                                                                  'enable_faceID',
                                                              val: true);
                                                      turnOnFaceID();
                                                    } else {
                                                      StorageUtils.instance
                                                          .setBool(
                                                              key:
                                                                  'enable_faceID',
                                                              val: false);
                                                      turnOffFaceID();
                                                    }
                                                  },
                                                ),
                                              )
                                            : Icon(
                                                Icons.chevron_right_outlined,
                                                size: 30.w,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground,
                                              ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    const Divider(
                                      height: 0,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      BlocProvider(
                        create: (context) => LogoutBloc(),
                        child: BlocListener<LogoutBloc, LogoutState>(
                          listener: (context, state) async {
                            if (state is LogoutSuccess) {
                              // Lấy trạng thái ghi nhớ đăng nhập
                              final bool? remembered = StorageUtils.instance
                                  .getBool(key: 'remember_login');

                              // Nếu không ghi nhớ đăng nhập hoặc remembered là null
                              if (remembered != true) {
                                await Future.wait([
                                  StorageUtils.instance
                                      .removeKey(key: 'saved_email'),
                                  StorageUtils.instance
                                      .removeKey(key: 'saved_password'),
                                  StorageUtils.instance
                                      .removeKey(key: 'remember_login'),
                                ]);
                              }

                              // Xóa các thông tin session hiện tại
                              await Future.wait([
                                StorageUtils.instance.removeKey(key: 'token'),
                                StorageUtils.instance
                                    .removeKey(key: 'user_info'),
                                StorageUtils.instance
                                    .removeKey(key: 'is_shipper'),
                                // Thêm các key khác cần xóa khi logout
                              ]);

                              // Delay một chút để đảm bảo các thao tác storage đã hoàn tất
                              await Future.delayed(
                                  const Duration(milliseconds: 100));

                              if (context.mounted) {
                                // Chuyển về trang đăng nhập và xóa toàn bộ stack navigation
                                navigatorKey.currentContext
                                    ?.go('/', extra: {'clearStack': true});
                              }
                            } else if (state is LogoutFailure) {
                              showCustomDialogModal(
                                  context: navigatorKey.currentContext!,
                                  textDesc: state.errorText ??
                                      'Không thể kết nối đến máy chủ',
                                  title: "Thông báo",
                                  colorButtonOk: Colors.red,
                                  btnOKText: "Xác nhận",
                                  typeDialog: "error",
                                  eventButtonOKPress: () {},
                                  isTwoButton: false);
                            }
                          },
                          child: BlocBuilder<LogoutBloc, LogoutState>(
                            builder: (context, state) {
                              return InkWell(
                                  onTap: () {
                                    showCustomDialogModal(
                                        context: navigatorKey.currentContext!,
                                        textDesc:
                                            "Bạn có chắc muốn đăng xuất ?",
                                        title: "Thông báo",
                                        colorButtonOk: Colors.blue,
                                        btnOKText: "Xác nhận",
                                        typeDialog: "question",
                                        eventButtonOKPress: () {
                                          context.read<LogoutBloc>().add(
                                                LogoutButtonPressed(),
                                              );
                                        },
                                        isTwoButton: true);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(10.w),
                                    child: Container(
                                      // width: 1.sw,
                                      padding: EdgeInsets.only(
                                          top: 8.h, bottom: 8.h),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.r),
                                        color: Colors.red,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 4,
                                            offset: const Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          TextApp(
                                            text: "Đăng xuất",
                                            color: Colors.white,
                                            fontsize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          SizedBox(width: 5.w),
                                          SizedBox(
                                              width: 30.w,
                                              height: 30.w,
                                              child: const Icon(
                                                Icons.logout,
                                                color: Colors.white,
                                              )),
                                        ],
                                      ),
                                    ),
                                  ));
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 35.h,
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is GetInforProfileStateFailure) {
              return ErrorDialog(
                eventConfirm: () {
                  Navigator.pop(context);
                },
                errorText: state.message,
              );
            }
            return Center(
              child: SizedBox(
                width: 100.w,
                height: 100.w,
                child: Lottie.asset('assets/lottie/loading_kango.json'),
              ),
            );
          },
        ),
      ),
    );
  }
}
