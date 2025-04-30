import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scan_barcode_app/bloc/ticket/create_ticket/create_ticket_bloc.dart';
import 'package:scan_barcode_app/data/models/ticket/list_type_ticket.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/ticket/ticket_manager.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'dart:math' as math;

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final typeTextController = TextEditingController();
  final codeTicketTextController = TextEditingController();
  final titleErrorTextController = TextEditingController();
  final inforErrorTextController = TextEditingController();
  final _formTicketKey = GlobalKey<FormState>();
  ListTypeTicketModel? listTypeTicket;
  final ImagePicker picker = ImagePicker();
  int currentIndexTicketKind = 0;
  List<XFile> imageFileList = [];
  List<File> fileList = [];
  List<String> fileNames = [];

  void pickFile() async {
    if (imageFileList.length + fileList.length >= 3) {
      _showLimitDialog();
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        fileList.add(file);
        fileNames.add(file.path.split('/').last);
      });
    } else {
      // User canceled the picker
    }
  }

  void pickMultipleImage() async {
    if (imageFileList.length + fileList.length >= 3) {
      _showLimitDialog();
      return;
    }

    final List<XFile> selectedImages = await picker.pickMultiImage();
    setState(() {
      if (imageFileList.length + fileList.length + selectedImages.length > 3) {
        _showLimitDialog();
        return;
      }
      imageFileList.addAll(selectedImages);
    });
  }

  void deleteImage(int index) {
    setState(() {
      imageFileList.removeAt(index);
    });
  }

  void deleteFile(int index) {
    setState(() {
      fileList.removeAt(index);
      fileNames.removeAt(index);
    });
  }

  void onGetListTypeTicket() {
    context.read<ListTypeTicketBloc>().add(GetListTypeTicket());
  }

  Future<String> convertFileToBase64(File file) async {
    List<int> fileBytes = await file.readAsBytes();
    return base64Encode(fileBytes);
  }

  String getExtensionFromPath(String filePath) {
    int lastDotIndex = filePath.lastIndexOf('.');
    if (lastDotIndex == -1) {
      return ''; // No extension found
    }

    return filePath.substring(lastDotIndex + 1);
  }

  Future<void> onCreateTicket() async {
    String? file0;
    String? file1;
    String? file2;
    String? extension0;
    String? extension1;
    String? extension2;

    List<File> allFiles = [
      ...imageFileList.map((xfile) => File(xfile.path)),
      ...fileList
    ];

    if (allFiles.isNotEmpty) {
      file0 = await convertFileToBase64(allFiles[0]);
      var extensionInit = getExtensionFromPath(allFiles[0].toString());
      var extensionLats = extensionInit.replaceAll("'", "");
      extension0 = extensionLats;
    }
    if (allFiles.length > 1) {
      file1 = await convertFileToBase64(allFiles[1]);
      var extensionInit = getExtensionFromPath(allFiles[1].toString());
      var extensionLats = extensionInit.replaceAll("'", "");
      extension1 = extensionLats;
    }
    if (allFiles.length > 2) {
      file2 = await convertFileToBase64(allFiles[2]);
      var extensionInit = getExtensionFromPath(allFiles[2].toString());
      var extensionLats = extensionInit.replaceAll("'", "");
      extension2 = extensionLats;
    }
    context.read<ListTypeTicketBloc>().add(HandleCreateTicket(
          ticketKind: currentIndexTicketKind,
          ticketTransactionCode: codeTicketTextController.text,
          ticketTitle: titleErrorTextController.text,
          ticketMessageContent: inforErrorTextController.text,
          file0: file0,
          file1: file1,
          file2: file2,
          extension0: extension0,
          extension1: extension1,
          extension2: extension2,
        ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onGetListTypeTicket();
  }

  void _showLimitDialog() {
    showCustomDialogModal(
      context: navigatorKey.currentContext!,
      textDesc: "Bạn chỉ có thể tải lên tổng cộng 3 hình ảnh hoặc tập tin.",
      title: "Thông báo",
      colorButtonOk: Colors.red,
      btnOKText: "Xác nhận",
      typeDialog: "error",
      eventButtonOKPress: () {},
      isTwoButton: false,
    );
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
          title: TextApp(
            text: "Tạo Ticket",
            fontsize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<ListTypeTicketBloc, CreateTicketState>(
                listener: (context, state) {
              if (state is ListTypeTicketStateSuccess) {
                listTypeTicket = state.listTypeTicketModel;
              } else if (state is HandleCreateTicketStateSuccess) {
                log("CreateTicketStateSuccess");
                Navigator.pop(context);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TicketManagerScreen()),
                );
                showCustomDialogModal(
                  context: navigatorKey.currentContext!,
                  textDesc: "Tạo ticket thành công!",
                  title: "Thông báo",
                  colorButtonOk: Colors.green,
                  btnOKText: "Xác nhận",
                  typeDialog: "success",
                  eventButtonOKPress: () {},
                  isTwoButton: false,
                );
              } else if (state is HandleCreateTicketStateFailure) {
                log("CreateTicketStateFailure");
              }
            })
          ],
          child: BlocBuilder<ListTypeTicketBloc, CreateTicketState>(
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.all(20.w),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formTicketKey,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextApp(
                              text: "Phân loại",
                              color: Theme.of(context).colorScheme.onBackground,
                              fontsize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        CustomTextFormField(
                            readonly: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng chọn loại ticket';
                              }
                              return null;
                            },
                            controller: typeTextController,
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
                                  itemCount:
                                      listTypeTicket?.tiketKinds.length ?? 0,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: 20.w),
                                          child: InkWell(
                                            onTap: () async {
                                              Navigator.pop(context);
                                              setState(() {
                                                typeTextController.text =
                                                    listTypeTicket?.tiketKinds[
                                                            index.toString()] ??
                                                        '';
                                                currentIndexTicketKind = 1;
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                TextApp(
                                                  text: listTypeTicket
                                                              ?.tiketKinds[
                                                          index.toString()] ??
                                                      'Chọn loại ticket',
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
                            hintText: ''),
                        SizedBox(
                          height: 15.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextApp(
                              text: "Mã lỗi",
                              color: Theme.of(context).colorScheme.onBackground,
                              fontsize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        CustomTextFormField(
                            controller: codeTicketTextController,
                            hintText: 'Nhập mã cần kiểm tra'),
                        SizedBox(
                          height: 5.h,
                        ),
                        Divider(),
                        SizedBox(
                          height: 5.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextApp(
                              text: "Tiêu đề",
                              color: Theme.of(context).colorScheme.onBackground,
                              fontsize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        CustomTextFormField(
                            controller: titleErrorTextController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập tiêu đề';
                              }
                              return null;
                            },
                            hintText: 'Nhập tiêu đề'),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextApp(
                              text: "Nội dung",
                              color: Theme.of(context).colorScheme.onBackground,
                              fontsize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        TextFormField(
                          onTapOutside: (event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          controller: inforErrorTextController,
                          keyboardType: TextInputType.multiline,
                          minLines: 5,
                          maxLines: 10,
                          style:
                              TextStyle(fontSize: 14.sp, color: Colors.black),
                          cursorColor: Theme.of(context).colorScheme.primary,
                          decoration: InputDecoration(
                            fillColor: Theme.of(context).colorScheme.primary,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2.0),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            hintText:
                                'Vui lòng cung cấp thông tin chi tiết về vấn đề bạn đang gặp phải.',
                            isDense: true,
                            contentPadding: EdgeInsets.all(20.w),
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          children: [
                            TextApp(
                              text: " Đính kèm ảnh và tệp",
                              fontsize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        if (imageFileList.isEmpty && fileList.isEmpty)
                          DottedBorder(
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
                                  children: [
                                    InkWell(
                                      onTap: pickMultipleImage,
                                      child: Container(
                                        width: 120.w,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.r),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
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
                                              SizedBox(width: 5.w),
                                              TextApp(
                                                fontsize: 14.sp,
                                                text: "Chọn ảnh",
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    InkWell(
                                      onTap: pickFile,
                                      child: Container(
                                        width: 120.w,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.r),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(8.w),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.upload_file,
                                                size: 24.sp,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 5.w),
                                              TextApp(
                                                fontsize: 14.sp,
                                                text: "Chọn tệp",
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          DottedBorder(
                            dashPattern: const [3, 1, 0, 2],
                            color: Colors.black.withOpacity(0.6),
                            strokeWidth: 1.5,
                            padding: const EdgeInsets.all(3),
                            child: Column(
                              children: [
                                SizedBox(height: 10.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: pickMultipleImage,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.r),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
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
                                              SizedBox(width: 5.w),
                                              TextApp(
                                                fontsize: 14.sp,
                                                text: "Chọn ảnh",
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    InkWell(
                                      onTap: pickFile,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.r),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(8.w),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.upload_file,
                                                size: 24.sp,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 5.w),
                                              TextApp(
                                                fontsize: 14.sp,
                                                text: "Chọn tệp",
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                                GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: imageFileList.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        imageFileList.length < 2 ? 1 : 2,
                                    crossAxisSpacing: 4.0,
                                    mainAxisSpacing: 4.0,
                                  ),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                            child: Image.file(
                                              File(imageFileList[index].path),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: IconButton(
                                            icon: const Icon(Icons.cancel,
                                                color: Colors.black),
                                            onPressed: () => deleteImage(index),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: fileList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ListTile(
                                      leading: Icon(Icons.insert_drive_file,
                                          size: 24.sp),
                                      title: Text(fileNames[index]),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.cancel,
                                            color: Colors.black),
                                        onPressed: () => deleteFile(index),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ButtonApp(
                              event: () {
                                if (_formTicketKey.currentState!.validate()) {
                                  onCreateTicket();
                                }
                              },
                              text: "Tạo ticket",
                              fontWeight: FontWeight.bold,
                              colorText: Colors.white,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              outlineColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ));
  }
}
