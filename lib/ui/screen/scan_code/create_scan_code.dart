import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class CreateScanCode extends StatefulWidget {
  const CreateScanCode({super.key});

  @override
  State<CreateScanCode> createState() => _CreateScanCodeState();
}

class _CreateScanCodeState extends State<CreateScanCode> {
  final barcoddeNumberController = TextEditingController();
  final barcodeForm = GlobalKey<FormState>();
  bool isShowBarCode = false;
  void hanldeCreateBarCodeImage() async {
    setState(() {
      isShowBarCode = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white, //change your color here
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shadowColor: Colors.white,
          title: TextApp(
            text: "Thông báo",
            fontsize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: Form(
          key: barcodeForm,
          child: Padding(
            padding: EdgeInsets.all(15.w),
            child: Column(
              children: [
                CustomTextFormField(
                    keyboardType: TextInputType.number,
                    controller: barcoddeNumberController,
                    textInputFormatter: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số barcode';
                      }

                      return null;
                    },
                    hintText: 'Nhập số điện thoại'),
                SizedBox(
                  height: 20.h,
                ),
                ButtonApp(
                    event: () {
                      if (barcodeForm.currentState!.validate()) {
                        hanldeCreateBarCodeImage();
                      }
                    },
                    text: "Create",
                    colorText: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    outlineColor: Theme.of(context).colorScheme.primary),
                SizedBox(
                  height: 20.h,
                ),
                isShowBarCode
                    ? Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          BarcodeGenerator(data: barcoddeNumberController.text)
                        ],
                      ))
                    : Container()
              ],
            ),
          ),
        ));
  }
}

class BarcodeGenerator extends StatelessWidget {
  final String data;

  BarcodeGenerator({required this.data});

  @override
  Widget build(BuildContext context) {
    return BarcodeWidget(
      barcode: Barcode.code128(), // Choose the type of barcode
      data: data,
      width: 200,
      height: 100,
      drawText: false, // If you want to display the text below the barcode
    );
  }
}
