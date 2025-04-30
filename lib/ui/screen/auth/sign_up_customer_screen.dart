import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/auth/sign_up_bloc/sign_up_bloc.dart';
import 'package:scan_barcode_app/bloc/auth/sign_up_bloc/sign_up_event.dart';
import 'package:scan_barcode_app/bloc/auth/sign_up_bloc/sign_up_state.dart';
import 'package:scan_barcode_app/data/models/area_Vn.dart';
import 'package:scan_barcode_app/data/models/utils/list_postion.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/maps/map_order_pickup.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';

class SignUpCustomerScreen extends StatefulWidget {
  const SignUpCustomerScreen({super.key});

  @override
  State<SignUpCustomerScreen> createState() => _SignUpCustomerScreenState();
}

class _SignUpCustomerScreenState extends State<SignUpCustomerScreen> {
  bool isSignUpFwd = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocProvider(
        create: (context) => SignUpBloc(),
        child: BlocListener<SignUpBloc, SignUpState>(
          listener: (context, state) async {
            if (state is SignUpSuccess) {
              navigatorKey.currentContext?.go('/');

              Future.delayed(const Duration(milliseconds: 300), () {
                showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: state.responseText ?? 'Đăng kí thành công',
                    title: "Thông báo",
                    colorButtonOk: Colors.green,
                    btnOKText: "Xác nhận",
                    typeDialog: "success",
                    eventButtonOKPress: () {},
                    isTwoButton: false);
              });
            } else if (state is SignUpFailure) {
              showCustomDialogModal(
                  context: navigatorKey.currentContext!,
                  textDesc: state.errorText ?? 'Không thể kết nối đến máy chủ',
                  title: "Thông báo",
                  colorButtonOk: Colors.red,
                  btnOKText: "Xác nhận",
                  typeDialog: "error",
                  eventButtonOKPress: () {},
                  isTwoButton: false);
            }
          },
          child: BlocBuilder<SignUpBloc, SignUpState>(
            builder: (context, state) {
              if (state is SignUpLoading) {
                return Center(
                  child: SizedBox(
                    width: 250.w,
                    height: 250.w,
                    child: Lottie.asset('assets/lottie/loading_kango.json'),
                  ),
                );
              }

              return SafeArea(
                  child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(
                      height: 80.h,
                    ),
                    // get started text
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
                      text: isSignUpFwd
                          ? 'Bạn đang đăng kí tài khoản FWD'
                          : 'Bạn đang đăng kí tài khoản nhân viên',
                      fontsize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    // ButtonApp(
                    //     event: () {
                    //       setState(() {
                    //         isSignUpFwd = !isSignUpFwd;
                    //       });
                    //     },
                    //     text: isSignUpFwd
                    //         ? 'Đăng kí tài khoản nhân viên'
                    //         : 'Đăng kí tài khoản FWD',
                    //     colorText: Colors.white,
                    //     backgroundColor: Theme.of(context).colorScheme.primary,
                    //     outlineColor: Theme.of(context).colorScheme.primary),
                    InkWell(
                        onTap: () {
                          setState(() {
                            isSignUpFwd = !isSignUpFwd;
                          });
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextApp(
                              text: isSignUpFwd
                                  ? 'Đăng kí tài khoản nhân viên'
                                  : 'Đăng kí tài khoản FWD',
                              fontsize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            Icon(
                              Icons.arrow_right_alt_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 26.sp,
                            )
                          ],
                        )),
                    SizedBox(
                      height: 20.h,
                    ),
                    isSignUpFwd ? SignUpForm() : SignUpStaffForm()
                  ],
                ),
              ));
            },
          ),
        ),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final Map<String, TextEditingController> controllers = {};

  final _formSignupKey = GlobalKey<FormState>();

  bool agreePersonalData = true;
  bool passwordVisible = true;
  bool confirmPasswordVisible = true;
  bool isLoading = false;

  int? currentIndexCity;
  int? currentIndexDistric;
  int? currentIndexWard;

  List cityList = [];
  List districList = [];
  List wardList = [];

  List<int>? stateIDList = [];
  List<int>? districIDList = [];
  List<int>? wardIDList = [];

  final ImagePicker picker = ImagePicker();

  File? selectedImage;
  String selectedFile = '';

  @override
  void dispose() {
    controllers.forEach((key, controller) {
      controller.dispose();
    });
    currentIndexCity = null;
    currentIndexDistric = null;
    currentIndexWard = null;
    selectedImage = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    handleGetAreaVN(cityID: null, districtID: null);
    initializeControllers([
      'email',
      'passworld',
      'confirmPassword',
      'keyForAccount',
      'companyName',
      'contactName',
      'taxCode',
      'phoneNumber',
      'address',
      'latitude',
      'longitude',
      'country',
      'city',
      'distric',
      'ward',
    ]);
  }

  void initializeControllers(List<String> keys) {
    for (var key in keys) {
      controllers[key] = TextEditingController();
    }
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

  void handleGetAreaVN({
    required int? cityID,
    required int? districtID,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$getAreaVNApi'),
      headers: ApiUtils.getHeaders(),
      body: jsonEncode({
        'city': cityID,
        'district': districtID,
      }),
    );
    final data = jsonDecode(response.body);
    try {
      if (data['status'] == 200) {
        mounted
            ? setState(() {
                cityList.clear();
                districList.clear();
                wardList.clear();
                var areaVNDataRes = AreaVnModel.fromJson(data);
                cityList = areaVNDataRes.areas.cities;
                districList = areaVNDataRes.areas.districts;
                wardList = areaVNDataRes.areas.wards;
              })
            : null;
      } else {
        log("ERROR AREA OK 1");
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
    } catch (error) {
      log("ERROR AREA OK 2 $error");
      if (error is http.ClientException) {
        showDialog(
            context: navigatorKey.currentContext!,
            builder: (BuildContext context) {
              return ErrorDialog(
                errorText: "Không thể kết nối đến máy chủ",
                eventConfirm: () {
                  Navigator.pop(context);
                },
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formSignupKey,
      child: Padding(
        padding: EdgeInsets.only(left: 20.w, right: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
            // full name
            CustomTextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: controllers['email']!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập Email';
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
              height: 20.h,
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
            // password
            CustomTextFormField(
              controller: controllers['passworld']!,
              hintText: 'Nhập mật khẩu',
              isPassword: true, // Enable password behavior
              passwordVisible: false, // Password visibility initial state
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

            SizedBox(
              height: 20.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextApp(
                  text: "Xác nhận mật khẩu",
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
              controller: controllers['confirmPassword']!,
              hintText: 'Nhập mật khẩu',
              isPassword: true, // Enable password behavior
              passwordVisible: false, // Password visibility initial state
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng xác nhận mật khẩu';
                } else if (value != controllers['passworld']!.text) {
                  return "Mật khẩu xác nhận không khớp!";
                } else {
                  return null;
                }
              },
              opacityHintText: 0.5,
            ),

            SizedBox(
              height: 20.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextApp(
                  text: "Key for Accountant",
                  color: Theme.of(context).colorScheme.onBackground,
                  fontsize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            SizedBox(
              height: 5.h,
            ),
            // email
            CustomTextFormField(
                controller: controllers['keyForAccount']!,
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
                hintText: 'Ít nhất 10 ký tự gồm chữ thường, chữ hoa, số'),
            SizedBox(
              height: 20.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextApp(
                  text: "Tên Công Ty",
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
                controller: controllers['companyName']!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên công ty';
                  }
                  return null;
                },
                hintText: 'Nhập tên công ty'),

            SizedBox(
              height: 20.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextApp(
                  text: "Tên Liên Hệ",
                  color: Theme.of(context).colorScheme.onBackground,
                  fontsize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            SizedBox(
              height: 5.h,
            ),
            // email
            CustomTextFormField(
                controller: controllers['contactName']!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên liên hệ';
                  }
                  return null;
                },
                hintText: 'Nhập tên liên hệ'),
            SizedBox(
              height: 20.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextApp(
                  text: "Mã số thuế",
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
                keyboardType: TextInputType.number,
                controller: controllers['taxCode']!,
                textInputFormatter: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mã số thuế';
                  }
                  return null;
                },
                hintText: 'Nhập mã số thuế'),

            SizedBox(
              height: 20.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextApp(
                  text: "Điện thoại",
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
                keyboardType: TextInputType.number,
                controller: controllers['phoneNumber']!,
                textInputFormatter: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }

                  bool phoneValid =
                      RegExp(r'^(?:[+0]9)?[0-9]{10}$').hasMatch(value);

                  if (!phoneValid) {
                    return "Số điện thoại không hợp lệ";
                  } else {
                    return null;
                  }
                },
                hintText: 'Nhập số điện thoại'),

            SizedBox(
              height: 20.h,
            ),

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextApp(
                      text: " Tỉnh/Thành phố",
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
                  readonly: true,
                  controller: controllers['city']!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nội dung không được để trống';
                    }
                    return null;
                  },
                  hintText: 'Chọn tỉnh/thành phố',
                  suffixIcon: Transform.rotate(
                    angle: 90 * math.pi / 180,
                    child: Icon(
                      Icons.chevron_right,
                      size: 32.sp,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  onTap: () {
                    showMyCustomModalBottomSheet(
                      context: context,
                      isScroll: true,
                      itemCount: cityList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 20.w),
                              child: InkWell(
                                onTap: () async {
                                  Navigator.pop(context);

                                  //use for getAreaVN
                                  handleGetAreaVN(
                                      cityID: index, districtID: null);
                                  mounted
                                      ? setState(() {
                                          controllers['city']!.text =
                                              cityList[index];
                                          currentIndexCity = index;
                                          controllers['distric']!.clear();
                                          controllers['ward']!.clear();
                                          currentIndexDistric = null;
                                          currentIndexWard = null;
                                        })
                                      : null;
                                },
                                child: Row(
                                  children: [
                                    TextApp(
                                      text: cityList[index],
                                      color: Colors.black,
                                      fontsize: 20.sp,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 25.h,
                            )
                          ],
                        );
                      },
                    );
                  },
                ),
                SizedBox(
                  height: 20.h,
                ),
              ],
            ),

            districList.isNotEmpty
                ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextApp(
                            text: " Quận/Huyện",
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
                        readonly: true,
                        controller: controllers['distric']!,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nội dung không được để trống';
                          }
                          return null;
                        },
                        hintText: 'Chọn quận/huyện',
                        suffixIcon: Transform.rotate(
                          angle: 90 * math.pi / 180,
                          child: Icon(
                            Icons.chevron_right,
                            size: 32.sp,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                        onTap: () {
                          showMyCustomModalBottomSheet(
                              context: context,
                              isScroll: true,
                              itemCount: districList.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 20.w),
                                      child: InkWell(
                                        onTap: () async {
                                          Navigator.pop(context);
                                          handleGetAreaVN(
                                              cityID: currentIndexCity,
                                              districtID: index);
                                          mounted
                                              ? setState(() {
                                                  controllers['distric']!.text =
                                                      districList[index];
                                                  currentIndexDistric = index;
                                                  controllers['ward']!.clear();
                                                  currentIndexWard = null;
                                                })
                                              : null;
                                        },
                                        child: Row(
                                          children: [
                                            TextApp(
                                              text: districList[index],
                                              color: Colors.black,
                                              fontsize: 20.sp,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      height: 25.h,
                                    )
                                  ],
                                );
                              });
                        },
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                    ],
                  )
                : Container(),

            wardList.isNotEmpty
                ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextApp(
                            text: " Phường/Xã",
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
                        readonly: true,
                        controller: controllers['ward']!,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nội dung không được để trống';
                          }
                          return null;
                        },
                        hintText: 'Chọn phường/xã',
                        suffixIcon: Transform.rotate(
                          angle: 90 * math.pi / 180,
                          child: Icon(
                            Icons.chevron_right,
                            size: 32.sp,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                        onTap: () {
                          showMyCustomModalBottomSheet(
                              context: context,
                              isScroll: true,
                              itemCount: wardList.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 20.w),
                                      child: InkWell(
                                        onTap: () async {
                                          Navigator.pop(context);
                                          mounted
                                              ? setState(() {
                                                  controllers['ward']!.text =
                                                      wardList[index];
                                                  currentIndexWard = index;
                                                })
                                              : null;
                                        },
                                        child: Row(
                                          children: [
                                            TextApp(
                                              text: wardList[index],
                                              color: Colors.black,
                                              fontsize: 20.sp,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      height: 25.h,
                                    )
                                  ],
                                );
                              });
                        },
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                    ],
                  )
                : Container(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextApp(
                  text: "Địa chỉ",
                  color: Theme.of(context).colorScheme.onBackground,
                  fontsize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
                InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MapOrderPickUpScreen()),
                    );

                    if (result != null && result is Map<String, dynamic>) {
                      print('Selected address: ${result['address']}');
                      print('longitude value: ${result['longitude']}');
                      print('latitude value: ${result['latitude']}');

                      setState(() {
                        controllers['address']!.text =
                            result['address'].toString();
                        controllers['longitude']!.text =
                            result['longitude'].toString();
                        controllers['latitude']!.text =
                            result['latitude'].toString();
                      });
                    }
                  },
                  child: TextApp(
                    text: "Mở bản đồ",
                    fontsize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 5.h,
            ),

            CustomTextFormField(
                readonly: true,
                controller: controllers['address']!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn địa chỉ';
                  }
                  return null;
                },
                hintText: 'Mở bản đồ để chọn địa chỉ'),

            SizedBox(
              height: 20.h,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextApp(
                  text: "Upload Logo Công ty",
                  color: Theme.of(context).colorScheme.onBackground,
                  fontsize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            SizedBox(
              height: 20.h,
            ),

            selectedImage == null
                ? DottedBorder(
                    dashPattern: const [3, 1, 0, 2],
                    color: Colors.black.withOpacity(0.6),
                    strokeWidth: 1.5,
                    padding: const EdgeInsets.all(3),
                    child: SizedBox(
                      width: 1.sw,
                      height: 200.h,
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              pickImage();
                            },
                            child: Container(
                                width: 120.w,
                                // height: 50.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.r),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                child: Padding(
                                    padding: EdgeInsets.all(8.w),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.collections,
                                          size: 24.sp,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 5.w,
                                        ),
                                        TextApp(
                                          fontsize: 14.sp,
                                          text: "Chọn ảnh",
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
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
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.r),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(8.w),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.camera,
                                        size: 24.sp,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 5.w,
                                      ),
                                      TextApp(
                                        fontsize: 14.sp,
                                        text: "Chụp ảnh",
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
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
                          height: 250.w,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.fill,
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
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white.withOpacity(0.8),
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
              height: 25.h,
            ),
            // signup button
            SizedBox(
              width: 1.sw,
              height: 50.h,
              child: !isLoading
                  ? ButtonApp(
                      text: 'Đăng kí',
                      fontWeight: FontWeight.bold,
                      fontsize: 16.sp,
                      colorText: Theme.of(context).colorScheme.background,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      outlineColor: Theme.of(context).colorScheme.primary,
                      event: () async {
                        if (_formSignupKey.currentState!.validate() &&
                            agreePersonalData &&
                            selectedImage != null) {
                          Uint8List imagebytes = await selectedImage!
                              .readAsBytes(); //convert to bytes
                          String base64string = base64Encode(imagebytes);
                          context.read<SignUpBloc>().add(SignUpButtonPressed(
                              isCustomer: true,
                              email: controllers['email']!.text,
                              password: controllers['passworld']!.text,
                              confirmPassword:
                                  controllers['confirmPassword']!.text,
                              companyName: controllers['companyName']!.text,
                              contactName: controllers['contactName']!.text,
                              taxCode: controllers['taxCode']!.text,
                              phone: controllers['phoneNumber']!.text,
                              address1: currentIndexCity,
                              address2: currentIndexDistric,
                              address3: currentIndexWard,
                              address4: controllers['address']!.text,
                              longitude: controllers['longitude']!.text,
                              latitude: controllers['latitude']!.text,
                              accountantKey: controllers['keyForAccount']!.text,
                              positionID: null,
                              branchID: null,
                              userLogo: base64string));
                        } else if (!agreePersonalData) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Vui lòng tuân thủ điều khoản của Kango Express')),
                          );
                        } else if (selectedImage == null) {
                          showCustomDialogModal(
                              context: navigatorKey.currentContext!,
                              textDesc: "Chọn ít nhất một ảnh logo công ty !",
                              title: "Thông báo",
                              colorButtonOk: Colors.blue,
                              btnOKText: "Xác nhận",
                              typeDialog: "info",
                              eventButtonOKPress: () {},
                              isTwoButton: false);
                        }
                      },
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(
              height: 25.0,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Đã có tài khoản? ',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 16.sp),
                ),
                GestureDetector(
                  onTap: () {
                    context.go('/');
                  },
                  child: Text(
                    'Đăng nhập',
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
      ),
    );
  }
}

