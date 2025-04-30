import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/profile/get_infor/get_infor_bloc.dart';
import 'package:scan_barcode_app/data/models/infor_account_model.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/maps/map_order_pickup.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'dart:math' as math;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:signature/signature.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formField1 = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {};
  InforAccountModel? inforAccountDataRes;
  int? currentIndexCity;
  int? currentIndexDistric;
  int? currentIndexWard;
  bool? isLoading = false;
  List cityList = [];
  List districList = [];
  List wardList = [];

  final ImagePicker picker = ImagePicker();
  final SignatureController _controllerSignature = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  bool isLoadingButton = false;
  Future<void> _saveSignature() async {
    if (_controllerSignature.isNotEmpty) {
      Uint8List? data = await _controllerSignature.toPngBytes();
      if (data != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Signature"),
              content: Image.memory(data),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _clearSignature() {
    _controllerSignature.clear();
  }

  File? selectedImage;
  File? selectedImageSignature;
  String? selectedFile;
  String? selectedFileSignature;
  void pickImage() async {
    final returndImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returndImage == null) return;
    setState(() {
      selectedImage = File(returndImage.path);
    });
  }

  void pickImageSignature() async {
    final returndImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returndImage == null) return;
    setState(() {
      selectedImageSignature = File(returndImage.path);
    });
  }

  void deleteImageSignature() {
    setState(() {
      selectedImageSignature = null;
    });
  }

  void captureImageSignature() async {
    final XFile? capturedImage =
        await picker.pickImage(source: ImageSource.camera);
    if (capturedImage != null) {
      setState(() {
        selectedImageSignature = File(capturedImage.path);
      });
    }
  }

  Future<void> getInforUser() async {
    final int? userID = StorageUtils.instance.getInt(key: 'user_ID');
    context
        .read<GetInforProfileBloc>()
        .add(HandleGetInforProfile(userID: userID));
  }

  Future<void> handleGetAreaVN() async {
    context.read<GetAreaVNBloc>().add(HandleGetAreaVN(
        cityID: currentIndexCity, districtID: currentIndexDistric));
  }

  void init() async {
    await getInforUser();
  }

  void handleUpdateProfile({
    required String? userContactName,
    required String? userPhone,
    required String? userAddress,
    required String? userLatitude,
    required String? userLongitude,
    required String? userCompanyName,
    required String? userTaxCode,
    String? userAccountKey,
    required int? userAddress1,
    required int? userAddress2,
    required int? userAddress3,
    required String? userSignature,
  }) async {
    final int? userID = StorageUtils.instance.getInt(key: 'user_ID');
    if (selectedImage != null) {
      Uint8List imagebytes =
          await selectedImage!.readAsBytes(); //convert to bytes
      String base64string =
          base64Encode(imagebytes); //convert bytes to base64 string
      selectedFile = base64string;
    }
    if (selectedImageSignature != null) {
      Uint8List imagebytes =
          await selectedImageSignature!.readAsBytes(); //convert to bytes
      String base64string =
          base64Encode(imagebytes); //convert bytes to base64 string
      selectedFileSignature = base64string;
    }
    context.read<UpdateProfileBloc>().add(HandleUpdateProfile(
        userID: userID,
        userContactName: userContactName,
        userPhone: userPhone,
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        userAddress: userAddress,
        userCompanyName: userCompanyName,
        userTaxCode: userTaxCode,
        userAddress1: userAddress1,
        userAddress2: userAddress2,
        userAddress3: userAddress3,
        userLogo: selectedFile ?? inforAccountDataRes?.data.userLogo,
        userSignature: userSignature));
  }

  Future<void> initAreaField() async {
    if (currentIndexCity != null) {
      controllers['cityNameText']!.text = cityList[currentIndexCity!];
    }
    if (currentIndexDistric != null) {
      controllers['districNameText']!.text = districList[currentIndexDistric!];
    }
    if (currentIndexWard != null) {
      controllers['wardNameText']!.text = wardList[currentIndexWard!];
    }
  }

  void initializeControllers(List<String> keys) {
    for (var key in keys) {
      controllers[key] = TextEditingController();
    }
  }

  @override
  void initState() {
    super.initState();
    initializeControllers([
      'companyName',
      'contactName',
      'taxCode',
      'email',
      'phone',
      'currentPassworld',
      'newPassworld',
      'reNewPassworld',
      'address4',
      'latitude',
      'longitude',
      'passwordForOpenID',
      'cityNameText',
      'districNameText',
      'wardNameText',
    ]);
    init();
  }

  @override
  void dispose() {
    _controllerSignature.dispose();
    controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
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
            text: "Chỉnh sửa thông tin",
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

                          controllers['companyName']!.text =
                              inforAccountDataRes?.data.userCompanyName ?? '';
                          controllers['taxCode']!.text =
                              inforAccountDataRes?.data.userTaxCode ?? '';
                          controllers['phone']!.text =
                              inforAccountDataRes?.data.userPhone ?? '';
                          currentIndexCity =
                              inforAccountDataRes?.data.userAddress1;
                          currentIndexDistric =
                              inforAccountDataRes?.data.userAddress2;
                          currentIndexWard =
                              inforAccountDataRes?.data.userAddress3;
                          controllers['address4']!.text =
                              inforAccountDataRes?.data.userAddress ?? '';
                          controllers['contactName']!.text =
                              inforAccountDataRes?.data.userContactName ?? '';
                        })
                      : null;
                  handleGetAreaVN();
                }
              },
            ),
            BlocListener<GetAreaVNBloc, GetAreaVNState>(
              listener: (context, state) {
                if (state is GetAreaVNStateStateSuccess) {
                  print("handleGetAreaVN OKOK");
                  mounted
                      ? setState(() {
                          cityList.clear();
                          districList.clear();
                          wardList.clear();
                          var areaVNDataRes = state.areaVnModel;
                          cityList = areaVNDataRes.areas.cities;
                          districList = areaVNDataRes.areas.districts;
                          wardList = areaVNDataRes.areas.wards;
                        })
                      : null;
                  initAreaField();
                } else if (state is GetAreaVNStateFailure) {
                  showDialog(
                      context: navigatorKey.currentContext!,
                      builder: (BuildContext context) {
                        return ErrorDialog(
                          eventConfirm: () {
                            Navigator.pop(context);
                          },
                          errorText: state.message,
                        );
                      });
                }
              },
            ),
            BlocListener<UpdateProfileBloc, UpdateProfileState>(
              listener: (context, state) {
                if (state is UpdateProfileStateLoading) {
                  setState(() {
                    isLoadingButton = true;
                  });
                } else if (state is UpdateProfileStateSuccess) {
                  showCustomDialogModal(
                      context: navigatorKey.currentContext!,
                      textDesc: state.message,
                      title: "Thông báo",
                      colorButtonOk: Colors.green,
                      btnOKText: "Xác nhận",
                      typeDialog: "success",
                      eventButtonOKPress: () {
                        setState(() {
                          isLoadingButton = false;
                        });
                      },
                      isTwoButton: false);
                } else if (state is UpdateProfileStateFailure) {
                  showCustomDialogModal(
                      context: navigatorKey.currentContext!,
                      textDesc: state.message,
                      title: "Thông báo",
                      colorButtonOk: Colors.red,
                      btnOKText: "Xác nhận",
                      typeDialog: "error",
                      eventButtonOKPress: () {
                        setState(() {
                          isLoadingButton = false;
                        });
                      },
                      isTwoButton: false);
                }
              },
            ),
          ],
          child: BlocBuilder<GetInforProfileBloc, GetInforProfileState>(
            builder: (context, state) {
              if (state is GetInforProfileStateSuccess) {
                return SafeArea(
                  child: RefreshIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    onRefresh: () async {
                      init();
                    },
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
                                  child: Padding(
                                    padding: EdgeInsets.all(0.w),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "TÀI KHOẢN",
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
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        ),
                                        Container(
                                            width: 120.w,
                                            height: 120.w,
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          60.r),
                                                  child: selectedImage == null
                                                      ? inforAccountDataRes
                                                                  ?.data
                                                                  .userLogo ==
                                                              null
                                                          ? Image.asset(
                                                              "assets/images/user_avatar.png",
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Container(
                                                              width: 120.w,
                                                              height: 120.w,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            60.r),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  imageUrl: httpImage +
                                                                      inforAccountDataRes!
                                                                          .data
                                                                          .userLogo!,
                                                                  placeholder:
                                                                      (context,
                                                                              url) =>
                                                                          SizedBox(
                                                                    height:
                                                                        20.w,
                                                                    width: 20.w,
                                                                    child: const Center(
                                                                        child:
                                                                            CircularProgressIndicator()),
                                                                  ),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      const Icon(
                                                                          Icons
                                                                              .error),
                                                                ),
                                                              ),
                                                            )
                                                      : Container(
                                                          width: 120.w,
                                                          height: 120.w,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          60.r),
                                                              color:
                                                                  Colors.grey),
                                                          child: Image.file(
                                                            selectedImage!,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                ),
                                                Positioned(
                                                  bottom: 5.w,
                                                  right: 5
                                                      .w, // Ensure the container is centered
                                                  child: Container(
                                                    width: 30.h,
                                                    height: 30.h,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        15.r, // Match the border radius
                                                      ),
                                                    ),
                                                    child: InkWell(
                                                        onTap: () {
                                                          pickImage();
                                                        },
                                                        child:
                                                            Icon(Icons.camera)),
                                                  ),
                                                )
                                              ],
                                            )),
                                        SizedBox(
                                          height: 5.h,
                                        ),
                                        SizedBox(
                                          width: 1.sw / 2,
                                          child: TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Nội dung không được để trống";
                                              } else {
                                                return null;
                                              }
                                            },
                                            onTapOutside: (event) {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            textAlign: TextAlign.center,
                                            controller:
                                                controllers['contactName']!,
                                            decoration: const InputDecoration(
                                              border: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                        ),

                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 100.w,
                                              child: Text(
                                                "Email: ",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: "Icomoon",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10.w,
                                            ),
                                            Expanded(
                                              child: Text(
                                                inforAccountDataRes
                                                        ?.data.userName ??
                                                    '',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: "Icomoon",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 100.w,
                                              child: Text(
                                                "Id account: ",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: "Icomoon",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10.w,
                                            ),
                                            Expanded(
                                              child: Text(
                                                inforAccountDataRes
                                                        ?.data.userCode ??
                                                    '',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: "Icomoon",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 100.w,
                                              child: Text(
                                                "Key for Api: ",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: "Icomoon",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10.w,
                                            ),
                                            Expanded(
                                              child: Text(
                                                inforAccountDataRes
                                                        ?.data.userApiKey ??
                                                    '',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: "Icomoon",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp,
                                                ),
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
                                              "CÔNG TY",
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
                                            TextApp(
                                              text: " Tên công ty",
                                              fontsize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            CustomTextFormField(
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Tên công ty không để trống";
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                controller:
                                                    controllers['companyName']!,
                                                hintText: '')
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextApp(
                                              text: " Mã số thuế",
                                              fontsize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            CustomTextFormField(
                                                controller:
                                                    controllers['taxCode']!,
                                                hintText: '')
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                        // Column(
                                        //   children: [
                                        //     Signature(
                                        //       controller: _controllerSignature,
                                        //       height: 300,
                                        //       backgroundColor: Colors.grey[200]!,
                                        //     ),
                                        //     SizedBox(height: 20),
                                        //     Row(
                                        //       mainAxisAlignment:
                                        //           MainAxisAlignment.spaceEvenly,
                                        //       children: [
                                        //         ElevatedButton(
                                        //           onPressed: _saveSignature,
                                        //           child: Text('Save'),
                                        //         ),
                                        //         ElevatedButton(
                                        //           onPressed: _clearSignature,
                                        //           child: Text('Clear'),
                                        //         ),
                                        //       ],
                                        //     ),
                                        //   ],
                                        // ),
                                        // Column(
                                        //   crossAxisAlignment:
                                        //       CrossAxisAlignment.start,
                                        //   children: [
                                        //     TextApp(
                                        //       text: " Chữ ký",
                                        //       fontsize: 14.sp,
                                        //       fontWeight: FontWeight.bold,
                                        //       color: Colors.black,
                                        //     ),
                                        //     SizedBox(
                                        //       height: 10.h,
                                        //     ),
                                        //     inforAccountDataRes
                                        //                 ?.data.userSignature ==
                                        //             null
                                        //         ? selectedImageSignature == null
                                        //             ? DottedBorder(
                                        //                 dashPattern: const [
                                        //                   3,
                                        //                   1,
                                        //                   0,
                                        //                   2
                                        //                 ],
                                        //                 color: Colors.black
                                        //                     .withOpacity(0.6),
                                        //                 strokeWidth: 1.5,
                                        //                 padding:
                                        //                     const EdgeInsets
                                        //                         .all(3),
                                        //                 child: SizedBox(
                                        //                   width: 1.sw,
                                        //                   height: 200.h,
                                        //                   child: Center(
                                        //                       child: Column(
                                        //                     mainAxisAlignment:
                                        //                         MainAxisAlignment
                                        //                             .center,
                                        //                     crossAxisAlignment:
                                        //                         CrossAxisAlignment
                                        //                             .center,
                                        //                     children: [
                                        //                       InkWell(
                                        //                         onTap: () {
                                        //                           pickImageSignature();
                                        //                         },
                                        //                         child: Container(
                                        //                             width: 120.w,
                                        //                             // height: 50.h,
                                        //                             decoration: BoxDecoration(
                                        //                               borderRadius:
                                        //                                   BorderRadius.circular(
                                        //                                       5.r),
                                        //                               color: Theme.of(
                                        //                                       context)
                                        //                                   .colorScheme
                                        //                                   .primary,
                                        //                             ),
                                        //                             child: Padding(
                                        //                                 padding: EdgeInsets.all(8.w),
                                        //                                 child: Row(
                                        //                                   children: [
                                        //                                     Icon(
                                        //                                       Icons.collections,
                                        //                                       size: 24.sp,
                                        //                                       color: Colors.white,
                                        //                                     ),
                                        //                                     SizedBox(
                                        //                                       width: 5.w,
                                        //                                     ),
                                        //                                     TextApp(
                                        //                                       fontsize: 14.sp,
                                        //                                       text: "Chọn ảnh",
                                        //                                       color: Colors.white,
                                        //                                       fontWeight: FontWeight.bold,
                                        //                                     ),
                                        //                                   ],
                                        //                                 ))),
                                        //                       ),
                                        //                       SizedBox(
                                        //                         height: 10.h,
                                        //                       ),
                                        //                       InkWell(
                                        //                         onTap: () {
                                        //                           captureImageSignature();
                                        //                         },
                                        //                         child: Container(
                                        //                             width: 120.w,
                                        //                             // height: 50.h,
                                        //                             decoration: BoxDecoration(
                                        //                               borderRadius:
                                        //                                   BorderRadius.circular(
                                        //                                       5.r),
                                        //                               color: Theme.of(
                                        //                                       context)
                                        //                                   .colorScheme
                                        //                                   .primary,
                                        //                             ),
                                        //                             child: Padding(
                                        //                               padding: EdgeInsets
                                        //                                   .all(8
                                        //                                       .w),
                                        //                               child:
                                        //                                   Row(
                                        //                                 children: [
                                        //                                   Icon(
                                        //                                     Icons.camera,
                                        //                                     size:
                                        //                                         24.sp,
                                        //                                     color:
                                        //                                         Colors.white,
                                        //                                   ),
                                        //                                   SizedBox(
                                        //                                     width:
                                        //                                         5.w,
                                        //                                   ),
                                        //                                   TextApp(
                                        //                                     fontsize:
                                        //                                         14.sp,
                                        //                                     text:
                                        //                                         "Chụp ảnh",
                                        //                                     color:
                                        //                                         Colors.white,
                                        //                                     fontWeight:
                                        //                                         FontWeight.bold,
                                        //                                   ),
                                        //                                 ],
                                        //                               ),
                                        //                             )),
                                        //                       ),
                                        //                     ],
                                        //                   )),
                                        //                 ),
                                        //               )
                                        //             : Stack(
                                        //                 children: [
                                        //                   SizedBox(
                                        //                       width: 1.sw,
                                        //                       height: 250.w,
                                        //                       child: ClipRRect(
                                        //                         borderRadius:
                                        //                             BorderRadius
                                        //                                 .circular(
                                        //                                     10.r),
                                        //                         child:
                                        //                             Image.file(
                                        //                           selectedImageSignature!,
                                        //                           fit: BoxFit
                                        //                               .fill,
                                        //                         ),
                                        //                       )),
                                        //                   Positioned(
                                        //                     top: 5.w,
                                        //                     right: 5.w,
                                        //                     child: InkWell(
                                        //                       onTap: () {
                                        //                         deleteImageSignature();
                                        //                       },
                                        //                       child: Container(
                                        //                         width: 30,
                                        //                         height: 30,
                                        //                         decoration:
                                        //                             BoxDecoration(
                                        //                           borderRadius:
                                        //                               BorderRadius
                                        //                                   .circular(
                                        //                                       15),
                                        //                           color: Colors
                                        //                               .white
                                        //                               .withOpacity(
                                        //                                   0.8),
                                        //                         ),
                                        //                         child: Center(
                                        //                             child: Icon(
                                        //                           Icons.close,
                                        //                           size: 20.sp,
                                        //                           color: Colors
                                        //                               .black,
                                        //                         )),
                                        //                       ),
                                        //                     ),
                                        //                   ),
                                        //                 ],
                                        //               )
                                        //         : Stack(
                                        //             children: [
                                        //               SizedBox(
                                        //                   width: 1.sw,
                                        //                   height: 250.w,
                                        //                   child: ClipRRect(
                                        //                     borderRadius:
                                        //                         BorderRadius
                                        //                             .circular(
                                        //                                 10.r),
                                        //                     child:
                                        //                         CachedNetworkImage(
                                        //                       fit: BoxFit.fill,
                                        //                       imageUrl: httpImage +
                                        //                           inforAccountDataRes
                                        //                               ?.data
                                        //                               .userSignature,
                                        //                       placeholder:
                                        //                           (context,
                                        //                                   url) =>
                                        //                               SizedBox(
                                        //                         height: 20.w,
                                        //                         width: 20.w,
                                        //                         child: const Center(
                                        //                             child:
                                        //                                 CircularProgressIndicator()),
                                        //                       ),
                                        //                       errorWidget: (context,
                                        //                               url,
                                        //                               error) =>
                                        //                           const Icon(Icons
                                        //                               .error),
                                        //                     ),
                                        //                   )),
                                        //               Positioned(
                                        //                 top: 5.w,
                                        //                 right: 5.w,
                                        //                 child: InkWell(
                                        //                   onTap: () {
                                        //                     deleteImageSignature();
                                        //                   },
                                        //                   child: Container(
                                        //                     width: 30,
                                        //                     height: 30,
                                        //                     decoration:
                                        //                         BoxDecoration(
                                        //                       borderRadius:
                                        //                           BorderRadius
                                        //                               .circular(
                                        //                                   15),
                                        //                       color: Colors
                                        //                           .white
                                        //                           .withOpacity(
                                        //                               0.8),
                                        //                     ),
                                        //                     child: Center(
                                        //                         child: Icon(
                                        //                       Icons.close,
                                        //                       size: 20.sp,
                                        //                       color:
                                        //                           Colors.black,
                                        //                     )),
                                        //                   ),
                                        //                 ),
                                        //               ),
                                        //             ],
                                        //           ),
                                        //   ],
                                        // ),
                                        // SizedBox(
                                        //   height: 20.h,
                                        // ),
                                        Row(
                                          children: [
                                            Text(
                                              "LIÊN LẠC",
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
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextApp(
                                              text: " Số điện thoại",
                                              fontsize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            CustomTextFormField(
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Vui lòng nhập số điện thoại';
                                                  }
                                                  if (value.isEmpty) {
                                                    // return phoneIsRequied;
                                                  }
                                                  bool phoneValid = RegExp(
                                                          r'^(?:[+0]9)?[0-9]{10}$')
                                                      .hasMatch(value);

                                                  if (!phoneValid) {
                                                    return "Số điện thoại không hợp lệ";
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                controller:
                                                    controllers['phone']!,
                                                hintText: '')
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextApp(
                                              text: " Tỉnh/Thành phố",
                                              fontsize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            CustomTextFormField(
                                              readonly: true,
                                              controller:
                                                  controllers['cityNameText']!,
                                              hintText: 'Chọn tỉnh/thành phố',
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "Nội dung không để trống";
                                                } else {
                                                  return null;
                                                }
                                              },
                                              suffixIcon: Transform.rotate(
                                                angle: 90 * math.pi / 180,
                                                child: Icon(
                                                  Icons.chevron_right,
                                                  size: 32.sp,
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                              onTap: () {
                                                showMyCustomModalBottomSheet(
                                                    context: context,
                                                    isScroll: true,
                                                    itemCount: cityList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 20.w),
                                                            child: InkWell(
                                                              onTap: () async {
                                                                Navigator.pop(
                                                                    context);
                                                                setState(() {
                                                                  controllers['cityNameText']!
                                                                          .text =
                                                                      cityList[
                                                                          index];
                                                                  currentIndexCity =
                                                                      index;
                                                                  controllers[
                                                                          'districNameText']!
                                                                      .clear();
                                                                  controllers[
                                                                          'wardNameText']!
                                                                      .clear();
                                                                  currentIndexDistric =
                                                                      null;
                                                                  currentIndexWard =
                                                                      null;
                                                                });
                                                                handleGetAreaVN();
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  TextApp(
                                                                    text: cityList[
                                                                        index],
                                                                    color: Colors
                                                                        .black,
                                                                    fontsize:
                                                                        20.sp,
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
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                        districList.isNotEmpty
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  TextApp(
                                                    text: " Quận/Huyện",
                                                    fontsize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  SizedBox(
                                                    height: 10.h,
                                                  ),
                                                  CustomTextFormField(
                                                    readonly: true,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return "Nội dung không để trống";
                                                      } else {
                                                        return null;
                                                      }
                                                    },
                                                    controller: controllers[
                                                        'districNameText']!,
                                                    hintText: 'Chọn quận/huyện',
                                                    suffixIcon:
                                                        Transform.rotate(
                                                      angle: 90 * math.pi / 180,
                                                      child: Icon(
                                                        Icons.chevron_right,
                                                        size: 32.sp,
                                                        color: Colors.black
                                                            .withOpacity(0.5),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      showModalBottomSheet(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topRight: Radius
                                                                  .circular(
                                                                      15.r),
                                                              topLeft: Radius
                                                                  .circular(
                                                                      15.r),
                                                            ),
                                                          ),
                                                          clipBehavior: Clip
                                                              .antiAliasWithSaveLayer,
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          builder: (context) {
                                                            return DraggableScrollableSheet(
                                                              maxChildSize: 0.8,
                                                              expand: false,
                                                              builder: (BuildContext
                                                                      context,
                                                                  ScrollController
                                                                      scrollController) {
                                                                return Container(
                                                                    color: Colors
                                                                        .white,
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              50.w,
                                                                          height:
                                                                              5.w,
                                                                          margin: EdgeInsets.only(
                                                                              top: 15.h,
                                                                              bottom: 15.h),
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(10.r),
                                                                              color: Colors.grey),
                                                                        ),
                                                                        Expanded(
                                                                          child: ListView.builder(
                                                                              padding: EdgeInsets.only(top: 10.w),
                                                                              controller: scrollController,
                                                                              itemCount: districList.length,
                                                                              itemBuilder: (context, index) {
                                                                                return Column(
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: EdgeInsets.only(left: 20.w),
                                                                                      child: InkWell(
                                                                                        onTap: () async {
                                                                                          Navigator.pop(context);
                                                                                          // handleGetAreaVN(cityID: currentIndexCity, districtID: index);

                                                                                          setState(() {
                                                                                            controllers['districNameText']!.text = districList[index];
                                                                                            currentIndexDistric = index;
                                                                                            controllers['wardNameText']!.clear();
                                                                                            currentIndexWard = null;
                                                                                          });
                                                                                          handleGetAreaVN();
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
                                                                              }),
                                                                        )
                                                                      ],
                                                                    ));
                                                              },
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
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  TextApp(
                                                    text: " Phường/Xã",
                                                    fontsize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  SizedBox(
                                                    height: 10.h,
                                                  ),
                                                  CustomTextFormField(
                                                    readonly: true,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return "Nội dung không để trống";
                                                      } else {
                                                        return null;
                                                      }
                                                    },
                                                    controller: controllers[
                                                        'wardNameText']!,
                                                    hintText: 'Chọn phường/xã',
                                                    suffixIcon:
                                                        Transform.rotate(
                                                      angle: 90 * math.pi / 180,
                                                      child: Icon(
                                                        Icons.chevron_right,
                                                        size: 32.sp,
                                                        color: Colors.black
                                                            .withOpacity(0.5),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      showModalBottomSheet(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topRight: Radius
                                                                  .circular(
                                                                      15.r),
                                                              topLeft: Radius
                                                                  .circular(
                                                                      15.r),
                                                            ),
                                                          ),
                                                          clipBehavior: Clip
                                                              .antiAliasWithSaveLayer,
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          builder: (context) {
                                                            return DraggableScrollableSheet(
                                                              maxChildSize: 0.8,
                                                              expand: false,
                                                              builder: (BuildContext
                                                                      context,
                                                                  ScrollController
                                                                      scrollController) {
                                                                return Container(
                                                                    color: Colors
                                                                        .white,
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              50.w,
                                                                          height:
                                                                              5.w,
                                                                          margin: EdgeInsets.only(
                                                                              top: 15.h,
                                                                              bottom: 15.h),
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(10.r),
                                                                              color: Colors.grey),
                                                                        ),
                                                                        Expanded(
                                                                          child: ListView.builder(
                                                                              padding: EdgeInsets.only(top: 10.w),
                                                                              controller: scrollController,
                                                                              itemCount: wardList.length,
                                                                              itemBuilder: (context, index) {
                                                                                return Column(
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: EdgeInsets.only(left: 20.w),
                                                                                      child: InkWell(
                                                                                        onTap: () async {
                                                                                          Navigator.pop(context);
                                                                                          setState(() {
                                                                                            controllers['wardNameText']!.text = wardList[index];
                                                                                            currentIndexWard = index;
                                                                                          });
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
                                                                              }),
                                                                        ),
                                                                      ],
                                                                    ));
                                                              },
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
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                TextApp(
                                                  text: " Số nhà, đường",
                                                  fontsize: 14.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    final result =
                                                        await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              MapOrderPickUpScreen()),
                                                    );

                                                    if (result != null &&
                                                        result is Map<String,
                                                            dynamic>) {
                                                      print(
                                                          'Selected address: ${result['address']}');
                                                      print(
                                                          'longitude value: ${result['longitude']}');
                                                      print(
                                                          'latitude value: ${result['latitude']}');

                                                      setState(() {
                                                        controllers['address4']!
                                                                .text =
                                                            result['address']
                                                                .toString();
                                                        controllers[
                                                                'longitude']!
                                                            .text = result[
                                                                'longitude']
                                                            .toString();
                                                        controllers['latitude']!
                                                                .text =
                                                            result['latitude']
                                                                .toString();
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
                                              height: 10.h,
                                            ),
                                            CustomTextFormField(
                                                readonly: false,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Vui lòng nhập địa chỉ";
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                controller:
                                                    controllers['address4']!,
                                                hintText:
                                                    'Mở bản đồ để chọn địa chỉ'),
                                            SizedBox(
                                              height: 20.h,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            isLoadingButton
                                                ? const Center(
                                                    child:
                                                        CircularProgressIndicator())
                                                : ButtonApp(
                                                    text: 'Cập nhật',
                                                    fontsize: 16.sp,
                                                    fontWeight: FontWeight.bold,
                                                    colorText: Theme.of(context)
                                                        .colorScheme
                                                        .background,
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                    outlineColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                    event: () {
                                                      if (_formField1
                                                          .currentState!
                                                          .validate()) {
                                                        handleUpdateProfile(
                                                            userContactName: controllers[
                                                                    'contactName']!
                                                                .text,
                                                            userPhone:
                                                                controllers[
                                                                        'phone']!
                                                                    .text,
                                                            userAddress: controllers[
                                                                    'address4']!
                                                                .text,
                                                            userLatitude: controllers[
                                                                    'latitude']!
                                                                .text,
                                                            userLongitude: controllers[
                                                                    'longitude']!
                                                                .text,
                                                            userCompanyName:
                                                                controllers[
                                                                        'companyName']!
                                                                    .text,
                                                            userTaxCode:
                                                                controllers[
                                                                        'taxCode']!
                                                                    .text,
                                                            userAddress1:
                                                                currentIndexCity,
                                                            userAddress2:
                                                                currentIndexDistric,
                                                            userAddress3:
                                                                currentIndexWard,
                                                            userSignature:
                                                                null);
                                                      }
                                                    },
                                                  )
                                          ],
                                        )
                                      ],
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else if (state is GetInforProfileStateFailure) {
                return ErrorDialog(
                  eventConfirm: () {
                    Navigator.pop(context);
                  },
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
        ));
  }
}