class SignUpStaffForm extends StatefulWidget {
  const SignUpStaffForm({super.key});

  @override
  State<SignUpStaffForm> createState() => _SignUpStaffFormState();
}

class _SignUpStaffFormState extends State<SignUpStaffForm> {
  final Map<String, TextEditingController> controllers = {};

  final _formSignupStaffKey = GlobalKey<FormState>();

  bool passwordVisible = true;
  bool confirmPasswordVisible = true;
  bool isLoading = false;

  List<Position> role = [];
  List<Branch> branches = [];

  int currentRoleIndex = 0;
  int currentBranchIndex = 0;

  @override
  void dispose() {
    controllers.forEach((key, controller) {
      controller.dispose();
    });

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getListPosition();

    initializeControllers([
      'email',
      'passworld',
      'confirmPassword',
      'contactName',
      'phoneNumber',
      'address',
      'role',
      'branch'
    ]);
  }

  void initializeControllers(List<String> keys) {
    for (var key in keys) {
      controllers[key] = TextEditingController();
    }
  }

  Future<void> getListPosition() async {
    try {
      // Sending the HTTP request
      final response = await http.post(
        Uri.parse('$baseUrl$getHTMLPolicy'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
        }),
      );

      if (response.statusCode == 200) {
        // Parse response body
        final data = jsonDecode(response.body);

        if (data['status'] == 200) {
          var dataPositionList = PositionListModel.fromJson(data).positions;
          var dataBranches = BranchesListModel.fromJson(data).branches;
          setState(() {
            role = dataPositionList;
            branches = dataBranches;
          });
        } else {
          log("getListTypeService error: status ${data['status']}");
        }
      } else {
        log("HTTP error: ${response.statusCode}"); // Log HTTP error
      }
    } catch (error) {
      log("getListTypeService error: $error"); // Catch and log any errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formSignupStaffKey,
      child: Padding(
        padding: EdgeInsets.only(left: 20.w, right: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
            // full name
            CustomTextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: controllers['email']!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập Email';
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
              height: 20.h,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextApp(
                  text: "Điện thoại",
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
                keyboardType: TextInputType.number,
                controller: controllers['phoneNumber']!,
                textInputFormatter: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }

                  bool phoneValid =
                      RegExp(r'^(?:[+0]9)?[0-9]{10}$').hasMatch(value);

                  if (!phoneValid) {
                    return "Số điện thoại không hợp lệ";
                  } else {
                    return null;
                  }
                },
                hintText: 'Nhập số điện thoại'),

            SizedBox(
              height: 20.h,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextApp(
                  text: "Tên Liên Hệ",
                  color: Theme.of(context).colorScheme.onBackground,
                  fontsize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            SizedBox(
              height: 5.h,
            ),
            // email
            CustomTextFormField(
                controller: controllers['contactName']!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên liên hệ';
                  }
                  return null;
                },
                hintText: 'Nhập tên liên hệ'),
            SizedBox(
              height: 20.h,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextApp(
                  text: "Địa chỉ",
                  color: Theme.of(context).colorScheme.onBackground,
                  fontsize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
                InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MapOrderPickUpScreen()),
                    );

                    if (result != null && result is Map<String, dynamic>) {
                      print('Selected address: ${result['address']}');
                      print('longitude value: ${result['longitude']}');
                      print('latitude value: ${result['latitude']}');

                      setState(() {
                        controllers['address']!.text =
                            result['address'].toString();
                        controllers['longitude']!.text =
                            result['longitude'].toString();
                        controllers['latitude']!.text =
                            result['latitude'].toString();
                      });
                    }
                  },
                  child: TextApp(
                    text: "Mở bản đồ",
                    fontsize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 5.h,
            ),

            CustomTextFormField(
                // readonly: true,
                controller: controllers['address']!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn địa chỉ';
                  }
                  return null;
                },
                hintText: 'Mở bản đồ để chọn địa chỉ'),

            SizedBox(
              height: 20.h,
            ),

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextApp(
                      text: " Chức vụ",
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
                  readonly: true,
                  controller: controllers['role']!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nội dung không được để trống';
                    }
                    return null;
                  },
                  hintText: 'Chọn chức vụ',
                  suffixIcon: Transform.rotate(
                    angle: 90 * math.pi / 180,
                    child: Icon(
                      Icons.chevron_right,
                      size: 32.sp,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  onTap: () {
                    showMyCustomModalBottomSheet(
                      context: context,
                      isScroll: true,
                      itemCount: role.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 20.w),
                              child: InkWell(
                                onTap: () async {
                                  Navigator.pop(context);
                                  setState(() {
                                    controllers['role']!.text =
                                        role[index].positionName;
                                    currentRoleIndex = role[index].positionId;
                                  });
                                },
                                child: Row(
                                  children: [
                                    TextApp(
                                      text: role[index].positionName,
                                      color: Colors.black,
                                      fontsize: 20.sp,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 25.h,
                            )
                          ],
                        );
                      },
                    );
                  },
                ),
                SizedBox(
                  height: 20.h,
                ),
              ],
            ),

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextApp(
                      text: " Chi nhánh",
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
                  readonly: true,
                  controller: controllers['branch']!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nội dung không được để trống';
                    }
                    return null;
                  },
                  hintText: 'Chọn chi nhánh',
                  suffixIcon: Transform.rotate(
                    angle: 90 * math.pi / 180,
                    child: Icon(
                      Icons.chevron_right,
                      size: 32.sp,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  onTap: () {
                    showMyCustomModalBottomSheet(
                      context: context,
                      isScroll: true,
                      height: 0.62,
                      itemCount: branches.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 20.w),
                              child: InkWell(
                                onTap: () async {
                                  Navigator.pop(context);
                                  setState(() {
                                    controllers['branch']!.text =
                                        branches[index].branchName;
                                    currentBranchIndex =
                                        branches[index].branchId;
                                  });
                                },
                                child: Row(
                                  children: [
                                    TextApp(
                                      text: branches[index].branchName,
                                      color: Colors.black,
                                      fontsize: 20.sp,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 25.h,
                            )
                          ],
                        );
                      },
                    );
                  },
                ),
                SizedBox(
                  height: 20.h,
                ),
              ],
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
            // password
            TextFormField(
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              controller: controllers['passworld']!,
              obscureText: passwordVisible,
              obscuringCharacter: '*',
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
              decoration: InputDecoration(
                  suffixIconColor: Theme.of(context).colorScheme.onBackground,
                  suffixIcon: IconButton(
                      onPressed: () {
                        mounted
                            ? setState(
                                () {
                                  passwordVisible = !passwordVisible;
                                },
                              )
                            : null;
                      },
                      icon: Icon(passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility)),
                  hintText: 'Nhập mật khẩu',
                  hintStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.5),
                      fontSize: 14.sp),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2.0),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  contentPadding: EdgeInsets.all(20.w)),
            ),
            SizedBox(
              height: 20.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextApp(
                  text: "Xác nhận mật khẩu",
                  color: Theme.of(context).colorScheme.onBackground,
                  fontsize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            SizedBox(
              height: 5.h,
            ),
            TextFormField(
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              controller: controllers['confirmPassword']!,
              obscureText: confirmPasswordVisible,
              obscuringCharacter: '*',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng xác nhận mật khẩu';
                } else if (value != controllers['passworld']!.text) {
                  return "Mật khẩu xác nhận không khớp!";
                } else {
                  return null;
                }
              },
              decoration: InputDecoration(
                  suffixIconColor: Theme.of(context).colorScheme.onBackground,
                  suffixIcon: IconButton(
                      onPressed: () {
                        mounted
                            ? setState(
                                () {
                                  confirmPasswordVisible =
                                      !confirmPasswordVisible;
                                },
                              )
                            : null;
                      },
                      icon: Icon(confirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility)),
                  hintText: 'Nhập lại mật khẩu',
                  hintStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.5),
                      fontSize: 14.sp),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2.0),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  contentPadding: EdgeInsets.all(20.w)),
            ),
            SizedBox(
              height: 20.h,
            ),

            // signup button
            SizedBox(
              width: 1.sw,
              height: 50.h,
              child: !isLoading
                  ? ButtonApp(
                      text: 'Đăng kí',
                      fontWeight: FontWeight.bold,
                      fontsize: 16.sp,
                      colorText: Theme.of(context).colorScheme.background,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      outlineColor: Theme.of(context).colorScheme.primary,
                      event: () async {
                        if (_formSignupStaffKey.currentState!.validate()) {
                          context.read<SignUpBloc>().add(SignUpButtonPressed(
                                isCustomer: false,
                                email: controllers['email']!.text,
                                password: controllers['passworld']!.text,
                                confirmPassword:
                                    controllers['confirmPassword']!.text,
                                companyName: null,
                                contactName: controllers['contactName']!.text,
                                taxCode: null,
                                phone: controllers['phoneNumber']!.text,
                                address1: null,
                                address2: null,
                                address3: null,
                                address4: controllers['address']!.text,
                                longitude: null,
                                latitude: null,
                                accountantKey: null,
                                positionID: currentRoleIndex,
                                branchID: currentBranchIndex,
                                userLogo: null,
                              ));
                        }
                      },
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(
              height: 25.0,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Đã có tài khoản? ',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 16.sp),
                ),
                GestureDetector(
                  onTap: () {
                    context.go('/');
                  },
                  child: Text(
                    'Đăng nhập',
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
      ),
    );
  }
}
